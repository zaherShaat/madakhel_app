import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/routing/app_transition.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/view/auth/splash_screen.dart';
import 'package:madakhel_app/view/auth/start_page.dart';
import 'package:madakhel_app/view/settings/settings_screen.dart';
import 'package:madakhel_app/view/transactions/add_category_screen.dart';
import 'package:madakhel_app/view/transactions/categories_screen.dart';
import 'package:madakhel_app/view/transactions/transactions_screen.dart';

import '../../model/income_source_with_balance.dart';
import '../../view/home/home_screen.dart';
import '../../view/income_source/income_source_form_screen.dart';
import '../../view/income_source/source_detail_screen.dart';
import '../../view_model/auth_view_model.dart';

GoRouter createAppRouter(AuthViewModel auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, GoRouterState state) {
      if (!auth.ready || state.matchedLocation == '/splash') return null;

      final signedIn = auth.isSignedIn;
      final isAuthRoute = state.matchedLocation == '/start';

      if (!signedIn && !isAuthRoute) return '/start';
      if (signedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/start',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const StartPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/source-detail',
        pageBuilder: (context, state) {
          final extra = state.extra as IncomeSourceWithBalance;
          return AppTransitions.slideVertical(
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
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: const TransactionsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => AppTransitions.slideHorizontal(
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
        pageBuilder: (context, state) => AppTransitions.slideVertical(
          context: context,
          state: state,
          child: AddCategoryScreen(
            initial: state.extra is TransactionCategory
                ? state.extra as TransactionCategory
                : null,
          ),
        ),
      ),
    ],
  );
}
