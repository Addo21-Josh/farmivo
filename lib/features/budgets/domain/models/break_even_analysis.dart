import '../../../../core/money/money.dart';

/// Rating indicating how safely invested capital is insulated against crop loss or price drops.
enum CapitalProtectionStatus {
  /// Strong buffer: >= 20% cushion above both break-even yield and price.
  secure,

  /// Narrow buffer: 0% to 19.9% cushion above break-even.
  moderate,

  /// Deficit: Projected yield or price falls below break-even (capital at risk).
  vulnerable,
}

/// Comprehensive pre-season break-even model for agricultural decision support.
class BreakEvenAnalysis {
  final double expectedYield;
  final String yieldUnit;
  final int expectedUnitPriceMinor;
  final int totalBudgetedCostMinor;
  final String currency;

  const BreakEvenAnalysis({
    required this.expectedYield,
    required this.yieldUnit,
    required this.expectedUnitPriceMinor,
    required this.totalBudgetedCostMinor,
    this.currency = 'GHS',
  });

  /// Break-even Quantity = Total Budgeted Cost / Expected Unit Price.
  double get breakEvenQuantity => expectedUnitPriceMinor > 0
      ? (totalBudgetedCostMinor / expectedUnitPriceMinor)
      : 0.0;

  /// Break-even Price = Total Budgeted Cost / Expected Yield.
  Money get breakEvenPrice => expectedYield > 0
      ? Money(
          BigInt.from((totalBudgetedCostMinor / expectedYield).round()),
          currency: currency,
        )
      : Money.zero(currency: currency);

  /// Total Budgeted Cost as strongly typed [Money].
  Money get totalBudgetedCost =>
      Money(BigInt.from(totalBudgetedCostMinor), currency: currency);

  /// Expected Unit Price as strongly typed [Money].
  Money get expectedUnitPrice =>
      Money(BigInt.from(expectedUnitPriceMinor), currency: currency);

  /// Projected Gross Revenue = Expected Yield * Expected Unit Price.
  Money get projectedRevenue => Money(
    BigInt.from((expectedYield * expectedUnitPriceMinor).round()),
    currency: currency,
  );

  /// Projected Net Profit = Projected Revenue - Budgeted Cost.
  Money get projectedProfit => Money(
    BigInt.from(
      (expectedYield * expectedUnitPriceMinor).round() - totalBudgetedCostMinor,
    ),
    currency: currency,
  );

  /// Yield Margin of Safety (Quantity): Expected Yield - Break-Even Quantity.
  double get yieldMarginOfSafety => expectedYield - breakEvenQuantity;

  /// Yield Margin of Safety %: ((Expected Yield - Break-Even Quantity) / Expected Yield) * 100.
  double get yieldSafetyPercentage {
    if (expectedYield <= 0) return 0.0;
    return (yieldMarginOfSafety / expectedYield) * 100.0;
  }

  /// Price Margin of Safety: Expected Unit Price - Break-Even Price.
  Money get priceMarginOfSafety => expectedUnitPrice - breakEvenPrice;

  /// Price Margin of Safety %: ((Expected Price - Break-Even Price) / Expected Price) * 100.
  double get priceSafetyPercentage {
    if (expectedUnitPriceMinor <= 0) return 0.0;
    return ((expectedUnitPriceMinor - breakEvenPrice.minorUnits.toInt()) /
            expectedUnitPriceMinor) *
        100.0;
  }

  /// Determines the capital protection status based on safety cushions.
  CapitalProtectionStatus get protectionStatus {
    if (totalBudgetedCostMinor <= 0) return CapitalProtectionStatus.secure;
    if (yieldSafetyPercentage >= 20.0 && priceSafetyPercentage >= 20.0) {
      return CapitalProtectionStatus.secure;
    } else if (yieldSafetyPercentage >= 0.0 && priceSafetyPercentage >= 0.0) {
      return CapitalProtectionStatus.moderate;
    } else {
      return CapitalProtectionStatus.vulnerable;
    }
  }

  /// Human-readable advisory guidance tailored for producers.
  String get advisoryMessage {
    switch (protectionStatus) {
      case CapitalProtectionStatus.secure:
        return 'Strong Capital Buffer: You can absorb up to a ${yieldSafetyPercentage.toStringAsFixed(0)}% yield drop or ${priceSafetyPercentage.toStringAsFixed(0)}% price decline before risking capital loss.';
      case CapitalProtectionStatus.moderate:
        return 'Moderate Capital Buffer: You have a ${yieldSafetyPercentage.toStringAsFixed(0)}% production margin. Consider locking in forward market agreements or optimizing discretionary inputs.';
      case CapitalProtectionStatus.vulnerable:
        return 'Capital at Risk: At current estimates, harvest proceeds will fall short of pre-season costs by ${projectedProfit.format().replaceAll('-', '')}. Review input budget or explore higher-value sales channels.';
    }
  }

  String get formattedBreakEvenQuantity => breakEvenQuantity % 1 == 0
      ? breakEvenQuantity.toInt().toString()
      : breakEvenQuantity.toStringAsFixed(1);

  String get formattedExpectedYield => expectedYield % 1 == 0
      ? expectedYield.toInt().toString()
      : expectedYield.toString();
}
