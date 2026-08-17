import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:madakhel_app/core/local_logger.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/backup/backup_service.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/view_model/connectivity_view_model.dart';

class BackupViewModel extends ChangeNotifier {
  final BackupService _service;
  final AppDatabase _db;
  final ConnectivityViewModel _connectivityVm;

  bool isBackingUp = false;
  bool isRestoring = false;
  String? error;

  BackupViewModel(this._service, this._db, this._connectivityVm);
  bool isInternetHere() {
    // Check internet connection
    return _connectivityVm.hasInternet;
  }

  /// Backup to Google Drive using the authenticated user's access token.
  /// This method now calls backupToDrive() instead of the deprecated Supabase method.
  Future<String> backup() async {
    try {
      isBackingUp = true;
      error = null;
      notifyListeners();

      // Log start
      unawaited(
        LocalLogger.instance.logBackup('START', 'backup initiated (G Drive)'),
      );
      // Check internet connection
      if (!isInternetHere()) {
        throw Exception(_connectivityVm.getNoInternetMessage());
      }

      // Use Google Drive backup instead of Supabase
      final fileId = await _service.backupToDrive();
      // Log success with G Drive file ID
      unawaited(
        LocalLogger.instance.logBackup(
          'SUCCESS',
          'backup saved to G Drive: $fileId',
        ),
      );
      return fileId;
    } catch (e) {
      error = e is StateError ? e.message : e.toString();
      debugPrint('Backup error: $error');
      unawaited(LocalLogger.instance.logBackup('ERROR', error ?? e.toString()));
      rethrow;
    } finally {
      isBackingUp = false;
      notifyListeners();
    }
  }

  Future<void> restore({bool merge = true}) async {
    try {
      isRestoring = true;
      error = null;
      notifyListeners();

      unawaited(
        LocalLogger.instance.logBackup(
          'RESTORE_START',
          'restore initiated merge=$merge',
        ),
      );
      // Check internet connection
      if (!isInternetHere()) {
        throw Exception(_connectivityVm.getNoInternetMessage());
      }

      if (!merge) {
        await _service.restoreUserDataFromGDrive();
        unawaited(
          LocalLogger.instance.logBackup(
            'RESTORE_SUCCESS',
            'restore (full replace from G Drive) completed',
          ),
        );
        return;
      }

      final backupFileData = await _service.fetchBackupDataFromGDrive();

      final List<IncomeSource> remoteIncomeSources = List<IncomeSource>.from(
        backupFileData[incomeSourcesKey] ?? [],
      );
      debugPrint("incomeSources: $remoteIncomeSources");
      final List<TransactionCategory> remoteCategories =
          List<TransactionCategory>.from(
            backupFileData[transactionCategoriesKey] ?? [],
          );
      final List<FinancialTransaction> remoteTransactions =
          List<FinancialTransaction>.from(
            backupFileData[financialTransactionsKey] ?? [],
          );
      final mergeResult = await _mergeRemoteDataIntoLocal(
        remoteIncomeSources,
        remoteCategories,
        remoteTransactions,
      );
      unawaited(
        LocalLogger.instance.logBackup('RESTORE_MERGE', 'merged: $mergeResult'),
      );
    } catch (e) {
      error = e is StateError ? e.message : e.toString();
      unawaited(LocalLogger.instance.logBackup('ERROR', error ?? e.toString()));
      rethrow;
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  Future<BackupSnapshot> downloadBackupSnapshot() async {
    try {
      isRestoring = true;
      error = null;
      notifyListeners();

      if (!isInternetHere()) {
        throw Exception(_connectivityVm.getNoInternetMessage());
      }

      // Use Google Drive backup restoration instead of Supabase
      final backupFileData = await _service.fetchBackupDataFromGDrive();

      // Fail loudly on incomplete/malformed data instead of silently defaulting
      const requiredKeys = [
        incomeSourcesKey,
        transactionCategoriesKey,
        financialTransactionsKey,
      ];
      final missingKeys = requiredKeys
          .where((k) => !backupFileData.containsKey(k))
          .toList();
      if (missingKeys.isNotEmpty) {
        throw StateError(
          'Backup data incomplete — missing: ${missingKeys.join(', ')}',
        );
      }
      return BackupSnapshot(
        incomeSources: List<IncomeSource>.from(
          backupFileData[incomeSourcesKey] ?? [],
        ),
        categories: List<TransactionCategory>.from(
          backupFileData[transactionCategoriesKey] ?? [],
        ),
        transactions: List<FinancialTransaction>.from(
          backupFileData[financialTransactionsKey] ?? [],
        ),
      );
    } catch (e) {
      error = e is StateError ? e.message : e.toString();
      unawaited(LocalLogger.instance.logBackup('ERROR', error ?? e.toString()));
      rethrow;
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> replaceWithSnapshot(BackupSnapshot snapshot) async {
    try {
      isRestoring = true;
      error = null;
      notifyListeners();

      await _replaceLocalData(
        snapshot.incomeSources,
        snapshot.categories,
        snapshot.transactions,
      );
      unawaited(
        LocalLogger.instance.logBackup(
          'RESTORE_SUCCESS',
          'restore (downloaded full replace) completed',
        ),
      );
    } catch (e) {
      error = e is StateError ? e.message : e.toString();
      unawaited(LocalLogger.instance.logBackup('ERROR', error ?? e.toString()));
      rethrow;
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  //TODO: MAKE IT SIMPLE AND CLEANER
  Future<Map<String, int>> _mergeRemoteDataIntoLocal(
    List<IncomeSource> remoteIncomeSources,
    List<TransactionCategory> remoteCategories,
    List<FinancialTransaction> remoteTransactions,
  ) async {
    var incomeInserted = 0;
    var categoryInserted = 0;
    var txInserted = 0;

    await _db.transaction(() async {
      // Maps to resolve remote id -> local id
      final Map<String, int> remoteIdToLocalIncome = {};
      final Map<String, int> remoteIdToLocalCategory = {};
      final localTxByRemote = <String, FinancialTransaction>{};

      final uid = remoteIncomeSources.isNotEmpty
          ? remoteIncomeSources.first.userId
          : (remoteCategories.isNotEmpty
                ? remoteCategories.first.userId
                : (remoteTransactions.isNotEmpty
                      ? remoteTransactions.first.userId
                      : null));

      // Income sources
      final localIncome = await (_db.select(
        _db.incomeSources,
      )..where((t) => t.userId.equals(uid ?? ''))).get();

      final localByRemote = <String, IncomeSource>{};
      for (final l in localIncome) {
        if (l.remoteId != null && l.remoteId!.isNotEmpty) {
          localByRemote[l.remoteId!] = l;
        }
      }

      for (final r in remoteIncomeSources) {
        final key = r.remoteId ?? r.id.toString();
        final existing = r.remoteId != null
            ? localByRemote[r.remoteId!]
            : localIncome.firstWhereOrNull((l) => l.id == r.id);

        if (existing != null) {
          remoteIdToLocalIncome[key] = existing.id;
          continue;
        } else {
          final newId = await _db
              .into(_db.incomeSources)
              .insert(
                IncomeSourcesCompanion.insert(
                  userId: Value(r.userId),
                  name: r.name,
                  currency: Value(r.currency),
                  starterBalance: Value(r.starterBalance),
                  createdAt: r.createdAt,
                  updatedAt: r.updatedAt,
                  syncStatus: Value(r.syncStatus),
                  remoteId: Value(r.remoteId),
                  isDeleted: Value(r.isDeleted),
                ),
              );
          remoteIdToLocalIncome[key] = newId;
          incomeInserted++;
        }
      }

      // Categories
      final localCategories = await (_db.select(
        _db.transactionCategories,
      )..where((t) => t.userId.equals(uid ?? ''))).get();

      final localCatByRemote = <String, TransactionCategory>{};
      for (final l in localCategories) {
        if (l.remoteId != null && l.remoteId!.isNotEmpty) {
          localCatByRemote[l.remoteId!] = l;
        }
      }

      for (final r in remoteCategories) {
        final key = r.remoteId ?? r.id.toString();
        final existing = r.remoteId != null
            ? localCatByRemote[r.remoteId!]
            : localCategories.firstWhereOrNull((l) => l.id == r.id);

        if (existing != null) {
          remoteIdToLocalCategory[key] = existing.id;
          continue;
        } else {
          final newId = await _db
              .into(_db.transactionCategories)
              .insert(
                TransactionCategoriesCompanion.insert(
                  userId: Value(r.userId),
                  name: r.name,
                  direction: r.direction,
                  createdAt: r.createdAt,
                  updatedAt: r.updatedAt,
                  syncStatus: Value(r.syncStatus),
                  remoteId: Value(r.remoteId),
                  isDeleted: Value(r.isDeleted),
                ),
              );
          remoteIdToLocalCategory[key] = newId;
          categoryInserted++;
        }
      }

      // Transactions
      final localTransactions = await (_db.select(
        _db.financialTransactions,
      )..where((t) => t.userId.equals(uid ?? ''))).get();

      for (final l in localTransactions) {
        if (l.remoteId != null && l.remoteId!.isNotEmpty) {
          localTxByRemote[l.remoteId!] = l;
        }
      }

      for (final r in remoteTransactions) {
        // Resolve foreign keys
        final mappedIncomeId =
            remoteIdToLocalIncome[r.incomeSourceId.toString()] ??
            localIncome.firstWhereOrNull((l) => l.id == r.incomeSourceId)?.id;
        final mappedCategoryId =
            remoteIdToLocalCategory[r.categoryId.toString()] ??
            localCategories.firstWhereOrNull((l) => l.id == r.categoryId)?.id;

        final existing = r.remoteId != null
            ? localTxByRemote[r.remoteId!]
            : localTransactions.firstWhereOrNull((l) => l.id == r.id);

        if (existing != null) {
          continue;
        } else {
          // Determine denormalized direction for the transaction. Prefer
          // the direction provided by the transaction JSON; otherwise fall
          // back to the category direction mapping.
          var dir = r.direction;
          // if (dir == null) {
          //   final localCat = localCategories.firstWhereOrNull(
          //     (c) => c.id == r.categoryId,
          //   );
          //   dir = localCat?.direction ?? TransactionDirection.inFlow;
          // }

          await _db
              .into(_db.financialTransactions)
              .insert(
                FinancialTransactionsCompanion.insert(
                  userId: Value(r.userId),
                  incomeSourceId: mappedIncomeId ?? r.incomeSourceId,
                  categoryId: mappedCategoryId ?? r.categoryId,
                  isSystem: Value(r.isSystem),
                  direction: dir,
                  amount: r.amount,
                  note: Value(r.note),
                  date: r.date,
                  createdAt: r.createdAt,
                  updatedAt: r.updatedAt,
                  syncStatus: Value(r.syncStatus),
                  remoteId: Value(r.remoteId),
                  isDeleted: Value(r.isDeleted),
                ),
              );
          txInserted++;
        }
      }
    });

    return {
      'incomeInserted': incomeInserted,
      'categoryInserted': categoryInserted,
      'txInserted': txInserted,
    };
  }

  Future<void> _replaceLocalData(
    List<IncomeSource> incomeSources,
    List<TransactionCategory> categories,
    List<FinancialTransaction> transactions,
  ) async {
    final backupOwner = incomeSources.isNotEmpty
        ? incomeSources.first.userId
        : (categories.isNotEmpty
              ? categories.first.userId
              : (transactions.isNotEmpty ? transactions.first.userId : null));

    if (backupOwner == null) {
      throw StateError(
        'Cannot restore backup because the backup file is empty.',
      );
    }

    await _db.transaction(() async {
      await (_db.delete(
        _db.financialTransactions,
      )..where((t) => t.userId.equals(backupOwner))).go();
      await (_db.delete(
        _db.transactionCategories,
      )..where((t) => t.userId.equals(backupOwner))).go();
      await (_db.delete(
        _db.incomeSources,
      )..where((t) => t.userId.equals(backupOwner))).go();

      for (final source in incomeSources) {
        await _db.into(_db.incomeSources).insert(source.toCompanion(false));
      }
      for (final category in categories) {
        await _db
            .into(_db.transactionCategories)
            .insert(category.toCompanion(false));
      }
      for (final transaction in transactions) {
        await _db
            .into(_db.financialTransactions)
            .insert(transaction.toCompanion(false));
      }
    });
  }
}

class BackupSnapshot {
  final List<IncomeSource> incomeSources;
  final List<TransactionCategory> categories;
  final List<FinancialTransaction> transactions;

  const BackupSnapshot({
    required this.incomeSources,
    required this.categories,
    required this.transactions,
  });
}
