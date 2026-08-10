import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/pdf/permissions_manager.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/income_source/components/add_transaction_sheet.dart';
import 'package:madakhel_app/view/income_source/components/pdf_export_btn.dart';
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
  TransactionClassifier selectedClassifier = TransactionClassifier.allFlow;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadInitialTransactions();
  // }

  @override
  void didUpdateWidget(covariant SourceDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source.id != widget.source.id) {
      _loadInitialTransactions();
    }
  }

  void _loadInitialTransactions() {
    debugPrint(
      "$selectedClassifier >> selected clasifier > _loadInitialTransactions",
    );

    context.read<IncomeSourceDetailViewModel>().loadInitialTransactions(
      widget.source.id,
      transactionClassifier: selectedClassifier,
    );
  }

  Future<void> _refreshTransactions({
    required TransactionClassifier classifier,
  }) {
    return context.read<IncomeSourceDetailViewModel>().refreshTransactions(
      widget.source.id,
      transactionClassifier: classifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    const permissionsServices = PermissionsServices();
    final scheme = Theme.of(context).colorScheme;
    final sourceDetailesC = context.watch<IncomeSourceDetailViewModel>();
    final state = sourceDetailesC.state;
    final transactions = state.transactions;

    double outSum = sourceDetailesC.outSum;
    double inSum = sourceDetailesC.inSum;
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
              child: Builder(
                builder: (context) {
                  if (state.isInitialLoading && transactions.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    );
                  }

                  if (state.errorMessage != null && transactions.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () =>
                          _refreshTransactions(classifier: selectedClassifier),
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
                      transactions.length <= sourceDetailesC.initialPageSize
                      ? 'عرض الكل'
                      : 'عرض المزيد';
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scaleW(16),
                      vertical: context.scaleH(18),
                    ),
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: context.scaleH(12),
                        crossAxisSpacing: context.scaleW(12),
                        childAspectRatio: 1.4,
                        children: [
                          StatCard(
                            value: (inSum - outSum).toStringAsFixed(2),
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
                      ),

                      SizedBox(height: context.scaleH(20)),
                      PdfExportButton(
                        isLoading: state.isExportingPdf,
                        disabled: transactions.isEmpty,
                        onPressed: transactions.isEmpty
                            ? () {}
                            : () async {
                                try {
                                  final range = await _pickPdfDateRange(
                                    context,
                                  );
                                  if (!context.mounted || range == null) {
                                    return;
                                  }
                                  final hasPermission =
                                      await permissionsServices
                                          .checkAndRequestPermission(context);
                                  if (!hasPermission) {
                                    return;
                                  } else {
                                    final path = await sourceDetailesC
                                        .exportPdf(
                                          widget.source,
                                          startDate: range.start,
                                          endDate: range.end,
                                        );
                                    if (!context.mounted || path.isEmpty) {
                                      return;
                                    }

                                    showPdfSavedSnackBar(
                                      context,
                                      path: path,
                                      onOpen: () async => await sourceDetailesC
                                          .openSavedPdf(path),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تعذر حفظ ملف PDF: $e'),
                                    ),
                                  );
                                }
                              },
                      ),
                      SizedBox(height: context.scaleH(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'المعاملات الماليّة',
                            style: TextStyle(
                              fontSize: context.scaleSp(14),
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scaleH(8)),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: context.scaleW(8),
                        children: TransactionClassifier.values.map((
                          classifier,
                        ) {
                          final isSelected = selectedClassifier == classifier;
                          final label = () {
                            switch (classifier) {
                              case TransactionClassifier.inFlow:
                                return 'الدخل';
                              case TransactionClassifier.outFlow:
                                return 'المصروفات';
                              case TransactionClassifier.allFlow:
                                return 'عرض الكل';
                            }
                          }();

                          return ChoiceChip(
                            selected: isSelected,
                            label: Text(label),
                            selectedColor: scheme.primary,
                            backgroundColor: scheme.surfaceContainerHighest,
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
                                _refreshTransactions(
                                  classifier: selectedClassifier,
                                );
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
                        ...transactions.asMap().entries.map((entry) {
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
                              onLongPress: () =>
                                  _showDeleteConfirmation(context, entry.value),
                              child: TransactionRow(
                                transaction: entry.value,
                                showBorder: false,
                              ),
                            ),
                          );
                        }),
                      if (state.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(top: context.scaleH(10)),
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
                          padding: EdgeInsets.only(top: context.scaleH(12)),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                debugPrint(
                                  "$selectedClassifier >> selectedClassifier from text button",
                                );
                                state.isLoadingMore
                                    ? null
                                    : sourceDetailesC.loadMoreTransactions(
                                        transactionClassifier:
                                            selectedClassifier,
                                      );
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      if (transactions.isNotEmpty && !state.hasMore)
                        Padding(
                          padding: EdgeInsets.only(top: context.scaleH(16)),
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
                ).whenComplete(
                  () => _refreshTransactions(classifier: selectedClassifier),
                );
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
          await _refreshTransactions(classifier: selectedClassifier);
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
    ).whenComplete(() {
      _refreshTransactions(classifier: selectedClassifier);
    });
  }

  Future<DateTimeRange?> _pickPdfDateRange(BuildContext context) async {
    final now = DateTime.now();
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
    );
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
            await _refreshTransactions(classifier: selectedClassifier);
            if (!context.mounted) return;
            Navigator.pop(dialogContext);
            context.pop();
          },
        ),
      ),
    );
  }
}
