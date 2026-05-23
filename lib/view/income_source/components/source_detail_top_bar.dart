import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class SourceDetailTopBar extends StatelessWidget {
  final String sourceName;
  final String currency;
  final VoidCallback onMenuTap;
  final VoidCallback onBackTap;
  final bool isDeleted;
  const SourceDetailTopBar({
    super.key,
    required this.sourceName,
    required this.currency,
    required this.onMenuTap,
    required this.onBackTap,
    required this.isDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(16),
        vertical: context.scaleH(12),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withAlpha(50),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: context.scaleW(34),
              height: context.scaleH(34),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(context.scaleW(8)),
                border: Border.all(
                  color: scheme.outlineVariant.withAlpha(30),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: context.scaleSp(22),
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          SizedBox(width: context.scaleW(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  sourceName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: context.scaleSp(15),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.scaleH(2)),
                Text(
                  currency,
                  style: TextStyle(
                    fontSize: context.scaleSp(11),
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaleW(8)),
          Visibility(
            visible: !isDeleted,
            child: GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: context.scaleW(34),
                height: context.scaleH(34),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(context.scaleW(8)),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '⋯',
                    style: TextStyle(
                      fontSize: context.scaleSp(16),
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
