import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/db/tables.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view_controller/transaction_controller.dart';
import 'package:provider/provider.dart';

class TransactionData {
  final String templateName;
  final double amount;
  final DateTime date;
  final TransactionDirection direction;
  final String? note;

  TransactionData({
    required this.templateName,
    required this.amount,
    required this.date,
    required this.direction,
    this.note,
  });
}

class AddTransactionSheet extends StatefulWidget {
  final int incomeTypeId;
  final List<Transaction> templates;
  final Function(TransactionData)? onAdd;

  const AddTransactionSheet({
    super.key,
    required this.incomeTypeId,
    required this.templates,
    this.onAdd,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  late Transaction _selectedTemplate;
  late DateTime _selectedDate;
  late TransactionDirection _selectedDirection;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.templates.isNotEmpty) {
      _selectedTemplate = widget.templates.first;
      _selectedDirection = _selectedTemplate.direction;
    } else {
      _selectedDirection = TransactionDirection.inFlow;
    }
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
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
      templateName: widget.templates.isNotEmpty
          ? _selectedTemplate.name
          : 'معاملة جديدة',
      amount: amount,
      date: _selectedDate,
      direction: _selectedDirection,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    if (mounted) {
      final state = controller.state;
      if (state.isSuccess) {
        widget.onAdd?.call(
          TransactionData(
            templateName: widget.templates.isNotEmpty
                ? _selectedTemplate.name
                : 'معاملة جديدة',
            amount: amount,
            date: _selectedDate,
            direction: _selectedDirection,
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

                // Template Selector
                if (widget.templates.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'قالب المعاملة',
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
                        child: DropdownButton<Transaction>(
                          value: _selectedTemplate,
                          isExpanded: true,
                          underline: const SizedBox(),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scaleW(12),
                            vertical: context.scaleH(8),
                          ),
                          items: widget.templates
                              .map(
                                (template) => DropdownMenuItem(
                                  value: template,
                                  child: Text(template.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedTemplate = value;
                                _selectedDirection = value.direction;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: context.scaleH(12)),
                    ],
                  ),

                // Direction Selector (if no templates)
                if (widget.templates.isEmpty)
                  Column(
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
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () => _selectedDirection =
                                      TransactionDirection.inFlow,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.scaleH(10),
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedDirection ==
                                          TransactionDirection.inFlow
                                      ? Colors.green.withAlpha(30)
                                      : scheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    context.scaleW(8),
                                  ),
                                  border: Border.all(
                                    color:
                                        _selectedDirection ==
                                            TransactionDirection.inFlow
                                        ? Colors.green
                                        : scheme.outlineVariant,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'دخل',
                                    style: TextStyle(
                                      fontSize: context.scaleSp(12),
                                      color:
                                          _selectedDirection ==
                                              TransactionDirection.inFlow
                                          ? Colors.green
                                          : scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.scaleW(8)),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () => _selectedDirection =
                                      TransactionDirection.outFlow,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.scaleH(10),
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedDirection ==
                                          TransactionDirection.outFlow
                                      ? Colors.red.withAlpha(30)
                                      : scheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    context.scaleW(8),
                                  ),
                                  border: Border.all(
                                    color:
                                        _selectedDirection ==
                                            TransactionDirection.outFlow
                                        ? Colors.red
                                        : scheme.outlineVariant,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'مصروف',
                                    style: TextStyle(
                                      fontSize: context.scaleSp(12),
                                      color:
                                          _selectedDirection ==
                                              TransactionDirection.outFlow
                                          ? Colors.red
                                          : scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scaleH(12)),
                    ],
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
