// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/pdf/income_source_pdf_export_service.dart';
import 'package:madakhel_app/data/repositories/transaction_category_repository.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:provider/provider.dart';

class IncomeSourceDetailState {
  final List<FinancialTransaction> transactions;
  final int totalCount;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isExportingPdf;
  final String? errorMessage;

  const IncomeSourceDetailState({
    this.transactions = const [],
    this.totalCount = 0,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.isExportingPdf = false,
    this.errorMessage,
  });

  bool get hasMore => transactions.length < totalCount;

  IncomeSourceDetailState copyWith({
    List<FinancialTransaction>? transactions,
    int? totalCount,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isExportingPdf,
    String? errorMessage,
  }) {
    return IncomeSourceDetailState(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isExportingPdf: isExportingPdf ?? this.isExportingPdf,
      errorMessage: errorMessage,
    );
  }
}

class IncomeSourceDetailViewModel extends ChangeNotifier {
  int initialPageSize = 5;
  int pageSize = 5;

  final TransactionRepository _repository;
  final TransactionCategoryRepository _categoryRepository;
  final IncomeSourcePdfExportService _pdfExportService;
  IncomeSourceDetailState _state = const IncomeSourceDetailState();
  int? _incomeSourceId;

  IncomeSourceDetailViewModel(
    this._repository,
    this._categoryRepository,
    this._pdfExportService,
  );

  IncomeSourceDetailState get state => _state;

  Future<void> loadInitialTransactions(
    int incomeSourceId, {
    TransactionClassifier transactionClassifier =
        TransactionClassifier.allFlow,
  }) async {
    _incomeSourceId = incomeSourceId;
    _setState(const IncomeSourceDetailState(isInitialLoading: true));

    try {
      final totalCount = await _repository.countTransactions(incomeSourceId);
      final transactions = await _repository.getTransactionsPage(
        incomeSourceId: incomeSourceId,
        limit: initialPageSize,
        offset: 0,
        transactionClassifier: transactionClassifier,
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

  Future<void> loadMoreTransactions( {
    TransactionClassifier transactionClassifier =
        TransactionClassifier.allFlow,
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

  Future<void> refreshTransactions(int incomeSourceId, {
    TransactionClassifier transactionClassifier =
        TransactionClassifier.allFlow,
  }) {
    return loadInitialTransactions(incomeSourceId,transactionClassifier: transactionClassifier);
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

  Future<String> exportPdf(IncomeSourceWithBalance source) async {
    if (_state.isExportingPdf) return '';

    _setState(_state.copyWith(isExportingPdf: true));
    try {
      final transactions = await _repository.getTransactions(source.id);
      final categories = await _categoryRepository.getAll();
      final inSum = await _repository.getInSum(source.id);
      final outSum = await _repository.getOutSum(source.id);
      final path = await _pdfExportService.saveIncomeSourceDetails(
        source: source,
        transactions: transactions,
        categories: categories,
        inSum: inSum,
        outSum: outSum,
      );
      _setState(_state.copyWith(isExportingPdf: false));
      debugPrint("$path NNNN");
      return path;
    } catch (_) {
      _setState(_state.copyWith(isExportingPdf: false));
      rethrow;
    }
  }

  // Future<bool> openDoc(String path) async {
  //   try {
  //     await _pdfExportService.readFile(path: path);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  void _setState(IncomeSourceDetailState state) {
    _state = state;
    notifyListeners();
  }
}
