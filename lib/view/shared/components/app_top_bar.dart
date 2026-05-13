import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showBorder;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.showBorder = true,
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
        border: showBorder
            ? Border(bottom: BorderSide(color: scheme.outline, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          leading ?? SizedBox(width: context.scaleW(34)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: context.scaleH(4)),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ?? SizedBox(width: context.scaleW(34)),
        ],
      ),
    );
  }
}
