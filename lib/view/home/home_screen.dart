import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/context_ext.dart';
import '../../data/repositories/income_type_repository.dart';
import '../../model/income_source_with_balance.dart';
import '../income_source/components/add_source_row.dart';
import '../income_source/components/income_source_card.dart';
import '../shared/components/bottom_nav_bar.dart';
import 'components/home_empty_state.dart';
import 'components/home_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTabIndex = 2; // Home is at index 2

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = context.watch<IncomeTypeRepository>();

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          HomeTopBar(
            sourceCount: 0,
            onAddTap: () => context.push('/income-source/new'),
            onSettingsTap: () {
              setState(() => _activeTabIndex = 0);
              context.go('/settings');
            },
          ),
          Expanded(
            child: StreamBuilder<List<IncomeSourceWithBalance>>(
              stream: repo.watchIncomeSourcesWithBalance(),
              builder: (context, snapshot) {
                final status = snapshot.connectionState;
                final dbSources =
                    snapshot.data ?? const <IncomeSourceWithBalance>[];

                return Builder(
                  builder: (context) {
                    switch (status) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.done:
                      case ConnectionState.active:
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(context.scaleW(16)),
                          children: [
                            if (dbSources.isEmpty)
                              const HomeEmptyState()
                            else
                              ...dbSources.map(
                                (source) => Column(
                                  children: [
                                    IncomeSourceCard(
                                      source: source,
                                      onTap: () => context.push(
                                        '/source-detail',
                                        extra: source,
                                      ),
                                    ),
                                    SizedBox(height: context.scaleH(12)),
                                  ],
                                ),
                              ),
                            AddSourceRow(
                              onTap: () => context.push('/income-source/new'),
                            ),
                          ],
                        );
                      default:
                        return const HomeEmptyState();
                    }
                  },
                );
              },
            ),
          ),
          BottomNavBar(
            activeIndex: _activeTabIndex,
            onTap: (index) {
              setState(() => _activeTabIndex = index);
              if (index == 0) {
                context.go('/settings');
              } else if (index == 1) {
                context.go('/transactions');
              }
              // index 2 is home, no need to navigate
            },
          ),
        ],
      ),
    );
  }
}
