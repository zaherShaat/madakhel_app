import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';

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
              title: 'ط¥ط¹ط§ط¯ط© طھط¹ظٹظٹظ† ظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±',
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
                              'ط£ط¯ط®ظ„ ط¨ط±ظٹط¯ظƒ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ ظˆط³ظ†ط±ط³ظ„ ظ„ظƒ ط±ط§ط¨ط· ط¥ط¹ط§ط¯ط© ط§ظ„طھط¹ظٹظٹظ†.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: 1.7,
                                    color: scheme.onSurface.withValues(alpha: 0.8),
                                  ),
                            ),
                            SizedBox(height: context.scaleH(12)),
                            AppTextField(
                              label: 'ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ',
                              hintText: 'you@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: context.scaleH(16)),
                            AppPrimaryButton(
                              label: 'ط¥ط±ط³ط§ظ„ ط§ظ„ط±ط§ط¨ط·',
                              onPressed: () => context.go('/start'),
                            ),
                            SizedBox(height: context.scaleH(10)),
                            AppGhostButton(
                              label: 'ط§ظ„ط¹ظˆط¯ط© ظ„طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„',
                              onPressed: () => context.go('/start'),
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

