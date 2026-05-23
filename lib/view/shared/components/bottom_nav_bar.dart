import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tabs = [
      (label: 'الإعدادات', icon: Icons.circle_outlined),
      (label: 'المعاملات', icon: Icons.unfold_more),
      (label: 'الرئيسية', icon: Icons.square_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outline.withAlpha(40), width: 0.5),
        ),
        color: scheme.surface,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = index == activeIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: context.scaleH(10),
                  horizontal: context.scaleW(4),
                ),
                decoration: isActive
                    ? BoxDecoration(color: scheme.onSurface)
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index].icon,
                      size: context.scaleW(16),
                      color: isActive
                          ? scheme.surface
                          : scheme.onSurfaceVariant,
                    ),
                    SizedBox(height: context.scaleH(3)),
                    Text(
                      tabs[index].label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? scheme.surface
                            : scheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
