// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/pdf/income_source_pdf_export_service.dart';
import 'package:madakhel_app/data/repositories/transaction_category_repository.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:provider/provider.dart';

class IncomeSourceDetailState {
  final List<FinancialTransaction> transactions;
  final int totalCount;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isExportingPdf;
  final String? errorMessage;
  final double inSum;
  final double outSum;
  IncomeSourceDetailState({
    this.transactions = const [],
    this.totalCount = 0,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.isExportingPdf = false,
    this.errorMessage,
    this.inSum = 0,
    this.outSum = 0,
  });
  //  {
  //   final inTx = transactions
  //       .where((tx) => tx.direction == TransactionDirection.inFlow)
  //       .toList();
  //   if (inTx.isNotEmpty) {
  //     for (var tx in inTx) {
  //       inSum += tx.amount;
  //     }
  //   }
  //   final outTx = transactions
  //       .where((tx) => tx.direction == TransactionDirection.inFlow)
  //       .toList();
  //   if (outTx.isNotEmpty) {
  //     for (var tx in outTx) {
  //       outSum += tx.amount;
  //     }
  //   }
  //   debugPrint("$outTx >>");
  // }

  bool get hasMore => transactions.length < totalCount;

  IncomeSourceDetailState copyWith({
    List<FinancialTransaction>? transactions,
    int? totalCount,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isExportingPdf,
    String? errorMessage,
    double? inSum,
    double? outSum,
  }) {
    return IncomeSourceDetailState(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isExportingPdf: isExportingPdf ?? this.isExportingPdf,
      errorMessage: errorMessage,
      inSum: inSum ?? this.inSum,
      outSum: outSum ?? this.outSum,
    );
  }
}

class IncomeSourceDetailViewModel extends ChangeNotifier {
  int initialPageSize = 5;
  int pageSize = 5;

  final TransactionRepository _repository;
  final TransactionCategoryRepository _categoryRepository;
  final IncomeSourcePdfExportService _pdfExportService;
  IncomeSourceDetailState _state = IncomeSourceDetailState();
  int? _incomeSourceId;

  double _sourceInSum = 0;

  double _sourceOutSum = 0;
  double get inSum => _sourceInSum;
  double get outSum => _sourceOutSum;

  IncomeSourceDetailViewModel(
    this._repository,
    this._categoryRepository,
    this._pdfExportService,
  );

  IncomeSourceDetailState get state => _state;

  Future<void> loadInitialTransactions(
    int incomeSourceId, {
    TransactionClassifier transactionClassifier = TransactionClassifier.allFlow,
  }) async {
    _incomeSourceId = incomeSourceId;
    _setState(IncomeSourceDetailState(isInitialLoading: true));

    try {
      final totalCount = await _repository.countTransactions(incomeSourceId);
      final transactions = await _repository.getTransactionsPage(
        incomeSourceId: incomeSourceId,
        limit: initialPageSize,
        offset: 0,
        transactionClassifier: transactionClassifier,
      );
      _sourceInSum = await _repository.getInSum(incomeSourceId);
      _sourceOutSum = await _repository.getOutSum(incomeSourceId);

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

  Future<void> loadMoreTransactions({
    TransactionClassifier transactionClassifier = TransactionClassifier.allFlow,
  }) async {
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
        transactionClassifier: transactionClassifier,
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

  Future<void> refreshTransactions(
    int incomeSourceId, {
    TransactionClassifier transactionClassifier = TransactionClassifier.allFlow,
  }) async {

    return await loadInitialTransactions(
      incomeSourceId,
      transactionClassifier: transactionClassifier,
    );
  }

  Stream<List<FinancialTransaction>> watchTransactions(int incomeSourceId) {
    return _repository.watchTransactions(incomeSourceId);
  }

  Future<double> getInSum(int incomeSourceId) async {
    final inSum = _repository.getInSum(incomeSourceId);
    _sourceInSum = await inSum;
    notifyListeners();

    return inSum;
  }

  Future<double> getOutSum(int incomeSourceId) async {
    final outSum = _repository.getOutSum(incomeSourceId);
    _sourceOutSum = await outSum;
    notifyListeners();
    return outSum;
  }

  Future<String> exportPdf(
    IncomeSourceWithBalance source, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_state.isExportingPdf) return '';

    _setState(_state.copyWith(isExportingPdf: true));
    try {
      final allTransactions = await _repository.getTransactions(source.id);
      final transactions = allTransactions.where((transaction) {
        final date = DateUtils.dateOnly(transaction.date);
        final startsOk =
            startDate == null || !date.isBefore(DateUtils.dateOnly(startDate));
        final endsOk =
            endDate == null || !date.isAfter(DateUtils.dateOnly(endDate));
        return startsOk && endsOk;
      }).toList();
      final categories = await _categoryRepository.getAll();
      final inSum = transactions
          .where(
            (transaction) =>
                transaction.direction == TransactionDirection.inFlow,
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
      final outSum = transactions
          .where(
            (transaction) =>
                transaction.direction == TransactionDirection.outFlow,
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
      final path = await _pdfExportService.saveIncomeSourceDetails(
        source: source,
        transactions: transactions,
        categories: categories,
        inSum: inSum,
        outSum: outSum,
        startDate: startDate,
        endDate: endDate,
      );
      _setState(_state.copyWith(isExportingPdf: false));
      return path;
    } catch (_) {
      _setState(_state.copyWith(isExportingPdf: false));
      rethrow;
    }
  }

  Future<void> openSavedPdf(String path) async =>
      await _pdfExportService.openSavedPdf(path);

  void _setState(IncomeSourceDetailState state) {
    _state = state;
    notifyListeners();
  }
}
