import 'package:flutter/material.dart';
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
      padding: EdgeInsets.only(bottom: context.scaleH(12)),
      child: Material(
        color: source.isDeleted ? Colors.transparent : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaleW(18),
              vertical: context.scaleH(16),
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: source.isDeleted ? scheme.error : scheme.outline,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: context.scaleW(10),
                  height: context.scaleH(40),
                  decoration: BoxDecoration(
                    color: SourceColor.fromId(source.id).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: SourceColor.fromId(source.id),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scaleW(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: context.scaleH(6)),
                      Text(
                        source.currency,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatBalance(source.balance),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: context.scaleH(6)),
                    Text(
                      source.isDeleted ? 'آخر رصيد قبل الحذف' : 'الرصيد',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
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

  String _formatBalance(double value) {
    final rounded = value.toStringAsFixed(3);
    return rounded.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
