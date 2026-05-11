import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/transaction_category_repository.dart';
import 'package:madakhel_app/view_controller/transaction_controller.dart';
import 'package:provider/provider.dart';

class TransactionData {
  final String templateName;
  final double amount;
  final DateTime date;
  final int categoryId;
  final String? note;

  TransactionData({
    required this.templateName,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  });
}

class AddTransactionSheet extends StatefulWidget {
  final int incomeTypeId;
  final Function(TransactionData)? onAdd;

  const AddTransactionSheet({
    super.key,
    required this.incomeTypeId,
    this.onAdd,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionCategory? _selectedCategory;
  late DateTime _selectedDate;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار نوع المعاملة')));
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال المبلغ')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')));
      return;
    }

    final controller = context.read<TransactionController>();
    await controller.createTransaction(
      incomeTypeId: widget.incomeTypeId,
      transactionName: _nameController.text,
      amount: amount,
      date: _selectedDate,
      categoryId: _selectedCategory!.id,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    if (mounted) {
      final state = controller.state;
      if (state.isSuccess) {
        widget.onAdd?.call(
          TransactionData(
            templateName: 'معاملة جديدة',
            amount: amount,
            date: _selectedDate,
            categoryId: _selectedCategory!.id,
            note: _noteController.text.isNotEmpty ? _noteController.text : null,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<TransactionController>(
      builder: (context, controller, _) {
        final state = controller.state;
        final isLoading = state.isLoading;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: context.scaleW(16),
            right: context.scaleW(16),
            top: context.scaleH(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'إضافة معاملة',
                  style: TextStyle(
                    fontSize: context.scaleSp(18),
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: context.scaleH(16)),

                // Error Message
                if (state.errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(context.scaleW(12)),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(context.scaleW(8)),
                      border: Border.all(
                        color: Colors.red.withAlpha(100),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: context.scaleW(20),
                        ),
                        SizedBox(width: context.scaleW(8)),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(
                              fontSize: context.scaleSp(12),
                              color: Colors.red,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.clearError,
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                            size: context.scaleW(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.errorMessage != null)
                  SizedBox(height: context.scaleH(12)),

                // Success Message
                if (state.isSuccess && state.successMessage != null)
                  Container(
                    padding: EdgeInsets.all(context.scaleW(12)),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(context.scaleW(8)),
                      border: Border.all(
                        color: Colors.green.withAlpha(100),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: context.scaleW(20),
                        ),
                        SizedBox(width: context.scaleW(8)),
                        Expanded(
                          child: Text(
                            state.successMessage!,
                            style: TextStyle(
                              fontSize: context.scaleSp(12),
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.isSuccess) SizedBox(height: context.scaleH(12)),

                // Category Selector
                FutureBuilder<List<TransactionCategory>>(
                  future: context
                      .read<TransactionCategoryRepository>()
                      .getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final categories = snapshot.data ?? [];
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              context.scaleW(8),
                            ),
                            border: Border.all(
                              color: scheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          child: DropdownButton<TransactionCategory>(
                            value: _selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.scaleW(12),
                              vertical: context.scaleH(8),
                            ),
                            hint: const Text('اختر نوع المعاملة'),
                            items: categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(height: context.scaleH(12)),
                      ],
                    );
                  },
                ),

                // Amount Input
                Column(
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
                      controller: _amountController,
                      enabled: !isLoading,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scaleW(8),
                          ),
                          borderSide: BorderSide(
                            color: scheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(12),
                          vertical: context.scaleH(12),
                        ),
                      ),
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(height: context.scaleH(12)),
                  ],
                ),

                // Date Picker
                Column(
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
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            context.scaleW(8),
                          ),
                          border: Border.all(
                            color: scheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(12),
                          vertical: context.scaleH(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: context.scaleW(20),
                              color: scheme.onSurfaceVariant,
                            ),
                            Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: context.scaleSp(14),
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.scaleH(12)),
                  ],
                ),

                // Note Field
                Column(
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
                      controller: _noteController,
                      enabled: !isLoading,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أضف ملاحظة...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scaleW(8),
                          ),
                          borderSide: BorderSide(
                            color: scheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(12),
                          vertical: context.scaleH(12),
                        ),
                      ),
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(height: context.scaleH(16)),
                  ],
                ),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: context.scaleSp(14),
                            color: isLoading
                                ? scheme.onSurfaceVariant.withAlpha(128)
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.scaleW(8)),
                    Expanded(
                      child: FilledButton(
                        onPressed: isLoading ? null : _handleAdd,
                        child: isLoading
                            ? SizedBox(
                                height: context.scaleH(20),
                                width: context.scaleW(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    scheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'إضافة',
                                style: TextStyle(
                                  fontSize: context.scaleSp(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scaleH(16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
