import 'package:drift/drift.dart';

import '../../model/transaction_direction.dart';

class IncomeSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  RealColumn get starterBalance => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  // Sync flags
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class TransactionCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get direction =>
      text().map(const TransactionDirectionConverter())();
  DateTimeColumn get createdAt => dateTime()();

  // Sync flags
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class FinancialTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().withDefault(const Constant(''))();

  // Belongs to one income source
  IntColumn get incomeSourceId => integer().references(IncomeSources, #id)();

  // Belongs to one transaction category
  IntColumn get categoryId =>
      integer().references(TransactionCategories, #id)();

  /// Denormalized direction for faster queries and simpler filtering.
  /// This stores the `TransactionDirection` value at the time of creation.
  TextColumn get direction =>
      text().map(const TransactionDirectionConverter())();

  /// True for system-generated rows (e.g. opening balance).
  /// System rows are included in sums but must NOT be editable by the user.
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  // Sync flags
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
