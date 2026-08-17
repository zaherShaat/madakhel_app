import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/trans_data.dart';
import 'package:madakhel_app/view/components/app_primary_button.dart';
import 'package:madakhel_app/view/components/trans_sheet_components.dart';
import 'package:madakhel_app/view_model/transaction_view_model.dart';
import 'package:provider/provider.dart';

class AddTransactionSheet extends StatefulWidget {
  final int incomeTypeId;
  final FinancialTransaction? initial;
  final Function(TransactionData)? onAdd;

  const AddTransactionSheet({
    super.key,
    required this.incomeTypeId,
    this.initial,
    this.onAdd,
  });

  bool get isEdit => initial != null;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionCategory? _selectedCategory;
  late DateTime _selectedDate;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _selectedDate = initial?.date ?? DateTime.now();
    if (initial != null) {
      _amountController.text = initial.amount.toString();
      _noteController.text = initial.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final controller = context.watch<TransactionViewModel>();
    final state = controller.state;
    return Builder(
      builder: (context) {
        final isLoading = state.isLoading;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: context.scaleW(16),
            right: context.scaleW(16),
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.scaleW(24)),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: context.scaleW(18),
                vertical: context.scaleH(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: context.scaleW(40),
                      height: context.scaleH(4),
                      decoration: BoxDecoration(
                        color: scheme.outline.withAlpha(100),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(18)),
                  Text(
                    widget.isEdit ? 'تعديل معاملة' : 'إضافة معاملة',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(height: context.scaleH(12)),
                  Visibility(
                    visible: !widget.isEdit,
                    child: Text(
                      'أضف تفاصيل المعاملة حتى تتمكن من تتبع الدخل والمصروفات بدقة.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(16)),
                  if (state.errorMessage != null) ...[
                    MessageBox(
                      message: state.errorMessage!,
                      color: scheme.error,
                      icon: Icons.error_outline,
                      onClose: controller.clearError,
                    ),
                    SizedBox(height: context.scaleH(14)),
                  ],
                  CategoryField(
                    selected: _selectedCategory,
                    initialCategoryId: widget.initial?.categoryId,
                    enabled: widget.isEdit ? false : !isLoading,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    isEdit: widget.isEdit,
                  ),
                  SizedBox(height: context.scaleH(14)),
                  AmountField(
                    controller: _amountController,
                    enabled: !isLoading,
                  ),
                  SizedBox(height: context.scaleH(14)),
                  DateField(
                    selectedDate: _selectedDate,
                    enabled: !isLoading,
                    onChanged: (date) => setState(() => _selectedDate = date),
                  ),
                  SizedBox(height: context.scaleH(14)),
                  NoteField(controller: _noteController, enabled: !isLoading),
                  SizedBox(height: context.scaleH(22)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.scaleW(16),
                              ),
                            ),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      SizedBox(width: context.scaleW(10)),
                      Expanded(
                        child: Visibility(
                          replacement: SizedBox(
                            height: context.scaleH(20),
                            width: context.scaleW(20),
                            child: LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                scheme.onPrimary,
                              ),
                              color: scheme.primary,
                            ),
                          ),
                          visible: !isLoading,
                          child: AppPrimaryButton(
                            onPressed: isLoading ? () {} : _handleSave,
                            label: widget.isEdit ? 'حفظ' : 'إضافة',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.scaleH(18)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    debugPrint(
      "${_selectedCategory == null && !widget.isEdit} > _selectedCategory == null && !widget.isEdit",
    );
    if (_selectedCategory == null && !widget.isEdit) {
      _showMessage('يرجى اختيار نوع المعاملة');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showMessage('يرجى إدخال مبلغ صحيح');
      return;
    }

    final note = _noteController.text.trim();
    final controller = context.read<TransactionViewModel>();
    if (widget.isEdit) {
      await controller.updateTransaction(
        id: widget.initial!.id,
        amount: amount,
        date: _selectedDate,
        categoryId: widget.initial!.categoryId,
        note: note.isEmpty ? null : note,
      );
    } else {
      await controller.createTransaction(
        incomeTypeId: widget.incomeTypeId,
        amount: amount,
        date: _selectedDate,
        categoryId: _selectedCategory!.id,
        note: note.isEmpty ? null : note,
      );
    }

    if (!mounted) return;
    if (controller.state.errorMessage == null) {
      widget.onAdd?.call(
        TransactionData(
          amount: amount,
          date: _selectedDate,
          categoryId: _selectedCategory!.id,
          note: note.isEmpty ? null : note,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
