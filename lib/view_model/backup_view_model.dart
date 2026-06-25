import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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

  Future<String> backup() async {
    try {
      isBackingUp = true;
      error = null;
      notifyListeners();

      // Check internet connection
      if (!_connectivityVm.hasInternet) {
        throw Exception(_connectivityVm.getNoInternetMessage());
      }

      final path = await _service.backupUserData();
      return path;
    } catch (e) {
      error = e.toString();
      debugPrint('Backup error: $error');
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

      // Check internet connection
      if (!_connectivityVm.hasInternet) {
        throw Exception(_connectivityVm.getNoInternetMessage());
      }

      if (!merge) {
        await _service.restoreUserData();
        return;
      }

      final data = await _service.fetchBackupData();

      final List<IncomeSource> remoteIncomeSources = List<IncomeSource>.from(
        data['incomeSources'] ?? [],
      );
      final List<TransactionCategory> remoteCategories =
          List<TransactionCategory>.from(data['transactionCategories'] ?? []);
      final List<FinancialTransaction> remoteTransactions =
          List<FinancialTransaction>.from(data['financialTransactions'] ?? []);

      await _db.transaction(() async {
        // Maps to resolve remote id -> local id
        final Map<String, int> remoteIdToLocalIncome = {};
        final Map<String, int> remoteIdToLocalCategory = {};
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
            // update if remote newer
            if (r.updatedAt.isAfter(existing.updatedAt)) {
              await (_db.update(
                _db.incomeSources,
              )..where((t) => t.id.equals(existing.id))).write(
                IncomeSourcesCompanion(
                  name: Value(r.name),
                  currency: Value(r.currency),
                  starterBalance: Value(r.starterBalance),
                  updatedAt: Value(r.updatedAt),
                  syncStatus: Value(r.syncStatus),
                  remoteId: Value(r.remoteId),
                  isDeleted: Value(r.isDeleted),
                ),
              );
            }
            remoteIdToLocalIncome[key] = existing.id;
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
            if (r.updatedAt.isAfter(existing.updatedAt)) {
              await (_db.update(
                _db.transactionCategories,
              )..where((t) => t.id.equals(existing.id))).write(
                TransactionCategoriesCompanion(
                  name: Value(r.name),
                  direction: Value(r.direction),
                  updatedAt: Value(r.updatedAt),
                  syncStatus: Value(r.syncStatus),
                  remoteId: Value(r.remoteId),
                  isDeleted: Value(r.isDeleted),
                ),
              );
            }
            remoteIdToLocalCategory[key] = existing.id;
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
          }
        }

        // Transactions
        final localTransactions = await (_db.select(
          _db.financialTransactions,
        )..where((t) => t.userId.equals(uid ?? ''))).get();

        final localTxByRemote = <String, FinancialTransaction>{};
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
            if (r.updatedAt.isAfter(existing.updatedAt)) {
              await (_db.update(
                _db.financialTransactions,
              )..where((t) => t.id.equals(existing.id))).write(
                FinancialTransactionsCompanion(
                  incomeSourceId: Value(mappedIncomeId ?? r.incomeSourceId),
                  categoryId: Value(mappedCategoryId ?? r.categoryId),
                  isSystem: Value(r.isSystem),
                  amount: Value(r.amount),
                  note: Value(r.note),
                  date: Value(r.date),
                  updatedAt: Value(r.updatedAt),
                  syncStatus: Value(r.syncStatus),
                  remoteId: Value(r.remoteId),
                  isDeleted: Value(r.isDeleted),
                ),
              );
            }
          } else {
            await _db
                .into(_db.financialTransactions)
                .insert(
                  FinancialTransactionsCompanion.insert(
                    userId: Value(r.userId),
                    incomeSourceId: mappedIncomeId ?? r.incomeSourceId,
                    categoryId: mappedCategoryId ?? r.categoryId,
                    isSystem: Value(r.isSystem),
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
          }
        }
      });
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }
}
