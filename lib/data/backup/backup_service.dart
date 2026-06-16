import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:madakhel_app/data/auth/auth_service.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/auth_user.dart';

class BackupService {
  static const _backupFolder = 'backups';
  static const _backupFileName = 'latest.json';
  static const _maxBackupSize = 10 * 1024 * 1024; // 10 MB

  final AppDatabase _db;
  final AuthService _auth;
  final FirebaseStorage _storage;

  BackupService(this._db, this._auth, {FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> backupUserData() async {
    final user = _requireSignedInUser();
    final uid = user.uid;

    final incomeSources = await (_db.select(
      _db.incomeSources,
    )..where((t) => t.userId.equals(uid))).get();
    final categories = await (_db.select(
      _db.transactionCategories,
    )..where((t) => t.userId.equals(uid))).get();
    final transactions = await (_db.select(
      _db.financialTransactions,
    )..where((t) => t.userId.equals(uid))).get();

    final payload = jsonEncode({
      'version': 1,
      'userId': uid,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'incomeSources': incomeSources.map((e) => e.toJson()).toList(),
      'transactionCategories': categories.map((e) => e.toJson()).toList(),
      'financialTransactions': transactions.map((e) => e.toJson()).toList(),
    });

    final ref = _storage
        .ref()
        .child(_backupFolder)
        .child(uid)
        .child(_backupFileName);

    await ref.putData(
      utf8.encode(payload),
      SettableMetadata(contentType: 'application/json'),
    );

    return ref.fullPath;
  }

  Future<bool> backupExists() async {
    try {
      final ref = _latestBackupRef(_requireSignedInUser().uid);
      await ref.getMetadata();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreUserData() async {
    final uid = _requireSignedInUser().uid;
    final ref = _latestBackupRef(uid);
    final bytes = await ref.getData(_maxBackupSize);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('لا يوجد نسخة احتياطية متاحة للاستعادة.');
    }

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('تنسيق النسخة الاحتياطية غير صالح.');
    }

    final backupUserId = decoded['userId'];
    if (backupUserId != uid) {
      throw StateError('نسخة احتياطية مختلفة عن المستخدم الحالي.');
    }

    final incomeSourcesJson = _extractList(decoded['incomeSources']);
    final categoriesJson = _extractList(decoded['transactionCategories']);
    final transactionsJson = _extractList(decoded['financialTransactions']);

    final incomeSources = incomeSourcesJson
        .map((item) => IncomeSource.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final categories = categoriesJson
        .map(
          (item) =>
              TransactionCategory.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    final transactions = transactionsJson
        .map(
          (item) =>
              FinancialTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    await _db.transaction(() async {
      await (_db.delete(
        _db.financialTransactions,
      )..where((t) => t.userId.equals(uid))).go();
      await (_db.delete(
        _db.transactionCategories,
      )..where((t) => t.userId.equals(uid))).go();
      await (_db.delete(
        _db.incomeSources,
      )..where((t) => t.userId.equals(uid))).go();

      for (final source in incomeSources) {
        await _db
            .into(_db.incomeSources)
            .insert(
              IncomeSourcesCompanion(
                id: Value(source.id),
                userId: Value(source.userId),
                name: Value(source.name),
                currency: Value(source.currency),
                starterBalance: Value(source.starterBalance),
                createdAt: Value(source.createdAt),
                updatedAt: Value(source.updatedAt),
                syncStatus: Value(source.syncStatus),
                remoteId: Value(source.remoteId),
                isDeleted: Value(source.isDeleted),
              ),
            );
      }

      for (final category in categories) {
        await _db
            .into(_db.transactionCategories)
            .insert(
              TransactionCategoriesCompanion(
                id: Value(category.id),
                userId: Value(category.userId),
                name: Value(category.name),
                direction: Value(category.direction),
                createdAt: Value(category.createdAt),
                updatedAt: Value(category.updatedAt),
                syncStatus: Value(category.syncStatus),
                remoteId: Value(category.remoteId),
                isDeleted: Value(category.isDeleted),
              ),
            );
      }

      for (final transaction in transactions) {
        await _db
            .into(_db.financialTransactions)
            .insert(
              FinancialTransactionsCompanion(
                id: Value(transaction.id),
                userId: Value(transaction.userId),
                incomeSourceId: Value(transaction.incomeSourceId),
                categoryId: Value(transaction.categoryId),
                isSystem: Value(transaction.isSystem),
                amount: Value(transaction.amount),
                note: Value(transaction.note),
                date: Value(transaction.date),
                createdAt: Value(transaction.createdAt),
                updatedAt: Value(transaction.updatedAt),
                syncStatus: Value(transaction.syncStatus),
                remoteId: Value(transaction.remoteId),
                isDeleted: Value(transaction.isDeleted),
              ),
            );
      }
    });
  }

  AuthUser _requireSignedInUser() {
    final user = _auth.currentAuthUser;
    if (user == null) {
      throw StateError('No signed-in user available for backup.');
    }
    return user;
  }

  Reference _latestBackupRef(String uid) {
    return _storage
        .ref()
        .child(_backupFolder)
        .child(uid)
        .child(_backupFileName);
  }

  List<Map<String, dynamic>> _extractList(Object? raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .cast<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw StateError('Expected a JSON array but got ${raw.runtimeType}.');
  }
}
