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
    final TransactionCategory? cat = context
        .select<CategoryViewModel, TransactionCategory?>(
          (catVM) => catVM.categories.firstWhereOrNull(
            (cat) => cat.id == transaction.categoryId,
          ),
        );
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
    final note = transaction.note?.trim();
    return Container(
      padding: EdgeInsets.all(context.scaleW(16)),
      margin: EdgeInsets.only(bottom: showBorder ? context.scaleH(10) : 0),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.scaleW(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                cat?.name ?? (transaction.note ?? 'معاملة'),
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
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
          SizedBox(height: context.scaleH(8)),
          Row(
            children: [
              Text(
                transaction.date.formattedReadableDate(transaction.date),
                style: TextStyle(
                  fontSize: context.scaleSp(11),
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Spacer(),
              Text(
                transaction.date.formattedReadableTime(transaction.date),
                style: TextStyle(
                  fontSize: context.scaleSp(11),
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (note != null && note.isNotEmpty) ...[
            SizedBox(height: context.scaleH(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.scaleW(10),
                vertical: context.scaleH(7),
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(context.scaleW(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: context.scaleSp(14),
                    color: scheme.onSurfaceVariant,
                  ),
                  SizedBox(width: context.scaleW(6)),
                  Expanded(
                    child: Text(
                      note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: context.scaleSp(11),
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<TransactionCategory?> _loadCategory(
    BuildContext context,
    int categoryId,
  ) async {
    return context.read<CategoryViewModel>().getCategoryById(categoryId);
  }
}
