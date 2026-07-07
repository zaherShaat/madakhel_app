import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';

import '../components/app_action_link.dart';
import '../components/app_primary_button.dart';
import '../components/app_screen_header.dart';
import '../components/app_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(title: 'إنشاء حساب', onBack: () => context.pop()),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scaleW(18),
                      vertical: context.scaleH(18),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth > 520
                              ? 520
                              : constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.all(context.scaleW(22)),
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
                                    'ابدأ الآن',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: scheme.onBackground,
                                        ),
                                  ),
                                  SizedBox(height: context.scaleH(8)),
                                  Text(
                                    'أنشئ حسابك لتبدأ في إدارة مصادر الدخل وتتبع معاملاتك المالية بسهولة.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                              label: 'الاسم الكامل',
                              hintText: 'اسمك هنا',
                              controller: _nameController,
                            ),
                            SizedBox(height: context.scaleH(12)),
                            AppTextField(
                              label: 'البريد الإلكتروني',
                              hintText: 'you@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: context.scaleH(12)),
                            AppTextField(
                              maxLines: 1,
                              label: 'كلمة المرور',
                              hintText: '8 أحرف على الأقل',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onSuffixPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            SizedBox(height: context.scaleH(12)),
                            AppTextField(
                              maxLines: 1,
                              label: 'تأكيد كلمة المرور',
                              hintText: 'أعد كتابة كلمة المرور',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onSuffixPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            SizedBox(height: context.scaleH(20)),
                            AppPrimaryButton(
                              label: 'إنشاء الحساب',
                              onPressed: () => context.go('/start'),
                            ),
                            SizedBox(height: context.scaleH(18)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'لديك حساب؟',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                SizedBox(width: context.scaleW(8)),
                                AppActionLink(
                                  label: 'تسجيل الدخول',
                                  onPressed: () => context.push('/sign-in'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
