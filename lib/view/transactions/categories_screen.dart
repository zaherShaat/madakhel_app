import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/circle_icon_button.dart';
import 'package:madakhel_app/view/shared/components/section_title.dart';
import 'package:madakhel_app/view/transactions/add_category_screen.dart';
import 'package:madakhel_app/view_model/category_view_model.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<CategoryViewModel>();

    return Scaffold(
      backgroundColor: scheme.background,
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
                onTap: () => _showCategorySheet(context),
                backgroundColor: scheme.primaryContainer,
                iconColor: scheme.primary,
                borderColor: scheme.primary.withOpacity(0.2),
                showBorder: false,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<TransactionCategory>>(
                stream: viewModel.watchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _CategoryLoadingList();
                  }

                  final categories = snapshot.data ?? [];
                  if (categories.isEmpty) {
                    return _CategoryEmptyState(
                      onAdd: () => _showCategorySheet(context),
                    );
                  }

                  final income = categories
                      .where(
                        (category) =>
                            category.direction == TransactionDirection.inFlow,
                      )
                      .toList();
                  final expense = categories
                      .where(
                        (category) =>
                            category.direction == TransactionDirection.outFlow,
                      )
                      .toList();

                  return ListView(
                    padding: EdgeInsets.all(context.scaleW(16)),
                    children: [
                      const _InfoBox(),
                      SizedBox(height: context.scaleH(18)),
                      if (income.isNotEmpty) ...[
                        const SectionTitle('فئات الدخل'),
                        ...income.map(
                          (category) => _CategoryRow(
                            category,
                            onEdit: () =>
                                _showCategorySheet(context, initial: category),
                          ),
                        ),
                        SizedBox(height: context.scaleH(24)),
                      ],
                      if (expense.isNotEmpty) ...[
                        const SectionTitle('فئات المصروف'),
                        ...expense.map(
                          (category) => _CategoryRow(
                            category,
                            onEdit: () =>
                                _showCategorySheet(context, initial: category),
                          ),
                        ),
                        SizedBox(height: context.scaleH(18)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet(
    BuildContext context, {
    TransactionCategory? initial,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaleW(16)),
        ),
      ),
      builder: (_) => AddCategoryScreen(initial: initial),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(context.scaleW(12)),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outline.withAlpha(40), width: 0.5),
        borderRadius: BorderRadius.circular(context.scaleW(8)),
      ),
      child: Text(
        'الفئات عامة ويمكن استخدامها في أي مصدر دخل عند إضافة معاملة مالية.',
        style: TextStyle(
          fontSize: context.scaleSp(12),
          color: scheme.onSurfaceVariant,
          height: 1.6,
        ),
      ),
    );
  }
}

class _CategoryLoadingList extends StatelessWidget {
  const _CategoryLoadingList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: EdgeInsets.all(context.scaleW(16)),
      itemBuilder: (_, __) => Container(
        height: context.scaleH(42),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(context.scaleW(8)),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: context.scaleH(8)),
      itemCount: 6,
    );
  }
}

class _CategoryEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _CategoryEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scaleW(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.scaleW(56),
              height: context.scaleW(56),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                color: scheme.onSurfaceVariant,
                size: context.scaleW(24),
              ),
            ),
            SizedBox(height: context.scaleH(12)),
            Text(
              'لا توجد فئات بعد',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: context.scaleH(6)),
            Text(
              'أضف فئة دخل أو مصروف لاستخدامها عند تسجيل المعاملات.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            SizedBox(height: context.scaleH(16)),
            ElevatedButton(onPressed: onAdd, child: const Text('إضافة فئة')),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final TransactionCategory category;
  final VoidCallback onEdit;

  const _CategoryRow(this.category, {required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = category.direction == TransactionDirection.inFlow;
    final bgColor = isIncome ? scheme.primaryContainer : scheme.errorContainer;
    final textColor = isIncome
        ? scheme.onPrimaryContainer
        : scheme.onErrorContainer;
    final label = isIncome ? 'دخل' : 'مصروف';

    return Container(
      margin: EdgeInsets.only(bottom: context.scaleH(8)),
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(14),
        vertical: context.scaleH(14),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.scaleW(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaleW(10),
              vertical: context.scaleH(6),
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
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: context.scaleSp(13),
                color: scheme.onSurface,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                _confirmDelete(context, category);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('تعديل')),
              PopupMenuItem(value: 'delete', child: Text('حذف')),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransactionCategory category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AppConfirmActionDialog(
        title: 'حذف الفئة',
        message: 'سيتم إخفاء هذه الفئة من القوائم الجديدة. هل تريد المتابعة؟',
        confirmLabel: 'حذف',
        cancelLabel: 'إلغاء',
        isDanger: true,
        onConfirm: () async {
          await context.read<CategoryViewModel>().deleteCategory(category.id);
          if (!dialogContext.mounted) return;
          Navigator.pop(dialogContext);
        },
      ),
    );
  }
}
