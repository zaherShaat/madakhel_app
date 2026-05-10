import 'package:drift/drift.dart';

import '../../model/transaction_direction.dart';
import '../db/app_db.dart';
import '../db/generic_db_controller.dart';

class TransactionRepository extends DbController<Transaction> {
  final AppDatabase _db;

  TransactionRepository(this._db);

  @override
  Future<int> create(Transaction item) {
    throw UnimplementedError(
      'Use createTransaction() or createTemplate() instead',
    );
  }

  @override
  Future<Transaction?> getById(int id) {
    return (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<List<Transaction>> getAll() {
    return (_db.select(
      _db.transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  @override
  Future<void> update(Transaction item) {
    throw UnimplementedError('Use updateTemplateName() instead');
  }

  /// Get templates for an income type (used in dropdown menus)
  Future<List<Transaction>> getTemplates(int incomeTypeId) {
    return (_db.select(_db.transactions)
          ..where(
            (t) => t.incomeTypeId.equals(incomeTypeId) & t.amount.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<Transaction>> watchTemplates(int incomeTypeId) {
    return (_db.select(_db.transactions)
          ..where(
            (t) => t.incomeTypeId.equals(incomeTypeId) & t.amount.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Get real transactions for an income type
  Future<List<Transaction>> getTransactions(int incomeTypeId) {
    return (_db.select(_db.transactions)
          ..where(
            (t) => t.incomeTypeId.equals(incomeTypeId) & t.amount.isNotNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Stream<List<Transaction>> watchTransactions(int incomeTypeId) {
    return (_db.select(_db.transactions)
          ..where(
            (t) => t.incomeTypeId.equals(incomeTypeId) & t.amount.isNotNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Create a template (null amount, no date)
  Future<int> createTemplate({
    required int incomeTypeId,
    required String name,
    required TransactionDirection direction,
  }) {
    return _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            incomeTypeId: incomeTypeId,
            isSystem: const Value(false),
            name: name,
            direction: direction,
            amount: const Value(null),
            note: const Value(null),
            date: const Value(null),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Create a real transaction
  Future<int> createTransaction({required TransactionsCompanion tx}) async{
    return await _db.into(_db.transactions).insert(tx);
  }

  Future<void> updateTemplateName(int templateId, String name) async {
    final row = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(templateId))).getSingle();
    if (row.isSystem) return;

    await (_db.update(_db.transactions)..where((t) => t.id.equals(templateId)))
        .write(TransactionsCompanion(name: Value(name)));
  }

  @override
  Future<void> deleteById(int id) async {
    final row = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row?.isSystem ?? false) return;

    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Get total inflow for an income type
  Future<double> getInSum(int incomeTypeId) async {
    final sumExpr = _db.transactions.amount.sum();
    return (_db.selectOnly(_db.transactions)
          ..addColumns([sumExpr])
          ..where(
            _db.transactions.incomeTypeId.equals(incomeTypeId) &
                _db.transactions.direction.equalsValue(
                  TransactionDirection.inFlow,
                ) &
                _db.transactions.amount.isNotNull(),
          ))
        .map((row) => row.read(sumExpr) ?? 0.0)
        .getSingle();
  }

  /// Get total outflow for an income type
  Future<double> getOutSum(int incomeTypeId) async {
    final sumExpr = _db.transactions.amount.sum();
    return (_db.selectOnly(_db.transactions)
          ..addColumns([sumExpr])
          ..where(
            _db.transactions.incomeTypeId.equals(incomeTypeId) &
                _db.transactions.direction.equalsValue(
                  TransactionDirection.outFlow,
                ) &
                _db.transactions.amount.isNotNull(),
          ))
        .map((row) => row.read(sumExpr) ?? 0.0)
        .getSingle();
  }
}
