import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/income_source/components/add_transaction_sheet.dart';
import 'package:madakhel_app/view/income_source/components/source_detail_top_bar.dart';
import 'package:madakhel_app/view/income_source/components/stat_card.dart';
import 'package:madakhel_app/view/income_source/components/transaction_row.dart';
import 'package:madakhel_app/view_model/category_view_model.dart';
import 'package:madakhel_app/view_model/income_source_detail_view_model.dart';
import 'package:madakhel_app/view_model/income_source_view_model.dart';
import 'package:madakhel_app/view_model/transaction_view_model.dart';
import 'package:provider/provider.dart';

class SourceDetailScreen extends StatefulWidget {
  final IncomeSourceWithBalance source;

  const SourceDetailScreen({super.key, required this.source});

  @override
  State<SourceDetailScreen> createState() => _SourceDetailScreenState();
}

class _SourceDetailScreenState extends State<SourceDetailScreen> {
  TransactionClassifier selectedClassifier = TransactionClassifier.allFlows;

  @override
  void initState() {
    super.initState();
    // _loadInitialTransactions();
  }

  @override
  void didUpdateWidget(covariant SourceDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source.id != widget.source.id) {
      _loadInitialTransactions();
    }
  }

  void _loadInitialTransactions() {
    context.read<IncomeSourceDetailViewModel>().loadInitialTransactions(
      widget.source.id,
    );
  }

  Future<void> _refreshTransactions() {
    return context.read<IncomeSourceDetailViewModel>().refreshTransactions(
      widget.source.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    // _loadInitialTransactions();

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SourceDetailTopBar(
              isDeleted: widget.source.isDeleted,
              sourceName: widget.source.name,
              currency: widget.source.currency,
              onMenuTap: () => _showSourceActions(context),
              onBackTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Consumer<IncomeSourceDetailViewModel>(
                builder: (context, detailViewModel, child) {
                  final state = detailViewModel.state;
                  final transactions = state.transactions;

                  if (state.isInitialLoading && transactions.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    );
                  }

                  if (state.errorMessage != null && transactions.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshTransactions,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(16),
                          vertical: context.scaleH(18),
                        ),
                        children: [
                          SizedBox(height: context.scaleH(120)),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            color: scheme.surface,
                            child: Padding(
                              padding: EdgeInsets.all(context.scaleW(18)),
                              child: Column(
                                children: [
                                  Text(
                                    'تعذر تحميل المعاملات',
                                    style: TextStyle(
                                      fontSize: context.scaleSp(14),
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: context.scaleH(12)),
                                  Text(
                                    'حاول مرة أخرى فيما بعد أو اسحب للتحديث.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: context.scaleSp(12),
                                      color: scheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: context.scaleH(16)),
                                  OutlinedButton(
                                    onPressed: _loadInitialTransactions,
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final loadMoreLabel =
                      transactions.length <= detailViewModel.initialPageSize
                      ? 'عرض الكل'
                      : 'عرض المزيد';

                  return RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    child: Consumer<CategoryViewModel>(
                      builder: (context, catV, child) {
                        final cats = catV.categories;

                        // Build id sets once to avoid repeated lookups and
                        // to prevent `StateError: No element` from `firstWhere`.
                        final inFlowIds = cats
                            .where(
                              (c) => c.direction == TransactionDirection.inFlow,
                            )
                            .map((c) => c.id)
                            .toSet();
                        final outFlowIds = cats
                            .where(
                              (c) =>
                                  c.direction == TransactionDirection.outFlow,
                            )
                            .map((c) => c.id)
                            .toSet();

                        late final List<FinancialTransaction>
                        currentTransactions;
                        switch (selectedClassifier) {
                          case TransactionClassifier.inFlows:
                            // If there are no in-flow categories, return empty list.
                            currentTransactions = inFlowIds.isEmpty
                                ? <FinancialTransaction>[]
                                : transactions
                                      .where(
                                        (t) => inFlowIds.contains(t.categoryId),
                                      )
                                      .toList();
                            break;
                          case TransactionClassifier.outFlows:
                            currentTransactions = outFlowIds.isEmpty
                                ? <FinancialTransaction>[]
                                : transactions
                                      .where(
                                        (t) =>
                                            outFlowIds.contains(t.categoryId),
                                      )
                                      .toList();
                            break;
                          case TransactionClassifier.allFlows:
                            currentTransactions = transactions;
                            break;
                        }
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.scaleW(16),
                            vertical: context.scaleH(18),
                          ),
                          children: [
                            FutureBuilder<List<double>>(
                              future: Future.wait([
                                detailViewModel.getInSum(widget.source.id),
                                detailViewModel.getOutSum(widget.source.id),
                              ]),
                              builder: (context, sumsSnap) {
                                final inSum =
                                    (sumsSnap.data != null &&
                                        sumsSnap.data!.isNotEmpty)
                                    ? sumsSnap.data![0]
                                    : 0.0;
                                final outSum =
                                    (sumsSnap.data != null &&
                                        sumsSnap.data!.length > 1)
                                    ? sumsSnap.data![1]
                                    : 0.0;

                                return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: context.scaleH(12),
                                  crossAxisSpacing: context.scaleW(12),
                                  childAspectRatio: 1.4,
                                  children: [
                                    StatCard(
                                      value: (inSum - outSum).toStringAsFixed(
                                        2,
                                      ),
                                      label: 'الرصيد',
                                    ),
                                    StatCard(
                                      value: inSum.toStringAsFixed(2),
                                      label: 'إجمالي الدخل',
                                      isIncome: true,
                                    ),
                                    StatCard(
                                      value: outSum.toStringAsFixed(2),
                                      label: 'إجمالي المصروف',
                                      isIncome: false,
                                    ),
                                    StatCard(
                                      value: state.totalCount.toString(),
                                      label: 'عدد المعاملات',
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: context.scaleH(20)),
                            Text(
                              'آخر المعاملات',
                              style: TextStyle(
                                fontSize: context.scaleSp(14),
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: context.scaleW(8),
                              children: TransactionClassifier.values.map((
                                classifier,
                              ) {
                                final isSelected =
                                    selectedClassifier == classifier;
                                final label = () {
                                  switch (classifier) {
                                    case TransactionClassifier.inFlows:
                                      return 'الدخل';
                                    case TransactionClassifier.outFlows:
                                      return 'المصروفات';
                                    case TransactionClassifier.allFlows:
                                      return 'عرض الكل';
                                  }
                                }();

                                return ChoiceChip(
                                  selected: isSelected,
                                  label: Text(label),
                                  selectedColor: scheme.primary,
                                  backgroundColor:
                                      scheme.surfaceContainerHighest,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? scheme.onPrimary
                                        : scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSelected: (selected) {
                                    if (!selected) return;
                                    setState(() {
                                      selectedClassifier = classifier;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: context.scaleH(12)),
                            if (transactions.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.scaleH(24),
                                  ),
                                  child: Text(
                                    'لا توجد معاملات حتى الآن',
                                    style: TextStyle(
                                      fontSize: context.scaleSp(14),
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...currentTransactions.asMap().entries.map((
                                entry,
                              ) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: entry.key < transactions.length - 1
                                        ? context.scaleH(12)
                                        : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _showEditTransactionSheet(
                                      context,
                                      entry.value,
                                    ),
                                    onLongPress: () => _showDeleteConfirmation(
                                      context,
                                      entry.value,
                                    ),
                                    child: TransactionRow(
                                      transaction: entry.value,
                                      showBorder: false,
                                    ),
                                  ),
                                );
                              }),
                            if (state.errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: context.scaleH(10),
                                ),
                                child: Text(
                                  'تعذر تحميل المزيد من المعاملات',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.scaleSp(12),
                                    color: scheme.error,
                                  ),
                                ),
                              ),
                            if (state.hasMore)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: context.scaleH(12),
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: state.isLoadingMore
                                        ? null
                                        : detailViewModel.loadMoreTransactions,
                                    child: state.isLoadingMore
                                        ? SizedBox(
                                            height: context.scaleH(18),
                                            width: context.scaleW(18),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: scheme.primary,
                                            ),
                                          )
                                        : Text(
                                            loadMoreLabel,
                                            style: TextStyle(
                                              fontSize: context.scaleSp(12),
                                              color: scheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            if (transactions.isNotEmpty && !state.hasMore)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: context.scaleH(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'أنت في نهاية القائمة',
                                    style: TextStyle(
                                      fontSize: context.scaleSp(12),
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.source.isDeleted
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(context.scaleW(22)),
                    ),
                  ),
                  builder: (context) =>
                      AddTransactionSheet(incomeTypeId: widget.source.id),
                ).whenComplete(_refreshTransactions);
              },
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scaleW(56)),
              ),
              child: Icon(
                Icons.add,
                size: context.scaleSp(24),
                color: scheme.onPrimary,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic transaction) {
    if (transaction.isSystem == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن حذف معاملة نظامية')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AppConfirmActionDialog(
        title: 'تأكيد الحذف',
        message:
            'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
        confirmLabel: 'نعم، احذف',
        cancelLabel: 'إلغاء',
        isDanger: true,
        onConfirm: () async {
          await context.read<TransactionViewModel>().deleteTransaction(
            transaction.id,
          );
          if (!dialogContext.mounted) return;
          Navigator.pop(dialogContext);
          if (!context.mounted) return;
          await _refreshTransactions();
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حذف المعاملة')));
        },
      ),
    );
  }

  void _showEditTransactionSheet(
    BuildContext context,
    FinancialTransaction transaction,
  ) {
    if (transaction.isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن تعديل معاملة نظامية')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaleW(20)),
        ),
      ),
      builder: (context) => AddTransactionSheet(
        incomeTypeId: widget.source.id,
        initial: transaction,
      ),
    ).whenComplete(_refreshTransactions);
  }

  void _showSourceActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaleW(16)),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.scaleW(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('تعديل المصدر'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/income-source/edit', extra: widget.source);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('حذف المصدر'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteSourceConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteSourceConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, value, child) => AppConfirmActionDialog(
          title: 'تأكيد حذف المصدر',
          message:
              'سيتم حذف مصدر الدخل وجميع المعاملات المرتبطة به. لا يمكن التراجع عن هذا الإجراء.',
          confirmLabel: 'نعم، احذف',
          cancelLabel: 'إلغاء',
          isDanger: true,
          onConfirm: () async {
            await context.read<IncomeSourceViewModel>().deleteIncomeSource(
              widget.source.id,
            );
            if (!context.mounted) return;
            Navigator.pop(dialogContext);
            context.pop();
          },
        ),
      ),
    );
  }
}
