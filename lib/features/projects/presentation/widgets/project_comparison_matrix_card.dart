import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/financial_engine/project_comparison.dart';
import '../../../../shared/widgets/app_card.dart';

/// Interactive visual card presenting a side-by-side comparison matrix across multiple projects (Milestone 7.5).
class ProjectComparisonMatrixCard extends StatelessWidget {
  final ProjectComparisonMatrix matrix;

  const ProjectComparisonMatrixCard({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final records = matrix.records;

    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      title: 'Project Comparison Matrix',
      subtitle:
          'Side-by-side performance benchmarking across ${records.length} ventures',
      leadingIcon: const Icon(Icons.table_chart_outlined),
      trailingAction: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.healthGreenBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${records.length} VENTURES',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.healthGreen,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Scrollable Comparative Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Leftmost Metric Labels Column
                  _buildMetricLabelsColumn(context),

                  const SizedBox(width: 8),

                  // Data Columns for each project
                  ...records.map(
                    (record) => _buildProjectDataColumn(
                      context: context,
                      record: record,
                      isBestRoi:
                          matrix.bestRoiProject?.projectId ==
                              record.projectId &&
                          record.roiPercentage > 0,
                      isMostProfitable:
                          matrix.mostProfitableProject?.projectId ==
                              record.projectId &&
                          record.netProfit.isPositive,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Aggregate Portfolio Summary Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor.withAlpha(70)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Combined Portfolio Totals',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Avg ROI: ${matrix.averageRoiPercentage >= 0 ? "+" : ""}${matrix.averageRoiPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: matrix.averageRoiPercentage >= 0
                            ? colors.healthGreen
                            : colors.healthRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        label: 'Total Invested',
                        value: matrix.totalCapitalInvested.format(),
                        color: colors.cashOut,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Total Revenue',
                        value: matrix.totalRevenue.format(),
                        color: colors.cashIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Total Net Profit',
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
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Benchmarking Diagnosis Narrative Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.healthGreenBg.withAlpha(80),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.healthGreen.withAlpha(70)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 20,
                  color: colors.healthGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comparative Performance Insights',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.healthGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        matrix.summaryDiagnosis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
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
    );
  }

  Widget _buildMetricLabelsColumn(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56), // Matches header height
          _labelCell('Lifecycle Stage', theme),
          _labelCell('Health Rating', theme),
          _labelCell('Land Size', theme),
          _labelCell('Cycle Duration', theme),
          _labelCell('Capital Invested', theme),
          _labelCell('Total Revenue', theme),
          _labelCell('Net Profit', theme),
          _labelCell('ROI %', theme),
          _labelCell('Profit / Land Unit', theme),
        ],
      ),
    );
  }

  Widget _labelCell(String text, ThemeData theme) {
    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withAlpha(50)),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProjectDataColumn({
    required BuildContext context,
    required ProjectComparisonRecord record,
    required bool isBestRoi,
    required bool isMostProfitable,
  }) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isProfit = record.netProfit.isPositive;
    final isLoss = record.netProfit.isNegative;

    Color healthColor;
    Color healthBg;
    switch (record.healthStatus) {
      case ProjectHealthStatus.healthy:
        healthColor = colors.healthGreen;
        healthBg = colors.healthGreenBg;
        break;
      case ProjectHealthStatus.watch:
        healthColor = colors.healthYellow;
        healthBg = colors.healthYellowBg;
        break;
      case ProjectHealthStatus.atRisk:
        healthColor = colors.healthRed;
        healthBg = colors.healthRedBg;
        break;
    }

    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isBestRoi
            ? colors.healthGreenBg.withAlpha(40)
            : theme.colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBestRoi
              ? colors.healthGreen.withAlpha(120)
              : theme.dividerColor.withAlpha(70),
          width: isBestRoi ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header Tile
          SizedBox(
            height: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.projectName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isBestRoi)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.healthGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TOP ROI',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.commodity}${record.variety != null ? " • ${record.variety}" : ""}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (record.farmName != null)
                  Text(
                    record.farmName!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // 1. Stage
          _dataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.dividerColor.withAlpha(40),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                record.stageLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            theme,
          ),

          // 2. Health Rating
          _dataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: healthBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                record.healthBadge,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: healthColor,
                ),
              ),
            ),
            theme,
          ),

          // 3. Land Size
          _dataCell(
            Text(
              record.formattedLand,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            theme,
          ),

          // 4. Cycle Duration
          _dataCell(
            Text(
              '${record.cycleDurationDays} Days',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            theme,
          ),

          // 5. Capital Invested
          _dataCell(
            Text(
              record.capitalInvested.format(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.cashOut,
              ),
            ),
            theme,
          ),

          // 6. Total Revenue
          _dataCell(
            Text(
              record.totalRevenue.format(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.cashIn,
              ),
            ),
            theme,
          ),

          // 7. Net Profit
          _dataCell(
            Text(
              '${isProfit ? "+" : ""}${record.netProfit.format()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isProfit
                    ? colors.healthGreen
                    : (isLoss ? colors.healthRed : Colors.grey),
              ),
            ),
            theme,
          ),

          // 8. ROI %
          _dataCell(
            Row(
              children: [
                Text(
                  '${record.roiPercentage >= 0 ? "+" : ""}${record.roiPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: record.roiPercentage > 0
                        ? colors.healthGreen
                        : (record.roiPercentage < 0 ? colors.healthRed : null),
                  ),
                ),
                if (isBestRoi) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.workspace_premium,
                    size: 14,
                    color: colors.healthGreen,
                  ),
                ],
              ],
            ),
            theme,
          ),

          // 9. Profit / Land Unit
          _dataCell(
            Text(
              '${record.profitPerLandUnit.format()} / ${record.landUnit}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: record.profitPerLandUnit.isPositive
                    ? colors.healthGreen
                    : (record.profitPerLandUnit.isNegative
                          ? colors.healthRed
                          : Colors.grey),
              ),
            ),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _dataCell(Widget child, ThemeData theme) {
    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withAlpha(50)),
        ),
      ),
      child: child,
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
