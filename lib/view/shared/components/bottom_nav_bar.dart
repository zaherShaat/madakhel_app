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
      (label: 'الإعدادات', icon: Icons.settings_outlined),
      (label: 'المعاملات', icon: Icons.receipt_long_outlined),
      (label: 'الرئيسية', icon: Icons.home_outlined),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: context.scaleH(10)),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outline.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = index == activeIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(context.scaleW(18)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.symmetric(horizontal: context.scaleW(6)),
                padding: EdgeInsets.symmetric(vertical: context.scaleH(10)),
                decoration: BoxDecoration(
                  color: isActive
                      ? scheme.primary.withOpacity(0.16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(context.scaleW(18)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isActive ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        tabs[index].icon,
                        size: context.scaleW(20),
                        color: isActive
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.scaleH(4)),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: isActive
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Text(tabs[index].label),
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
