import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madakhel_app/core/theme/app_theme.dart';
import 'package:madakhel_app/data/backup/backup_service.dart';
import 'package:madakhel_app/data/connectivity/connectivity_service.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/income_type_repository.dart';
import 'package:madakhel_app/data/repositories/transaction_category_repository.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';
import 'package:madakhel_app/firebase_options.dart';
import 'package:madakhel_app/model/auth_user.dart';
import 'package:madakhel_app/view_model/connectivity_view_model.dart';
import 'package:madakhel_app/view_model/theme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';
import 'data/auth/auth_service.dart';
import 'view_model/auth_view_model.dart';
import 'view_model/backup_view_model.dart';
import 'view_model/category_view_model.dart';
import 'view_model/home_view_model.dart';
import 'view_model/income_source_detail_view_model.dart';
import 'view_model/income_source_view_model.dart';
import 'view_model/splash_view_model.dart';
import 'view_model/transaction_view_model.dart';
import 'view_model/transactions_view_model.dart';

const _supabaseUrl = 'https://ckztchatsttfgndwhjbw.supabase.co';
const _supabasePublishableKey =
    'sb_publishable_XYParoDszXKgy85akbTnfQ_MMreCuwp';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );
  await GoogleSignIn.instance.initialize(
    clientId:
        '997046209271-jh0ll4tm1m94s597tc9esuh7pnalbpet.apps.googleusercontent.com',
  );
  final authService = AuthService();
  final db = AppDatabase();
  final connectivityService = ConnectivityService();
  runApp(
    MultiProvider(
      providers: [
        // Provider<AuthService>(create: (ctx) => AuthService()),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) => AuthViewModel(authService),
        ),
        ProxyProvider<AuthViewModel, AuthUser?>(
          update: (ctx, authViewModel, authUser) => authViewModel.user,
        ),
        Provider<AppDatabase>.value(value: db),
        Provider<ConnectivityService>.value(value: connectivityService),
        ChangeNotifierProvider<ConnectivityViewModel>(
          create: (ctx) =>
              ConnectivityViewModel(ctx.read<ConnectivityService>()),
        ),
        Provider<BackupService>(
          create: (ctx) =>
              BackupService(ctx.read<AppDatabase>(), ctx.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              // ignore: prefer_const_constructors
              BackupViewModel(
                ctx.read<BackupService>(),
                ctx.read<AppDatabase>(),
                ctx.read<ConnectivityViewModel>(),
              ),
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (ctx) => ThemeViewModel()..loadThemeMode(),
        ),
        // Repositories
        Provider<IncomeTypeRepository>(
          create: (ctx) =>
              IncomeTypeRepository(db, () => authService.currentAuthUser?.uid),
        ),
        Provider<TransactionRepository>(
          create: (ctx) =>
              TransactionRepository(db, () => authService.currentAuthUser?.uid),
        ),
        Provider<TransactionCategoryRepository>(
          create: (ctx) => TransactionCategoryRepository(
            db,
            () => authService.currentAuthUser?.uid,
          ),
        ),
        // ViewModels
        ChangeNotifierProvider<TransactionViewModel>(
          create: (ctx) =>
              TransactionViewModel(ctx.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider<TransactionsViewModel>(
          create: (ctx) =>
              TransactionsViewModel(ctx.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider<CategoryViewModel>(
          create: (ctx) =>
              CategoryViewModel(ctx.read<TransactionCategoryRepository>()),
        ),
        ChangeNotifierProvider<IncomeSourceViewModel>(
          create: (ctx) =>
              IncomeSourceViewModel(ctx.read<IncomeTypeRepository>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (ctx) => HomeViewModel(ctx.read<IncomeTypeRepository>()),
        ),
        ChangeNotifierProvider<IncomeSourceDetailViewModel>(
          create: (ctx) =>
              IncomeSourceDetailViewModel(ctx.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider<SplashViewModel>(
          create: (ctx) => SplashViewModel(
            ctx.read<AuthViewModel>(),
            ctx.read<IncomeTypeRepository>(),
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final auth = context.read<AuthViewModel>();
        final themeViewModel = context.watch<ThemeViewModel>();
        final router = createAppRouter(auth);
        return MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeViewModel.mode,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
