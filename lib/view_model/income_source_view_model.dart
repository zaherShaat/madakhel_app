import 'package:flutter/material.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/income_type_repository.dart';

class IncomeSourceState {
  final bool isLoading;
  final bool isSuccess;
  final String? successMessage;
  final String? errorMessage;

  const IncomeSourceState({
    this.isLoading = false,
    this.isSuccess = false,
    this.successMessage,
    this.errorMessage,
  });

  IncomeSourceState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? successMessage,
    String? errorMessage,
  }) {
    return IncomeSourceState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class IncomeSourceViewModel extends ChangeNotifier {
  final IncomeTypeRepository _repository;
  IncomeSourceState _state = const IncomeSourceState();

  IncomeSourceViewModel(this._repository);

  IncomeSourceState get state => _state;

  /// Create a new income source
  Future<int?> createIncomeSource({
    required String name,
    required String currency,
  }) async {
    _setState(_state.copyWith(isLoading: true, isSuccess: false));

    try {
      final id = await _repository.createIncomeType(
        name: name,
        currency: currency,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تمت إضافة مصدر الدخل بنجاح',
          errorMessage: null,
        ),
      );

      _setState(_state.copyWith(isSuccess: false, successMessage: null));
      return id;
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'خطأ: ${e.toString()}',
        ),
      );
      clearError();
      return null;
    }
  }

  /// Update income source name
  Future<void> updateIncomeSource({
    required int id,
    required String name,
    required String currency,
  }) async {
    _setState(_state.copyWith(isLoading: true));

    try {
      await _repository.updateIncomeType(
        id: id,
        name: name,
        currency: currency,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تم تحديث مصدر الدخل بنجاح',
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      _setState(_state.copyWith(isSuccess: false, successMessage: null));
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'خطأ في التحديث: ${e.toString()}',
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      clearError();
    }
  }

  /// Delete income source
  Future<void> deleteIncomeSource(int id) async {
    _setState(_state.copyWith(isLoading: true));

    try {
      await _repository.deleteById(id);
      _setState(
        _state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'تم حذف مصدر الدخل بنجاح',
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
      await Future.delayed(const Duration(seconds: 1));
      clearError();
    }
  }

  /// Get single income source by ID
  Future<IncomeSource?> getIncomeSourceById(int id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      _setState(_state.copyWith(errorMessage: 'خطأ: ${e.toString()}'));
      await Future.delayed(const Duration(seconds: 1));
      clearError();
      return null;
    }
  }

  /// Get all income sources
  Future<List<IncomeSource>> getAllIncomeSources() async {
    try {
      return await _repository.getAll();
    } catch (e) {
      _setState(_state.copyWith(errorMessage: 'خطأ: ${e.toString()}'));
      await Future.delayed(const Duration(seconds: 1));
      clearError();
      return [];
    }
  }

  void clearError() {
    _setState(_state.copyWith(errorMessage: null));
  }

  void _setState(IncomeSourceState newState) {
    _state = newState;
    notifyListeners();
  }
}
