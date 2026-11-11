import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/financial_engine/project_comparison.dart';
import '../../../../shared/widgets/app_card.dart';

/// Grouped bar chart comparing Capital Invested, Revenue, and Net Profit across projects (Milestone 8.1).
class ProjectComparisonBarChart extends StatelessWidget {
  final ProjectComparisonMatrix matrix;
  final String title;
  final String subtitle;

  const ProjectComparisonBarChart({
    super.key,
    required this.matrix,
    this.title = 'Cross-Project Financial Comparison',
    this.subtitle = 'Side-by-side Capital Invested, Revenue, and Net Profit',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final records = matrix.records;

    if (records.isEmpty) {
      return AppCard(
        title: title,
        subtitle: subtitle,
        leadingIcon: const Icon(Icons.leaderboard_outlined),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.hub_outlined, size: 40, color: theme.dividerColor),
              const SizedBox(height: 8),
              Text(
                'No projects available for comparison',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final visible = records.take(5).toList();

    double maxY = 0.0;
    for (final r in visible) {
      if (r.capitalInvested.toMajor() > maxY) {
        maxY = r.capitalInvested.toMajor();
      }
      if (r.totalRevenue.toMajor() > maxY) maxY = r.totalRevenue.toMajor();
      if (r.netProfit.toMajor() > maxY) maxY = r.netProfit.toMajor();
    }
    if (maxY <= 0) maxY = 100.0;
    maxY = maxY * 1.15;

    return AppCard(
      title: title,
      subtitle: subtitle,
      leadingIcon: const Icon(Icons.leaderboard_outlined),
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(label: 'Capital', color: colors.cashOut),
          const SizedBox(width: 8),
          _LegendDot(label: 'Revenue', color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          _LegendDot(label: 'Profit', color: colors.cashIn),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Grouped Bar Chart
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surfaceContainerHighest,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final p = visible[group.x.toInt()];
                      final String label;
                      final String val;
                      final Color col;

                      if (rodIndex == 0) {
                        label = 'Capital';
                        val = p.capitalInvested.format();
                        col = colors.cashOut;
                      } else if (rodIndex == 1) {
                        label = 'Revenue';
                        val = p.totalRevenue.format();
                        col = theme.colorScheme.primary;
                      } else {
                        label = 'Net Profit';
                        val = p.netProfit.format();
                        col = p.netProfit.isPositive
                            ? colors.cashIn
                            : colors.healthRed;
                      }

                      return BarTooltipItem(
                        '${p.projectName}\n$label: $val\nROI: ${p.roiPercentage >= 0 ? "+" : ""}${p.roiPercentage.toStringAsFixed(1)}%',
                        TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: col,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, meta) {
                        if (val == meta.max || val == meta.min) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          val >= 1000
                              ? '${(val / 1000).toStringAsFixed(0)}k'
                              : '${val.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= visible.length) {
                          return const SizedBox.shrink();
                        }
                        final name = visible[idx].projectName;
                        final shortName = name.length > 7
                            ? '${name.substring(0, 6)}.'
                            : name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            shortName,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: theme.dividerColor.withAlpha(40),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(visible.length, (i) {
                  final p = visible[i];
                  final profitVal = p.netProfit.isPositive
                      ? p.netProfit.toMajor()
                      : 0.0;

                  return BarChartGroupData(
                    x: i,
                    barsSpace: 3,
                    barRods: [
                      // Capital Invested
                      BarChartRodData(
                        toY: p.capitalInvested.toMajor(),
                        color: colors.cashOut,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                      // Revenue
                      BarChartRodData(
                        toY: p.totalRevenue.toMajor(),
                        color: theme.colorScheme.primary,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                      // Net Profit
                      BarChartRodData(
                        toY: profitVal,
                        color: colors.cashIn,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
