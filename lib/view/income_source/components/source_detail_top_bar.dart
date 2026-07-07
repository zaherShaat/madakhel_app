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
      padding: EdgeInsets.fromLTRB(
        context.scaleW(18),
        context.scaleH(18),
        context.scaleW(18),
        context.scaleH(20),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(context.scaleW(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: context.scaleW(38),
              height: context.scaleH(38),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(context.scaleW(12)),
              ),
              child: Icon(
                Icons.arrow_back,
                size: context.scaleSp(20),
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          SizedBox(width: context.scaleW(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sourceName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: context.scaleSp(18),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.scaleH(6)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scaleW(12),
                        vertical: context.scaleH(6),
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(context.scaleW(16)),
                      ),
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontSize: context.scaleSp(12),
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (isDeleted) ...[
                      SizedBox(width: context.scaleW(8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(10),
                          vertical: context.scaleH(6),
                        ),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(
                            context.scaleW(16),
                          ),
                        ),
                        child: Text(
                          'محذوف',
                          style: TextStyle(
                            fontSize: context.scaleSp(12),
                            fontWeight: FontWeight.w600,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaleW(12)),
          Visibility(
            visible: !isDeleted,
            child: GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: context.scaleW(42),
                height: context.scaleH(42),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(context.scaleW(14)),
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: context.scaleSp(20),
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
