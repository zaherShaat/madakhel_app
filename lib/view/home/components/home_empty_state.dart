import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(10)),
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(16),
        vertical: context.scaleH(24),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline, width: 0.5),
      ),
      child: Text(
        'لا يوجد مصادر دخل حتى الآن.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
      ),
    );
  }
}

