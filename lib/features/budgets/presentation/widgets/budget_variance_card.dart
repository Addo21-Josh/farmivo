import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/budget_category_presets.dart';
import '../../domain/models/budget_variance.dart';
import '../providers/budget_variance_providers.dart';

/// Outdoor-optimized card presenting real-time planned vs. actual budget variance,
/// percentage deltas, and automated threshold alerts (Warning ≥80%, Critical 100%, Overrun >100%).
class BudgetVarianceCard extends ConsumerWidget {
  final Project project;

  const BudgetVarianceCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final varianceAsync = ref.watch(projectVarianceReportProvider(project.id));

    return varianceAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (report) {
        // Only render if there are budget items or transactions
        if (report.totalPlanned.isZero && report.totalSpent.isZero) {
          return const SizedBox.shrink();
        }

        final isOverrun = report.variance.isPositive;
        final isUnderBudget = report.variance.isNegative;
        final spentPercentage = report.spentPercentage;
        final alerts = report.categoriesAtRisk;

        return AppCard(
          title: 'Planned vs. Actual Variance',
          subtitle: 'Real-time expenditure & threshold alerts',
          leadingIcon: const Icon(Icons.analytics_outlined),
          trailingAction: _buildStatusPill(context, report.overallThreshold),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Core Variance Summary Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'PLANNED BUDGET',
                      value: report.totalPlanned.format(),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'ACTUAL SPENT',
                      value: report.totalSpent.format(),
                      color: isOverrun
                          ? colors.healthRed
                          : (spentPercentage >= 80
                                ? colors.healthYellow
                                : theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      context,
                      label: 'NET VARIANCE',
                      value:
                          '${isOverrun ? "+" : ""}${report.variance.format()}',
                      subtitle:
                          '${report.variancePercentage >= 0 ? "+" : ""}${report.variancePercentage.toStringAsFixed(1)}%',
                      color: isOverrun
                          ? colors.healthRed
                          : (isUnderBudget
                                ? colors.healthGreen
                                : theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Capital Utilization Progress Bar with 80% & 100% threshold markers
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capital Spent: ${spentPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverrun
                              ? colors.healthRed
                              : (spentPercentage >= 80
                                    ? colors.healthYellow
                                    : colors.healthGreen),
                        ),
                      ),
                      Text(
                        isOverrun
                            ? 'Overrun: +${report.variance.format()}'
                            : '${(report.totalPlanned - report.totalSpent).format()} remaining',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOverrun
                              ? colors.healthRed
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isOverrun
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (spentPercentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverrun
                                ? colors.healthRed
                                : (spentPercentage >= 80
                                      ? colors.healthYellow
                                      : colors.healthGreen),
                          ),
                        ),
                      ),
                      // 80% marker line
                      Positioned(
                        left: (MediaQuery.of(context).size.width - 64) * 0.8,
                        child: Container(
                          width: 2,
                          height: 12,
                          color: theme.dividerColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 3. Automated Threshold Alerts Section
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      report.overrunCount > 0
                          ? Icons.error_outline
                          : Icons.warning_amber_rounded,
                      size: 18,
                      color: report.overrunCount > 0
                          ? colors.healthRed
                          : colors.healthYellow,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVE THRESHOLD ALERTS (${alerts.length})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: report.overrunCount > 0
                            ? colors.healthRed
                            : colors.healthYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...alerts.map(
                  (catVariance) => _buildAlertItem(context, catVariance),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '$label: $value${subtitle != null ? ", $subtitle" : ""}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(
    BuildContext context,
    BudgetVarianceThreshold threshold,
  ) {
    final colors = context.appColors;

    Color bg;
    Color fg;
    IconData icon;

    switch (threshold) {
      case BudgetVarianceThreshold.overrun:
        bg = colors.healthRedBg;
        fg = colors.healthRed;
        icon = Icons.error_outline;
      case BudgetVarianceThreshold.critical:
        bg = colors.healthYellowBg;
        fg = const Color(0xFFE65100); // Deep orange
        icon = Icons.dangerous_outlined;
      case BudgetVarianceThreshold.warning:
        bg = colors.healthYellowBg;
        fg = colors.healthYellow;
        icon = Icons.warning_amber_rounded;
      case BudgetVarianceThreshold.healthy:
        bg = colors.healthGreenBg;
        fg = colors.healthGreen;
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withAlpha(90), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            threshold.displayName,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, CategoryVariance catVariance) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final catIcon = BudgetCategoryIconHelper.getIcon(
      catVariance.category.iconName,
    );

    final isOverrun = catVariance.threshold == BudgetVarianceThreshold.overrun;
    final isCritical =
        catVariance.threshold == BudgetVarianceThreshold.critical;

    final badgeColor = isOverrun
        ? colors.healthRed
        : (isCritical ? const Color(0xFFE65100) : colors.healthYellow);
    final badgeBg = isOverrun ? colors.healthRedBg : colors.healthYellowBg;

    return Semantics(
      container: true,
      label:
          'Category warning: ${catVariance.category.name}, ${catVariance.alertMessage}, ${catVariance.spentPercentage.toStringAsFixed(0)}% of allocation spent',
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: badgeColor.withAlpha(90)),
        ),
        child: Row(
          children: [
            Icon(catIcon, size: 18, color: badgeColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catVariance.category.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                  Text(
                    catVariance.alertMessage,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${catVariance.spentPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
