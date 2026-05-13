import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madakhel_app/core/theme/app_theme.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/income_type_repository.dart';
import 'package:madakhel_app/data/repositories/transaction_category_repository.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';
import 'package:madakhel_app/firebase_options.dart';
import 'package:madakhel_app/model/auth_user.dart';
import 'package:madakhel_app/view_controller/theme_provider.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'data/auth/auth_service.dart';
import 'view_controller/auth_controller.dart';
import 'view_controller/income_source_controller.dart';
import 'view_controller/transaction_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize(
    clientId:
        '997046209271-jh0ll4tm1m94s597tc9esuh7pnalbpet.apps.googleusercontent.com',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = AppDatabase();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(ctx.read<AuthService>()),
        ),
        ProxyProvider<AuthController, AuthUser?>(
          update: (_, authController, __) => authController.user,
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (ctx) => ThemeProvider()),
        // Repositories
        Provider<IncomeTypeRepository>(create: (_) => IncomeTypeRepository(db)),
        Provider<TransactionRepository>(
          create: (_) => TransactionRepository(db),
        ),
        Provider<TransactionCategoryRepository>(
          create: (_) => TransactionCategoryRepository(db),
        ),
        // Controllers
        ChangeNotifierProvider<TransactionController>(
          create: (ctx) =>
              TransactionController(ctx.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider<IncomeSourceController>(
          create: (ctx) =>
              IncomeSourceController(ctx.read<IncomeTypeRepository>()),
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
        final auth = context.read<AuthController>();
        final themeProvider = context.watch<ThemeProvider>();
        final router = createAppRouter(auth);
        return MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.mode,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
