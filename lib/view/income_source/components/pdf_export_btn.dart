import 'package:flutter/material.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:path/path.dart' as p;

class PdfExportButton extends StatelessWidget {
  final bool isLoading, disabled;
  final VoidCallback onPressed;

  const PdfExportButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
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
            colors: disabled
                ? [
                    Theme.of(context).disabledColor,
                    Theme.of(context).disabledColor,
                  ]
                : [scheme.primary, scheme.tertiary],
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
    );
  }
}

void showPdfSavedSnackBar(
  BuildContext context, {
  required String path,
  required VoidCallback onOpen,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;

  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(minutes: 1),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(
        context.scaleW(16),
        0,
        context.scaleW(16),
        context.scaleH(16),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scaleW(14)),
      ),
      backgroundColor: scheme.inverseSurface,
      content: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: scheme.primary, size: 22),
          SizedBox(width: context.scaleW(10)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم حفظ الملف ${p.basename(path)} في مستندات الجهاز',
                  style: TextStyle(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: context.scaleSp(13),
                  ),
                ),
                // Text(
                //   p.basename(path),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //     color: scheme.onInverseSurface.withValues(alpha: 0.75),
                //     fontSize: context.scaleSp(11),
                //   ),
                // ),
              ],
            ),
          ),
          TextButton(
            onPressed: onOpen,
            child: Text('فتح الملف', style: TextStyle(color: scheme.primary)),
          ),
          
        ],
      ),
    ),
  );
}
