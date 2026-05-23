import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/actions_states.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view_model/category_view_model.dart';
import 'package:provider/provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final TransactionCategory? initial;

  const AddCategoryScreen({super.key, this.initial});

  bool get isEdit => initial != null;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TransactionDirection _selectedDirection = TransactionDirection.inFlow;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final category = widget.initial;
    if (category != null) {
      _nameController.text = category.name;
      _selectedDirection = category.direction;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: context.scaleW(16),
          right: context.scaleW(16),
          bottom: MediaQuery.of(context).viewInsets.bottom + context.scaleH(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.scaleH(10)),
              Center(
                child: Container(
                  width: context.scaleW(36),
                  height: context.scaleH(4),
                  decoration: BoxDecoration(
                    color: scheme.outline.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.scaleH(14)),
              Text(
                widget.isEdit ? 'تعديل الفئة' : 'فئة جديدة',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: context.scaleH(16)),
              Text(
                'الاسم',
                style: TextStyle(
                  fontSize: context.scaleSp(11),
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.scaleH(4)),
              TextFormField(
                controller: _nameController,
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم الفئة';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'مثال: مشتريات',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                ),
              ),
              SizedBox(height: context.scaleH(12)),
              Text(
                'الاتجاه',
                style: TextStyle(
                  fontSize: context.scaleSp(11),
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.scaleH(6)),
              Row(
                children: [
                  FilterChip(
                    selected: _selectedDirection == TransactionDirection.inFlow,
                    onSelected: widget.isEdit || _isSaving
                        ? null
                        : (_) => setState(
                              () => _selectedDirection =
                                  TransactionDirection.inFlow,
                            ),
                    label: Text(
                      '+ دخل',
                      style: TextStyle(fontSize: context.scaleSp(12)),
                    ),
                  ),
                  SizedBox(width: context.scaleW(6)),
                  FilterChip(
                    selected:
                        _selectedDirection == TransactionDirection.outFlow,
                    onSelected: widget.isEdit || _isSaving
                        ? null
                        : (_) => setState(
                              () => _selectedDirection =
                                  TransactionDirection.outFlow,
                            ),
                    label: Text(
                      '- مصروف',
                      style: TextStyle(fontSize: context.scaleSp(12)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.scaleH(12)),
              Container(
                padding: EdgeInsets.all(context.scaleW(12)),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(
                    color: scheme.outline.withAlpha(40),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(context.scaleW(8)),
                ),
                child: Text(
                  'لا يمكن تغيير الاتجاه بعد الحفظ لأن حسابات المعاملات تعتمد عليه.',
                  style: TextStyle(
                    fontSize: context.scaleSp(11),
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: context.scaleH(16)),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ الفئة'),
              ),
              SizedBox(height: context.scaleH(8)),
              OutlinedButton(
                onPressed: _isSaving ? null : () => context.pop(),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final viewModel = context.read<CategoryViewModel>();
    final name = _nameController.text.trim();

    await viewModel.saveCategory(
      id: widget.initial?.id,
      name: name,
      direction: _selectedDirection,
    );

    if (!mounted) return;
    if (viewModel.actionState is! ActionError) {
      context.pop();
      return;
    }

    final error = viewModel.actionState as ActionError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل حفظ الفئة: ${error.message}')),
    );
    setState(() => _isSaving = false);
  }
}
