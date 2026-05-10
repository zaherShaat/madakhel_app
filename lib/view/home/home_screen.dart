import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/view/income_source/components/add_source_row.dart';
import 'package:madakhel_app/view/income_source/components/income_source_card.dart';

import '../../core/context_ext.dart';
import 'components/home_empty_state.dart';
import 'components/home_top_bar.dart';
import 'home_dummy_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const sources = HomeDummyData.incomeSources;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              HomeTopBar(
                sourceCount: sources.length,
                onAddTap: () {},
                onSettingsTap: () {},
              ),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(context.scaleW(16)),
                  children: [
                    if (sources.isEmpty)
                      const HomeEmptyState()
                    else
                      ...sources.map(
                        (source) => Column(
                          children: [
                            IncomeSourceCard(
                              source: source,
                              onTap: () {
                                context.push(
                                  '/source-detail/',
                                  extra: source,
                                );
                              },
                            ),
                            SizedBox(height: context.scaleH(12)),
                          ],
                        ),
                      ),
                    AddSourceRow(onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
