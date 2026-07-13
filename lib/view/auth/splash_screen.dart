import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/view_model/splash_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndRoute());
  }

  Future<void> _loadAndRoute() async {
    bool? signedIn;

    if (mounted) {
      signedIn = await context.read<SplashViewModel>().load();
    }

    if (!mounted) return;
    context.go(signedIn! ? '/home' : '/start');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.scaleW(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.scaleW(80),
                  height: context.scaleW(80),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(context.scaleW(24)),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha:0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: scheme.onPrimary,
                    size: context.scaleW(38),
                  ),
                ),
                SizedBox(height: context.scaleH(26)),
                Text(
                  'مداخيل',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: context.scaleH(10)),
                Text(
                  'تحميل بياناتك وتأمين حسابك...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.scaleH(24)),
                CircularProgressIndicator(color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
