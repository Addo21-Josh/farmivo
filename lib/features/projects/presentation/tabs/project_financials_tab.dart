import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../budgets/presentation/widgets/break_even_summary_card.dart';
import '../../../budgets/presentation/widgets/yield_revenue_forecast_card.dart';
import '../../domain/models/project_metrics.dart';
import '../widgets/dynamic_break_even_card.dart';
import '../widgets/multi_dimensional_profitability_card.dart';
import '../widgets/project_health_score_card.dart';
import '../widgets/scenario_planning_card.dart';

/// Sub-navigation tab presenting executive P&L, break-even estimations,
/// ROI metrics, and financial decision recommendations.
class ProjectFinancialsTab extends StatelessWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectFinancialsTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isProfitable = metrics.netProfit.isPositive;
    final isLoss = metrics.netProfit.isNegative;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      children: [
        // 1. Executive P&L Card
        AppCard(
          title: 'Executive Profit & Loss',
          subtitle: 'Net financial return for ${project.name}',
          leadingIcon: const Icon(Icons.analytics_outlined),
          trailingAction: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isProfitable
                  ? colors.healthGreenBg
                  : (isLoss
                        ? colors.healthRedBg
                        : theme.dividerColor.withAlpha(40)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isProfitable
                  ? 'NET PROFIT'
                  : (isLoss ? 'NET DEFICIT' : 'BREAK-EVEN'),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isProfitable
                    ? colors.healthGreen
                    : (isLoss ? colors.healthRed : Colors.grey),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Return',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MoneyDisplay(
                        money: metrics.netProfit,
                        sentiment: isProfitable
                            ? MoneyDisplaySentiment.positive
                            : (isLoss
                                  ? MoneyDisplaySentiment.negative
                                  : MoneyDisplaySentiment.neutral),
                        showSign: true,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Return on Investment',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${metrics.roiPercentage >= 0 ? "+" : ""}${metrics.roiPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: metrics.roiPercentage > 0
                              ? colors.healthGreen
                              : (metrics.roiPercentage < 0
                                    ? colors.healthRed
                                    : null),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FinancialPill(
                      label: 'Gross Sales Value',
                      value: metrics.totalRevenue.format(),
                      color: colors.cashIn,
                      icon: Icons.storefront_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FinancialPill(
                      label: 'Total Expenditures',
                      value: metrics.totalSpent.format(),
                      color: colors.cashOut,
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _FinancialPill(
                      label: 'Collected Cash',
                      value: metrics.collectedRevenue.format(),
                      color: colors.healthGreen,
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FinancialPill(
                      label: 'Accounts Receivable',
                      value: metrics.accountsReceivable.format(),
                      color: metrics.accountsReceivable.isPositive
                          ? colors.healthYellow
                          : colors.healthGreen,
                      icon: Icons.hourglass_top_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    120,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor.withAlpha(60)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash-Basis Profit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        MoneyDisplay(
                          money: metrics.cashProfit,
                          sentiment: metrics.cashProfit.isPositive
                              ? MoneyDisplaySentiment.positive
                              : (metrics.cashProfit.isNegative
                                    ? MoneyDisplaySentiment.negative
                                    : MoneyDisplaySentiment.neutral),
                          showSign: true,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Cash Collected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${metrics.collectionRatePercentage.toStringAsFixed(0)}% Liquid Cash',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colors.cashIn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Algorithmic Health Score Card (Milestone 7.4)
        ProjectHealthScoreCard(metrics: metrics),

        // 3. Multi-Dimensional Profitability Card (Milestone 7.1)
        MultiDimensionalProfitabilityCard(metrics: metrics),

        // 3. Dynamic Break-Even Analysis Card (Milestone 7.2)
        DynamicBreakEvenCard(metrics: metrics),

        // 4. Pre-Season Revenue & Yield Forecast Modeler
        YieldRevenueForecastCard(project: project),

        // 5. Sensitivity Scenario Planning Matrix (Milestone 7.3)
        ScenarioPlanningCard(project: project),

        // 6. Break-Even & Capital Protection Threshold Card
        BreakEvenSummaryCard(project: project),

        // 5. Decision Engine Advisory (PRD Section 1.2 Question 5)
        AppCard(
          title: 'Decision Recommendation',
          subtitle: 'Agricultural venture viability analysis',
          leadingIcon: const Icon(Icons.psychology_outlined),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      metrics.healthStatus.icon,
                      size: 20,
                      color: colors.healthGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _buildRecommendationTitle(metrics),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _buildRecommendationBody(metrics),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ),

        // 9. Cross-Project Benchmarking Action (Milestone 7.5)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.projectComparison),
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Compare with Other Projects & Past Seasons'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        // 10. Generate Bank-Ready Financial Statement PDF (Milestone 8.2)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ElevatedButton.icon(
            onPressed: () {
              context.push(
                AppRoutes.pdfReportPreview.replaceFirst(
                  ':projectId',
                  project.id,
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Generate Bank-Ready PDF Financial Statement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.healthGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _buildRecommendationTitle(ProjectMetrics m) {
    if (m.stage == ProjectLifecycleState.planning) {
      return 'Action: Finalize Budget Before Launch';
    } else if (m.stage == ProjectLifecycleState.completed ||
        m.stage == ProjectLifecycleState.archived) {
      return m.netProfit.isPositive
          ? 'Recommendation: High Replicability (Repeat Next Season)'
          : 'Recommendation: Audit Category Costs Before Repeating';
    } else if (m.budgetSpentPercentage > 100) {
      return 'Attention: Operational Cost Overrun';
    } else if (m.netProfit.isPositive) {
      return 'Recommendation: Profitable & Scalable Project';
    } else {
      return 'Recommendation: Maintain Agronomic Schedule';
    }
  }

  String _buildRecommendationBody(ProjectMetrics m) {
    if (m.stage == ProjectLifecycleState.planning) {
      return 'Confirm pre-season input costs, labour rates, and land tenure terms before releasing cash funds into field operations.';
    } else if (m.stage == ProjectLifecycleState.completed ||
        m.stage == ProjectLifecycleState.archived) {
      return m.netProfit.isPositive
          ? 'This project achieved a ${m.roiPercentage.toStringAsFixed(1)}% ROI and net profit of ${m.netProfit.format()}. Document lesson notes and prepare to replicate.'
          : 'The project concluded with a net deficit of ${m.netProfit.format()}. Compare actual category expenses against original planned budget to identify leakage.';
    } else if (m.budgetSpentPercentage > 100) {
      return 'Current expenditures exceed the allocated budget by ${(m.budgetSpentPercentage - 100).toStringAsFixed(1)}%. Restrict non-critical spending to prevent further margin compression.';
    } else if (m.netProfit.isPositive) {
      return 'Sales revenue has surpassed total capital expenditures. Complete remaining harvest collections and clear outstanding buyer receivables.';
    } else {
      return 'Continue active field care and monitoring. Ensure timely fertilizer and pest control applications to protect expected yield.';
    }
  }
}

class _FinancialPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _FinancialPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
