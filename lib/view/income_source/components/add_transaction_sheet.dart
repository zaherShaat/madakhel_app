import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';
import 'package:madakhel_app/view/transactions/add_category_screen.dart';
import 'package:madakhel_app/view_model/category_view_model.dart';
import 'package:madakhel_app/view_model/transaction_view_model.dart';
import 'package:provider/provider.dart';

class TransactionData {
  final double amount;
  final DateTime date;
  final int categoryId;
  final String? note;

  TransactionData({
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  });
}

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

    return Consumer<TransactionViewModel>(
      builder: (context, controller, _) {
        final state = controller.state;
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
                  Text(
                    'أضف تفاصيل المعاملة حتى تتمكن من تتبع الدخل والمصروفات بدقة.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: context.scaleH(16)),
                  if (state.errorMessage != null) ...[
                    _MessageBox(
                      message: state.errorMessage!,
                      color: scheme.error,
                      icon: Icons.error_outline,
                      onClose: controller.clearError,
                    ),
                    SizedBox(height: context.scaleH(14)),
                  ],
                  _CategoryField(
                    selected: _selectedCategory,
                    initialCategoryId: widget.initial?.categoryId,
                    enabled: widget.isEdit ? false : !isLoading,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    isEdit: widget.isEdit,
                  ),
                  SizedBox(height: context.scaleH(14)),
                  _AmountField(
                    controller: _amountController,
                    enabled: !isLoading,
                  ),
                  SizedBox(height: context.scaleH(14)),
                  _DateField(
                    selectedDate: _selectedDate,
                    enabled: !isLoading,
                    onChanged: (date) => setState(() => _selectedDate = date),
                  ),
                  SizedBox(height: context.scaleH(14)),
                  _NoteField(controller: _noteController, enabled: !isLoading),
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
                              // strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                scheme.onPrimary,
                              ),
                              color: scheme.primary,
                            ),
                          ),
                          visible: !isLoading,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.scaleW(16),
                                ),
                              ),
                            ),
                            child: Text(widget.isEdit ? 'حفظ' : 'إضافة'),
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
    if (_selectedCategory == null) {
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
        categoryId: _selectedCategory!.id,
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

class _CategoryField extends StatelessWidget {
  final TransactionCategory? selected;
  final int? initialCategoryId;
  final bool enabled;
  final ValueChanged<TransactionCategory?> onChanged;
  final bool isEdit;
  const _CategoryField({
    required this.selected,
    required this.initialCategoryId,
    required this.enabled,
    required this.onChanged,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<TransactionCategory>>(
      future: context.read<CategoryViewModel>().getCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        var value = selected;

        if (value == null && initialCategoryId != null) {
          for (final category in categories) {
            if (category.id == initialCategoryId) {
              value = category;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) onChanged(category);
              });
              break;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نوع المعاملة',
              style: TextStyle(
                fontSize: context.scaleSp(12),
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: context.scaleH(8)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<TransactionCategory>(
                    initialValue: value,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    hint: const Text('اختر نوع المعاملة'),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
                isEdit ? Container() : SizedBox(width: context.scaleW(8)),
                isEdit
                    ? Container()
                    : SizedBox(
                        width: context.scaleW(40),
                        height: context.scaleH(40),
                        child: CircleIconButton(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(context.scaleW(16)),
                                ),
                              ),
                              builder: (_) => AddCategoryScreen(),
                            );
                          },
                          icon: Icons.add,
                        ),
                      ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _AmountField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المبلغ',
          style: TextStyle(
            fontSize: context.scaleSp(12),
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '0.00'),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime selectedDate;
  final bool enabled;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.selectedDate,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: TextStyle(
            fontSize: context.scaleSp(12),
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        InkWell(
          onTap: !enabled
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onChanged(picked);
                },
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: context.scaleW(18),
                  color: scheme.onSurfaceVariant,
                ),
                Text(label),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _NoteField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات (اختياري)',
          style: TextStyle(
            fontSize: context.scaleSp(12),
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.scaleH(8)),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'أضف ملاحظة...'),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;

  const _MessageBox({
    required this.message,
    required this.color,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaleW(12)),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(context.scaleW(8)),
        border: Border.all(color: color.withAlpha(100), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: context.scaleW(20)),
          SizedBox(width: context.scaleW(8)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: context.scaleSp(12), color: color),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: color, size: context.scaleW(16)),
          ),
        ],
      ),
    );
  }
}
