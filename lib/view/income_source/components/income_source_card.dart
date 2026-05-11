import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/view/income_source/components/deleted_stamp.dart';

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
        color: source.isDeleted ? Colors.transparent : scheme.surface,
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
              border: Border.all(
                color: source.isDeleted ? scheme.error : scheme.outline,
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                Row(
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

                    source.isDeleted
                        ? const DeletedStamp(size: 63, opacity: 0.6)
                        : const SizedBox.shrink(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          source.balance.toString(),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: context.scaleH(8)),
                        Text(
                          source.isDeleted ? 'آخر رصيد قبل الحذف' : 'الرصيد',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.75),
                              ),
                        ),
                      ],
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
