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
      backgroundColor: scheme.surface,
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
                      child: Text(
                        'فشل تحميل المعاملات: ${(state as ErrorState).message}',
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
                        children: [
                          SizedBox(height: context.scaleH(180)),
                          Center(
                            child: Text(
                              'لا توجد معاملات بعد',
                              style: Theme.of(context).textTheme.bodyMedium,
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
                      padding: EdgeInsets.all(context.scaleW(16)),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: context.scaleH(8)),
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
            BottomNavBar(
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
          ],
        ),
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
        border: Border.all(color: scheme.outline.withAlpha(45), width: 0.5),
        borderRadius: BorderRadius.circular(context.scaleW(8)),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(horizontal: context.scaleW(12)),
        childrenPadding: EdgeInsets.symmetric(horizontal: context.scaleW(12)),
        title: Row(
          children: [
            _DirectionBadge(isIncome: isIncome),
            SizedBox(width: context.scaleW(8)),
            Expanded(
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.scaleSp(13),
                  fontWeight: FontWeight.w600,
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
          ),
        ),
        children: [
          ...transactions.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () => _showEditSheet(context, entry.value),
              onLongPress: () => _confirmDelete(context, entry.value),
              child: TransactionRow(
                transaction: entry.value,
                showBorder: entry.key < transactions.length - 1,
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
