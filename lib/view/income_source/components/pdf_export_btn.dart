import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';

class PdfExportButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PdfExportButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(context.scaleW(18)),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: context.scaleW(16),
            vertical: context.scaleH(14),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
            ),
            borderRadius: BorderRadius.circular(context.scaleW(18)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: context.scaleW(18),
                  height: context.scaleW(18),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              else
                Icon(
                  Icons.picture_as_pdf_outlined,
                  color: scheme.onPrimary,
                  size: context.scaleSp(20),
                ),
              SizedBox(width: context.scaleW(10)),
              Text(
                isLoading ? 'جاري تجهيز PDF...' : 'تصدير التفاصيل PDF',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: context.scaleSp(13),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
