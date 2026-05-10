import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            AppScreenHeader(
              title: 'إنشاء حساب',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth > 480
                              ? 420
                              : constraints.maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: 'الاسم الكامل',
                              hintText: 'اسمك هنا',
                              controller: _nameController,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'البريد الإلكتروني',
                              hintText: 'you@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
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
                            const SizedBox(height: 12),
                            AppTextField(
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
                            const SizedBox(height: 16),
                            AppPrimaryButton(
                              label: 'إنشاء الحساب',
                              onPressed: () => context.go('/start'),
                            ),
                            const SizedBox(height: 16),
                            const Divider(thickness: 0.5),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'لديك حساب؟',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurface.withOpacity(0.8),
                                      ),
                                ),
                                const SizedBox(width: 8),
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

