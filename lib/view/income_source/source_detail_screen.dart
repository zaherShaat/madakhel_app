import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/income_source/components/add_transaction_sheet.dart';
import 'package:madakhel_app/view/income_source/components/source_detail_top_bar.dart';
import 'package:madakhel_app/view/income_source/components/stat_card.dart';
import 'package:madakhel_app/view/income_source/components/transaction_row.dart';
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
      backgroundColor: scheme.surface,
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
                        padding: EdgeInsets.all(context.scaleW(14)),
                        children: [
                          SizedBox(height: context.scaleH(160)),
                          Center(
                            child: Text(
                              'تعذر تحميل المعاملات',
                              style: TextStyle(
                                fontSize: context.scaleSp(14),
                                color: scheme.error,
                              ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: _loadInitialTransactions,
                              child: const Text('إعادة المحاولة'),
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
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(context.scaleW(14)),
                      children: [
                        // Stats Grid — fetch sums asynchronously
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
                              mainAxisSpacing: context.scaleH(8),
                              crossAxisSpacing: context.scaleW(8),
                              children: [
                                StatCard(
                                  value: "${inSum - outSum}",
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
                        SizedBox(height: context.scaleH(12)),
                        // Divider
                        Container(
                          height: 0.5,
                          color: scheme.outlineVariant.withAlpha(30),
                        ),
                        SizedBox(height: context.scaleH(12)),
                        // Recent Transactions Section
                        Text(
                          'آخر المعاملات',
                          style: TextStyle(
                            fontSize: context.scaleSp(14),
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.04,
                          ),
                        ),
                        SizedBox(height: context.scaleH(10)),
                        if (transactions.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scaleH(20),
                              ),
                              child: Text(
                                'لا توجد معاملات',
                                style: TextStyle(
                                  fontSize: context.scaleSp(14),
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        else
                          ...transactions.asMap().entries.map(
                            (entry) => GestureDetector(
                              onTap: () => _showEditTransactionSheet(
                                context,
                                entry.value,
                              ),
                              onLongPress: () =>
                                  _showDeleteConfirmation(context, entry.value),
                              child: TransactionRow(
                                transaction: entry.value,
                                showBorder: entry.key < transactions.length - 1,
                              ),
                            ),
                          ),
                        if (transactions.isNotEmpty)
                          SizedBox(height: context.scaleH(8)),
                        if (state.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: context.scaleH(8)),
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
                          Center(
                            // Pagination action: stay on this screen and fetch
                            // the next DB page instead of opening /transactions.
                            child: TextButton(
                              onPressed: state.isLoadingMore
                                  ? null
                                  : () {
                                      detailViewModel.loadMoreTransactions();
                                    },
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
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        if (transactions.isNotEmpty && !state.hasMore)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scaleH(12),
                              ),
                              child: Text(
                                'لا مزيد من المعاملات لعرضها',
                                style: TextStyle(
                                  fontSize: context.scaleSp(12),
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: context.scaleH(16)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FAB - Triggers Add Transaction Sheet
      floatingActionButton: widget.source.isDeleted
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(context.scaleW(20)),
                    ),
                  ),
                  builder: (context) =>
                      AddTransactionSheet(incomeTypeId: widget.source.id),
                ).whenComplete(_refreshTransactions);
              },
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scaleW(50)),
              ),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: context.scaleSp(22),
                  color: Colors.white,
                ),
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
