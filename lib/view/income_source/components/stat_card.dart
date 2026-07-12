import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool? isIncome;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = ColorHelper.getStatColor(scheme, isIncome: isIncome);
    final icon = isIncome == true
        ? Icons.trending_up
        : isIncome == false
        ? Icons.trending_down
        : Icons.bar_chart_outlined;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(context.scaleW(18)),
        border: Border.all(color: scheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(14),
        vertical: context.scaleH(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.scaleW(8),
                height: context.scaleW(8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(context.scaleW(4)),
                ),
              ),
              SizedBox(width: context.scaleW(10)),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: context.scaleW(8)),
              Container(
                width: context.scaleW(34),
                height: context.scaleW(34),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: context.scaleW(18), color: accent),
              ),
            ],
          ),
          SizedBox(height: context.scaleH(14)),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: context.scaleSp(18),
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
