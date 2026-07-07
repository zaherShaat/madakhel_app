import 'package:flutter/material.dart';

class AppActionLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AppActionLink({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
      child: Text(label),
    );
  }
}
