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
        border: Border(bottom: BorderSide(color: scheme.outline, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: scheme.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward,
                size: 18,
                color: scheme.onBackground,
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onBackground,
            ),
          ),

          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 34, height: 34),
        ],
      ),
    );
  }
}
