class IncomeSourceWithBalance {
  final int id;
  final String name;
  final String currency;
  final double balance;
  final bool isDeleted;

  const IncomeSourceWithBalance({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.isDeleted,
  });
}

