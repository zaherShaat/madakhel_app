import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

import '../components/app_primary_button.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.scaleW(24),
                vertical: context.scaleH(32),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - context.scaleH(64),
                  maxWidth: constraints.maxWidth > 480
                      ? 420
                      : constraints.maxWidth,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _AppLogoCard(),
                    SizedBox(height: context.scaleH(24)),
                    Text(
                      'مداخيل',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onBackground,
                          ),
                    ),
                    SizedBox(height: context.scaleH(8)),
                    Text(
                      'تتبع كل مصدر دخل بدقة،\nواعرف رصيدك في أي وقت.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.7,
                        color: scheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                    SizedBox(height: context.scaleH(24)),
                    Selector<AuthViewModel, bool>(
                      selector: (_, viewModel) => viewModel.busy,
                      builder: (context, busy, _) => AppPrimaryButton(
                        label: busy
                            ? 'جاري تسجيل الدخول...'
                            : 'المتابعة مع Google',
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
                            ? null
                            : () async {
                                try {
                                  await context
                                      .read<AuthViewModel>()
                                      .signInWithGoogle();
                                  if (!context.mounted) return;
                                  context.go('/home');
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'فشل تسجيل الدخول عبر Google',
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppLogoCard extends StatelessWidget {
  const _AppLogoCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: context.scaleW(72),
      height: context.scaleW(72),
      decoration: BoxDecoration(
        color: scheme.onBackground,
        borderRadius: BorderRadius.circular(context.scaleW(20)),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.account_balance_wallet_outlined,
        color: scheme.background,
        size: context.scaleW(36),
      ),
    );
  }
}
