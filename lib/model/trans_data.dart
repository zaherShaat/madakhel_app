class TransactionData {
  final double amount;
  final DateTime date;
  final int categoryId;
  final String? note;

  TransactionData({
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  });
}