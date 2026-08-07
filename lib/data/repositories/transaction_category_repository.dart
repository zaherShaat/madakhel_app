import 'package:drift/drift.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

import '../db/app_db.dart';

class TransactionCategoryRepository {
  final AppDatabase _db;
  final String? Function() _currentUserId;
  final categories = <TransactionCategory>[];
  TransactionCategoryRepository(this._db, this._currentUserId);

  String? get _userId {
    final userId = _currentUserId();
    return userId == null || userId.isEmpty ? null : userId;
  }

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('No signed-in user for local category data.');
    }
    return userId;
  }

  Future<int> createCategory({
    required String name,
    required TransactionDirection direction,
  }) {
    final now = DateTime.now();
    final userId = _requireUserId();
    return _db
        .into(_db.transactionCategories)
        .insert(
          TransactionCategoriesCompanion.insert(
            userId: Value(userId),
            name: name,
            direction: direction,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<TransactionCategory?> getById(int id) {
    final userId = _userId;
    if (userId == null) return Future.value(null);

    return (_db.select(_db.transactionCategories)..where(
          (t) =>
              t.id.equals(id) &
              t.userId.equals(userId) &
              t.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  Future<List<TransactionCategory>> getAll()async {
    final userId = _userId;
    if (userId == null) return Future.value([]);
    final categories =
      await  (_db.select(_db.transactionCategories)
              ..where(
                (t) => t.userId.equals(userId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    this.categories.addAll(categories);
    return categories;
  }

  Stream<List<TransactionCategory>> watchAll() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return (_db.select(_db.transactionCategories)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> updateCategory({required int id, required String name}) async {
    final userId = _requireUserId();
    await (_db.update(
      _db.transactionCategories,
    )..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      TransactionCategoriesCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> deleteById(int id) async {
    final userId = _requireUserId();
    await (_db.update(
      _db.transactionCategories,
    )..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      TransactionCategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
