import 'package:flutter/material.dart';
import 'package:madakhel_app/core/color_helper.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/transaction_direction.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final bool showBorder;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isIncome = transaction.direction == TransactionDirection.inFlow;
    final amountColor = ColorHelper.getDirectionColor(
      scheme,
      transaction.direction.name,
    );
    final badgeBgColor = isIncome
        ? scheme.primaryContainer
        : scheme.errorContainer;
    final badgeTextColor = isIncome
        ? scheme.onPrimaryContainer
        : scheme.onErrorContainer;

    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withOpacity(0.3),
                  width: 0.5,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(vertical: context.scaleH(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scaleW(8),
                    vertical: context.scaleH(2),
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(context.scaleW(99)),
                  ),
                  child: Text(
                    isIncome ? 'دخل' : 'مصروف',
                    style: TextStyle(
                      fontSize: context.scaleSp(10),
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
                SizedBox(width: context.scaleW(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.name,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: context.scaleSp(13),
                          color: scheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.scaleH(3)),
                      Text(
                        transaction.date!.toIso8601String(),
                        style: TextStyle(
                          fontSize: context.scaleSp(10),

                          // color: scheme.te,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaleW(8)),
          Text(
            transaction.amount.toString(),
            style: textTheme.titleMedium?.copyWith(
              fontSize: context.scaleSp(13),
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
