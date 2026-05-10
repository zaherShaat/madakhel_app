import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';

class AddSourceRow extends StatelessWidget {
  final VoidCallback onTap;

  const AddSourceRow({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.scaleH(11)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline, width: 0.8),
        ),
        alignment: Alignment.center,
        child: Text(
          '+ إضافة مصدر دخل',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.85),
              ),
        ),
      ),
    );
  }
}

