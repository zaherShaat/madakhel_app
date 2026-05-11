import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/view_controller/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../core/context_ext.dart';
import '../components/app_action_link.dart';
import '../components/app_screen_header.dart';
import '../components/app_text_field.dart';
import '../components/app_primary_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppScreenHeader(
                title: 'تسجيل الدخول',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scaleW(16),
                        vertical: context.scaleH(14),
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
                                validator: FieldsValidator.validateEmail,
                                label: 'البريد الإلكتروني',
                                hintText: 'you@email.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: context.scaleH(12)),
                              AppTextField(
                                validator: FieldsValidator.validatePassword,
                                label: 'كلمة المرور',
                                hintText: '••••••••',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                maxLines: 1,
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
                              SizedBox(height: context.scaleH(10)),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AppActionLink(
                                  label: 'نسيت كلمة المرور؟',
                                  onPressed: () =>
                                      context.go('/forgot-password'),
                                ),
                              ),
                              SizedBox(height: context.scaleH(16)),
                              Selector<AuthController, bool>(
                                selector: (_, controller) => controller.busy,
                                builder: (context, busy, _) {
                                  return AppPrimaryButton(
                                    label: busy
                                        ? 'جاري تسجيل الدخول...'
                                        : 'تسجيل الدخول عبر Google',
                                    outlinedStyle: true,
                                    leading: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: scheme.outline,
                                          width: 0.6,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                    ),
                                    onPressed: busy
                                        ? () {}
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              try {
                                                await context
                                                    .read<AuthController>()
                                                    .signInWithGoogle();
                                              } catch (error) {
                                                if (!context.mounted) return;
                                                debugPrint("$error < error>");
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'فشل تسجيل الدخول عبر Google',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                  );
                                },
                              ),
                              SizedBox(height: context.scaleH(16)),
                              const Divider(thickness: 0.5),
                              SizedBox(height: context.scaleH(16)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ليس لديك حساب؟',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                  ),
                                  SizedBox(width: context.scaleW(8)),
                                  AppActionLink(
                                    label: 'إنشاء حساب',
                                    onPressed: () => context.go('/sign-up'),
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
      ),
    );
  }
}
