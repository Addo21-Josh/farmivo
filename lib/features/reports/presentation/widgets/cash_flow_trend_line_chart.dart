import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/cash_flow_point.dart';

/// Cumulative Cash In vs. Cash Out line chart with break-even crossover detection (Milestone 8.1).
class CashFlowTrendLineChart extends StatelessWidget {
  final List<CashFlowPoint> timeline;
  final String title;
  final String subtitle;

  const CashFlowTrendLineChart({
    super.key,
    required this.timeline,
    this.title = 'Cumulative Cash Flow Trend',
    this.subtitle = 'Cash In vs. Cash Out & Break-Even Crossover',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    if (timeline.isEmpty) {
      return AppCard(
        title: title,
        subtitle: subtitle,
        leadingIcon: const Icon(Icons.show_chart_outlined),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.timeline_outlined,
                size: 40,
                color: theme.dividerColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No cash transactions recorded yet',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final latest = timeline.last;
    final isCashBreakEven = latest.isBreakEvenAchieved;

    // Detect first crossover point
    CashFlowPoint? crossoverPoint;
    for (final p in timeline) {
      if (p.isBreakEvenAchieved) {
        crossoverPoint = p;
        break;
      }
    }

    double maxY = 0.0;
    for (final p in timeline) {
      if (p.cumulativeCashIn.toMajor() > maxY) {
        maxY = p.cumulativeCashIn.toMajor();
      }
      if (p.cumulativeCashOut.toMajor() > maxY) {
        maxY = p.cumulativeCashOut.toMajor();
      }
    }
    if (maxY <= 0) maxY = 100.0;
    maxY = maxY * 1.15;

    // Generate spots
    final inSpots = <FlSpot>[];
    final outSpots = <FlSpot>[];

    for (var i = 0; i < timeline.length; i++) {
      final p = timeline[i];
      inSpots.add(FlSpot(i.toDouble(), p.cumulativeCashIn.toMajor()));
      outSpots.add(FlSpot(i.toDouble(), p.cumulativeCashOut.toMajor()));
    }

    return AppCard(
      title: title,
      subtitle: subtitle,
      leadingIcon: const Icon(Icons.show_chart_outlined),
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(label: 'Cash In', color: colors.cashIn),
          const SizedBox(width: 10),
          _LegendDot(label: 'Cash Out', color: colors.cashOut),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Line Chart
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (timeline.length - 1).toDouble().clamp(
                  0.0,
                  double.infinity,
                ),
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surfaceContainerHighest,
                    getTooltipItems: (touchedSpots) {
                      if (touchedSpots.isEmpty) return [];
                      final idx = touchedSpots.first.x.toInt();
                      if (idx < 0 || idx >= timeline.length) return [];
                      final pt = timeline[idx];
                      final dateStr =
                          '${pt.date.day} ${_monthName(pt.date.month)}';

                      return touchedSpots.map((spot) {
                        final isCashIn = spot.barIndex == 0;
                        final label = isCashIn ? 'Cash In' : 'Cash Out';
                        final val = isCashIn
                            ? pt.cumulativeCashIn.format()
                            : pt.cumulativeCashOut.format();

                        return LineTooltipItem(
                          spot.barIndex == 0
                              ? '$dateStr\n$label: $val'
                              : '$label: $val',
                          TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCashIn ? colors.cashIn : colors.cashOut,
                          ),
                        );
                      }).toList();
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
                        if (idx < 0 || idx >= timeline.length) {
                          return const SizedBox.shrink();
                        }

                        // Only show first, middle, and last date to avoid clutter
                        final isFirst = idx == 0;
                        final isLast = idx == timeline.length - 1;
                        final isMiddle = idx == (timeline.length / 2).floor();

                        if (isFirst || isLast || isMiddle) {
                          final d = timeline[idx].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              '${d.day}/${d.month}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
                lineBarsData: [
                  // Cash In (Green)
                  LineChartBarData(
                    spots: inSpots,
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: colors.cashIn,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: timeline.length <= 15,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 3,
                            color: colors.cashIn,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colors.cashIn.withAlpha(20),
                    ),
                  ),
                  // Cash Out (Red)
                  LineChartBarData(
                    spots: outSpots,
                    isCurved: true,
                    curveSmoothness: 0.15,
                    color: colors.cashOut,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: timeline.length <= 15,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 3,
                            color: colors.cashOut,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colors.cashOut.withAlpha(15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Break-Even Crossover Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isCashBreakEven
                  ? colors.healthGreenBg.withAlpha(90)
                  : colors.healthYellowBg.withAlpha(90),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCashBreakEven
                    ? colors.healthGreen.withAlpha(80)
                    : colors.healthYellow.withAlpha(80),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCashBreakEven
                      ? Icons.check_circle_outline
                      : Icons.hourglass_top_outlined,
                  size: 20,
                  color: isCashBreakEven
                      ? colors.healthGreen
                      : colors.healthYellow,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCashBreakEven
                            ? 'Cash Break-Even Reached'
                            : 'Cash Break-Even In Progress',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCashBreakEven
                              ? colors.healthGreen
                              : Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCashBreakEven && crossoverPoint != null
                            ? 'Collected cash crossed total expenditures on ${_formatDate(crossoverPoint.date)}. Current surplus: +${latest.netPosition.format()}.'
                            : 'Liquid cash collected (${latest.cumulativeCashIn.format()}) covers ${((latest.cumulativeCashIn.toMajor() / (latest.cumulativeCashOut.toMajor() > 0 ? latest.cumulativeCashOut.toMajor() : 1)) * 100).toStringAsFixed(0)}% of spent capital. Deficit: ${Money(latest.cumulativeCashOut.minorUnits - latest.cumulativeCashIn.minorUnits, currency: latest.cumulativeCashOut.currency).format()}.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
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

  static String _monthName(int month) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return m[(month - 1).clamp(0, 11)];
  }

  static String _formatDate(DateTime d) {
    return '${d.day} ${_monthName(d.month)} ${d.year}';
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
