import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/project_metrics.dart';

/// Interactive financial card presenting live in-season break-even analysis (Milestone 7.2):
/// - Cost recovery progress (% of incurred costs recouped via sales and liquid cash)
/// - Unrecovered capital deficit
/// - Remaining crop units (kg/bags/crates/birds) required to achieve break-even
/// - Feasibility assessment comparing remaining units with remaining harvest yield
class DynamicBreakEvenCard extends StatelessWidget {
  final ProjectMetrics metrics;

  const DynamicBreakEvenCard({super.key, required this.metrics});

  DynamicBreakEven get breakEven => metrics.dynamicBreakEven;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isAccrualAchieved = breakEven.isAccrualBreakEvenAchieved;
    final isCashAchieved = breakEven.isCashBreakEvenAchieved;
    final feasibility = breakEven.feasibility;

    // Determine badge text and styling
    final String badgeText;
    final Color badgeColor;
    final Color badgeBg;
    final IconData badgeIcon;

    if (isAccrualAchieved) {
      badgeText = isCashAchieved ? 'CASH BREAK-EVEN' : 'BREAK-EVEN ACHIEVED';
      badgeColor = colors.healthGreen;
      badgeBg = colors.healthGreenBg;
      badgeIcon = Icons.check_circle_outline;
    } else if (feasibility == BreakEvenFeasibility.onTrack) {
      badgeText = 'ON TRACK';
      badgeColor = colors.healthGreen;
      badgeBg = colors.healthGreenBg;
      badgeIcon = Icons.trending_up;
    } else {
      badgeText = 'SHORTFALL RISK';
      badgeColor = colors.healthRed;
      badgeBg = colors.healthRedBg;
      badgeIcon = Icons.warning_amber_rounded;
    }

    final recoveryRatio = (breakEven.accrualRecoveryPercentage / 100.0).clamp(
      0.0,
      1.0,
    );

    return Semantics(
      container: true,
      label:
          'Dynamic Break-Even Analysis: $badgeText. Cost recouped: ${breakEven.accrualRecoveryPercentage.toStringAsFixed(1)}%. Deficit to break-even: ${breakEven.accrualDeficit.format()}. Remaining output required: ${breakEven.remainingUnitsToBreakEven.toStringAsFixed(1)} ${breakEven.unit}.',
      child: AppCard(
        title: 'Dynamic Break-Even Analysis',
        subtitle: 'In-season cost recoupment & volume targets',
        leadingIcon: const Icon(Icons.toll_outlined),
        trailingAction: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                badgeText,
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
            // 1. Live Capital Recovery Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Cost Recouped: ${breakEven.accrualRecoveryPercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${breakEven.cashRecoveryPercentage.toStringAsFixed(0)}% Liquid Cash',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCashAchieved ? colors.healthGreen : colors.cashIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: recoveryRatio,
                minHeight: 10,
                backgroundColor: theme.dividerColor.withAlpha(50),
                color: isAccrualAchieved ? colors.healthGreen : colors.cashIn,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Primary Metrics: Unrecovered Deficit & Remaining Units
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Unrecovered Deficit',
                    value: breakEven.accrualDeficit.format(),
                    subtext: isAccrualAchieved
                        ? '100% Incurred Costs Covered'
                        : 'Pending Gross Sales',
                    valueColor: isAccrualAchieved
                        ? colors.healthGreen
                        : colors.cashOut,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricTile(
                    label: 'Units to Break-Even',
                    value: isAccrualAchieved
                        ? '0 ${breakEven.unit}'
                        : '${breakEven.formattedRemainingUnits} ${breakEven.unit}',
                    subtext: breakEven.effectiveUnitPrice.isPositive
                        ? '@ ${breakEven.effectiveUnitPrice.format()} / ${breakEven.unit}'
                        : 'Baseline price pending',
                    valueColor: isAccrualAchieved
                        ? colors.healthGreen
                        : theme.textTheme.bodyLarge?.color,
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. Liquid Cash Break-Even Sub-Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withAlpha(60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Liquid Cash Deficit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          breakEven.cashDeficit.format(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCashAchieved
                                ? colors.healthGreen
                                : colors.cashOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Cash Volume Target',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCashAchieved
                              ? '0 ${breakEven.unit}'
                              : '${_formatUnits(breakEven.remainingUnitsCashBreakEven)} ${breakEven.unit}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCashAchieved
                                ? colors.healthGreen
                                : colors.cashIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. In-Season Feasibility & Decision Advisory Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeBg.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withAlpha(80)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(badgeIcon, size: 20, color: badgeColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      breakEven.advisoryMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
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

  static String _formatUnits(double units) {
    return units % 1 == 0 ? units.toInt().toString() : units.toStringAsFixed(1);
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Color? valueColor;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtext,
    this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '$label: $value, $subtext',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
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
