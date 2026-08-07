import 'package:flutter/material.dart';
import 'package:madakhel_app/core/actions_states.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/transaction_category_repository.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

class CategoryViewModel extends ChangeNotifier {
  final TransactionCategoryRepository _repository;
  ActionState _actionState = const ActionIdle();

  CategoryViewModel(this._repository) {
    getCategories();
  }
  final categories = <TransactionCategory>[];
  ActionState get actionState => _actionState;
  Stream<List<TransactionCategory>> watchCategories() {
    final catStream = _repository.watchAll();
    
    return catStream;
  }

  Future<List<TransactionCategory>> getCategories() async {
    final cats = await _repository.getAll();
    categories.addAll(cats);
    notifyListeners();
    return cats;
  }

  Future<TransactionCategory?> getCategoryById(int id) =>
      _repository.getById(id);

  Future<TransactionCategory?> saveCategory({
    int? id,
    required String name,
    required TransactionDirection direction,
  }) async {
    _setActionState(const ActionLoading());
    try {
      if (id == null) {
        final newId = await _repository.createCategory(
          name: name,
          direction: direction,
        );
        final category = await _repository.getById(newId);
        _setActionState(const ActionSuccess());
        return category;
      } else {
        await _repository.updateCategory(id: id, name: name);
        final category = await _repository.getById(id);
        _setActionState(const ActionSuccess());
        return category;
      }
    } catch (e) {
      _setActionState(ActionError(e.toString()));
      return null;
    }
  }

  Future<void> deleteCategory(int id) async {
    _setActionState(const ActionLoading());
    try {
      await _repository.deleteById(id);
      _setActionState(const ActionSuccess());
    } catch (e) {
      _setActionState(ActionError(e.toString()));
    }
  }

  void clearActionState() => _setActionState(const ActionIdle());

  void _setActionState(ActionState state) {
    _actionState = state;
    notifyListeners();
  }
}
