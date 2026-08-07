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
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.scaleW(22)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.scaleW(18),
            vertical: context.scaleH(18),
          ),
          child: Form(
            key: _formKey,
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
                SizedBox(height: context.scaleH(14)),
                Text(
                  widget.isEdit ? 'تعديل الفئة' : 'فئة جديدة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.scaleH(10)),
                Text(
                  'حدد اسم الفئة واتجاهها لتصنيف المعاملات بشكل واضح.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: context.scaleH(20)),
                Text(
                  'الاسم',
                  style: TextStyle(
                    fontSize: context.scaleSp(12),
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.scaleH(6)),
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
                    fillColor: scheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.scaleW(16)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(16)),
                Text(
                  'الاتجاه',
                  style: TextStyle(
                    fontSize: context.scaleSp(12),
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.scaleH(8)),
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        selected:
                            _selectedDirection == TransactionDirection.inFlow,
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
                        selectedColor: scheme.primaryContainer,
                        side: BorderSide.none,
                      ),
                    ),
                    SizedBox(width: context.scaleW(10)),
                    Expanded(
                      child: FilterChip(
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
                        selectedColor: scheme.errorContainer,
                        side: BorderSide.none,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scaleH(16)),
                Container(
                  padding: EdgeInsets.all(context.scaleW(14)),
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(context.scaleW(14)),
                  ),
                  child: Text(
                    'لا يمكن تغيير الاتجاه بعد الحفظ لأن حسابات المعاملات تعتمد عليه.',
                    style: TextStyle(
                      fontSize: context.scaleSp(12),
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: context.scaleH(24)),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scaleW(16)),
                    ),
                  ),
                  child: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ الفئة'),
                ),
                SizedBox(height: context.scaleH(10)),
                OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scaleW(16)),
                    ),
                  ),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
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

    final category = await viewModel.saveCategory(
      id: widget.initial?.id,
      name: name,
      direction: _selectedDirection,
    );

    if (!mounted) return;
    if (viewModel.actionState is! ActionError) {
      context.pop(category);
      return;
    }

    final error = viewModel.actionState as ActionError;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('فشل حفظ الفئة: ${error.message}')));
    setState(() => _isSaving = false);
  }
}
