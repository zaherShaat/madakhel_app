import 'package:drift/drift.dart';

import '../../model/transaction_direction.dart';
import '../db/app_db.dart';

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  Future<int> create(FinancialTransaction item) {
    throw UnimplementedError('Use createTransaction(...) instead');
  }

  Future<FinancialTransaction?> getById(int id) {
    return (_db.select(_db.financialTransactions)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<FinancialTransaction>> getAll() {
    return (_db.select(_db.financialTransactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> update(FinancialTransaction item) async {
    await (_db.update(
      _db.financialTransactions,
    )..where((t) => t.id.equals(item.id))).write(
      FinancialTransactionsCompanion(
        amount: Value(item.amount),
        note: Value(item.note),
        date: Value(item.date),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Get templates for an income source — templates removed in v3 model.
  /// Keep API for compatibility; return empty list for now.
  Future<List<FinancialTransaction>> getTemplates(int incomeSourceId) async {
    return [];
  }

  Stream<List<FinancialTransaction>> watchTemplates(int incomeSourceId) {
    return Stream.value(<FinancialTransaction>[]);
  }

  /// Get real transactions for an income source
  Future<List<FinancialTransaction>> getTransactions(int incomeSourceId) {
    return (_db.select(_db.financialTransactions)
          ..where(
            (t) =>
                t.incomeSourceId.equals(incomeSourceId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Stream<List<FinancialTransaction>> watchTransactions(int incomeSourceId) {
    return (_db.select(_db.financialTransactions)
          ..where(
            (t) =>
                t.incomeSourceId.equals(incomeSourceId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Create a real transaction. We accept direction and create/find a default
  /// category for that direction to attach the transaction to.
  Future<int> createTransaction({
    required int incomeSourceId,
    required String transactionName,
    required double amount,
    required DateTime date,
    required int categoryId,
    String? note,
  }) async {
    final now = DateTime.now();
    return await _db
        .into(_db.financialTransactions)
        .insert(
          FinancialTransactionsCompanion.insert(
            incomeSourceId: incomeSourceId,
            categoryId: categoryId,
            amount: amount,
            note: Value(note),
            date: date,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> deleteById(int id) async {
    await (_db.update(
      _db.financialTransactions,
    )..where((t) => t.id.equals(id))).write(
      FinancialTransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Get total inflow for an income source
  Future<double> getInSum(int incomeSourceId) async {
    final query = '''
SELECT COALESCE(SUM(ft.amount), 0) AS s
FROM financial_transactions ft
JOIN transaction_categories tc ON tc.id = ft.category_id
WHERE ft.income_source_id = ? AND tc.direction = ? AND ft.is_deleted = 0 AND tc.is_deleted = 0
''';
    final rows = await _db
        .customSelect(
          query,
          variables: [
            Variable<int>(incomeSourceId),
            Variable<String>(
              const TransactionDirectionConverter().toSql(
                TransactionDirection.inFlow,
              ),
            ),
          ],
          readsFrom: {_db.financialTransactions, _db.transactionCategories},
        )
        .get();

    return rows.isNotEmpty ? rows.first.read<double>('s') : 0.0;
  }

  /// Get total outflow for an income source
  Future<double> getOutSum(int incomeSourceId) async {
    final query = '''
SELECT COALESCE(SUM(ft.amount), 0) AS s
FROM financial_transactions ft
JOIN transaction_categories tc ON tc.id = ft.category_id
WHERE ft.income_source_id = ? AND tc.direction = ? AND ft.is_deleted = 0 AND tc.is_deleted = 0
''';
    final rows = await _db
        .customSelect(
          query,
          variables: [
            Variable<int>(incomeSourceId),
            Variable<String>(
              const TransactionDirectionConverter().toSql(
                TransactionDirection.outFlow,
              ),
            ),
          ],
          readsFrom: {_db.financialTransactions, _db.transactionCategories},
        )
        .get();

    return rows.isNotEmpty ? rows.first.read<double>('s') : 0.0;
  }

  /// Get all transactions grouped by category
  Future<Map<TransactionCategory, List<FinancialTransaction>>>
  getAllGroupedByCategory() async {
    final rows = await (_db.select(_db.financialTransactions).join([
      innerJoin(
        _db.transactionCategories,
        _db.transactionCategories.id.equalsExp(
          _db.financialTransactions.categoryId,
        ),
      ),
    ])..orderBy([OrderingTerm.desc(_db.financialTransactions.date)])).get();

    final Map<TransactionCategory, List<FinancialTransaction>> grouped = {};
    for (final row in rows) {
      final cat = row.readTable(_db.transactionCategories);
      final tx = row.readTable(_db.financialTransactions);
      grouped.putIfAbsent(cat, () => []).add(tx);
    }
    return grouped;
  }
}
