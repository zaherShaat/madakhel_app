import 'package:flutter/material.dart';
import 'package:madakhel_app/core/app_states.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  AppState<Map<TransactionCategory, List<FinancialTransaction>>> _state =
      const IdleState();

  TransactionsViewModel(this._repository);

  AppState<Map<TransactionCategory, List<FinancialTransaction>>> get state =>
      _state;

  Future<void> load() async {
    _setState(const LoadingState());
    try {
      final grouped = await _repository.getAllGroupedByCategory();
      _setState(SuccessState(grouped));
    } catch (e) {
      _setState(ErrorState(e.toString()));
    }
  }

  Future<void> refresh() => load();

  void _setState(
    AppState<Map<TransactionCategory, List<FinancialTransaction>>> state,
  ) {
    _state = state;
    notifyListeners();
  }
}
