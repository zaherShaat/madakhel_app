import 'package:flutter/material.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';

class IncomeSourceDetailViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  IncomeSourceDetailViewModel(this._repository);

  Stream<List<FinancialTransaction>> watchTransactions(int incomeSourceId) {
    return _repository.watchTransactions(incomeSourceId);
  }

  Future<double> getInSum(int incomeSourceId) {
    return _repository.getInSum(incomeSourceId);
  }

  Future<double> getOutSum(int incomeSourceId) {
    return _repository.getOutSum(incomeSourceId);
  }
}
