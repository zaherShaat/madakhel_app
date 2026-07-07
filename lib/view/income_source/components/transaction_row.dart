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
          padding: EdgeInsets.all(context.scaleW(16)),
          margin: EdgeInsets.only(bottom: showBorder ? context.scaleH(10) : 0),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(context.scaleW(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaleW(10),
                  vertical: context.scaleH(5),
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(context.scaleW(12)),
                ),
                alignment: Alignment.center,
                child: Text(
                  isIncome ? 'دخل' : 'مصروف',
                  style: TextStyle(
                    fontSize: context.scaleSp(11),
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
              SizedBox(width: context.scaleW(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat?.name ?? (transaction.note ?? 'معاملة'),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.scaleH(6)),
                    Text(
                      '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: context.scaleSp(11),
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.scaleW(12)),
              Text(
                transaction.amount.toStringAsFixed(2),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: context.scaleSp(15),
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
