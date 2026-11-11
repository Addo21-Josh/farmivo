import '../money/money.dart';
import '../../data/database/app_database.dart';

/// Categorization of downside financial risk under worst-case agricultural conditions.
enum DownsideExposureRisk {
  /// Venture remains profitable even under conservative (-20% yield, -15% price) conditions.
  robust,

  /// Conservative scenario incurs a manageable deficit (<= 25% of invested capital).
  moderate,

  /// Conservative scenario incurs severe capital loss (> 25% of invested capital).
  high,
}

/// Represents a single evaluated scenario outcome in the sensitivity matrix.
class ScenarioMatrixItem {
  /// Scenario identifier: 'CONSERVATIVE', 'EXPECTED', or 'OPTIMISTIC'.
  final String scenarioType;

  /// Human-friendly display title.
  final String title;

  /// Subtitle or variation summary (e.g. "-20% Yield, -15% Price").
  final String subtitle;

  /// Expected crop yield in units.
  final double expectedYield;

  /// Unit of measurement (e.g. 'Bags', 'kg', 'Crates').
  final String yieldUnit;

  /// Unit selling price.
  final Money expectedUnitPrice;

  /// Total budgeted or projected operational cost.
  final Money projectedCost;

  /// Projected gross commercial revenue (Yield * Unit Price).
  final Money projectedRevenue;

  /// Projected net profit (Projected Revenue - Projected Cost).
  final Money projectedProfit;

  /// Projected Return on Investment (ROI) percentage.
  final double projectedRoiPercent;

  const ScenarioMatrixItem({
    required this.scenarioType,
    required this.title,
    required this.subtitle,
    required this.expectedYield,
    required this.yieldUnit,
    required this.expectedUnitPrice,
    required this.projectedCost,
    required this.projectedRevenue,
    required this.projectedProfit,
    required this.projectedRoiPercent,
  });

  bool get isProfitable => projectedProfit.isPositive;
  bool get isLoss => projectedProfit.isNegative;
  bool get isBreakEven => projectedProfit.isZero;

  /// Formatted yield quantity string without unnecessary trailing decimals.
  String get formattedYield => expectedYield % 1 == 0
      ? expectedYield.toInt().toString()
      : expectedYield.toStringAsFixed(1);

  /// Formatted ROI string with sign prefix.
  String get formattedRoi =>
      '${projectedRoiPercent >= 0 ? "+" : ""}${projectedRoiPercent.toStringAsFixed(1)}%';
}

/// Tri-scenario sensitivity model evaluating:
/// 1. Conservative (Worst Case): -20% Yield, -15% Price.
/// 2. Expected Case: Budgeted / Target assumptions.
/// 3. Optimistic (Best Case): +15% Yield, +10% Price.
class ScenarioPlanningMatrix {
  final ScenarioMatrixItem conservative;
  final ScenarioMatrixItem expected;
  final ScenarioMatrixItem optimistic;
  final Money totalBudgetedCost;
  final String currency;

  const ScenarioPlanningMatrix({
    required this.conservative,
    required this.expected,
    required this.optimistic,
    required this.totalBudgetedCost,
    this.currency = 'GHS',
  });

  /// Factory computing the full 3-scenario matrix from baseline inputs.
  factory ScenarioPlanningMatrix.compute({
    required double baselineYield,
    required String yieldUnit,
    required Money baselineUnitPrice,
    required Money totalBudgetedCost,
    double conservativeYieldMultiplier = 0.80, // -20%
    double conservativePriceMultiplier = 0.85, // -15%
    double optimisticYieldMultiplier = 1.15, // +15%
    double optimisticPriceMultiplier = 1.10, // +10%
    String currency = 'GHS',
  }) {
    final cleanYield = baselineYield > 0 ? baselineYield : 0.0;
    final cleanUnitPrice = baselineUnitPrice.isPositive
        ? baselineUnitPrice
        : Money.zero(currency: currency);
    final cleanCost = totalBudgetedCost.isPositive
        ? totalBudgetedCost
        : Money.zero(currency: currency);

    // 1. Expected Scenario (Base)
    final expectedRevenueMinor =
        (cleanYield * cleanUnitPrice.minorUnits.toDouble()).round();
    final expectedRevenue = Money(
      BigInt.from(expectedRevenueMinor),
      currency: currency,
    );
    final expectedProfit = expectedRevenue - cleanCost;
    final expectedRoi = cleanCost.isPositive
        ? (expectedProfit.toMajor() / cleanCost.toMajor()) * 100.0
        : 0.0;

    final expectedItem = ScenarioMatrixItem(
      scenarioType: 'EXPECTED',
      title: 'Expected Case',
      subtitle: 'Target Plan',
      expectedYield: cleanYield,
      yieldUnit: yieldUnit,
      expectedUnitPrice: cleanUnitPrice,
      projectedCost: cleanCost,
      projectedRevenue: expectedRevenue,
      projectedProfit: expectedProfit,
      projectedRoiPercent: expectedRoi,
    );

    // 2. Conservative Scenario (-20% Yield, -15% Price)
    final consYield =
        (cleanYield * conservativeYieldMultiplier * 10000).round() / 10000;
    final consPriceMinor =
        (cleanUnitPrice.minorUnits.toDouble() * conservativePriceMultiplier)
            .round();
    final consPrice = Money(BigInt.from(consPriceMinor), currency: currency);
    final consRevenueMinor = (consYield * consPriceMinor.toDouble()).round();
    final consRevenue = Money(
      BigInt.from(consRevenueMinor),
      currency: currency,
    );
    final consProfit = consRevenue - cleanCost;
    final consRoi = cleanCost.isPositive
        ? (consProfit.toMajor() / cleanCost.toMajor()) * 100.0
        : 0.0;

    final conservativeItem = ScenarioMatrixItem(
      scenarioType: 'CONSERVATIVE',
      title: 'Conservative',
      subtitle: '-20% Yield, -15% Price',
      expectedYield: consYield,
      yieldUnit: yieldUnit,
      expectedUnitPrice: consPrice,
      projectedCost: cleanCost,
      projectedRevenue: consRevenue,
      projectedProfit: consProfit,
      projectedRoiPercent: consRoi,
    );

    // 3. Optimistic Scenario (+15% Yield, +10% Price)
    final optYield =
        (cleanYield * optimisticYieldMultiplier * 10000).round() / 10000;
    final optPriceMinor =
        (cleanUnitPrice.minorUnits.toDouble() * optimisticPriceMultiplier)
            .round();
    final optPrice = Money(BigInt.from(optPriceMinor), currency: currency);
    final optRevenueMinor = (optYield * optPriceMinor.toDouble()).round();
    final optRevenue = Money(BigInt.from(optRevenueMinor), currency: currency);
    final optProfit = optRevenue - cleanCost;
    final optRoi = cleanCost.isPositive
        ? (optProfit.toMajor() / cleanCost.toMajor()) * 100.0
        : 0.0;

    final optimisticItem = ScenarioMatrixItem(
      scenarioType: 'OPTIMISTIC',
      title: 'Optimistic',
      subtitle: '+15% Yield, +10% Price',
      expectedYield: optYield,
      yieldUnit: yieldUnit,
      expectedUnitPrice: optPrice,
      projectedCost: cleanCost,
      projectedRevenue: optRevenue,
      projectedProfit: optProfit,
      projectedRoiPercent: optRoi,
    );

    return ScenarioPlanningMatrix(
      conservative: conservativeItem,
      expected: expectedItem,
      optimistic: optimisticItem,
      totalBudgetedCost: cleanCost,
      currency: currency,
    );
  }

  /// Constructs a matrix from a list of Drift [Scenario] records.
  /// If conservative or optimistic records are missing, auto-computes them from EXPECTED.
  factory ScenarioPlanningMatrix.fromScenarios({
    required List<Scenario> scenarios,
    required Money liveBudgetedCost,
    String currency = 'GHS',
  }) {
    Scenario? expRecord;
    Scenario? consRecord;
    Scenario? optRecord;

    for (final s in scenarios) {
      if (s.scenarioType.toUpperCase() == 'EXPECTED') expRecord = s;
      if (s.scenarioType.toUpperCase() == 'CONSERVATIVE') consRecord = s;
      if (s.scenarioType.toUpperCase() == 'OPTIMISTIC') optRecord = s;
    }

    if (expRecord == null) {
      return ScenarioPlanningMatrix.zero(currency: currency);
    }

    final baselineYield = expRecord.expectedYield;
    final yieldUnit = expRecord.yieldUnit;
    final baselineUnitPrice = Money(
      BigInt.from(expRecord.expectedUnitPriceMinor),
      currency: currency,
    );
    final costToUse = liveBudgetedCost.isPositive
        ? liveBudgetedCost
        : Money(BigInt.from(expRecord.projectedCostMinor), currency: currency);

    // If all 3 records are saved in DB, build directly
    if (consRecord != null && optRecord != null) {
      ScenarioMatrixItem buildItem(Scenario s, String title, String subtitle) {
        final price = Money(
          BigInt.from(s.expectedUnitPriceMinor),
          currency: currency,
        );
        final revenue = Money(
          BigInt.from(s.projectedRevenueMinor),
          currency: currency,
        );
        final profit = revenue - costToUse;
        final roi = costToUse.isPositive
            ? (profit.toMajor() / costToUse.toMajor()) * 100.0
            : 0.0;
        return ScenarioMatrixItem(
          scenarioType: s.scenarioType,
          title: title,
          subtitle: subtitle,
          expectedYield: s.expectedYield,
          yieldUnit: s.yieldUnit,
          expectedUnitPrice: price,
          projectedCost: costToUse,
          projectedRevenue: revenue,
          projectedProfit: profit,
          projectedRoiPercent: roi,
        );
      }

      return ScenarioPlanningMatrix(
        conservative: buildItem(
          consRecord,
          'Conservative',
          '-20% Yield, -15% Price',
        ),
        expected: buildItem(expRecord, 'Expected Case', 'Target Plan'),
        optimistic: buildItem(
          optRecord,
          'Optimistic',
          '+15% Yield, +10% Price',
        ),
        totalBudgetedCost: costToUse,
        currency: currency,
      );
    }

    // Otherwise compute derived conservative and optimistic scenarios
    return ScenarioPlanningMatrix.compute(
      baselineYield: baselineYield,
      yieldUnit: yieldUnit,
      baselineUnitPrice: baselineUnitPrice,
      totalBudgetedCost: costToUse,
      currency: currency,
    );
  }

  /// Default zeroed model for empty states.
  factory ScenarioPlanningMatrix.zero({String currency = 'GHS'}) {
    final zeroMoney = Money.zero(currency: currency);
    final zeroItem = ScenarioMatrixItem(
      scenarioType: 'EXPECTED',
      title: 'Expected Case',
      subtitle: 'Target Plan',
      expectedYield: 0.0,
      yieldUnit: 'kg',
      expectedUnitPrice: zeroMoney,
      projectedCost: zeroMoney,
      projectedRevenue: zeroMoney,
      projectedProfit: zeroMoney,
      projectedRoiPercent: 0.0,
    );
    return ScenarioPlanningMatrix(
      conservative: zeroItem,
      expected: zeroItem,
      optimistic: zeroItem,
      totalBudgetedCost: zeroMoney,
      currency: currency,
    );
  }

  /// Net capital deficit in the conservative scenario (0 if conservative is profitable).
  Money get downsideDeficit {
    if (conservative.isLoss) {
      return Money(
        conservative.projectedProfit.minorUnits.abs(),
        currency: currency,
      );
    }
    return Money.zero(currency: currency);
  }

  /// Percentage of invested capital at risk of loss in conservative scenario.
  double get downsideCapitalExposurePercent {
    if (totalBudgetedCost.minorUnits <= BigInt.zero || !conservative.isLoss) {
      return 0.0;
    }
    return (downsideDeficit.toMajor() / totalBudgetedCost.toMajor()) * 100.0;
  }

  /// Total profit spread between Optimistic and Conservative scenarios.
  Money get profitSpread =>
      optimistic.projectedProfit - conservative.projectedProfit;

  /// Risk rating categorizing project downside exposure.
  DownsideExposureRisk get riskRating {
    if (conservative.isProfitable || conservative.isBreakEven) {
      return DownsideExposureRisk.robust;
    }
    if (downsideCapitalExposurePercent <= 25.0) {
      return DownsideExposureRisk.moderate;
    }
    return DownsideExposureRisk.high;
  }

  /// Human-readable badge text for downside rating.
  String get riskBadgeLabel {
    switch (riskRating) {
      case DownsideExposureRisk.robust:
        return 'ROBUST DOWNSIDE DEFENSE';
      case DownsideExposureRisk.moderate:
        return 'MODERATE CAPITAL RISK';
      case DownsideExposureRisk.high:
        return 'HIGH DOWNSIDE EXPOSURE';
    }
  }

  /// Plain-text advisory decision guidance based on scenario analysis.
  String get advisoryMessage {
    if (totalBudgetedCost.minorUnits <= BigInt.zero) {
      return 'Finalize pre-season budget to evaluate downside capital exposure.';
    }
    if (expected.expectedYield <= 0 ||
        expected.expectedUnitPrice.minorUnits <= BigInt.zero) {
      return 'Enter baseline yield and price assumptions to generate scenario projections.';
    }

    switch (riskRating) {
      case DownsideExposureRisk.robust:
        return 'Resilient Capital Defense: Even under worst-case yield (-20%) and price (-15%) conditions, this venture remains profitable with a projected net return of ${conservative.projectedProfit.format()} (${conservative.formattedRoi} ROI). Capital is well protected.';
      case DownsideExposureRisk.moderate:
        return 'Manageable Downside Exposure: In the conservative scenario, the project risks a deficit of ${downsideDeficit.format()} (${downsideCapitalExposurePercent.toStringAsFixed(1)}% of capital). Maintain a liquid contingency buffer of at least ${downsideDeficit.format()} to absorb market shocks.';
      case DownsideExposureRisk.high:
        return 'High Downside Vulnerability: Worst-case conditions result in a substantial capital loss of ${downsideDeficit.format()} (${downsideCapitalExposurePercent.toStringAsFixed(1)}% of total budget). Strongly consider forward sales contracts, staggered harvesting, or lowering variable input costs before launching.';
    }
  }
}
