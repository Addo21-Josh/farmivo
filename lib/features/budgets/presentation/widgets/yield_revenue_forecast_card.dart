import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/forecast_providers.dart';
import 'revenue_forecast_modeler_sheet.dart';

/// Pre-season visual card presenting expected harvest yield, selling price, gross revenue, and ROI %.
class YieldRevenueForecastCard extends ConsumerWidget {
  final Project project;

  const YieldRevenueForecastCard({super.key, required this.project});

  void _openModeler(BuildContext context, Scenario? scenario) {
    RevenueForecastModelerSheet.show(
      context,
      project: project,
      initialScenario: scenario,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final forecastAsync = ref.watch(
      projectLiveForecastCalculationProvider(project.id),
    );
    final rawScenarioAsync = ref.watch(projectForecastProvider(project.id));

    return forecastAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error loading revenue forecast: $err'),
      ),
      data: (calc) {
        final scenario = rawScenarioAsync.valueOrNull;

        if (calc == null) {
          // Empty State Prompt Card
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
                        color: colors.healthGreenBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: colors.healthGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revenue & ROI Modeler',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Model expected harvest yield & selling price',
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
                  'Calculate pre-season gross revenue, net margin, and return on investment before committing capital.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => _openModeler(context, null),
                  icon: const Icon(Icons.auto_graph, size: 18),
                  label: const Text('Model Revenue & Profit'),
                ),
              ],
            ),
          );
        }

        // Populated Forecast State
        final isProfitable = calc.isProfitable;
        final isLoss = calc.isLoss;

        return AppCard(
          title: 'Revenue & Yield Forecast',
          subtitle:
              '${scenario?.scenarioType ?? "EXPECTED"} Scenario for ${project.commodity}',
          leadingIcon: const Icon(Icons.trending_up),
          trailingAction: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isProfitable
                  ? colors.healthGreenBg
                  : (isLoss ? colors.healthRedBg : colors.healthYellowBg),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${calc.projectedRoiPercent >= 0 ? '+' : ''}${calc.projectedRoiPercent.toStringAsFixed(1)}% ROI',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isProfitable
                    ? colors.healthGreen
                    : (isLoss ? colors.healthRed : colors.healthYellow),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formula & Benchmark
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    80,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.scatter_plot_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        calc.formulaDisplay,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3 Metric Grid
              Row(
                children: [
                  // Gross Revenue
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gross Revenue',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calc.projectedRevenue.format(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Budgeted Cost
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budgeted Cost',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calc.totalBudgetedCost.format(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Net Profit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProfitable
                              ? 'Projected Profit'
                              : 'Projected Deficit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calc.projectedProfit.format(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isProfitable
                                ? colors.healthGreen
                                : (isLoss
                                      ? colors.healthRed
                                      : colors.healthYellow),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Adjust Action
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () => _openModeler(context, scenario),
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Adjust Yield & Price Forecast'),
              ),
            ],
          ),
        );
      },
    );
  }
}
