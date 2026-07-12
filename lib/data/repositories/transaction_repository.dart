import 'package:drift/drift.dart';

import '../../model/transaction_direction.dart';
import '../db/app_db.dart';

class TransactionRepository {
  final AppDatabase _db;
  final String? Function() _currentUserId;

  TransactionRepository(this._db, this._currentUserId);

  String? get _userId {
    final userId = _currentUserId();
    return userId == null || userId.isEmpty ? null : userId;
  }

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('No signed-in user for local transaction data.');
    }
    return userId;
  }

  Future<int> create(FinancialTransaction item) {
    throw UnimplementedError('Use createTransaction(...) instead');
  }

  Future<FinancialTransaction?> getById(int id) {
    final userId = _userId;
    if (userId == null) return Future.value(null);

    return (_db.select(_db.financialTransactions)..where(
          (t) =>
              t.id.equals(id) &
              t.userId.equals(userId) &
              t.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  Future<List<FinancialTransaction>> getAll() {
    final userId = _userId;
    if (userId == null) return Future.value([]);

    return (_db.select(_db.financialTransactions)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> update(FinancialTransaction item) async {
    final userId = _requireUserId();
    await (_db.update(
      _db.financialTransactions,
    )..where((t) => t.id.equals(item.id) & t.userId.equals(userId))).write(
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
    final userId = _userId;
    if (userId == null) return Future.value([]);

    return (_db.select(_db.financialTransactions)
          ..where(
            (t) =>
                t.incomeSourceId.equals(incomeSourceId) &
                t.userId.equals(userId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Count real transactions for an income source without loading all rows.
  Future<int> countTransactions(int incomeSourceId) async {
    final userId = _userId;
    if (userId == null) return 0;

    final countExp = _db.financialTransactions.id.count();
    final row =
        await (_db.selectOnly(_db.financialTransactions)
              ..addColumns([countExp])
              ..where(
                _db.financialTransactions.incomeSourceId.equals(
                      incomeSourceId,
                    ) &
                    _db.financialTransactions.userId.equals(userId) &
                    _db.financialTransactions.isDeleted.equals(false),
              ))
            .getSingle();

    return row.read(countExp) ?? 0;
  }

  /// Load one transaction page from SQLite using LIMIT/OFFSET.
  Future<List<FinancialTransaction>> getTransactionsPage({
    required int incomeSourceId,
    required int limit,
    required int offset,
  }) {
    final userId = _userId;
    if (userId == null) return Future.value([]);

    return (_db.select(_db.financialTransactions)
          ..where(
            (t) =>
                t.incomeSourceId.equals(incomeSourceId) &
                t.userId.equals(userId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<List<FinancialTransaction>> watchTransactions(int incomeSourceId) {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return (_db.select(_db.financialTransactions)
          ..where(
            (t) =>
                t.incomeSourceId.equals(incomeSourceId) &
                t.userId.equals(userId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Create a real transaction. We accept direction and create/find a default
  /// category for that direction to attach the transaction to.
  Future<int> createTransaction({
    required int incomeSourceId,
    required double amount,
    required DateTime date,
    required int categoryId,
    String? note,
  }) async {
    final now = DateTime.now();
    final userId = _requireUserId();
    await _ensureIncomeSourceBelongsToUser(incomeSourceId, userId);
    await _ensureCategoryBelongsToUser(categoryId, userId);

    // Resolve the transaction direction from the category and store it
    // denormalized on the transaction row for faster queries later.
    final category = await (_db.select(_db.transactionCategories)..where(
      (c) => c.id.equals(categoryId) & c.userId.equals(userId) & c.isDeleted.equals(false),
    )).getSingle();

    return await _db.into(_db.financialTransactions).insert(
      FinancialTransactionsCompanion.insert(
        userId: Value(userId),
        incomeSourceId: incomeSourceId,
        categoryId: categoryId,
        // denormalized direction
        direction: category.direction,
        amount: amount,
        note: Value(note),
        date: date,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateTransaction({
    required int id,
    required double amount,
    required DateTime date,
    required int categoryId,
    String? note,
  }) async {
    final userId = _requireUserId();
    await _ensureCategoryBelongsToUser(categoryId, userId);

    // Fetch category direction to keep denormalized `direction` in sync
    final category = await (_db.select(_db.transactionCategories)..where(
      (c) => c.id.equals(categoryId) & c.userId.equals(userId) & c.isDeleted.equals(false),
    )).getSingle();

    await (_db.update(_db.financialTransactions)..where(
          (t) => t.id.equals(id) & t.userId.equals(userId) & t.isSystem.equals(false),
        ))
        .write(
          FinancialTransactionsCompanion(
            categoryId: Value(categoryId),
            // keep denormalized direction consistent with the selected category
            direction: Value(category.direction),
            amount: Value(amount),
            note: Value(note),
            date: Value(date),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
          ),
        );
  }

  Future<void> deleteById(int id) async {
    final userId = _requireUserId();
    await (_db.update(_db.financialTransactions)..where(
          (t) =>
              t.id.equals(id) &
              t.userId.equals(userId) &
              t.isSystem.equals(false),
        ))
        .write(
          FinancialTransactionsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
          ),
        );
  }

  Future<void> _ensureIncomeSourceBelongsToUser(int id, String userId) async {
    final source =
        await (_db.select(_db.incomeSources)..where(
              (t) =>
                  t.id.equals(id) &
                  t.userId.equals(userId) &
                  t.isDeleted.equals(false),
            ))
            .getSingleOrNull();

    if (source == null) {
      throw StateError('Income source does not belong to the signed-in user.');
    }
  }

  Future<void> _ensureCategoryBelongsToUser(int id, String userId) async {
    final category =
        await (_db.select(_db.transactionCategories)..where(
              (t) =>
                  t.id.equals(id) &
                  t.userId.equals(userId) &
                  t.isDeleted.equals(false),
            ))
            .getSingleOrNull();

    if (category == null) {
      throw StateError('Category does not belong to the signed-in user.');
    }
  }

  /// Get total inflow for an income source
  Future<double> getInSum(int incomeSourceId) async {
    final userId = _userId;
    if (userId == null) return 0.0;
    // Use denormalized `direction` column on financial_transactions for a
    // simpler and faster query (no join required).
    final query = '''
SELECT COALESCE(SUM(amount), 0) AS s
FROM financial_transactions
WHERE income_source_id = ? AND user_id = ? AND direction = ? AND is_deleted = 0
''';
    final rows = await _db.customSelect(
      query,
      variables: [
        Variable<int>(incomeSourceId),
        Variable<String>(userId),
        Variable<String>(
          const TransactionDirectionConverter().toSql(           TransactionDirection.inFlow,
          ),
        ),
      ],
      readsFrom: {_db.financialTransactions},
    ).get();

    return rows.isNotEmpty ? rows.first.read<double>('s') : 0.0;
  }

  /// Get total outflow for an income source
  Future<double> getOutSum(int incomeSourceId) async {
    final userId = _userId;
    if (userId == null) return 0.0;
    final query = '''
SELECT COALESCE(SUM(amount), 0) AS s
FROM financial_transactions
WHERE income_source_id = ? AND user_id = ? AND direction = ? AND is_deleted = 0
''';
    final rows = await _db.customSelect(
      query,
      variables: [
        Variable<int>(incomeSourceId),
        Variable<String>(userId),
        Variable<String>(
          const TransactionDirectionConverter().toSql(
            TransactionDirection.outFlow,
          ),
        ),
      ],
      readsFrom: {_db.financialTransactions},
    ).get();

    return rows.isNotEmpty ? rows.first.read<double>('s') : 0.0;
  }

  /// Get all transactions grouped by category
  Future<Map<TransactionCategory, List<FinancialTransaction>>>
  getAllGroupedByCategory() async {
    final userId = _userId;
    if (userId == null) return {};

    final rows =
        await (_db.select(_db.financialTransactions).join([
                innerJoin(
                  _db.transactionCategories,
                  _db.transactionCategories.id.equalsExp(
                    _db.financialTransactions.categoryId,
                  ),
                ),
                innerJoin(
                  _db.incomeSources,
                  _db.incomeSources.id.equalsExp(
                    _db.financialTransactions.incomeSourceId,
                  ),
                ),
              ])
              ..where(
                _db.financialTransactions.userId.equals(userId) &
                    _db.financialTransactions.isDeleted.equals(false) &
                    _db.transactionCategories.userId.equals(userId) &
                    _db.transactionCategories.isDeleted.equals(false) &
                    _db.incomeSources.userId.equals(userId) &
                    _db.incomeSources.isDeleted.equals(false),
              )
              ..orderBy([OrderingTerm.desc(_db.financialTransactions.date)]))
            .get();

    final Map<TransactionCategory, List<FinancialTransaction>> grouped = {};
    for (final row in rows) {
      final cat = row.readTable(_db.transactionCategories);
      final tx = row.readTable(_db.financialTransactions);
      grouped.putIfAbsent(cat, () => []).add(tx);
    }
    return grouped;
  }
}
