import 'package:drift/drift.dart';

/// Direction of money movement.
///
/// Stored in SQLite as 'in' | 'out' (not the enum name).
enum TransactionDirection { inFlow, outFlow }

class TransactionDirectionConverter
    extends TypeConverter<TransactionDirection, String> {
  const TransactionDirectionConverter();

  static const _in = 'in';
  static const _out = 'out';

  @override
  TransactionDirection fromSql(String fromDb) {
    return switch (fromDb) {
      _in => TransactionDirection.inFlow,
      _out => TransactionDirection.outFlow,
      _ => throw ArgumentError.value(fromDb, 'fromDb', 'Invalid direction'),
    };
  }

  @override
  String toSql(TransactionDirection value) {
    return switch (value) {
      TransactionDirection.inFlow => _in,
      TransactionDirection.outFlow => _out,
    };
  }
}

