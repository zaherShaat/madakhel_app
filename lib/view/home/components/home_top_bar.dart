import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onSettingsTap;

  const HomeTopBar({
    super.key,
    required this.onAddTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(16),
        vertical: context.scaleH(14),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: context.scaleH(12)),
          Row(
            children: [
              CircleIconButton(
                icon: Icons.add,
                onTap: onAddTap,
                backgroundColor: scheme.primaryContainer,
                iconColor: scheme.surfaceContainer,
                borderColor: scheme.primary.withValues(alpha: 0.18),
                showBorder: false,
              ),
              Spacer(),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'مداخيلي',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaleH(4)),
          
        ],
      ),
    );
  }
}
