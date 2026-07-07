import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madakhel_app/core/app_states.dart';
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:madakhel_app/view/components/app_confirm_action_dialog.dart';
import 'package:madakhel_app/view/income_source/components/add_transaction_sheet.dart';
import 'package:madakhel_app/view/income_source/components/transaction_row.dart';
import 'package:madakhel_app/view/shared/components/app_top_bar.dart';
import 'package:madakhel_app/view/shared/components/bottom_nav_bar.dart';
import 'package:madakhel_app/view_model/transaction_view_model.dart';
import 'package:madakhel_app/view_model/transactions_view_model.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _activeTabIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsViewModel>().load();
    });
  }

  Future<void> _refresh() => context.read<TransactionsViewModel>().refresh();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'المعاملات', subtitle: 'مصنفة حسب الفئة'),
            Expanded(
              child: Consumer<TransactionsViewModel>(
                builder: (context, viewModel, child) {
                  final state = viewModel.state;
                  if (state is LoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ErrorState) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: context.scaleW(48),
                              color: scheme.error,
                            ),
                            SizedBox(height: context.scaleH(16)),
                            Text(
                              'فشل تحميل المعاملات',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: context.scaleH(8)),
                            Text(
                              (state as ErrorState).message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final grouped =
                      state
                          is SuccessState<
                            Map<TransactionCategory, List<FinancialTransaction>>
                          >
                      ? state.data
                      : <TransactionCategory, List<FinancialTransaction>>{};

                  if (grouped.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.scaleW(16),
                          vertical: context.scaleH(24),
                        ),
                        children: [
                          SizedBox(height: context.scaleH(80)),
                          Container(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.scaleW(20)),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: context.scaleW(48),
                                    color: scheme.primary,
                                  ),
                                  SizedBox(height: context.scaleH(16)),
                                  Text(
                                    'لا توجد معاملات حتى الآن',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: context.scaleH(10)),
                                  Text(
                                    'أضف فئة أو سجل أول معاملة لتبدأ تتبع بياناتك المالية.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.6,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final entries = grouped.entries.toList();
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scaleW(16),
                        vertical: context.scaleH(16),
                      ),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: context.scaleH(12)),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _CategorySection(
                          category: entry.key,
                          transactions: entry.value,
                          onChanged: _refresh,
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
      bottomNavigationBar: BottomNavBar(
        activeIndex: _activeTabIndex,
        onTap: (index) {
          setState(() => _activeTabIndex = index);
          if (index == 0) {
            context.go('/settings');
          } else if (index == 2) {
            context.go('/home');
          }
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final TransactionCategory category;
  final List<FinancialTransaction> transactions;
  final Future<void> Function() onChanged;

  const _CategorySection({
    required this.category,
    required this.transactions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = category.direction == TransactionDirection.inFlow;
    final subtotal = transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.scaleW(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(
          horizontal: context.scaleW(16),
          vertical: context.scaleH(10),
        ),
        childrenPadding: EdgeInsets.symmetric(
          horizontal: context.scaleW(14),
          vertical: context.scaleH(8),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scaleW(20)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scaleW(20)),
        ),
        title: Row(
          children: [
            _DirectionBadge(isIncome: isIncome),
            SizedBox(width: context.scaleW(10)),
            Expanded(
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.scaleSp(14),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtotal.toStringAsFixed(2),
          style: TextStyle(
            color: isIncome ? scheme.primary : scheme.error,
            fontSize: context.scaleSp(12),
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          ...transactions.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () => _showEditSheet(context, entry.value),
              onLongPress: () => _confirmDelete(context, entry.value),
              child: TransactionRow(
                transaction: entry.value,
                showBorder: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, FinancialTransaction transaction) {
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
        incomeTypeId: transaction.incomeSourceId,
        initial: transaction,
      ),
    ).whenComplete(onChanged);
  }

  void _confirmDelete(BuildContext context, FinancialTransaction transaction) {
    if (transaction.isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن حذف معاملة نظامية')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AppConfirmActionDialog(
        title: 'حذف المعاملة',
        message: 'هل تريد حذف هذه المعاملة؟',
        confirmLabel: 'حذف',
        cancelLabel: 'إلغاء',
        isDanger: true,
        onConfirm: () async {
          await context.read<TransactionViewModel>().deleteTransaction(
            transaction.id,
          );
          if (!dialogContext.mounted) return;
          Navigator.pop(dialogContext);
          await onChanged();
        },
      ),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  final bool isIncome;

  const _DirectionBadge({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleW(8),
        vertical: context.scaleH(2),
      ),
      decoration: BoxDecoration(
        color: isIncome ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isIncome ? 'دخل' : 'مصروف',
        style: TextStyle(
          fontSize: context.scaleSp(10),
          color: isIncome ? scheme.onPrimaryContainer : scheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
