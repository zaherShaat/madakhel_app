import 'dart:async';

import 'package:flutter/material.dart';
import 'package:madakhel_app/core/local_logger.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';

class TransactionState {
  final bool isLoading;
  final bool isSuccess;
  final String? successMessage;
  final String? errorMessage;

  const TransactionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.successMessage,
    this.errorMessage,
  });

  TransactionState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? successMessage,
    String? errorMessage,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  TransactionState _state = const TransactionState();

  TransactionViewModel(this._repository);

  TransactionState get state => _state;

  Future<void> createTransaction({
    required int incomeTypeId,
    required double amount,
    required DateTime date,
    required int categoryId,
    String? note,
  }) async {
    _setState(_state.copyWith(isLoading: true, isSuccess: false));

    try {
      await _repository.createTransaction(
        incomeSourceId: incomeTypeId,
        amount: amount,
        date: date,
        categoryId: categoryId,
        note: note,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تمت إضافة المعاملة بنجاح',
          errorMessage: null,
        ),
      );

      unawaited(
        LocalLogger.instance.logDb(
          'CREATE_TRANSACTION',
          'incomeType:$incomeTypeId amount:$amount category:$categoryId note:${note ?? ''}',
        ),
      );

      _setState(_state.copyWith(isSuccess: false, successMessage: null));
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'خطأ: ${e.toString()}',
        ),
      );
      unawaited(LocalLogger.instance.logDb('ERROR_CREATE', e.toString()));
    }
  }

  Future<void> updateTransaction({
    required int id,
    required double amount,
    required DateTime date,
    required int categoryId,
    String? note,
  }) async {
    _setState(_state.copyWith(isLoading: true, isSuccess: false));

    try {
      await _repository.updateTransaction(
        id: id,
        amount: amount,
        date: date,
        categoryId: categoryId,
        note: note,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تم تحديث المعاملة بنجاح',
          errorMessage: null,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      _setState(_state.copyWith(isSuccess: false, successMessage: null));
      unawaited(
        LocalLogger.instance.logDb(
          'UPDATE_TRANSACTION',
          'id:$id amount:$amount category:$categoryId',
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'خطأ: ${e.toString()}',
        ),
      );
      unawaited(LocalLogger.instance.logDb('ERROR_UPDATE', e.toString()));
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    _setState(_state.copyWith(isLoading: true));

    try {
      await _repository.deleteById(transactionId);
      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تم حذف المعاملة بنجاح',
        ),
      );

      unawaited(
        LocalLogger.instance.logDb('DELETE_TRANSACTION', 'id:$transactionId'),
      );

      await Future.delayed(const Duration(seconds: 1));
      _setState(_state.copyWith(isSuccess: false, successMessage: null));
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'خطأ في الحذف: ${e.toString()}',
        ),
      );
    }
  }

  void clearError() {
    _setState(_state.copyWith(errorMessage: null));
  }

  void _setState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }
}
