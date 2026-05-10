import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../model/transaction_direction.dart';
import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [IncomeTypes, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Early-project migration policy:
          // schema v1 -> v2 removes `starterBalance` from IncomeTypes and adds
          // `isSystem` to Transactions. SQLite can't drop columns directly, so we
          // recreate tables.
          if (from < 2) {
            await m.deleteTable('transactions');
            await m.deleteTable('income_types');
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

