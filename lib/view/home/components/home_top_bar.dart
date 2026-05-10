import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/view/components/circle_icon_btn.dart';

class HomeTopBar extends StatelessWidget {
  final int sourceCount;
  final VoidCallback onAddTap;
  final VoidCallback onSettingsTap;

  const HomeTopBar({
    super.key,
    required this.sourceCount,
    required this.onAddTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(16),
        vertical: context.scaleH(12),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.add, onTap: onAddTap),
          Expanded(
            child: Column(
              children: [
                Text(
                  'مداخيلي',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.scaleH(12)),
                Text(
                  '$sourceCount مصادر',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          CircleIconButton(icon: Icons.settings_outlined, onTap: onSettingsTap),
        ],
      ),
    );
  }
}
