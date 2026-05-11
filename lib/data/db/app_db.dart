import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../model/transaction_direction.dart';
import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(
  tables: [IncomeSources, TransactionCategories, FinancialTransactions],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        await m.deleteTable('financial_transactions');
        await m.deleteTable('transaction_categories');
        await m.deleteTable('income_sources');
        await m.createAll();
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'madakhel.db'));
    return NativeDatabase.createInBackground(file);
  });
}
