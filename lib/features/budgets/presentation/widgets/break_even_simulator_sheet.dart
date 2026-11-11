import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/break_even_analysis.dart';
import '../providers/forecast_providers.dart';

/// Interactive simulation bottom sheet enabling farmers to stress-test market prices and harvest yields.
class BreakEvenSimulatorSheet extends ConsumerStatefulWidget {
  final Project project;
  final BreakEvenAnalysis initialAnalysis;
  final Scenario? initialScenario;

  const BreakEvenSimulatorSheet({
    super.key,
    required this.project,
    required this.initialAnalysis,
    this.initialScenario,
  });

  /// Displays the break-even simulator as a modal bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required Project project,
    required BreakEvenAnalysis initialAnalysis,
    Scenario? initialScenario,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BreakEvenSimulatorSheet(
          project: project,
          initialAnalysis: initialAnalysis,
          initialScenario: initialScenario,
        ),
      ),
    );
  }

  @override
  ConsumerState<BreakEvenSimulatorSheet> createState() =>
      _BreakEvenSimulatorSheetState();
}

class _BreakEvenSimulatorSheetState
    extends ConsumerState<BreakEvenSimulatorSheet> {
  late double _simulatedYield;
  late double _simulatedUnitPriceMajor;
  late final double _baselineYield;
  late final double _baselineUnitPriceMajor;
  late final int _totalCostMinor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _baselineYield = widget.initialAnalysis.expectedYield > 0
        ? widget.initialAnalysis.expectedYield
        : 100.0;
    _baselineUnitPriceMajor = widget.initialAnalysis.expectedUnitPrice
        .toMajor();
    if (_baselineUnitPriceMajor <= 0) {
      _simulatedUnitPriceMajor = 150.0;
    } else {
      _simulatedUnitPriceMajor = _baselineUnitPriceMajor;
    }
    _simulatedYield = _baselineYield;
    _totalCostMinor = widget.initialAnalysis.totalBudgetedCostMinor;
  }

  void _applySensitivityPreset(double factor) {
    setState(() {
      _simulatedYield = (_baselineYield * factor).roundToDouble().clamp(
        1.0,
        5000.0,
      );
      _simulatedUnitPriceMajor = (_baselineUnitPriceMajor * factor).clamp(
        1.0,
        5000.0,
      );
    });
  }

  BreakEvenAnalysis get _currentAnalysis {
    final priceMinor = (_simulatedUnitPriceMajor * 100).round();
    return BreakEvenAnalysis(
      expectedYield: _simulatedYield,
      yieldUnit: widget.initialAnalysis.yieldUnit,
      expectedUnitPriceMinor: priceMinor,
      totalBudgetedCostMinor: _totalCostMinor,
      currency: widget.project.currency,
    );
  }

  Future<void> _saveSimulatedScenario(String scenarioType) async {
    setState(() => _isSaving = true);
    try {
      final priceMinor = (_simulatedUnitPriceMajor * 100).round();
      final controller = ref.read(forecastControllerProvider.notifier);
      await controller.saveForecast(
        projectId: widget.project.id,
        scenarioType: scenarioType,
        expectedYield: _simulatedYield,
        yieldUnit: widget.initialAnalysis.yieldUnit,
        expectedUnitPriceMinor: priceMinor,
        projectedCostMinor: _totalCostMinor,
        notes: 'Simulated from break-even calculator ($scenarioType)',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved simulated values to $scenarioType scenario.'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final analysis = _currentAnalysis;
    final status = analysis.protectionStatus;

    Color statusColor;
    Color statusBgColor;
    String statusTitle;

    switch (status) {
      case CapitalProtectionStatus.secure:
        statusColor = colors.healthGreen;
        statusBgColor = colors.healthGreenBg;
        statusTitle = 'CAPITAL PROTECTED (SAFE BUFFER)';
        break;
      case CapitalProtectionStatus.moderate:
        statusColor = colors.healthYellow;
        statusBgColor = colors.healthYellowBg;
        statusTitle = 'MODERATE CUSHION (VULNERABLE)';
        break;
      case CapitalProtectionStatus.vulnerable:
        statusColor = colors.healthRed;
        statusBgColor = colors.healthRedBg;
        statusTitle = 'DEFICIT (CAPITAL AT RISK)';
        break;
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.balance_outlined,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Break-Even & Sensitivity Simulator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Simulate market price shocks and crop loss thresholds',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            160,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Live Capital Protection Gauge Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield, color: statusColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              statusTitle,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Break-Even Yield Threshold',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${analysis.formattedBreakEvenQuantity} ${analysis.yieldUnit}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Break-Even Price Threshold',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${analysis.breakEvenPrice.format()} / ${analysis.yieldUnit}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Net Profit: ${analysis.projectedProfit.format()}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: analysis.projectedProfit.isPositive
                                      ? colors.healthGreen
                                      : (analysis.projectedProfit.isNegative
                                            ? colors.healthRed
                                            : Colors.grey),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cost: ${analysis.totalBudgetedCost.format()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Sensitivity Preset Action Chips
                  Text(
                    'Quick Sensitivity Stress Tests',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            foregroundColor: colors.healthRed,
                            side: BorderSide(
                              color: colors.healthRed.withAlpha(120),
                            ),
                          ),
                          onPressed: () => _applySensitivityPreset(0.75),
                          child: const Text('-25% Shock'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () => _applySensitivityPreset(1.0),
                          child: const Text('Baseline'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            foregroundColor: colors.healthGreen,
                            side: BorderSide(
                              color: colors.healthGreen.withAlpha(120),
                            ),
                          ),
                          onPressed: () => _applySensitivityPreset(1.25),
                          child: const Text('+25% Boom'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Interactive Unit Selling Price Slider & Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Simulated Selling Price',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.project.currency} ${_simulatedUnitPriceMajor.toStringAsFixed(2)} / ${analysis.yieldUnit}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulatedUnitPriceMajor.clamp(10.0, 1000.0),
                    min: 10.0,
                    max: 1000.0,
                    divisions: 198,
                    label:
                        '${widget.project.currency} ${_simulatedUnitPriceMajor.toStringAsFixed(0)}',
                    onChanged: (val) {
                      setState(() => _simulatedUnitPriceMajor = val);
                    },
                  ),
                  Text(
                    'At this price, you need at least ${analysis.formattedBreakEvenQuantity} ${analysis.yieldUnit} to recover total costs.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Interactive Expected Yield Slider & Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Simulated Harvest Yield',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${analysis.formattedExpectedYield} ${analysis.yieldUnit}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulatedYield.clamp(1.0, 1000.0),
                    min: 1.0,
                    max: 1000.0,
                    divisions: 199,
                    label: '${_simulatedYield.toInt()} ${analysis.yieldUnit}',
                    onChanged: (val) {
                      setState(() => _simulatedYield = val);
                    },
                  ),
                  Text(
                    'At this harvest volume, your minimum price must be ${analysis.breakEvenPrice.format()} to avoid financial loss.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 5. Persist Sensitivity Scenario Actions (>= 48dp target)
                  Text(
                    'Save Simulated Result As Scenario',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () => _saveSimulatedScenario('CONSERVATIVE'),
                          child: const Text('Save as Conservative'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: _isSaving
                              ? null
                              : () => _saveSimulatedScenario('EXPECTED'),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save as Target'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
