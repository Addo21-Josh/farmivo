import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/project_metrics.dart';

/// Interactive visual card presenting the algorithmic project health score (Milestone 7.4):
/// - 5-factor weighted breakdown (Budget 30%, Revenue 25%, Liquidity 20%, Schedule 15%, Credit Risk 10%)
/// - Composite health score gauge (0 to 100)
/// - Visual health badges: 🟢 Healthy (>= 80), 🟡 Watch (60-79), 🔴 At Risk (< 60)
/// - Explicit explanation engine with plain-text diagnostic rationale
class ProjectHealthScoreCard extends StatelessWidget {
  final ProjectMetrics metrics;

  const ProjectHealthScoreCard({super.key, required this.metrics});

  ProjectHealthEvaluation get evaluation => metrics.healthEvaluation;
  ProjectHealthBreakdown get breakdown => evaluation.breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final status = evaluation.status;
    final score = evaluation.score;

    final Color statusColor;
    final Color statusBg;
    final IconData statusIcon;

    switch (status) {
      case ProjectHealthStatus.healthy:
        statusColor = colors.healthGreen;
        statusBg = colors.healthGreenBg;
        statusIcon = Icons.check_circle_outline;
        break;
      case ProjectHealthStatus.watch:
        statusColor = colors.healthYellow;
        statusBg = colors.healthYellowBg;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case ProjectHealthStatus.atRisk:
        statusColor = colors.healthRed;
        statusBg = colors.healthRedBg;
        statusIcon = Icons.error_outline_rounded;
        break;
    }

    return Semantics(
      container: true,
      label:
          'Project Health Score: $score out of 100, ${status.label} status. ${evaluation.summary}',
      child: AppCard(
        title: 'Algorithmic Health Score',
        subtitle: '5-factor composite viability rating (0–100)',
        leadingIcon: const Icon(Icons.health_and_safety_outlined),
        trailingAction: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                evaluation.badgeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Composite Score Gauge Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withAlpha(70)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$score',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            ' / 100',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        status.label.toUpperCase(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (score / 100.0).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: theme.dividerColor.withAlpha(50),
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. 5 Weighted Criteria Indicators
            Text(
              'Weighted Viability Breakdown',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            _CriteriaBar(
              title: 'Budget Discipline',
              weightLabel: '30% Weight',
              score: breakdown.budgetDisciplineScore,
              statusColor: _resolveScoreColor(
                breakdown.budgetDisciplineScore,
                colors,
              ),
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 6),

            _CriteriaBar(
              title: 'Revenue Performance',
              weightLabel: '25% Weight',
              score: breakdown.revenuePerformanceScore,
              statusColor: _resolveScoreColor(
                breakdown.revenuePerformanceScore,
                colors,
              ),
              icon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 6),

            _CriteriaBar(
              title: 'Cash Liquidity',
              weightLabel: '20% Weight',
              score: breakdown.cashLiquidityScore,
              statusColor: _resolveScoreColor(
                breakdown.cashLiquidityScore,
                colors,
              ),
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 6),

            _CriteriaBar(
              title: 'Operational Schedule Drift',
              weightLabel: '15% Weight',
              score: breakdown.scheduleDriftScore,
              statusColor: _resolveScoreColor(
                breakdown.scheduleDriftScore,
                colors,
              ),
              icon: Icons.calendar_month_outlined,
            ),
            const SizedBox(height: 6),

            _CriteriaBar(
              title: 'Credit Risk (Receivables)',
              weightLabel: '10% Weight',
              score: breakdown.creditRiskScore,
              statusColor: _resolveScoreColor(
                breakdown.creditRiskScore,
                colors,
              ),
              icon: Icons.credit_score_outlined,
            ),
            const SizedBox(height: 14),

            // 3. Explicit Explanation Engine
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusBg.withAlpha(90),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withAlpha(80)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(statusIcon, size: 20, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Algorithmic Diagnostics',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          evaluation.summary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _resolveScoreColor(double score, AppThemeExtension colors) {
    if (score >= 80) return colors.healthGreen;
    if (score >= 60) return colors.healthYellow;
    return colors.healthRed;
  }
}

class _CriteriaBar extends StatelessWidget {
  final String title;
  final String weightLabel;
  final double score;
  final Color statusColor;
  final IconData icon;

  const _CriteriaBar({
    required this.title,
    required this.weightLabel,
    required this.score,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '$title, weight $weightLabel: ${score.round()} out of 100',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($weightLabel)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${score.round()}/100',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (score / 100.0).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: theme.dividerColor.withAlpha(40),
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
