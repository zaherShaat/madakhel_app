import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isIncome;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(context.scaleW(8)),
      ),
      padding: EdgeInsets.all(context.scaleW(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: context.scaleSp(15),
              color: ColorHelper.getStatColor(scheme, isIncome: isIncome),
            ),
          ),
          SizedBox(height: context.scaleH(2)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.scaleSp(12),
              fontWeight: FontWeight.w400,
              color: scheme.primaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}
