import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(8)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: context.scaleSp(11),
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
