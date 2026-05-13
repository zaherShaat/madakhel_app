import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/bottom_nav_bar.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _activeTabIndex = 1; // Transactions tab is active

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'المعاملات', subtitle: 'مصنّفة حسب الفئة'),
            Expanded(
              child: Center(
                child: Text(
                  'قريباً - شاشة المعاملات',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            BottomNavBar(
              activeIndex: _activeTabIndex,
              onTap: (index) {
                setState(() => _activeTabIndex = index);
                if (index == 0) {
                  context.go('/settings');
                } else if (index == 2) {
                  context.go('/home');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
