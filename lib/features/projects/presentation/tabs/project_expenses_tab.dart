import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../budgets/presentation/widgets/budget_variance_card.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../expenses/presentation/widgets/expense_tile.dart';
import '../../domain/models/project_metrics.dart';

/// Sub-navigation tab presenting transactional ledger and operational expenses.
class ProjectExpensesTab extends ConsumerWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectExpensesTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final expensesAsync = ref.watch(
      projectExpensesWithDetailsProvider(project.id),
    );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      children: [
        // 1. Total Spent Card
        AppCard(
          title: 'Total Actual Expenditure',
          subtitle: '${project.currency} operational outflow',
          leadingIcon: const Icon(Icons.receipt_long_outlined),
          trailingAction: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: metrics.budgetSpentPercentage > 100
                  ? colors.healthRedBg
                  : colors.healthGreenBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metrics.totalBudgeted.isPositive
                  ? '${metrics.budgetSpentPercentage.toStringAsFixed(0)}% of budget'
                  : 'Actual Spent',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: metrics.budgetSpentPercentage > 100
                    ? colors.healthRed
                    : colors.healthGreen,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MoneyDisplay(
                money: metrics.totalSpent,
                sentiment: MoneyDisplaySentiment.negative,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Includes field operations, seeds, fertilizers, casual labour, and transport.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                ),
              ),
            ],
          ),
        ),

        // 2. Real-time Budget Variance & Threshold Alerts
        BudgetVarianceCard(project: project),

        // 3. Expenses Ledger Stream
        expensesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading expenses: $err'),
          ),
          data: (expenses) {
            if (expenses.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 48,
                      color: colors.healthRed.withAlpha(160),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Operational Expenses Logged',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Log cash, Mobile Money, and bank transactions in real time to monitor budget variance.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 48),
                      ),
                      onPressed: () => context.push(
                        '${AppRoutes.addExpense}?projectId=${project.id}',
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Record Expense'),
                    ),
                  ],
                ),
              );
            }

            final activeExpenses = expenses.where((e) => !e.isVoided).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction Ledger (${activeExpenses.length} active)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(
                          '${AppRoutes.addExpense}?projectId=${project.id}',
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Expense'),
                      ),
                    ],
                  ),
                ),
                ...expenses.map((exp) => ExpenseTile(expense: exp)),
              ],
            );
          },
        ),
      ],
    );
  }
}
