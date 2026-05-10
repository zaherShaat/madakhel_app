// import 'package:madakhel_app/model/transaction_direction.dart';

// class Transaction {
//   final int id;
//   final int incomeSourceId;
//   final String typeId;
//   final String typeName;
//   final double amount;
//   final DateTime date;
//   final String? note;
//   final TransactionDirection direction;

//   const Transaction({
//     required this.id,
//     required this.incomeSourceId,
//     required this.typeId,
//     required this.typeName,
//     required this.amount,
//     required this.date,
//     this.note,
//     required this.direction,
//   });

//   String get displayAmount {
//     final sign = direction == TransactionDirection.inFlow ? '+' : '−';
//     return '$sign$amount';
//   }

//   String get displayDate {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final txDay = DateTime(date.year, date.month, date.day);
//     final difference = today.difference(txDay).inDays;

//     if (difference == 0) return 'اليوم';
//     if (difference == 1) return 'أمس';
//     return '${date.day} ${_getMonthName(date.month)}';
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر',
//     ];
//     return months[month - 1];
//   }
// }
