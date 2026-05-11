import 'package:drift/drift.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

import '../db/app_db.dart';

class TransactionCategoryRepository  {
  final AppDatabase _db;

  TransactionCategoryRepository(this._db);

  Future<int> create(TransactionCategory item) {
    throw UnimplementedError('Use createCategory() with named parameters');
  }

  Future<int> createCategory({
    required String name,
    required TransactionDirection direction,
  }) {
    final now = DateTime.now();
    return _db
        .into(_db.transactionCategories)
        .insert(
          TransactionCategoriesCompanion.insert(
            name: name,
            direction: direction,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<TransactionCategory?> getById(int id) {
    return (_db.select(_db.transactionCategories)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<TransactionCategory>> getAll() {
    return (_db.select(_db.transactionCategories)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<TransactionCategory>> watchAll() {
    return (_db.select(_db.transactionCategories)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> update(TransactionCategory item) async {
    await (_db.update(
      _db.transactionCategories,
    )..where((t) => t.id.equals(item.id))).write(
      TransactionCategoriesCompanion(
        name: Value(item.name),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> deleteById(int id) async {
    await (_db.update(
      _db.transactionCategories,
    )..where((t) => t.id.equals(id))).write(
      TransactionCategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
