import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../budgets/domain/models/budget_category_presets.dart';
import '../../../budgets/domain/models/budget_item_with_category.dart';
import '../../../budgets/domain/models/budget_tracking.dart';
import '../../../budgets/presentation/providers/budget_item_providers.dart';
import '../../../budgets/presentation/widgets/break_even_summary_card.dart';
import '../../../budgets/presentation/widgets/budget_item_form_dialog.dart';
import '../../../budgets/presentation/widgets/budget_item_tile.dart';
import '../../../budgets/presentation/widgets/budget_variance_card.dart';
import '../../../budgets/presentation/widgets/yield_revenue_forecast_card.dart';
import '../../domain/models/project_metrics.dart';

/// Sub-navigation tab presenting pre-season budget allocations, line items, and dynamic formulas.
class ProjectBudgetTab extends ConsumerWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectBudgetTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  void _showAddItemDialog(
    BuildContext context, {
    String? preselectedCategoryId,
  }) {
    BudgetItemFormDialog.show(
      context,
      projectId: project.id,
      currency: project.currency,
      preselectedCategoryId: preselectedCategoryId,
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    BudgetItemWithCategory itemWithCategory,
  ) {
    BudgetItemFormDialog.show(
      context,
      projectId: project.id,
      currency: project.currency,
      initialItem: itemWithCategory,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BudgetItemWithCategory itemWithCat,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Budget Item?'),
          content: Text(
            'Are you sure you want to remove "${itemWithCat.item.name}" from the budget? This will update your total pre-season allocation.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(budgetItemControllerProvider.notifier)
            .deleteBudgetItem(itemWithCat.item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${itemWithCat.item.name}" from budget.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final groupedBudgetAsync = ref.watch(
      projectGroupedBudgetProvider(project.id),
    );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 48),
      children: [
        // 1. Budget Summary Card
        AppCard(
          title: 'Total Planned Budget',
          subtitle: '${project.currency} pre-season allocation',
          leadingIcon: const Icon(Icons.calculate_outlined),
          trailingAction: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.healthGreenBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${metrics.budgetSpentPercentage.toStringAsFixed(0)}% Spent',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.healthGreen,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MoneyDisplay(
                money: metrics.totalBudgeted,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enforces Planned Amount = Quantity × Unit Cost. Accurately stored in minor currency units.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () => context.push(AppRoutes.budgetCategories),
                      icon: const Icon(Icons.category_outlined, size: 18),
                      label: const Text('Categories'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () => _showAddItemDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Pre-Season Revenue & Return Forecast Card
        YieldRevenueForecastCard(project: project),

        // 3. Break-Even & Capital Protection Threshold Card
        BreakEvenSummaryCard(project: project),

        // 4. Planned vs. Actual Variance & Threshold Alerts
        BudgetVarianceCard(project: project),

        // 5. Budget Groups or Empty State
        groupedBudgetAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading budget items: $err'),
          ),
          data: (groups) {
            if (groups.isEmpty) {
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
                      Icons.playlist_add_outlined,
                      size: 48,
                      color: theme.colorScheme.primary.withAlpha(160),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Budget Items Configured',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Build a pre-season budget before committing capital to seeds, fertilizers, or land preparation.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                      onPressed: () => _showAddItemDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Budget Item'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PLANNED ALLOCATIONS BY CATEGORY',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${groups.fold<int>(0, (acc, g) => acc + g.items.length)} items',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            160,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...groups.map((group) {
                  final catIcon = BudgetCategoryIconHelper.getIcon(
                    group.category.iconName,
                  );
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withAlpha(80),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    catIcon,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      group.category.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${group.percentageOfTotal.toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    group.subtotal.format(),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (group.transactionCount > 0) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: (group.spentPercentage / 100.0)
                                        .clamp(0.0, 1.0),
                                    minHeight: 5,
                                    backgroundColor: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      group.isOverBudget
                                          ? colors.healthRed
                                          : (group.spentPercentage >= 80
                                                ? colors.healthYellow
                                                : colors.healthGreen),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Spent: ${group.effectiveActualSpent.format()} (${group.spentPercentage.toStringAsFixed(0)}%)',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: group.isOverBudget
                                                ? colors.healthRed
                                                : (group.spentPercentage >= 80
                                                      ? colors.healthYellow
                                                      : colors.healthGreen),
                                          ),
                                    ),
                                    Text(
                                      group.isOverBudget
                                          ? 'Overrun: +${(group.effectiveActualSpent - group.subtotal).format()}'
                                          : '${group.remaining.format()} remaining',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: group.isOverBudget
                                                ? colors.healthRed
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            fontWeight: group.isOverBudget
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Line Items in this Category
                        ...group.items.map((itemWithCat) {
                          final tracking = group.itemTrackings?.firstWhere(
                            (t) => t.item.id == itemWithCat.item.id,
                            orElse: () => BudgetItemTracking(
                              itemWithCategory: itemWithCat,
                              actualSpent: Money.zero(
                                currency: itemWithCat.item.currency,
                              ),
                            ),
                          );
                          return BudgetItemTile(
                            itemWithCategory: itemWithCat,
                            tracking: tracking,
                            onEdit: () =>
                                _showEditItemDialog(context, itemWithCat),
                            onDelete: () =>
                                _confirmDelete(context, ref, itemWithCat),
                          );
                        }),

                        // Inline add item under this specific category
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () => _showAddItemDialog(
                                context,
                                preselectedCategoryId: group.category.id,
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('Add to ${group.category.name}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}
