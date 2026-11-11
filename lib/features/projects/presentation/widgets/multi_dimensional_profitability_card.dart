import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../domain/models/project_metrics.dart';

/// Outdoor-optimized visual card presenting the 3 distinct financial profitability dimensions:
/// 1. Actual Net Profit & Actual ROI % (Accrual)
/// 2. Cash-Basis Profit & Cash ROI % (Liquid Cash)
/// 3. Projected Final Profit & Projected ROI % (Tri-Value Dynamic In-Season Projection)
class MultiDimensionalProfitabilityCard extends StatelessWidget {
  final ProjectMetrics metrics;

  const MultiDimensionalProfitabilityCard({super.key, required this.metrics});

  ProjectProfitability get profitability => metrics.profitability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final actualRoi = profitability.actualRoiPercentage;
    final cashRoi = profitability.cashRoiPercentage;
    final projectedRoi = profitability.projectedRoiPercentage;

    return Semantics(
      container: true,
      label:
          'Multi-Dimensional Profitability. Actual Net Profit: ${profitability.actualNetProfit.format()}, ROI: ${actualRoi.toStringAsFixed(1)}%. Liquid Cash Profit: ${profitability.cashProfit.format()}, Cash ROI: ${cashRoi.toStringAsFixed(1)}%. Projected Final Profit: ${profitability.projectedProfit.format()}, Projected ROI: ${projectedRoi.toStringAsFixed(1)}%.',
      child: AppCard(
        title: 'Multi-Dimensional Profitability',
        subtitle: 'Actuals vs. Liquid Cash vs. Full-Cycle Projection',
        leadingIcon: const Icon(Icons.insights_outlined),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dimension 1: Actual Net Profit (Accrual basis)
            _ProfitDimensionRow(
              title: 'Actual Net Profit (Accrual)',
              subtitle: 'Recorded sales revenue minus actual incurred costs',
              money: profitability.actualNetProfit,
              roiPercentage: actualRoi,
              roiLabel: 'Actual ROI',
              icon: Icons.storefront_outlined,
              isPositive: profitability.isActualProfitable,
              isNegative: profitability.actualNetProfit.isNegative,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Dimension 2: Cash-Basis Profit (Liquid Cash)
            _ProfitDimensionRow(
              title: 'Cash-Basis Profit (Liquid Cash)',
              subtitle: 'Cash actually collected minus disbursed expenses',
              money: profitability.cashProfit,
              roiPercentage: cashRoi,
              roiLabel: 'Cash ROI',
              icon: Icons.payments_outlined,
              isPositive: profitability.isCashProfitable,
              isNegative: profitability.cashProfit.isNegative,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Dimension 3: Projected Final Profit (Tri-Value Dynamic Projection)
            _ProfitDimensionRow(
              title: 'Projected Final Profit (Tri-Value)',
              subtitle:
                  'Actuals to date plus remaining unharvested yield potential',
              money: profitability.projectedProfit,
              roiPercentage: projectedRoi,
              roiLabel: 'Projected ROI',
              icon: Icons.trending_up,
              isPositive: profitability.isProjectedProfitable,
              isNegative: profitability.projectedProfit.isNegative,
            ),
            const SizedBox(height: 14),

            // Tri-Value Calculation Breakdown Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tri-Value Projection Synthesis',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _TriValueDetailRow(
                    label: 'Projected Revenue',
                    formula:
                        '${profitability.actualRevenue.format()} (Actual) + ${profitability.remainingAnticipatedRevenue.format()} (Remaining)',
                    total: profitability.projectedRevenue.format(),
                    color: colors.cashIn,
                  ),
                  const SizedBox(height: 6),
                  _TriValueDetailRow(
                    label: 'Projected Costs',
                    formula:
                        '${profitability.actualExpenses.format()} (Actual) + ${profitability.remainingEstimatedCost.format()} (Remaining Budget)',
                    total: profitability.projectedCost.format(),
                    color: colors.cashOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfitDimensionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Money money;
  final double roiPercentage;
  final String roiLabel;
  final IconData icon;
  final bool isPositive;
  final bool isNegative;

  const _ProfitDimensionRow({
    required this.title,
    required this.subtitle,
    required this.money,
    required this.roiPercentage,
    required this.roiLabel,
    required this.icon,
    required this.isPositive,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final badgeBgColor = isPositive
        ? colors.healthGreenBg
        : (isNegative ? colors.healthRedBg : theme.dividerColor.withAlpha(30));
    final badgeTextColor = isPositive
        ? colors.healthGreen
        : (isNegative ? colors.healthRed : Colors.grey);

    final sign = roiPercentage > 0 ? '+' : '';
    final formattedRoi = '$sign${roiPercentage.toStringAsFixed(1)}%';

    return Semantics(
      container: true,
      label: '$title: ${money.format()}, $roiLabel: $formattedRoi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: badgeTextColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Explicit ROI Badge (Milestone 7.1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeTextColor.withAlpha(60)),
                ),
                child: Text(
                  '$roiLabel: $formattedRoi',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          MoneyDisplay(
            money: money,
            showSign: true,
            sentiment: isPositive
                ? MoneyDisplaySentiment.positive
                : (isNegative
                      ? MoneyDisplaySentiment.negative
                      : MoneyDisplaySentiment.neutral),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TriValueDetailRow extends StatelessWidget {
  final String label;
  final String formula;
  final String total;
  final Color color;

  const _TriValueDetailRow({
    required this.label,
    required this.formula,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formula,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Text(
          total,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
