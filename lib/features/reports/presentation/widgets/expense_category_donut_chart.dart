import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/category_expense_share.dart';

/// Donut chart visualization of operational expense distribution across categories (Milestone 8.1).
class ExpenseCategoryDonutChart extends StatefulWidget {
  final List<CategoryExpenseShare> shares;
  final String title;
  final String subtitle;

  const ExpenseCategoryDonutChart({
    super.key,
    required this.shares,
    this.title = 'Expense Breakdown by Category',
    this.subtitle = 'Operational capital distribution',
  });

  @override
  State<ExpenseCategoryDonutChart> createState() =>
      _ExpenseCategoryDonutChartState();
}

class _ExpenseCategoryDonutChartState extends State<ExpenseCategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shares = widget.shares;

    if (shares.isEmpty) {
      return AppCard(
        title: widget.title,
        subtitle: widget.subtitle,
        leadingIcon: const Icon(Icons.pie_chart_outline),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: theme.dividerColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No expenses logged yet',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Compute grand total
    Money grandTotal = Money.zero(currency: shares.first.totalSpent.currency);
    for (final s in shares) {
      grandTotal = grandTotal + s.totalSpent;
    }

    final activeShare = _touchedIndex >= 0 && _touchedIndex < shares.length
        ? shares[_touchedIndex]
        : null;

    return AppCard(
      title: widget.title,
      subtitle: widget.subtitle,
      leadingIcon: const Icon(Icons.pie_chart_outline),
      trailingAction: Text(
        grandTotal.format(),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      child: Column(
        children: [
          // 1. Donut Pie Chart with interactive center label
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 52,
                    sections: List.generate(shares.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final s = shares[i];
                      final radius = isTouched ? 42.0 : 34.0;

                      return PieChartSectionData(
                        color: s.color,
                        value: s.totalSpent.toMajor(),
                        title: isTouched
                            ? '${s.percentage.toStringAsFixed(0)}%'
                            : '',
                        radius: radius,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
                // Center label inside donut hole
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activeShare != null ? activeShare.categoryName : 'TOTAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeShare != null
                          ? activeShare.totalSpent.format()
                          : grandTotal.format(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: activeShare != null ? 12 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activeShare != null)
                      Text(
                        '${activeShare.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: activeShare.color,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 2. Category Distribution Legend
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shares.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = shares[index];
              final isTouched = index == _touchedIndex;

              return InkWell(
                onTap: () {
                  setState(() {
                    _touchedIndex = _touchedIndex == index ? -1 : index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isTouched
                        ? s.color.withAlpha(25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.categoryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isTouched
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        s.totalSpent.format(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${s.percentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
