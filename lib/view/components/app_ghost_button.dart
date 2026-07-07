import 'package:flutter/material.dart';

class AppGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.primary.withOpacity(0.24), width: 1),
        backgroundColor: scheme.surfaceVariant,
        foregroundColor: scheme.primary,
        textStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
