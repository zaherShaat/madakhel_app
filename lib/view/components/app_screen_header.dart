import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class AppScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(16),
        vertical: context.scaleH(12),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(context.scaleW(20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onBack != null)
            InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Container(
                width: context.scaleW(38),
                height: context.scaleW(38),
                decoration: BoxDecoration(
                  color: scheme.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outline, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back,
                  size: context.scaleW(18),
                  color: scheme.onBackground,
                ),
              ),
            )
          else
            SizedBox(width: context.scaleW(38), height: context.scaleW(38)),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onBackground,
              ),
            ),
          ),
          trailing ??
              SizedBox(width: context.scaleW(38), height: context.scaleW(38)),
        ],
      ),
    );
  }
}
