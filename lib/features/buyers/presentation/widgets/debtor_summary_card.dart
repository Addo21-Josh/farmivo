import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/app/theme/app_theme_extension.dart';
import 'package:farmivo/features/buyers/domain/models/buyers_directory_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/shared/widgets/app_card.dart';
import 'package:farmivo/shared/widgets/money_display.dart';

/// Top-level metrics card displaying total accounts receivable,
/// active debtor counts, cash collection rate, and quick filter toggle.
class DebtorSummaryCard extends ConsumerWidget {
  final BuyersDirectorySummary summary;

  const DebtorSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final onlyDebtors = ref.watch(buyerOnlyDebtorsFilterProvider);

    return AppCard(
      title: 'Commercial Receivables',
      subtitle: 'Outstanding credit owed by produce buyers',
      leadingIcon: Icon(
        Icons.account_balance_wallet_outlined,
        color: summary.activeDebtorsCount > 0
            ? colors.healthRed
            : colors.healthGreen,
      ),
      trailingAction: FilterChip(
        avatar: Icon(
          onlyDebtors ? Icons.check : Icons.filter_alt_outlined,
          size: 16,
        ),
        label: Text(
          'Debtors (${summary.activeDebtorsCount})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: onlyDebtors ? Colors.white : null,
          ),
        ),
        selected: onlyDebtors,
        selectedColor: colors.healthRed,
        onSelected: (val) {
          ref.read(buyerOnlyDebtorsFilterProvider.notifier).state = val;
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Total Outstanding Debt
          MoneyDisplay(
            money: summary.totalReceivables,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: summary.totalReceivables.isPositive
                  ? colors.healthRed
                  : colors.healthGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.totalReceivables.isPositive
                ? '${summary.activeDebtorsCount} ${summary.activeDebtorsCount == 1 ? "customer owes" : "customers owe"} payment for produce'
                : 'All buyer accounts fully settled',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 2. Metrics Breakdown Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric(
                context,
                label: 'Total Buyers',
                value: '${summary.totalBuyers}',
              ),
              _buildMiniMetric(
                context,
                label: 'Total Sales',
                value: summary.totalSalesVolume.format(),
              ),
              _buildMiniMetric(
                context,
                label: 'Cash Collected',
                value: summary.totalCashCollected.format(),
                subValue:
                    '${summary.collectionRatePercentage.toStringAsFixed(0)}% paid',
                subColor: colors.healthGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
    BuildContext context, {
    required String label,
    required String value,
    String? subValue,
    Color? subColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subValue != null)
          Text(
            subValue,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: subColor,
            ),
          ),
      ],
    );
  }
}
