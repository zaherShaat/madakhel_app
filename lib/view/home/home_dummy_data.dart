import 'package:madakhel_app/model/income_source_with_balance.dart';

class HomeDummyData {
  static const List<IncomeSourceWithBalance> incomeSources = [
    IncomeSourceWithBalance(
      id: 1,
      name: 'مقهى الإنترنت',
      currency: '\$ USD',
      balance: 4280,
    ),
    IncomeSourceWithBalance(
      id: 2,
      name: 'المصدر ب',
      currency: '₪ ILS',
      balance: 1150,
    ),
    IncomeSourceWithBalance(
      id: 3,
      name: 'المصدر ج',
      currency: '\$ USD',
      balance: 870,
    ),
  ];
}
