import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/context_ext.dart';
import '../components/app_ghost_button.dart';
import '../components/app_primary_button.dart';
import '../components/app_screen_header.dart';
import '../components/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'إعادة تعيين كلمة المرور',
              onBack: () => context.go('/start'),
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
                            Text(
                              'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: 1.7,
                                    color: scheme.onSurface.withValues(alpha: 0.8),
                                  ),
                            ),
                            SizedBox(height: context.scaleH(12)),
                            AppTextField(
                              label: 'البريد الإلكتروني',
                              hintText: 'you@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: context.scaleH(16)),
                            AppPrimaryButton(
                              label: 'إرسال الرابط',
                              // TODO: Implement forgot password logic
                              onPressed: () => context.go('/sign-in'),
                            ),
                            SizedBox(height: context.scaleH(10)),
                            AppGhostButton(
                              label: 'العودة لتسجيل الدخول',
                              onPressed: () => context.go('/sign-in'),
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

