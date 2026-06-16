import 'package:drift/drift.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

import '../../model/income_source_with_balance.dart';
import '../db/app_db.dart';

class IncomeTypeRepository {
  final AppDatabase _db;
  final String? Function() _currentUserId;

  IncomeTypeRepository(this._db, this._currentUserId);

  String? get _userId {
    final userId = _currentUserId();
    return userId == null || userId.isEmpty ? null : userId;
  }

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('No signed-in user for local income source data.');
    }
    return userId;
  }

  /// Create with named parameters (business logic wrapper)
  Future<int> createIncomeType({
    required String name,
    required String currency,
  }) async {
    final now = DateTime.now();
    final userId = _requireUserId();
    return await _db
        .into(_db.incomeSources)
        .insert(
          IncomeSourcesCompanion.insert(
            userId: Value(userId),
            name: name,
            currency: Value(currency),
            starterBalance: const Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<IncomeSource?> getById(int id) async {
    final userId = _userId;
    if (userId == null) return null;

    return (_db.select(_db.incomeSources)..where(
          (t) =>
              t.id.equals(id) &
              t.userId.equals(userId) &
              t.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  Future<List<IncomeSource>> getAll() async {
    final userId = _userId;
    if (userId == null) return [];

    return (_db.select(_db.incomeSources)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<IncomeSource>> watchAll() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return (_db.select(_db.incomeSources)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Update with named parameters (business logic wrapper)
  Future<void> updateIncomeType({
    required int id,
    required String name,
    required String currency,
  }) async {
    final userId = _requireUserId();
    await (_db.update(
      _db.incomeSources,
    )..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      IncomeSourcesCompanion(
        name: Value(name),
        currency: Value(currency),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> deleteById(int id) async {
    final now = DateTime.now();
    final userId = _requireUserId();

    await (_db.update(
      _db.incomeSources,
    )..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      IncomeSourcesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Stream<List<IncomeSourceWithBalance>> watchIncomeSourcesWithBalance() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    final query =
        _db.select(_db.incomeSources).join([
            leftOuterJoin(
              _db.financialTransactions,
              _db.financialTransactions.incomeSourceId.equalsExp(
                    _db.incomeSources.id,
                  ) &
                  _db.financialTransactions.userId.equals(userId) &
                  _db.financialTransactions.isDeleted.equals(false),
            ),
            leftOuterJoin(
              _db.transactionCategories,
              _db.transactionCategories.id.equalsExp(
                    _db.financialTransactions.categoryId,
                  ) &
                  _db.transactionCategories.userId.equals(userId) &
                  _db.transactionCategories.isDeleted.equals(false),
            ),
          ])
          ..where(
            _db.incomeSources.userId.equals(userId) &
                _db.incomeSources.isDeleted.equals(false),
          )
          ..orderBy([OrderingTerm.desc(_db.incomeSources.createdAt)]);

    return query.watch().map((rows) {
      final Map<int, _BalanceAccumulator> accumulators = {};

      for (final row in rows) {
        final source = row.readTable(_db.incomeSources);
        final id = source.id;

        final acc = accumulators.putIfAbsent(
          id,
          () => _BalanceAccumulator(
            id: id,
            name: source.name,
            currency: source.currency,
            isDeleted: source.isDeleted,
          ),
        );

        // Read transaction and category (may be null because of left outer joins)
        final transaction = row.readTableOrNull(_db.financialTransactions);
        final category = transaction != null
            ? row.readTableOrNull(_db.transactionCategories)
            : null;

        if (transaction != null && category != null) {
          final signedAmount = category.direction == TransactionDirection.inFlow
              ? transaction.amount
              : -transaction.amount;
          acc.balance += signedAmount;
        }
      }

      return accumulators.values
          .map(
            (acc) => IncomeSourceWithBalance(
              id: acc.id,
              name: acc.name,
              currency: acc.currency,
              balance: acc.balance,
              isDeleted: acc.isDeleted,
            ),
          )
          .toList();
    });
  }
}

// Helper class to accumulate balance while processing rows
class _BalanceAccumulator {
  final int id;
  final String name;
  final String currency;
  final bool isDeleted;
  double balance = 0.0;

  _BalanceAccumulator({
    required this.id,
    required this.name,
    required this.currency,
    required this.isDeleted,
  });
}
