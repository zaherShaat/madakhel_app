import 'package:flutter/material.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';

class TransactionState {
  final bool isLoading;
  final bool isSuccess;
  final String? successMessage;
  final String? errorMessage;
  // Confirmation state
  final bool showConfirmation;
  final Map<String, dynamic>? confirmationData;

  const TransactionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.successMessage,
    this.errorMessage,
    this.showConfirmation = false,
    this.confirmationData,
  });

  TransactionState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? successMessage,
    String? errorMessage,
    bool? showConfirmation,
    Map<String, dynamic>? confirmationData,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      showConfirmation: showConfirmation ?? this.showConfirmation,
      confirmationData: confirmationData ?? this.confirmationData,
    );
  }

  void reset() {}
}

class TransactionController extends ChangeNotifier {
  final TransactionRepository _repository;
  TransactionState _state = const TransactionState();

  TransactionController(this._repository);

  TransactionState get state => _state;

  Future<void> createTransaction({
    required int incomeTypeId,
    required String transactionName,
    required double amount,
    required DateTime date,
    required int categoryId,
    String? note,
    bool skipConfirmation = false,
  }) async {
    if (!skipConfirmation) {
      // Show confirmation dialog
      _setState(
        _state.copyWith(
          showConfirmation: true,
          confirmationData: {
            'type': 'create',
            'incomeTypeId': incomeTypeId,
            'transactionName': transactionName,
            'amount': amount,
            'date': date,
            'categoryId': categoryId,
            'note': note,
          },
        ),
      );
      return;
    }

    _setState(_state.copyWith(isLoading: true, isSuccess: false));

    try {
      await _repository.createTransaction(
        incomeSourceId: incomeTypeId,
        transactionName: transactionName,
        amount: amount,
        date: date,
        categoryId: categoryId,
        note: note,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تمت إضافة المعاملة: $transactionName بنجاح',
          errorMessage: null,
          showConfirmation: false,
          confirmationData: null,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      _setState(_state.copyWith(isSuccess: false, successMessage: null));
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'خطأ: ${e.toString()}',
          showConfirmation: false,
        ),
      );
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
