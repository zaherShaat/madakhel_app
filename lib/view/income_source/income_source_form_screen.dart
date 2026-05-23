import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:madakhel_app/core/utils.dart';
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
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: widget.isEdit ? 'تعديل مصدر الدخل' : 'مصدر دخل جديد',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.scaleW(16)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      SizedBox(height: context.scaleH(12)),
                      Text(
                        'العملة',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: context.scaleH(6)),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: const InputDecoration(),
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
                        SizedBox(height: context.scaleH(10)),
                        Text(
                          ctrl.state.errorMessage!,
                          style: TextStyle(color: scheme.error),
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
