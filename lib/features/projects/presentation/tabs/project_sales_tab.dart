import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../sales/presentation/providers/sale_providers.dart';
import '../../../sales/presentation/widgets/sale_tile.dart';
import '../../domain/models/project_metrics.dart';

/// Sub-navigation tab presenting commercial harvest sales, customer receivables,
/// and liquid cash settlement tracking.
class ProjectSalesTab extends ConsumerWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectSalesTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final salesAsync = ref.watch(projectSalesWithDetailsProvider(project.id));
    final summaryAsync = ref.watch(projectSalesSummaryProvider(project.id));

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      children: [
        // 1. Commercial Sales & Receivables Summary Card
        summaryAsync.when(
          loading: () => AppCard(
            title: 'Commercial Revenue',
            subtitle: '${project.currency} sales earnings',
            leadingIcon: const Icon(Icons.point_of_sale_outlined),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (_, __) => _buildMetricsFallbackCard(context, colors, theme),
          data: (summary) {
            return AppCard(
              title: 'Commercial Revenue',
              subtitle: '${project.currency} sales earnings',
              leadingIcon: const Icon(Icons.point_of_sale_outlined),
              trailingAction: summary.totalAccountsReceivable.isPositive
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.healthYellowBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${summary.totalAccountsReceivable.format()} Due',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.healthYellow,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.healthGreenBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'All Settled',
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
                    money: summary.totalGrossSales,
                    sentiment: MoneyDisplaySentiment.positive,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gross Sales Value (Accrual)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator of cash collected vs gross
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: summary.totalGrossSales.isPositive
                                ? (summary.collectionRatePercentage / 100.0)
                                      .clamp(0.0, 1.0)
                                : 0.0,
                            backgroundColor: colors.healthYellowBg,
                            color: colors.cashIn,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${summary.collectionRatePercentage.toStringAsFixed(0)}% Cash Collected',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.cashIn,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Milestone 6.4: Separation of Sales vs Collected Cash & Receivables
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.healthGreenBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colors.healthGreen.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    size: 14,
                                    color: colors.healthGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Collected Revenue',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                summary.totalCashCollected.format(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: colors.healthGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: summary.totalAccountsReceivable.isPositive
                                ? colors.healthYellowBg
                                : theme.dividerColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: summary.totalAccountsReceivable.isPositive
                                  ? colors.healthYellow.withAlpha(50)
                                  : theme.dividerColor.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_top_outlined,
                                    size: 14,
                                    color:
                                        summary
                                            .totalAccountsReceivable
                                            .isPositive
                                        ? colors.healthYellow
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Accounts Receivable',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                summary.totalAccountsReceivable.format(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color:
                                      summary.totalAccountsReceivable.isPositive
                                      ? colors.healthYellow
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // 2. Action Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commercial Sales',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    onPressed: () => context.push(AppRoutes.buyers),
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Buyers'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    onPressed: () =>
                        context.push(AppRoutes.addSale, extra: project.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Record Sale'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // 3. Sales Ledger Stream
        salesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading sales: $err'),
          ),
          data: (sales) {
            final validSales = sales.where((s) => !s.sale.isVoided).toList();

            if (validSales.isEmpty) {
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
                      Icons.storefront_outlined,
                      size: 48,
                      color: colors.cashIn.withAlpha(160),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Commercial Sales Recorded',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Record transactions to commercial off-takers, market women, or retail consumers.',
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
                      onPressed: () =>
                          context.push(AppRoutes.addSale, extra: project.id),
                      icon: const Icon(Icons.add),
                      label: const Text('Record Harvest Sale'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: validSales.map((sale) {
                return SaleTile(sale: sale);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricsFallbackCard(
    BuildContext context,
    AppThemeExtension colors,
    ThemeData theme,
  ) {
    return AppCard(
      title: 'Commercial Revenue',
      subtitle: '${project.currency} sales earnings',
      leadingIcon: const Icon(Icons.point_of_sale_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoneyDisplay(
            money: metrics.totalRevenue,
            sentiment: MoneyDisplaySentiment.positive,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tracks market sales, buyer credit terms, and cash/MoMo collections.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}
