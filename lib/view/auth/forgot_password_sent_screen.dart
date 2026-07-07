import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/view/components/app_primary_button.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';

class ForgotPasswordSentScreen extends StatelessWidget {
  final String email;

  const ForgotPasswordSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'تم إرسال الرابط',
              leading: CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => context.pop(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.scaleW(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.scaleW(64),
                      height: context.scaleW(64),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: context.scaleW(28),
                        color: scheme.primary,
                      ),
                    ),
                    SizedBox(height: context.scaleH(18)),
                    Text(
                      'تم إرسال الرابط بنجاح',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onBackground,
                          ),
                    ),
                    SizedBox(height: context.scaleH(10)),
                    Text(
                      'لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى $email',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                    ),
                    SizedBox(height: context.scaleH(24)),
                    AppPrimaryButton(
                      label: 'العودة لتسجيل الدخول',
                      onPressed: () => context.go('/sign-in'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
