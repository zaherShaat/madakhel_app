import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

import '../../model/income_source_with_balance.dart';
import '../db/app_db.dart';

class IncomeTypeRepository {
  final AppDatabase _db;

  IncomeTypeRepository(this._db);

  /// Create with named parameters (business logic wrapper)
  Future<int> createIncomeType({
    required String name,
    required String currency,
  }) async {
    final now = DateTime.now();
    return await _db
        .into(_db.incomeSources)
        .insert(
          IncomeSourcesCompanion.insert(
            name: name,
            currency: Value(currency),
            starterBalance: const Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<IncomeSource?> getById(int id) async {
    return (_db.select(_db.incomeSources)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<IncomeSource>> getAll() async {
    return (_db.select(_db.incomeSources)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<IncomeSource>> watchAll() {
    return (_db.select(_db.incomeSources)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Update with named parameters (business logic wrapper)
  Future<void> updateIncomeType({
    required int id,
    required String name,
    required String currency,
  }) async {
    await (_db.update(_db.incomeSources)..where((t) => t.id.equals(id))).write(
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

    await _db.transaction(() async {
      // 1) Soft-delete all transactions belonging to this source
      await (_db.update(
        _db.financialTransactions,
      )..where((t) => t.incomeSourceId.equals(id))).write(
        FinancialTransactionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
        ),
      );

      // 2) Soft-delete the source itself
      await (_db.update(
        _db.incomeSources,
      )..where((t) => t.id.equals(id))).write(
        IncomeSourcesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
        ),
      );
    });
  }

  Stream<List<IncomeSourceWithBalance>> watchIncomeSourcesWithBalance() {
    // Base select from income_sources
    final query = _db.select(_db.incomeSources).join([
      // Left join financial_transactions (all rows, including deleted)
      leftOuterJoin(
        _db.financialTransactions,
        _db.financialTransactions.incomeSourceId.equalsExp(
          _db.incomeSources.id,
        ),
      ),
      // Left join transaction_categories to get direction
      leftOuterJoin(
        _db.transactionCategories,
        _db.transactionCategories.id.equalsExp(
          _db.financialTransactions.categoryId,
        ),
      ),
    ])..orderBy([OrderingTerm.desc(_db.incomeSources.createdAt)]);

    // Convert the stream of rows to List<IncomeSourceWithBalance>
    return query.watch().map((rows) {
      final Map<int, _BalanceAccumulator> accumulators = {};

      for (final row in rows) {
        // Read the income source (always present)
        final source = row.readTable(_db.incomeSources);
        final id = source.id;

        // Get or create accumulator for this source
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

        // If we have a valid transaction (not null), add its signed amount to balance
        if (transaction != null && category != null) {
          final signedAmount = category.direction == TransactionDirection.inFlow
              ? transaction.amount
              : -transaction.amount;
          acc.balance += signedAmount;
        }
      }

      // Convert accumulators to final model list
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
