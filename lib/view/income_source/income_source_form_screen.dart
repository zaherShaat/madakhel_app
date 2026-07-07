import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:provider/provider.dart';

import '../../model/income_source_with_balance.dart';
import '../../view_model/income_source_view_model.dart';
import '../components/app_primary_button.dart';
import '../components/app_screen_header.dart';
import '../components/app_text_field.dart';

class IncomeSourceFormScreen extends StatefulWidget {
  final IncomeSourceWithBalance? initial;

  const IncomeSourceFormScreen({super.key, this.initial});

  bool get isEdit => initial != null;

  @override
  State<IncomeSourceFormScreen> createState() => _IncomeSourceFormScreenState();
}

class _IncomeSourceFormScreenState extends State<IncomeSourceFormScreen> {
  final _nameController = TextEditingController();
  String _currency = 'USD';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final source = widget.initial;
    if (source != null) {
      _nameController.text = source.name;
      _currency = source.currency.replaceAll(RegExp(r'[^A-Z]'), '').trim();
      if (_currency.isEmpty) _currency = 'USD';
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
    final ctrl = context.watch<IncomeSourceViewModel>();
    const List<String> currencies = ['USD', 'ILS', 'EGP', 'EUR', 'SAR'];

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: widget.isEdit ? 'تعديل مصدر الدخل' : 'مصدر دخل جديد',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaleW(18),
                  vertical: context.scaleH(18),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.scaleW(20)),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              widget.isEdit
                                  ? 'حرر تفاصيل مصدر الدخل'
                                  : 'أضف مصدر دخل جديد',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onBackground,
                                  ),
                            ),
                            SizedBox(height: context.scaleH(8)),
                            Text(
                              'اختر اسمًا يوضح مصدر الدخل ثم قم باختيار العملة المناسبة.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.scaleH(22)),
                      AppTextField(
                        label: 'الاسم',
                        hintText: 'مثال: مقهى الإنترنت',
                        controller: _nameController,
                        validator: (p0) {
                          if (p0 == null || p0.trim().isEmpty) {
                            return 'يرجى إدخال اسم مصدر الدخل';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: context.scaleH(14)),
                      Text(
                        'العملة',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.scaleH(8)),
                      DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: scheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: scheme.outline.withOpacity(0.35),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 1.7,
                            ),
                          ),
                        ),
                        items: currencies
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _currency = v);
                        },
                      ),
                      SizedBox(height: context.scaleH(20)),
                      AppPrimaryButton(
                        label: ctrl.state.isLoading
                            ? 'جاري الحفظ...'
                            : (widget.isEdit
                                  ? 'حفظ التعديلات'
                                  : 'حفظ مصدر الدخل'),
                        onPressed: ctrl.state.isLoading ? null : _submit,
                      ),
                      if (ctrl.state.errorMessage != null) ...[
                        SizedBox(height: context.scaleH(12)),
                        Text(
                          ctrl.state.errorMessage!,
                          style: TextStyle(
                            color: scheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final ctrl = context.read<IncomeSourceViewModel>();
      if (widget.isEdit) {
        await ctrl.updateIncomeSource(
          id: widget.initial!.id,
          name: name,
          currency: _currency,
        );
      } else {
        await ctrl.createIncomeSource(name: name, currency: _currency);
      }

      if (!mounted) return;
      if (ctrl.state.errorMessage == null) {
        context.pop();
      } else {
        // Show error as snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ctrl.state.errorMessage!)));
      }
    }
  }
}
