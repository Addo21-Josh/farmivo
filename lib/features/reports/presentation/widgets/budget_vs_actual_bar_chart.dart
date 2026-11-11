import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../budgets/domain/models/budget_variance.dart';

/// Grouped bar chart comparing planned budget vs. actual expenditures per category (Milestone 8.1).
class BudgetVsActualBarChart extends StatelessWidget {
  final ProjectVarianceReport? report;
  final String title;
  final String subtitle;

  const BudgetVsActualBarChart({
    super.key,
    required this.report,
    this.title = 'Budget vs. Actual Spending',
    this.subtitle = 'Category allocations against incurred expenditures',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final List<CategoryVariance> categories = report?.categories ?? [];

    if (categories.isEmpty) {
      return AppCard(
        title: title,
        subtitle: subtitle,
        leadingIcon: const Icon(Icons.bar_chart_outlined),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.query_stats_outlined,
                size: 40,
                color: theme.dividerColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No budget items or expenses to compare',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Limit to top 6 categories with most spending or planned for clear mobile rendering
    final displayCategories = [...categories]
      ..sort((a, b) {
        final maxA = a.plannedAmount > a.actualSpent
            ? a.plannedAmount
            : a.actualSpent;
        final maxB = b.plannedAmount > b.actualSpent
            ? b.plannedAmount
            : b.actualSpent;
        return maxB.compareTo(maxA);
      });
    final visible = displayCategories.take(6).toList();

    double maxY = 0.0;
    for (final c in visible) {
      if (c.plannedAmount.toMajor() > maxY) maxY = c.plannedAmount.toMajor();
      if (c.actualSpent.toMajor() > maxY) maxY = c.actualSpent.toMajor();
    }
    if (maxY <= 0) maxY = 100.0;
    maxY = maxY * 1.15; // 15% head room

    return AppCard(
      title: title,
      subtitle: subtitle,
      leadingIcon: const Icon(Icons.bar_chart_outlined),
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(label: 'Planned', color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          _LegendDot(label: 'Actual', color: colors.cashIn),
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
                      final cat = visible[group.x.toInt()];
                      final isPlanned = rodIndex == 0;
                      final label = isPlanned ? 'Planned' : 'Actual';
                      final val = isPlanned
                          ? cat.plannedAmount.format()
                          : cat.actualSpent.format();
                      return BarTooltipItem(
                        '${cat.category.name}\n$label: $val',
                        theme.textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPlanned
                              ? theme.colorScheme.primary
                              : colors.cashIn,
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
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= visible.length) {
                          return const SizedBox.shrink();
                        }
                        final name = visible[idx].category.name;
                        // Abbreviate to 4-5 chars for clean mobile X-axis
                        final shortName = name.length > 5
                            ? '${name.substring(0, 4)}.'
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
                  final cat = visible[i];
                  final isOverrun = cat.actualSpent > cat.plannedAmount;

                  return BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      // Planned Bar
                      BarChartRodData(
                        toY: cat.plannedAmount.toMajor(),
                        color: theme.colorScheme.primary.withAlpha(180),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      // Actual Bar
                      BarChartRodData(
                        toY: cat.actualSpent.toMajor(),
                        color: isOverrun ? colors.healthRed : colors.cashIn,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Variance Summary Footnote Table
          Column(
            children: visible.map((c) {
              final isOverrun = c.actualSpent > c.plannedAmount;
              final variance = c.actualSpent - c.plannedAmount;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        c.category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Plan: ${c.plannedAmount.format()} | Act: ${c.actualSpent.format()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 72,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${isOverrun ? "+" : ""}${variance.format()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOverrun
                              ? colors.healthRed
                              : (variance.isNegative
                                    ? colors.healthGreen
                                    : Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
