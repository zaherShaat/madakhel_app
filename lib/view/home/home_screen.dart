import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/context_ext.dart';
import '../../data/repositories/income_type_repository.dart';
import '../../model/income_source_with_balance.dart';
import '../income_source/components/add_source_row.dart';
import '../income_source/components/income_source_card.dart';
import 'components/home_empty_state.dart';
import 'components/home_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = context.watch<IncomeTypeRepository>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: StreamBuilder<List<IncomeSourceWithBalance>>(
          stream: repo.watchIncomeSourcesWithBalance(),
          builder: (context, snapshot) {
            final status = snapshot.connectionState;
            final dbSources =
                snapshot.data ?? const <IncomeSourceWithBalance>[];

            return Column(
              children: [
                HomeTopBar(
                  sourceCount: status == ConnectionState.waiting
                      ? 0
                      : dbSources.where((source) => !source.isDeleted).length,
                  onAddTap: () => context.push('/income-source/new'),
                  onSettingsTap: () {},
                ),

                Builder(
                  builder: (context) {
                    switch (status) {
                      case ConnectionState.waiting:
                        return const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      case ConnectionState.done:
                      case ConnectionState.active:
                        return Expanded(
                          child: ListView(
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
                          ),
                        );
                      default:
                        HomeEmptyState();
                        return HomeEmptyState();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
