import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/project_metrics.dart';
import '../../domain/state_machine/project_state_machine.dart';
import 'project_status_transition_dialog.dart';

/// Outdoor-optimized vital metrics header card for the Project Detail Hub.
///
/// Surfaces the 4 core parameters:
/// 1. Days Active
/// 2. Current Stage (with interactive transition dialog trigger)
/// 3. Total Spent (formatted in precise currency minor units)
/// 4. Projected Yield (with actual harvest progress)
class ProjectVitalMetricsHeader extends StatelessWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectVitalMetricsHeader({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final stage = metrics.stage;
    final totalSpentFormatted = metrics.totalSpent.format();
    final budgetFormatted = metrics.totalBudgeted.isPositive
        ? metrics.totalBudgeted.format()
        : null;

    final budgetSubtitle = budgetFormatted != null
        ? 'of $budgetFormatted (${metrics.budgetSpentPercentage.toStringAsFixed(0)}%)'
        : 'Budget not set';

    final yieldSubtitle = metrics.actualYieldTotal > 0
        ? '${metrics.actualYieldTotal.toStringAsFixed(metrics.actualYieldTotal.truncateToDouble() == metrics.actualYieldTotal ? 0 : 1)} ${metrics.actualYieldUnit} harvested'
        : 'Expected at harvest';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Health Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _resolveHealthBackgroundColor(
                context,
                metrics.healthStatus,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  metrics.healthStatus.icon,
                  size: 20,
                  color: _resolveHealthForegroundColor(
                    context,
                    metrics.healthStatus,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metrics.healthMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _resolveHealthForegroundColor(
                        context,
                        metrics.healthStatus,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _resolveHealthForegroundColor(
                        context,
                        metrics.healthStatus,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    metrics.healthStatus.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _resolveHealthForegroundColor(
                        context,
                        metrics.healthStatus,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Metrics 2x2 Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Column 1: Days Active & Total Spent
                Expanded(
                  child: Column(
                    children: [
                      _MetricTile(
                        icon: Icons.calendar_today_outlined,
                        iconColor: theme.colorScheme.primary,
                        label: 'DAYS ACTIVE',
                        value:
                            '${metrics.daysActive} ${metrics.daysActive == 1 ? "Day" : "Days"}',
                        subtitle: 'Since launch',
                      ),
                      const SizedBox(height: 12),
                      _MetricTile(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor:
                            metrics.healthStatus == ProjectHealthStatus.atRisk
                            ? colors.healthRed
                            : theme.colorScheme.primary,
                        label: 'TOTAL SPENT',
                        value: totalSpentFormatted,
                        subtitle: budgetSubtitle,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 130,
                  color: theme.dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Column 2: Current Stage & Projected Yield
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          ProjectStatusTransitionDialog.show(
                            context,
                            project: project,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: _MetricTile(
                          icon: stage.stageIcon,
                          iconColor: theme.colorScheme.primary,
                          label: 'CURRENT STAGE',
                          value: stage.displayName,
                          subtitle: 'Tap to change stage',
                          isInteractive: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MetricTile(
                        icon: Icons.grass_outlined,
                        iconColor: colors.healthGreen,
                        label: 'PROJECTED YIELD',
                        value: metrics.projectedYieldDisplay,
                        subtitle: yieldSubtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _resolveHealthBackgroundColor(
    BuildContext context,
    ProjectHealthStatus status,
  ) {
    final colors = context.appColors;

    switch (status) {
      case ProjectHealthStatus.healthy:
        return colors.healthGreenBg;
      case ProjectHealthStatus.watch:
        return colors.healthYellowBg;
      case ProjectHealthStatus.atRisk:
        return colors.healthRedBg;
    }
  }

  Color _resolveHealthForegroundColor(
    BuildContext context,
    ProjectHealthStatus status,
  ) {
    final colors = context.appColors;

    switch (status) {
      case ProjectHealthStatus.healthy:
        return colors.healthGreen;
      case ProjectHealthStatus.watch:
        return colors.healthYellow;
      case ProjectHealthStatus.atRisk:
        return colors.healthRed;
    }
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;
  final bool isInteractive;

  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isInteractive)
                Icon(Icons.arrow_drop_down, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: isInteractive
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodySmall?.color?.withAlpha(160),
              fontWeight: isInteractive ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
