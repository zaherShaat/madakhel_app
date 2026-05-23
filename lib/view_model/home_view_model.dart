import 'package:flutter/material.dart';
import 'package:madakhel_app/data/repositories/income_type_repository.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';

class HomeViewModel extends ChangeNotifier {
  final IncomeTypeRepository _repository;

  HomeViewModel(this._repository);

  Stream<List<IncomeSourceWithBalance>> watchIncomeSourcesWithBalance() {
    return _repository.watchIncomeSourcesWithBalance();
  }
}
