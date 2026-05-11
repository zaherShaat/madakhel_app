import 'package:flutter/material.dart';

class DeletedStamp extends StatelessWidget {
  const DeletedStamp({
    super.key,
    this.text = 'محذوف',
    this.size = 120.0,
    this.color = Colors.red,
    this.opacity = 0.7,
    this.angle = -20, // degrees
  });

  final String text;
  final double size;
  final Color color;
  final double opacity;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true, // stamp does not block taps on underlying content
      child: Transform.rotate(
        angle: angle * 3.14159 / 180, // to radians
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(opacity), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: color.withOpacity(opacity),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}