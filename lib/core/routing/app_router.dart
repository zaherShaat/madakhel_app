import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/routing/app_transition.dart';
import 'package:madakhel_app/view/auth/forgot_password_screen.dart';
import 'package:madakhel_app/view/auth/forgot_password_sent_screen.dart';
import 'package:madakhel_app/view/auth/signin_screen.dart';
import 'package:madakhel_app/view/auth/signup_screen.dart';
import 'package:madakhel_app/view/auth/start_page.dart';
import 'package:madakhel_app/view/settings/settings_screen.dart';
import 'package:madakhel_app/view/transactions/add_category_screen.dart';
import 'package:madakhel_app/view/transactions/categories_screen.dart';
import 'package:madakhel_app/view/transactions/transactions_screen.dart';

import '../../model/income_source_with_balance.dart';
import '../../view/home/home_screen.dart';
import '../../view/income_source/income_source_form_screen.dart';
import '../../view/income_source/source_detail_screen.dart';
import '../../view_controller/auth_controller.dart';

GoRouter createAppRouter(AuthController auth) {
  String? lastSignedInState;

  return GoRouter(
    initialLocation: '/start',
    refreshListenable: auth,
    redirect: (context, GoRouterState state) {
      if (!auth.ready) {
        return null;
      }

      final signedIn = auth.isSignedIn;
      final signedInStr = signedIn.toString();

      // Skip if state hasn't changed
      if (lastSignedInState == signedInStr) {
        return null;
      }

      lastSignedInState = signedInStr;

      final isAuthRoute =
          state.matchedLocation == '/start' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/forgot-sent' ||
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
        path: '/forgot-sent',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: ForgotPasswordSentScreen(
            email: state.uri.queryParameters['email'] ?? 'your@email.com',
          ),
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
          final extra = state.extra as IncomeSourceWithBalance;
          return AppTransitions.fadeScale(
            context: context,
            state: state,
            child: SourceDetailScreen(source: extra),
          );
        },
      ),
      GoRoute(
        path: '/income-source/new',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const IncomeSourceFormScreen(),
        ),
      ),
      GoRoute(
        path: '/income-source/edit',
        pageBuilder: (context, state) {
          final extra = state.extra as IncomeSourceWithBalance;
          return AppTransitions.slideVertical(
            context: context,
            state: state,
            child: IncomeSourceFormScreen(initial: extra),
          );
        },
      ),
      GoRoute(
        path: '/transactions',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          context: context,
          state: state,
          child: const TransactionsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const CategoriesScreen(),
        ),
      ),
      GoRoute(
        path: '/add-category',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          context: context,
          state: state,
          child: const AddCategoryScreen(),
        ),
      ),
    ],
  );
}
