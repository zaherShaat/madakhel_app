import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/view/shared/components/bottom_nav_bar.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/income_source/components/add_transaction_sheet.dart';
import 'package:madakhel_app/view/income_source/components/source_detail_top_bar.dart';
import 'package:madakhel_app/view/income_source/components/stat_card.dart';
import 'package:madakhel_app/view/income_source/components/transaction_row.dart';
import 'package:madakhel_app/view_controller/income_source_controller.dart';
import 'package:madakhel_app/view_controller/transaction_controller.dart';
import 'package:provider/provider.dart';

class SourceDetailScreen extends StatefulWidget {
  final IncomeSourceWithBalance source;

  const SourceDetailScreen({super.key, required this.source});

  @override
  State<SourceDetailScreen> createState() => _SourceDetailScreenState();
}

class _SourceDetailScreenState extends State<SourceDetailScreen> {
  int _activeNavIndex = 1; // Transactions tab is active by default

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final txRepo = context.read<TransactionRepository>();

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
              child: StreamBuilder<List<FinancialTransaction>>(
                stream: txRepo.watchTransactions(widget.source.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    );
                  }

                  final transactions = snapshot.data ?? [];
                  final displayTransactions = transactions.length > 3
                      ? transactions.sublist(0, 3)
                      : transactions;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(context.scaleW(14)),
                    children: [
                      // Stats Grid — fetch sums asynchronously
                      FutureBuilder<List<double>>(
                        future: Future.wait([
                          txRepo.getInSum(widget.source.id),
                          txRepo.getOutSum(widget.source.id),
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
                                value: widget.source.balance.toString(),
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
                                value: transactions.length.toString(),
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
                      if (displayTransactions.isEmpty)
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
                        ...displayTransactions.asMap().entries.map(
                          (entry) => GestureDetector(
                            onLongPress: () =>
                                _showDeleteConfirmation(context, entry.value),
                            child: TransactionRow(
                              transaction: entry.value,
                              showBorder:
                                  entry.key < displayTransactions.length - 1,
                            ),
                          ),
                        ),
                      if (transactions.isNotEmpty)
                        SizedBox(height: context.scaleH(8)),
                      if (transactions.length > 3)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Navigate to all transactions screen
                            },
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(
                                fontSize: context.scaleSp(12),
                                color: scheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: context.scaleH(16)),
                    ],
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
                );
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
    showDialog(
      context: context,
      builder: (dialogContext) => AppConfirmActionDialog(
        title: 'تأكيد الحذف',
        message:
            'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
        confirmLabel: 'نعم، احذف',
        cancelLabel: 'إلغاء',
        isDanger: true,
        onConfirm: () {
          context.read<TransactionController>().deleteTransaction(
            transaction.id,
          );
          Navigator.pop(dialogContext);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حذف المعاملة')));
        },
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
            await context.read<IncomeSourceController>().deleteIncomeSource(
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
