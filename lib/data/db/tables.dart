import 'package:drift/drift.dart';

import '../../model/transaction_direction.dart';

class IncomeTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  DateTimeColumn get createdAt => dateTime()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get incomeTypeId => integer().references(IncomeTypes, #id)();

  /// True for system-generated transactions (e.g. opening balance).
  /// System rows are included in sums but must not be editable.
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  /// Template name (or displayed name for real transactions).
  TextColumn get name => text()();

  /// 'in' | 'out' (stored as text via converter)
  TextColumn get direction => text().map(const TransactionDirectionConverter())();

  /// Null = template row; non-null = real transaction row.
  RealColumn get amount => real().nullable()();

  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

