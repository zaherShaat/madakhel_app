import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view_model/category_view_model.dart';
import 'package:provider/provider.dart';

class TransactionRow extends StatelessWidget {
  final FinancialTransaction transaction;
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

    return FutureBuilder<TransactionCategory?>(
      future: _loadCategory(context, transaction.categoryId),
      builder: (context, snap) {
        final cat = snap.data;
        final isIncome =
            (cat?.direction ?? TransactionDirection.inFlow) ==
            TransactionDirection.inFlow;
        final directionStr = isIncome ? 'in' : 'out';
        final amountColor = ColorHelper.getDirectionColor(scheme, directionStr);
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
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
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
                            cat?.name ?? (transaction.note ?? 'معاملة'),
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: context.scaleSp(13),
                              color: scheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: context.scaleH(3)),
                          Text(
                            transaction.date.toIso8601String(),
                            style: TextStyle(fontSize: context.scaleSp(10)),
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
      },
    );
  }

  Future<TransactionCategory?> _loadCategory(
    BuildContext context,
    int categoryId,
  ) async {
    return context.read<CategoryViewModel>().getCategoryById(categoryId);
  }
}
