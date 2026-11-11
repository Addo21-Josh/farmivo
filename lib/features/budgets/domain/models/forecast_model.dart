import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';

/// Pure domain model holding pre-season yield, price, revenue, and profit calculations.
class ForecastCalculation {
  final double expectedYield;
  final String yieldUnit;
  final int expectedUnitPriceMinor;
  final int totalBudgetedCostMinor;
  final String currency;

  const ForecastCalculation({
    required this.expectedYield,
    required this.yieldUnit,
    required this.expectedUnitPriceMinor,
    required this.totalBudgetedCostMinor,
    this.currency = 'GHS',
  });

  /// Factory computing forecast from a saved Drift [Scenario] record.
  factory ForecastCalculation.fromScenario(
    Scenario scenario, {
    String currency = 'GHS',
  }) {
    return ForecastCalculation(
      expectedYield: scenario.expectedYield,
      yieldUnit: scenario.yieldUnit,
      expectedUnitPriceMinor: scenario.expectedUnitPriceMinor,
      totalBudgetedCostMinor: scenario.projectedCostMinor,
      currency: currency,
    );
  }

  /// Projected Gross Revenue in minor units: Yield * Unit Price.
  int get projectedRevenueMinor =>
      (expectedYield * expectedUnitPriceMinor).round();

  /// Projected Net Profit in minor units: Projected Revenue - Total Budgeted Cost.
  int get projectedProfitMinor =>
      projectedRevenueMinor - totalBudgetedCostMinor;

  /// Projected Return on Investment (ROI) percentage: (Profit / Cost) * 100.
  double get projectedRoiPercent {
    if (totalBudgetedCostMinor <= 0) return 0.0;
    return (projectedProfitMinor / totalBudgetedCostMinor) * 100.0;
  }

  /// Typed monetary representation of the estimated unit selling price.
  Money get expectedUnitPrice =>
      Money(BigInt.from(expectedUnitPriceMinor), currency: currency);

  /// Typed monetary representation of the projected gross revenue.
  Money get projectedRevenue =>
      Money(BigInt.from(projectedRevenueMinor), currency: currency);

  /// Typed monetary representation of the total pre-season budgeted cost.
  Money get totalBudgetedCost =>
      Money(BigInt.from(totalBudgetedCostMinor), currency: currency);

  /// Typed monetary representation of the projected profit (or deficit).
  Money get projectedProfit =>
      Money(BigInt.from(projectedProfitMinor), currency: currency);

  bool get isProfitable => projectedProfitMinor > 0;
  bool get isBreakEven => projectedProfitMinor == 0;
  bool get isLoss => projectedProfitMinor < 0;

  /// Clean quantity string without trailing decimals if integer.
  String get formattedYield => expectedYield % 1 == 0
      ? expectedYield.toInt().toString()
      : expectedYield.toString();

  /// Formatted formula display (e.g. "150 Bags × GH₵ 180.00 = GH₵ 27,000.00").
  String get formulaDisplay =>
      '$formattedYield $yieldUnit × ${expectedUnitPrice.format()} = ${projectedRevenue.format()}';

  /// Break-even Yield Quantity: Total Cost / Unit Price.
  double get breakEvenYield => expectedUnitPriceMinor > 0
      ? (totalBudgetedCostMinor / expectedUnitPriceMinor)
      : 0.0;

  /// Break-even Unit Price: Total Cost / Expected Yield.
  Money get breakEvenPrice => expectedYield > 0
      ? Money(
          BigInt.from((totalBudgetedCostMinor / expectedYield).round()),
          currency: currency,
        )
      : Money.zero(currency: currency);
}

/// Extension adding helper getters to Drift [Scenario] records.
extension ScenarioForecastX on Scenario {
  Money unitPrice([String currency = 'GHS']) =>
      Money(BigInt.from(expectedUnitPriceMinor), currency: currency);

  Money projectedRevenueMoney([String currency = 'GHS']) =>
      Money(BigInt.from(projectedRevenueMinor), currency: currency);

  Money projectedCostMoney([String currency = 'GHS']) =>
      Money(BigInt.from(projectedCostMinor), currency: currency);

  Money projectedProfitMoney([String currency = 'GHS']) =>
      Money(BigInt.from(projectedProfitMinor), currency: currency);

  bool get isProfitable => projectedProfitMinor > 0;
  bool get isLoss => projectedProfitMinor < 0;

  String get formattedYield => expectedYield % 1 == 0
      ? expectedYield.toInt().toString()
      : expectedYield.toString();
}
