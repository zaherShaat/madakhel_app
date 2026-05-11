import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final bool showLabelAbove;
  final String? Function(String?)? validator;
  final int? maxLines;

  final int? minLines;
  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixPressed,
    this.showLabelAbove = true,
    this.validator,
    this.maxLines,
    this.minLines,  
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textField = TextFormField(
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      
      decoration: InputDecoration(
        hintText: hintText,
        
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onSurface.withOpacity(0.55),
        ),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(icon: suffixIcon!, onPressed: onSuffixPressed),
      ),
    );

    if (!showLabelAbove) {
      return textField;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'Cairo',
            color: scheme.onSurface.withOpacity(0.75),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        SizedBox(height: context.scaleH(6)),
        textField,
      ],
    );
  }
}
