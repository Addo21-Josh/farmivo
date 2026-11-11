import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/models/break_even_analysis.dart';
import '../providers/forecast_providers.dart';
import 'break_even_simulator_sheet.dart';
import 'revenue_forecast_modeler_sheet.dart';

/// Visual summary card indicating the required yield and price thresholds to protect invested capital.
class BreakEvenSummaryCard extends ConsumerWidget {
  final Project project;

  const BreakEvenSummaryCard({super.key, required this.project});

  void _openSimulator(
    BuildContext context,
    BreakEvenAnalysis? analysis,
    Scenario? scenario,
  ) {
    if (analysis == null) {
      // If no forecast exists yet, open the modeler to establish initial baseline
      RevenueForecastModelerSheet.show(context, project: project);
    } else {
      BreakEvenSimulatorSheet.show(
        context,
        project: project,
        initialAnalysis: analysis,
        initialScenario: scenario,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final breakEvenAsync = ref.watch(
      projectBreakEvenAnalysisProvider(project.id),
    );
    final rawScenarioAsync = ref.watch(projectForecastProvider(project.id));

    return breakEvenAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error loading break-even analysis: $err'),
      ),
      data: (analysis) {
        final scenario = rawScenarioAsync.valueOrNull;

        if (analysis == null || analysis.totalBudgetedCostMinor <= 0) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withAlpha(90)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.healthYellowBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.balance_outlined,
                        color: colors.healthYellow,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Break-Even & Capital Protection',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Capital recovery threshold analysis',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withAlpha(160),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Add budget items and configure expected harvest yield to determine the exact threshold needed to protect your invested money.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => _openSimulator(context, null, null),
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Configure Yield & Price Baseline'),
                ),
              ],
            ),
          );
        }

        // Active Break-Even Analysis State
        final status = analysis.protectionStatus;
        Color statusColor;
        Color statusBgColor;
        String statusLabel;

        switch (status) {
          case CapitalProtectionStatus.secure:
            statusColor = colors.healthGreen;
            statusBgColor = colors.healthGreenBg;
            statusLabel = 'CAPITAL PROTECTED';
            break;
          case CapitalProtectionStatus.moderate:
            statusColor = colors.healthYellow;
            statusBgColor = colors.healthYellowBg;
            statusLabel = 'MODERATE BUFFER';
            break;
          case CapitalProtectionStatus.vulnerable:
            statusColor = colors.healthRed;
            statusBgColor = colors.healthRedBg;
            statusLabel = 'CAPITAL AT RISK';
            break;
        }

        return AppCard(
          title: 'Break-Even & Capital Protection',
          subtitle:
              'Required thresholds to recoup ${analysis.totalBudgetedCost.format()}',
          leadingIcon: const Icon(Icons.balance_outlined),
          trailingAction: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2 Column Threshold Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Break-Even Yield
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(60),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withAlpha(80),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'BREAK-EVEN YIELD',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${analysis.formattedBreakEvenQuantity} ${analysis.yieldUnit}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Planned: ${analysis.formattedExpectedYield} ${analysis.yieldUnit} (${analysis.yieldSafetyPercentage >= 0 ? '+' : ''}${analysis.yieldSafetyPercentage.toStringAsFixed(0)}% cushion)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: analysis.yieldSafetyPercentage >= 0
                                  ? colors.healthGreen
                                  : colors.healthRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Break-Even Price
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(60),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withAlpha(80),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sell_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'BREAK-EVEN PRICE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${analysis.breakEvenPrice.format()} / ${analysis.yieldUnit}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${analysis.expectedUnitPrice.format()} (${analysis.priceSafetyPercentage >= 0 ? '+' : ''}${analysis.priceSafetyPercentage.toStringAsFixed(0)}% cushion)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: analysis.priceSafetyPercentage >= 0
                                  ? colors.healthGreen
                                  : colors.healthRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Advisory Callout
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusBgColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      status == CapitalProtectionStatus.secure
                          ? Icons.shield
                          : (status == CapitalProtectionStatus.moderate
                                ? Icons.info_outline
                                : Icons.warning_amber),
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        analysis.advisoryMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Interactive Simulator Trigger Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () => _openSimulator(context, analysis, scenario),
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Break-Even Simulator & Sensitivity'),
              ),
            ],
          ),
        );
      },
    );
  }
}
