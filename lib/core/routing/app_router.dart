import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/routing/app_transition.dart';
import 'package:madakhel_app/view/auth/forgot_password_screen.dart';
import 'package:madakhel_app/view/auth/signin_screen.dart';
import 'package:madakhel_app/view/auth/signup_screen.dart';
import 'package:madakhel_app/view/auth/start_page.dart';

import '../../model/income_source_with_balance.dart';
import '../../view/home/home_screen.dart';
import '../../view/income_source/source_detail_screen.dart';
import '../../view_controller/auth_controller.dart';

GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final signedIn = auth.isSignedIn;
      debugPrint("$signedIn >>,signed in");
      final isAuthRoute =
          state.matchedLocation == '/start' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up';

      if (!signedIn) {
        return isAuthRoute ? null : '/start';
      }

      if (isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/start',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          context: context,
          state: state,
          child: const StartPage(),
        ),
      ),
      GoRoute(
        path: '/sign-in',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const SignInScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/sign-up',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/source-detail',
        pageBuilder: (context, state) {
          // final sourceId = int.parse(state.pathParameters['sourceId']!);
          final extra = state.extra as IncomeSourceWithBalance;
          return AppTransitions.fadeScale(
            context: context,
            state: state,
            child: SourceDetailScreen(source: extra),
          );
        },
      ),
    ],
  );
}
