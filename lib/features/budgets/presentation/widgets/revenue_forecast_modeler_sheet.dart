import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/forecast_model.dart';
import '../providers/budget_item_providers.dart';
import '../providers/forecast_providers.dart';

/// Interactive modal sheet allowing producers to model yield, selling price, revenue, and ROI in real time.
class RevenueForecastModelerSheet extends ConsumerStatefulWidget {
  final Project project;
  final Scenario? initialScenario;

  const RevenueForecastModelerSheet({
    super.key,
    required this.project,
    this.initialScenario,
  });

  /// Presents the modeler as a responsive bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required Project project,
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
        child: RevenueForecastModelerSheet(
          project: project,
          initialScenario: initialScenario,
        ),
      ),
    );
  }

  @override
  ConsumerState<RevenueForecastModelerSheet> createState() =>
      _RevenueForecastModelerSheetState();
}

class _RevenueForecastModelerSheetState
    extends ConsumerState<RevenueForecastModelerSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _yieldController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;

  String _selectedScenarioType = 'EXPECTED';
  String _selectedUnit = 'Bags';
  ForecastCalculation? _liveCalculation;
  bool _isSaving = false;

  static const List<String> _yieldUnits = [
    'Bags',
    'Kg',
    'Tonnes',
    'Crates',
    'Baskets',
    'Cartons',
    'Birds',
    'Pieces',
    'Litres',
    'Bundles',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.initialScenario;
    _selectedScenarioType = s?.scenarioType ?? 'EXPECTED';
    _selectedUnit = s?.yieldUnit ?? _inferDefaultUnit(widget.project.commodity);

    _yieldController = TextEditingController(
      text: s != null
          ? (s.expectedYield % 1 == 0
                ? s.expectedYield.toInt().toString()
                : s.expectedYield.toString())
          : _inferBenchmarkYield(widget.project),
    );

    _priceController = TextEditingController(
      text: s != null
          ? Money(
              BigInt.from(s.expectedUnitPriceMinor),
              currency: widget.project.currency,
            ).toMajor().toStringAsFixed(2)
          : '',
    );

    _notesController = TextEditingController(text: s?.notes ?? '');

    _yieldController.addListener(_recalculate);
    _priceController.addListener(_recalculate);
    _recalculate();
  }

  @override
  void dispose() {
    _yieldController.removeListener(_recalculate);
    _priceController.removeListener(_recalculate);
    _yieldController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  static String _inferDefaultUnit(String commodity) {
    final c = commodity.toLowerCase();
    if (c.contains('tomato')) return 'Crates';
    if (c.contains('poultry') || c.contains('broiler') || c.contains('layer')) {
      return 'Birds';
    }
    if (c.contains('cassava')) return 'Tonnes';
    return 'Bags';
  }

  static String _inferBenchmarkYield(Project project) {
    final c = project.commodity.toLowerCase();
    final size = project.landSize;
    if (c.contains('maize') || c.contains('corn')) {
      return (size * 25).round().toString();
    }
    if (c.contains('pepper')) return (size * 120).round().toString();
    if (c.contains('tomato')) return (size * 250).round().toString();
    if (c.contains('rice')) return (size * 30).round().toString();
    if (c.contains('cassava')) return (size * 8).round().toString();
    if (c.contains('poultry')) return size.round().toString();
    return '100';
  }

  void _recalculate() {
    final y = double.tryParse(_yieldController.text.trim());
    final priceMoney = Money.tryParse(
      _priceController.text.trim(),
      currency: widget.project.currency,
    );

    final totalCostMoney = ref
        .read(projectTotalPlannedMoneyProvider(widget.project.id))
        .valueOrNull;
    final costMinor =
        totalCostMoney?.minorUnits.toInt() ??
        widget.initialScenario?.projectedCostMinor ??
        0;

    if (y != null && y > 0 && priceMoney != null && !priceMoney.isNegative) {
      double activeYield = y;
      int activePriceMinor = priceMoney.minorUnits.toInt();

      if (_selectedScenarioType == 'CONSERVATIVE') {
        // -20% Yield shock, -15% Selling price drop
        activeYield = (y * 0.80 * 10000).round() / 10000;
        activePriceMinor = (priceMoney.minorUnits.toDouble() * 0.85).round();
      } else if (_selectedScenarioType == 'OPTIMISTIC') {
        // +15% Yield upside, +10% Selling price premium
        activeYield = (y * 1.15 * 10000).round() / 10000;
        activePriceMinor = (priceMoney.minorUnits.toDouble() * 1.10).round();
      }

      final calc = ForecastCalculation(
        expectedYield: activeYield,
        yieldUnit: _selectedUnit,
        expectedUnitPriceMinor: activePriceMinor,
        totalBudgetedCostMinor: costMinor,
        currency: widget.project.currency,
      );
      setState(() => _liveCalculation = calc);
    } else {
      if (_liveCalculation != null) {
        setState(() => _liveCalculation = null);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final y = double.tryParse(_yieldController.text.trim()) ?? 0.0;
    final priceMoney = Money.tryParse(
      _priceController.text.trim(),
      currency: widget.project.currency,
    );
    if (y <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expected yield must be greater than zero.'),
        ),
      );
      return;
    }
    if (priceMoney == null || priceMoney.isNegative) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid selling price.')),
      );
      return;
    }

    final totalCostMoney = ref
        .read(projectTotalPlannedMoneyProvider(widget.project.id))
        .valueOrNull;
    final costMinor =
        totalCostMoney?.minorUnits.toInt() ??
        widget.initialScenario?.projectedCostMinor ??
        0;

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(forecastControllerProvider.notifier);
      // Persist the full tri-scenario matrix atomically so Conservative, Expected, and Optimistic
      // sensitivity states are immediately available across cards and reports.
      await controller.saveScenarioMatrix(
        projectId: widget.project.id,
        expectedYield: y,
        yieldUnit: _selectedUnit,
        expectedUnitPriceMinor: priceMoney.minorUnits.toInt(),
        projectedCostMinor: costMinor,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
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
    final totalCostMoney =
        ref
            .watch(projectTotalPlannedMoneyProvider(widget.project.id))
            .valueOrNull ??
        Money(
          BigInt.from(widget.initialScenario?.projectedCostMinor ?? 0),
          currency: widget.project.currency,
        );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue & Yield Forecast Modeler',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pre-season viability for ${widget.project.name}',
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

          // Body Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Dynamic Live Real-Time Financial Indicators Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _liveCalculation != null
                            ? (_liveCalculation!.isProfitable
                                  ? colors.healthGreenBg
                                  : (_liveCalculation!.isLoss
                                        ? colors.healthRedBg
                                        : colors.healthYellowBg))
                            : theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(100),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _liveCalculation != null
                              ? (_liveCalculation!.isProfitable
                                    ? colors.healthGreen
                                    : (_liveCalculation!.isLoss
                                          ? colors.healthRed
                                          : colors.healthYellow))
                              : theme.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calculate_outlined,
                                size: 18,
                                color: _liveCalculation != null
                                    ? (_liveCalculation!.isProfitable
                                          ? colors.healthGreen
                                          : (_liveCalculation!.isLoss
                                                ? colors.healthRed
                                                : colors.healthYellow))
                                    : theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedScenarioType == 'CONSERVATIVE'
                                    ? 'CONSERVATIVE SCENARIO (-20% YIELD, -15% PRICE)'
                                    : (_selectedScenarioType == 'OPTIMISTIC'
                                          ? 'OPTIMISTIC SCENARIO (+15% YIELD, +10% PRICE)'
                                          : 'EXPECTED TARGET SCENARIO'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: _liveCalculation != null
                                      ? (_liveCalculation!.isProfitable
                                            ? colors.healthGreen
                                            : (_liveCalculation!.isLoss
                                                  ? colors.healthRed
                                                  : colors.healthYellow))
                                      : theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_liveCalculation != null) ...[
                            // Gross Revenue Formula
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Gross Revenue (${_liveCalculation!.formattedYield} $_selectedUnit × ${_liveCalculation!.expectedUnitPrice.format()}):',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _liveCalculation!.projectedRevenue.format(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Total Budgeted Cost
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Planned Budget Cost:',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _liveCalculation!.totalBudgetedCost.format(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Projected Net Profit & ROI %
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _liveCalculation!.isProfitable
                                          ? 'Projected Net Profit'
                                          : (_liveCalculation!.isLoss
                                                ? 'Projected Deficit'
                                                : 'Break-Even'),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _liveCalculation!.projectedProfit
                                          .format(),
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                _liveCalculation!.isProfitable
                                                ? colors.healthGreen
                                                : (_liveCalculation!.isLoss
                                                      ? colors.healthRed
                                                      : colors.healthYellow),
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _liveCalculation!.isProfitable
                                        ? colors.healthGreen
                                        : (_liveCalculation!.isLoss
                                              ? colors.healthRed
                                              : colors.healthYellow),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_liveCalculation!.projectedRoiPercent >= 0 ? '+' : ''}${_liveCalculation!.projectedRoiPercent.toStringAsFixed(1)}% ROI',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              'Enter your expected harvest yield and selling price to model revenue and return.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha(180),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Current Planned Budget Cost: ${totalCostMoney.format()}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Scenario Type Selector (Conservative, Expected, Optimistic)
                    Text(
                      'Scenario Type',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'CONSERVATIVE',
                          label: Text('Conservative'),
                          icon: Icon(Icons.shield_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: 'EXPECTED',
                          label: Text('Expected'),
                          icon: Icon(Icons.track_changes, size: 16),
                        ),
                        ButtonSegment(
                          value: 'OPTIMISTIC',
                          label: Text('Optimistic'),
                          icon: Icon(Icons.auto_graph, size: 16),
                        ),
                      ],
                      selected: {_selectedScenarioType},
                      onSelectionChanged: (newSelection) {
                        setState(
                          () => _selectedScenarioType = newSelection.first,
                        );
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedScenarioType == 'CONSERVATIVE'
                          ? 'Simulates adverse market conditions: 20% lower crop yield and 15% lower selling price.'
                          : (_selectedScenarioType == 'OPTIMISTIC'
                                ? 'Simulates favorable market conditions: 15% higher crop yield and 10% premium selling price.'
                                : 'Baseline target plan based on your estimated harvest yield and selling price.'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Expected Yield & Measurement Unit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expected Yield
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _yieldController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Expected Yield *',
                              hintText: '100',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter yield';
                              }
                              final numVal = double.tryParse(val.trim());
                              if (numVal == null || numVal <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Unit Selector
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _yieldUnits.contains(_selectedUnit)
                                ? _selectedUnit
                                : _yieldUnits.first,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Unit *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            items: _yieldUnits.map((u) {
                              return DropdownMenuItem<String>(
                                value: u,
                                child: Text(u, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedUnit = val;
                                  _recalculate();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. Estimated Unit Selling Price
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            'Estimated Unit Selling Price (${widget.project.currency}) *',
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.price_check),
                        prefixText: '${widget.project.currency} ',
                        suffixText: '/ $_selectedUnit',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter selling price';
                        }
                        final money = Money.tryParse(
                          val.trim(),
                          currency: widget.project.currency,
                        );
                        if (money == null || money.isNegative) {
                          return 'Enter valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. Notes / Assumptions
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Market Assumptions / Notes (Optional)',
                        hintText:
                            'e.g. Farmgate price during peak August harvest window',
                        prefixIcon: Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. Save Forecast Button (>= 48dp touch target)
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _submit,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _isSaving
                              ? 'Saving Forecast...'
                              : 'Save Forecast Modeler',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
