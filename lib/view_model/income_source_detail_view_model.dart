import 'package:flutter/material.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';

class IncomeSourceDetailState {
  final List<FinancialTransaction> transactions;
  final int totalCount;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const IncomeSourceDetailState({
    this.transactions = const [],
    this.totalCount = 0,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  bool get hasMore => transactions.length < totalCount;

  IncomeSourceDetailState copyWith({
    List<FinancialTransaction>? transactions,
    int? totalCount,
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return IncomeSourceDetailState(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

class IncomeSourceDetailViewModel extends ChangeNotifier {
  static const int initialPageSize = 3;
  static const int pageSize = 10;

  final TransactionRepository _repository;
  IncomeSourceDetailState _state = const IncomeSourceDetailState();
  int? _incomeSourceId;

  IncomeSourceDetailViewModel(this._repository);

  IncomeSourceDetailState get state => _state;

  Future<void> loadInitialTransactions(int incomeSourceId) async {
    _incomeSourceId = incomeSourceId;
    _setState(const IncomeSourceDetailState(isInitialLoading: true));

    try {
      final totalCount = await _repository.countTransactions(incomeSourceId);
      final transactions = await _repository.getTransactionsPage(
        incomeSourceId: incomeSourceId,
        limit: initialPageSize,
        offset: 0,
      );

      if (_incomeSourceId != incomeSourceId) return;

      _setState(
        IncomeSourceDetailState(
          transactions: transactions,
          totalCount: totalCount,
        ),
      );
    } catch (e) {
      if (_incomeSourceId != incomeSourceId) return;

      _setState(IncomeSourceDetailState(errorMessage: e.toString()));
    }
  }

  Future<void> loadMoreTransactions() async {
    final incomeSourceId = _incomeSourceId;
    if (incomeSourceId == null ||
        _state.isInitialLoading ||
        _state.isLoadingMore ||
        !_state.hasMore) {
      return;
    }

    _setState(_state.copyWith(isLoadingMore: true));

    try {
      // Offset equals the rows already shown, so the next SQL page appends only
      // unseen transactions instead of reloading the full list.
      final nextPage = await _repository.getTransactionsPage(
        incomeSourceId: incomeSourceId,
        limit: pageSize,
        offset: _state.transactions.length,
      );

      if (_incomeSourceId != incomeSourceId) return;

      final loadedTransactions = [..._state.transactions, ...nextPage];
      _setState(
        _state.copyWith(
          transactions: loadedTransactions,
          totalCount: nextPage.isEmpty ? loadedTransactions.length : null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (_incomeSourceId != incomeSourceId) return;

      _setState(
        _state.copyWith(isLoadingMore: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> refreshTransactions(int incomeSourceId) {
    return loadInitialTransactions(incomeSourceId);
  }

  Stream<List<FinancialTransaction>> watchTransactions(int incomeSourceId) {
    return _repository.watchTransactions(incomeSourceId);
  }

  Future<double> getInSum(int incomeSourceId) {
    return _repository.getInSum(incomeSourceId);
  }

  Future<double> getOutSum(int incomeSourceId) {
    return _repository.getOutSum(incomeSourceId);
  }

  void _setState(IncomeSourceDetailState state) {
    _state = state;
    notifyListeners();
  }
}
