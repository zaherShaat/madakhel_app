import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';

class ForgotPasswordSentScreen extends StatelessWidget {
  final String email;

  const ForgotPasswordSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'طھط£ظƒظٹط¯ ط§ظ„ط¥ط±ط³ط§ظ„',
              leading: CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => context.pop(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.scaleW(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.scaleW(56),
                      height: context.scaleW(56),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: context.scaleW(24),
                        color: const Color(0xFF3B6D11),
                      ),
                    ),
                    SizedBox(height: context.scaleH(16)),
                    Text(
                      'طھط­ظ‚ظ‚ ظ…ظ† ط¨ط±ظٹط¯ظƒ',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: context.scaleH(8)),
                    Text(
                      'ط£ط±ط³ظ„ظ†ط§ ط±ط§ط¨ط· ط¥ط¹ط§ط¯ط© ط§ظ„طھط¹ظٹظٹظ† ط¥ظ„ظ‰\n$email',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.scaleH(24)),
                    ElevatedButton(
                      onPressed: () => context.go('/start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.onSurface,
                        minimumSize: Size(double.infinity, context.scaleH(44)),
                      ),
                      child: Text(
                        'ط§ظ„ط¹ظˆط¯ط© ظ„طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„',
                        style: TextStyle(
                          color: scheme.surface,
                          fontSize: context.scaleSp(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
