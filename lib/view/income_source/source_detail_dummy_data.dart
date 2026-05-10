import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

class SourceDetailDummyData {
  static List<Transaction> sampleTransactions = [
    Transaction(
      amount: 120,
      date: DateTime(2024, 10, 6),
      direction: TransactionDirection.inFlow,
      id: 1,
      incomeTypeId: 1,
      isSystem: false,
      name: 'دخل الإنترنت',
      createdAt: DateTime(2024, 10, 6),
    ),
    Transaction(
      amount: 120,
      date: DateTime(2026, 5, 7),
      direction: TransactionDirection.inFlow,
      id: 2,
      incomeTypeId: 1,
      isSystem: false,
      name: 'دخل الإنترنت',
      createdAt: DateTime(2026, 5, 7),
    ),
  ];

  static const double totalIncome = 6500;
  static const double totalExpenses = 4220;
  static const int transactionCount = 48;
}
