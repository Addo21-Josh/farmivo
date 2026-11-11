import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme_extension.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../projects/presentation/providers/project_providers.dart';
import 'providers/reports_providers.dart';
import 'widgets/budget_vs_actual_bar_chart.dart';
import 'widgets/cash_flow_trend_line_chart.dart';
import 'widgets/expense_category_donut_chart.dart';
import 'widgets/export_options_sheet.dart';
import 'widgets/project_comparison_bar_chart.dart';

/// Executive Financial Analytics, Charting, and Reporting screen (Milestone 8).
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final selectedProjectId = ref.watch(selectedReportProjectIdProvider);
    final projectsAsync = ref.watch(projectsWithFarmStreamProvider);
    final expenseSharesAsync = ref.watch(reportCategoryExpenseSharesProvider);
    final cashFlowAsync = ref.watch(reportCashFlowTimelineProvider);
    final varianceAsync = ref.watch(reportVarianceProvider);
    final comparisonMatrixAsync = ref.watch(reportComparisonMatrixProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analytics',
            onPressed: () {
              ref.invalidate(reportCategoryExpenseSharesProvider);
              ref.invalidate(reportCashFlowTimelineProvider);
              ref.invalidate(reportVarianceProvider);
              ref.invalidate(reportComparisonMatrixProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 40),
        children: [
          // 1. Project Selector Filter Card
          AppCard(
            title: 'Scope Selection',
            subtitle: 'Choose individual project or combined portfolio view',
            leadingIcon: const Icon(Icons.tune_outlined),
            child: projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading projects: $e'),
              data: (projects) {
                return DropdownButtonFormField<String?>(
                  key: ValueKey(selectedProjectId),
                  initialValue: selectedProjectId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Reporting Scope',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'All Projects (Portfolio Overview)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...projects.map(
                      (p) => DropdownMenuItem<String?>(
                        value: p.project.id,
                        child: Text(
                          '${p.project.name} (${p.project.commodity})',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    ref.read(selectedReportProjectIdProvider.notifier).state =
                        val;
                  },
                );
              },
            ),
          ),

          // 2. Executive KPI Summary Card
          _buildExecutiveKpiCard(context, ref, selectedProjectId),

          // 3. Chart 1: Expense Breakdown by Category (Donut Chart)
          expenseSharesAsync.when(
            loading: () =>
                const _ChartLoadingCard(title: 'Expense Breakdown by Category'),
            error: (e, _) =>
                AppCard(title: 'Expense Breakdown', child: Text('Error: $e')),
            data: (shares) => ExpenseCategoryDonutChart(
              shares: shares,
              title: selectedProjectId == null
                  ? 'Portfolio Expense Distribution'
                  : 'Expense Breakdown by Category',
            ),
          ),

          // 4. Chart 2: Planned vs. Actual Budget Spending (Grouped Bar Chart)
          varianceAsync.when(
            loading: () =>
                const _ChartLoadingCard(title: 'Budget vs. Actual Spending'),
            error: (e, _) =>
                AppCard(title: 'Budget vs. Actual', child: Text('Error: $e')),
            data: (varianceReport) {
              if (selectedProjectId == null) {
                return AppCard(
                  title: 'Budget vs. Actual Spending',
                  subtitle:
                      'Select an individual project above for category variance',
                  leadingIcon: const Icon(Icons.bar_chart_outlined),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Budget vs. Actual comparison is calculated per project. Select a specific project above to inspect category-level variance.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }
              return BudgetVsActualBarChart(report: varianceReport);
            },
          ),

          // 5. Chart 3: Cumulative Cash Flow Trend Over Time (Line Chart with Crossover)
          cashFlowAsync.when(
            loading: () =>
                const _ChartLoadingCard(title: 'Cumulative Cash Flow Trend'),
            error: (e, _) =>
                AppCard(title: 'Cash Flow Trend', child: Text('Error: $e')),
            data: (timeline) => CashFlowTrendLineChart(timeline: timeline),
          ),

          // 6. Chart 4: Cross-Project Financial Comparison (Grouped Bar Chart)
          comparisonMatrixAsync.when(
            loading: () => const _ChartLoadingCard(
              title: 'Cross-Project Financial Comparison',
            ),
            error: (e, _) =>
                AppCard(title: 'Project Comparison', child: Text('Error: $e')),
            data: (matrix) => ProjectComparisonBarChart(matrix: matrix),
          ),

          // 7. Milestone 8.2 & 8.3 Bank-Ready Report Action Banner
          InkWell(
            onTap: () {
              ExportOptionsSheet.show(context, projectId: selectedProjectId);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.healthGreenBg.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.healthGreen.withAlpha(90)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 28,
                    color: colors.healthGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank-Ready Financial Statement',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.healthGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Generate verified 3-page PDF statement and export raw CSV ledgers for banks, cooperatives, and tax compliance.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.healthGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveKpiCard(
    BuildContext context,
    WidgetRef ref,
    String? selectedProjectId,
  ) {
    final colors = context.appColors;

    if (selectedProjectId != null) {
      final metricsAsync = ref.watch(projectMetricsProvider(selectedProjectId));

      return metricsAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => const SizedBox.shrink(),
        data: (m) {
          if (m == null) return const SizedBox.shrink();

          return AppCard(
            title: 'Executive Financial Summary',
            subtitle: '${m.stage.displayName} • ${m.daysActive} days active',
            leadingIcon: const Icon(Icons.analytics_outlined),
            child: Row(
              children: [
                Expanded(
                  child: _KpiTile(
                    label: 'Gross Sales',
                    value: m.totalRevenue.format(),
                    color: colors.cashIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiTile(
                    label: 'Total Expenses',
                    value: m.totalSpent.format(),
                    color: colors.cashOut,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiTile(
                    label: 'Net Profit',
                    value: m.netProfit.format(),
                    color: m.netProfit.isPositive
                        ? colors.healthGreen
                        : (m.netProfit.isNegative
                              ? colors.healthRed
                              : Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Portfolio View
      final matrixAsync = ref.watch(reportComparisonMatrixProvider);

      return matrixAsync.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const SizedBox.shrink(),
        data: (matrix) {
          return AppCard(
            title: 'Executive Portfolio Summary',
            subtitle: '${matrix.records.length} ventures active & completed',
            leadingIcon: const Icon(Icons.analytics_outlined),
            child: Row(
              children: [
                Expanded(
                  child: _KpiTile(
                    label: 'Gross Sales',
                    value: matrix.totalRevenue.format(),
                    color: colors.cashIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiTile(
                    label: 'Total Deployed',
                    value: matrix.totalCapitalInvested.format(),
                    color: colors.cashOut,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiTile(
                    label: 'Net Return',
                    value: matrix.totalNetProfit.format(),
                    color: matrix.totalNetProfit.isPositive
                        ? colors.healthGreen
                        : (matrix.totalNetProfit.isNegative
                              ? colors.healthRed
                              : Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartLoadingCard extends StatelessWidget {
  final String title;

  const _ChartLoadingCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: title,
      leadingIcon: const Icon(Icons.hourglass_top_outlined),
      child: const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
