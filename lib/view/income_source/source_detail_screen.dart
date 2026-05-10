import 'package:flutter/material.dart';
import 'package:madakhel_app/core/context_ext.dart';
import 'package:madakhel_app/data/repositories/transaction_repository.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/view/income_source/components/add_transaction_sheet.dart';
import 'package:madakhel_app/view/income_source/components/bottom_nav_bar.dart';
import 'package:madakhel_app/view/income_source/components/source_detail_top_bar.dart';
import 'package:madakhel_app/view/income_source/components/stat_card.dart';
import 'package:madakhel_app/view/income_source/components/transaction_row.dart';
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
              sourceName: widget.source.name,
              currency: widget.source.currency,
              onMenuTap: () {},
              onBackTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: StreamBuilder<List<dynamic>>(
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
                      // Stats Grid
                      GridView.count(
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
                            value: transactions
                                .where(
                                  (t) =>
                                      t.direction.toString() ==
                                      'TransactionDirection.inFlow',
                                )
                                .length
                                .toString(),
                            label: 'إجمالي الدخل',
                            isIncome: true,
                          ),
                          StatCard(
                            value: transactions
                                .where(
                                  (t) =>
                                      t.direction.toString() ==
                                      'TransactionDirection.outFlow',
                                )
                                .length
                                .toString(),
                            label: 'إجمالي المصروف',
                            isIncome: false,
                          ),
                          StatCard(
                            value: transactions.length.toString(),
                            label: 'عدد المعاملات',
                          ),
                        ],
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
            // Bottom Tab Bar
            BottomNavBar(
              activeIndex: _activeNavIndex,
              onTap: (index) {
                setState(() => _activeNavIndex = index);
                // TODO: Handle navigation based on index
              },
            ),
          ],
        ),
      ),
      // FAB - Triggers Add Transaction Sheet
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final txRepo = context.read<TransactionRepository>();
          final templates = await txRepo.getTemplates(widget.source.id);
          if (!context.mounted) return;

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
              templates: templates,
            ),
          );
        },
        backgroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scaleW(50)),
        ),
        child: Text(
          '+',
          style: TextStyle(fontSize: context.scaleSp(22), color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic transaction) {
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المعاملة'),
        content: Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TransactionController>().deleteTransaction(
                transaction.id,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم حذف المعاملة')));
            },
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
