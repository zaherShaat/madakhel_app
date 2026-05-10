import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/context_ext.dart';
import '../components/app_ghost_button.dart';
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
                    // const Spacer(),
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
                      'تتبّع كل مصدر دخل بدقة،\nواعرف رصيدك في أي وقت.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.7,
                        color: scheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                    SizedBox(height: context.scaleH(12)),
                    AppPrimaryButton(
                      label: 'ابدأ الآن',
                      onPressed: () => context.push('/sign-up'),
                    ),
                    SizedBox(height: context.scaleH(12)),
                    AppGhostButton(
                      label: 'لديّ حساب بالفعل',
                      onPressed: () => context.push('/sign-in'),
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
        Icons.lock_outline_rounded,
        color: scheme.background,
        size: context.scaleW(36),
      ),
    );
  }
}
