import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';

class IncomeSourceCard extends StatelessWidget {
  final IncomeSourceWithBalance source;
  final VoidCallback onTap;

  const IncomeSourceCard({
    super.key,
    required this.source,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(10)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaleW(14),
              vertical: context.scaleH(13),
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outline, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: context.scaleW(9),
                        height: context.scaleH(9),
                        decoration: BoxDecoration(
                          color: SourceColor.fromId(source.id),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: context.scaleW(10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: context.scaleH(8)),

                          Text(
                            source.currency,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      source.balance.toString(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: context.scaleH(8)),

                    Text(
                      'الرصيد',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
