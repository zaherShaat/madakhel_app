import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';

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

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withAlpha(30),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: context.scaleW(24)),
            activeIcon: Icon(Icons.home, size: context.scaleW(24)),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined, size: context.scaleW(24)),
            activeIcon: Icon(Icons.receipt, size: context.scaleW(24)),
            label: 'المعاملات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: context.scaleW(24)),
            activeIcon: Icon(Icons.settings, size: context.scaleW(24)),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
