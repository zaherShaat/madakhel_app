import 'package:drift/drift.dart';

import '../../model/income_source_with_balance.dart';
import '../db/app_db.dart';
import '../db/generic_db_controller.dart';

class IncomeTypeRepository extends DbController<IncomeType> {
  final AppDatabase _db;

  IncomeTypeRepository(this._db);

  @override
  Future<int> create(IncomeType item) {
    throw UnimplementedError('Use create() with named parameters instead');
  }

  /// Create with named parameters (business logic wrapper)
  Future<int> createIncomeType({
    required String name,
    String currency = 'USD',
  }) {
    return _db
        .into(_db.incomeTypes)
        .insert(
          IncomeTypesCompanion.insert(
            name: name,
            currency: Value(currency),
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<IncomeType?> getById(int id) {
    return (_db.select(
      _db.incomeTypes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<List<IncomeType>> getAll() {
    return (_db.select(
      _db.incomeTypes,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Stream<List<IncomeType>> watchAll() {
    return (_db.select(
      _db.incomeTypes,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<List<IncomeSourceWithBalance>> watchIncomeSourcesWithBalance() {
    const query = '''
SELECT
  it.id AS id,
  it.name AS name,
  it.currency AS currency,
  COALESCE(
    SUM(
      CASE
        WHEN tr.amount IS NULL THEN 0
        WHEN tr.direction = 'in' THEN tr.amount
        WHEN tr.direction = 'out' THEN -tr.amount
        ELSE 0
      END
    ),
    0
  ) AS balance
FROM income_types it
LEFT JOIN transactions tr ON tr.income_type_id = it.id
GROUP BY it.id, it.name, it.currency, it.created_at
ORDER BY it.created_at DESC
''';

    return _db
        .customSelect(query, readsFrom: {_db.incomeTypes, _db.transactions})
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => IncomeSourceWithBalance(
                  id: row.read<int>('id'),
                  name: row.read<String>('name'),
                  currency: row.read<String>('currency'),
                  balance: row.read<double>('balance'),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> update(IncomeType item) {
    return updateIncomeType(
      id: item.id,
      name: item.name,
      currency: item.currency,
    );
  }

  /// Update with named parameters (business logic wrapper)
  Future<void> updateIncomeType({
    required int id,
    required String name,
    required String currency,
  }) async {
    await (_db.update(_db.incomeTypes)..where((t) => t.id.equals(id))).write(
      IncomeTypesCompanion(name: Value(name), currency: Value(currency)),
    );
  }

  @override
  Future<void> deleteById(int id) async {
    await (_db.delete(_db.incomeTypes)..where((t) => t.id.equals(id))).go();
  }
}
