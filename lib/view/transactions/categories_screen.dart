import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'فئات المعاملات',
              leading: CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => context.pop(),
              ),
              trailing: CircleIconButton(
                icon: Icons.add,
                onTap: () => context.push('/add-category'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(context.scaleW(16)),
                children: [
                  // Info box
                  Container(
                    padding: EdgeInsets.all(context.scaleW(12)),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      border: Border.all(
                        color: scheme.outline.withAlpha(40),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(context.scaleW(8)),
                    ),
                    child: Text(
                      'الفئات عامة — يمكن استخدام أي فئة في أي مصدر دخل عند إضافة حركة مالية.',
                      style: TextStyle(
                        fontSize: context.scaleSp(12),
                        color: scheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: context.scaleH(16)),
                  // Income categories
                  _SectionTitle('فئات الدخل', context),
                  _CategoryRow('دخل الإنترنت', true, context),
                  _CategoryRow('مباريات كرة القدم', true, context),
                  SizedBox(height: context.scaleH(16)),
                  // Expense categories
                  _SectionTitle('فئات المصروف', context),
                  _CategoryRow('فواتير الإنترنت', false, context),
                  _CategoryRow('مشتريات', false, context),
                  _CategoryRow('رواتب', false, context),
                  SizedBox(height: context.scaleH(16)),
                  // Add category button
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.scaleH(11),
                      horizontal: context.scaleW(12),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: scheme.outline.withAlpha(60),
                        width: 0.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      borderRadius: BorderRadius.circular(context.scaleW(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: context.scaleSp(16),
                          color: scheme.onSurfaceVariant,
                        ),
                        SizedBox(width: context.scaleW(6)),
                        Text(
                          'إضافة فئة جديدة',
                          style: TextStyle(
                            fontSize: context.scaleSp(12),
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SectionTitle(String title, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(8)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: context.scaleSp(11),
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.04,
        ),
      ),
    );
  }

  Widget _CategoryRow(String name, bool isIncome, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = isIncome
        ? const Color(0xFFEAF3DE)
        : const Color(0xFFFCEBEB);
    final textColor = isIncome
        ? const Color(0xFF3B6D11)
        : const Color(0xFFA32D2D);
    final label = isIncome ? 'دخل' : 'مصروف';

    return Container(
      padding: EdgeInsets.symmetric(vertical: context.scaleH(11)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outline.withAlpha(40), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaleW(8),
                  vertical: context.scaleH(2),
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: context.scaleSp(10),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(width: context.scaleW(8)),
              Text(
                name,
                style: TextStyle(
                  fontSize: context.scaleSp(13),
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          Icon(
            Icons.more_vert,
            size: context.scaleSp(16),
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
