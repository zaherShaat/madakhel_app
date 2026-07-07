import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final bool showBorder;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size,
    this.iconSize,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final buttonSize = size ?? context.scaleW(32);
    final iSize = iconSize ?? context.scaleW(14);
    final bgColor = backgroundColor ?? scheme.surfaceContainerHighest;
    final bColor = borderColor ?? scheme.outline.withOpacity(0.55);
    final iColor = iconColor ?? scheme.onSurface;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: showBorder ? Border.all(color: bColor, width: 0.65) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: iSize, color: iColor),
      ),
    );
  }
}
