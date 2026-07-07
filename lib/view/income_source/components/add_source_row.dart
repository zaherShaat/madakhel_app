import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class AddSourceRow extends StatelessWidget {
  final VoidCallback onTap;

  const AddSourceRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.scaleH(14),
          horizontal: context.scaleW(18),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.primary.withOpacity(0.3), width: 1),
          color: scheme.primary.withOpacity(0.06),
        ),
        alignment: Alignment.center,
        child: Text(
          '+ إضافة مصدر دخل',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
