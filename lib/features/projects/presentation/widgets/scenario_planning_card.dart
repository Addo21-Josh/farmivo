import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../budgets/presentation/providers/forecast_providers.dart';
import '../../../budgets/presentation/widgets/revenue_forecast_modeler_sheet.dart';

/// Pre-season visual card presenting the 3-scenario sensitivity matrix (Milestone 7.3):
/// 1. Conservative (Worst Case): -20% Yield, -15% Price
/// 2. Expected Case: Budgeted / Target assumptions
/// 3. Optimistic (Best Case): +15% Yield, +10% Price
///
/// Provides instant comparative visualization of profit, downside exposure, and capital protection.
class ScenarioPlanningCard extends ConsumerWidget {
  final Project project;

  const ScenarioPlanningCard({super.key, required this.project});

  void _openModeler(BuildContext context, Scenario? scenario) {
    RevenueForecastModelerSheet.show(
      context,
      project: project,
      initialScenario: scenario,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final matrixAsync = ref.watch(
      projectScenarioPlanningMatrixProvider(project.id),
    );
    final expectedScenarioAsync = ref.watch(
      projectForecastProvider(project.id),
    );

    return matrixAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error loading scenario matrix: $err'),
      ),
      data: (matrix) {
        if (matrix == null) {
          // Empty state: no forecast scenario exists yet
          return AppCard(
            title: 'Scenario Planning Matrix',
            subtitle:
                'Conservative vs. Expected vs. Optimistic Downside Exposure',
            leadingIcon: const Icon(Icons.analytics_outlined),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulate 3-way agricultural sensitivity scenarios (-20% yield and -15% price drops) to evaluate downside capital risk before launching operations.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openModeler(context, null),
                  icon: const Icon(Icons.tune_outlined, size: 18),
                  label: const Text('Model Sensitivity Scenarios'),
                ),
              ],
            ),
          );
        }

        final rating = matrix.riskRating;
        final Color badgeColor;
        final Color badgeBg;
        final IconData badgeIcon;

        switch (rating) {
          case DownsideExposureRisk.robust:
            badgeColor = colors.healthGreen;
            badgeBg = colors.healthGreenBg;
            badgeIcon = Icons.verified_user_outlined;
            break;
          case DownsideExposureRisk.moderate:
            badgeColor = colors.healthYellow;
            badgeBg = colors.healthYellowBg;
            badgeIcon = Icons.info_outline;
            break;
          case DownsideExposureRisk.high:
            badgeColor = colors.healthRed;
            badgeBg = colors.healthRedBg;
            badgeIcon = Icons.warning_amber_rounded;
            break;
        }

        return Semantics(
          container: true,
          label:
              'Sensitivity Scenario Matrix: ${matrix.riskBadgeLabel}. Conservative profit: ${matrix.conservative.projectedProfit.format()}, ROI: ${matrix.conservative.projectedRoiPercent.toStringAsFixed(1)}%. Expected profit: ${matrix.expected.projectedProfit.format()}, ROI: ${matrix.expected.projectedRoiPercent.toStringAsFixed(1)}%. Optimistic profit: ${matrix.optimistic.projectedProfit.format()}, ROI: ${matrix.optimistic.projectedRoiPercent.toStringAsFixed(1)}%.',
          child: AppCard(
            title: 'Sensitivity Scenario Matrix',
            subtitle:
                'Conservative vs. Expected vs. Optimistic Downside Exposure',
            leadingIcon: const Icon(Icons.tune_outlined),
            trailingAction: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 14, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    matrix.riskBadgeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Three-Column Comparative Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ScenarioColumn(
                        item: matrix.conservative,
                        accentColor: matrix.conservative.isLoss
                            ? colors.healthRed
                            : colors.healthYellow,
                        isHighlighted: false,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ScenarioColumn(
                        item: matrix.expected,
                        accentColor: theme.colorScheme.primary,
                        isHighlighted: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ScenarioColumn(
                        item: matrix.optimistic,
                        accentColor: colors.healthGreen,
                        isHighlighted: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Downside Capital Protection & Risk Assessment Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badgeBg.withAlpha(90),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withAlpha(80)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(badgeIcon, size: 18, color: badgeColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              rating == DownsideExposureRisk.robust
                                  ? 'Resilient Downside Defense'
                                  : (rating == DownsideExposureRisk.moderate
                                        ? 'Moderate Capital Exposure'
                                        : 'High Downside Vulnerability'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (matrix.downsideDeficit.isPositive)
                            Text(
                              'At Risk: ${matrix.downsideDeficit.format()}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        matrix.advisoryMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Profit Spread & Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Profit Range: ${matrix.conservative.projectedProfit.format()} to ${matrix.optimistic.projectedProfit.format()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            190,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        final exp = expectedScenarioAsync.valueOrNull;
                        _openModeler(context, exp);
                      },
                      icon: const Icon(Icons.edit_note_outlined, size: 16),
                      label: const Text('Adjust Scenarios'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScenarioColumn extends StatelessWidget {
  final ScenarioMatrixItem item;
  final Color accentColor;
  final bool isHighlighted;

  const _ScenarioColumn({
    required this.item,
    required this.accentColor,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isProfit = item.isProfitable;
    final isLoss = item.isLoss;

    return Semantics(
      container: true,
      label:
          '${item.title} Scenario: Projected Profit: ${item.projectedProfit.format()}, ROI: ${item.projectedRoiPercent.toStringAsFixed(1)}%, Yield: ${item.expectedYield.toStringAsFixed(0)} ${item.yieldUnit}, Price: ${item.expectedUnitPrice.format()}',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.colorScheme.primary.withAlpha(20)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(70),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted
                ? theme.colorScheme.primary.withAlpha(120)
                : theme.dividerColor.withAlpha(80),
            width: isHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(35),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Net Profit
            Text(
              'Net Return',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 1),
            MoneyDisplay(
              money: item.projectedProfit,
              sentiment: isProfit
                  ? MoneyDisplaySentiment.positive
                  : (isLoss
                        ? MoneyDisplaySentiment.negative
                        : MoneyDisplaySentiment.neutral),
              showSign: true,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            const SizedBox(height: 4),

            // ROI %
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isProfit
                    ? colors.healthGreenBg
                    : (isLoss ? colors.healthRedBg : Colors.grey.withAlpha(40)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.formattedRoi,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isProfit
                      ? colors.healthGreen
                      : (isLoss ? colors.healthRed : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Yield & Price Details
            Text(
              '${item.formattedYield} ${item.yieldUnit}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              '@ ${item.expectedUnitPrice.format()}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Rev: ${item.projectedRevenue.format()}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.cashIn,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
