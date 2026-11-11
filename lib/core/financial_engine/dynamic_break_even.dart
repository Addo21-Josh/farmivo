import '../money/money.dart';

/// Feasibility rating indicating whether remaining expected crop harvests
/// will cover the unrecovered capital deficit to achieve break-even.
enum BreakEvenFeasibility {
  /// Capital fully recovered; operational break-even achieved.
  achieved,

  /// Remaining harvest yield exceeds the units required to break even.
  onTrack,

  /// Remaining harvest yield falls short of units required at current market price.
  shortfallRisk,
}

/// Represents live in-season dynamic break-even status based on actual costs to date
/// vs. sales and cash collected (Milestone 7.2).
class DynamicBreakEven {
  /// Total actual operational costs incurred to date.
  final Money actualCosts;

  /// Total gross sales revenue recorded to date (accrual basis).
  final Money actualSales;

  /// Total liquid cash collected from sales to date.
  final Money cashCollected;

  /// Effective unit selling price used to compute unit volume requirements.
  final Money effectiveUnitPrice;

  /// Unit of measure (e.g. 'Bags', 'kg', 'Crates').
  final String unit;

  /// Remaining crop yield anticipated to be harvested.
  final double remainingHarvestYield;

  /// Currency code (default 'GHS').
  final String currency;

  const DynamicBreakEven({
    required this.actualCosts,
    required this.actualSales,
    required this.cashCollected,
    required this.effectiveUnitPrice,
    this.unit = 'kg',
    this.remainingHarvestYield = 0.0,
    this.currency = 'GHS',
  });

  /// Factory constructing zeroed default model.
  factory DynamicBreakEven.zero({String currency = 'GHS'}) {
    final zero = Money.zero(currency: currency);
    return DynamicBreakEven(
      actualCosts: zero,
      actualSales: zero,
      cashCollected: zero,
      effectiveUnitPrice: zero,
      unit: 'kg',
      remainingHarvestYield: 0.0,
      currency: currency,
    );
  }

  /// Factory computing live in-season dynamic break-even indicators.
  factory DynamicBreakEven.compute({
    required Money actualCosts,
    required Money actualSales,
    required Money cashCollected,
    required Money effectiveUnitPrice,
    String unit = 'kg',
    double remainingHarvestYield = 0.0,
    String currency = 'GHS',
  }) {
    return DynamicBreakEven(
      actualCosts: actualCosts,
      actualSales: actualSales,
      cashCollected: cashCollected,
      effectiveUnitPrice: effectiveUnitPrice,
      unit: unit,
      remainingHarvestYield: remainingHarvestYield,
      currency: currency,
    );
  }

  /// Unrecovered capital deficit on an accrual basis (Gross Sales vs Actual Costs).
  Money get accrualDeficit {
    if (actualSales >= actualCosts) {
      return Money.zero(currency: currency);
    }
    return actualCosts - actualSales;
  }

  /// Unrecovered capital deficit on a cash basis (Cash Collected vs Actual Costs).
  Money get cashDeficit {
    if (cashCollected >= actualCosts) {
      return Money.zero(currency: currency);
    }
    return actualCosts - cashCollected;
  }

  /// True if gross sales revenue meets or exceeds total actual costs.
  bool get isAccrualBreakEvenAchieved =>
      actualCosts.isPositive && actualSales >= actualCosts;

  /// True if liquid cash collected meets or exceeds total actual costs.
  bool get isCashBreakEvenAchieved =>
      actualCosts.isPositive && cashCollected >= actualCosts;

  /// Percentage of incurred capital recouped through sales contracts (capped at 200%).
  double get accrualRecoveryPercentage {
    if (actualCosts.minorUnits == BigInt.zero) return 0.0;
    return (actualSales.toMajor() / actualCosts.toMajor()) * 100.0;
  }

  /// Percentage of incurred capital recouped in liquid collected cash.
  double get cashRecoveryPercentage {
    if (actualCosts.minorUnits == BigInt.zero) return 0.0;
    return (cashCollected.toMajor() / actualCosts.toMajor()) * 100.0;
  }

  /// Remaining crop units required to achieve accrual break-even.
  double get remainingUnitsToBreakEven {
    if (isAccrualBreakEvenAchieved) return 0.0;
    if (effectiveUnitPrice.minorUnits <= BigInt.zero) return 0.0;
    return accrualDeficit.minorUnits.toDouble() /
        effectiveUnitPrice.minorUnits.toDouble();
  }

  /// Remaining crop units required to achieve liquid cash break-even.
  double get remainingUnitsCashBreakEven {
    if (isCashBreakEvenAchieved) return 0.0;
    if (effectiveUnitPrice.minorUnits <= BigInt.zero) return 0.0;
    return cashDeficit.minorUnits.toDouble() /
        effectiveUnitPrice.minorUnits.toDouble();
  }

  /// Feasibility evaluation comparing remaining harvest yield to remaining units required.
  BreakEvenFeasibility get feasibility {
    if (isAccrualBreakEvenAchieved) return BreakEvenFeasibility.achieved;
    if (remainingHarvestYield >= remainingUnitsToBreakEven) {
      return BreakEvenFeasibility.onTrack;
    }
    return BreakEvenFeasibility.shortfallRisk;
  }

  /// Human-readable advisory guidance.
  String get advisoryMessage {
    if (actualCosts.minorUnits == BigInt.zero) {
      return 'No operational expenditures recorded yet.';
    }
    if (isCashBreakEvenAchieved) {
      return 'Capital Fully Recouped: 100% of invested capital has been recouped in liquid cash. Additional sales represent pure surplus profit.';
    }
    if (isAccrualBreakEvenAchieved) {
      return 'Accrual Break-Even Achieved: Invoiced sales cover 100% of costs. Collect ${cashDeficit.format()} in outstanding buyer receivables to achieve full liquid cash break-even.';
    }
    final formattedUnits = formattedRemainingUnits;
    if (feasibility == BreakEvenFeasibility.onTrack) {
      final surplus = remainingHarvestYield - remainingUnitsToBreakEven;
      final formattedSurplus = surplus % 1 == 0
          ? surplus.toInt().toString()
          : surplus.toStringAsFixed(1);
      return 'On Track: Need $formattedUnits $unit (${accrualDeficit.format()}) to break even. Remaining harvest ($remainingHarvestYield $unit) provides a safety buffer of $formattedSurplus $unit.';
    } else {
      final deficit = remainingUnitsToBreakEven - remainingHarvestYield;
      final formattedDeficit = deficit % 1 == 0
          ? deficit.toInt().toString()
          : deficit.toStringAsFixed(1);
      return 'Yield Shortfall Risk: Need $formattedUnits $unit to break even, but only $remainingHarvestYield $unit remains expected. Projected deficit of $formattedDeficit $unit at current price (${effectiveUnitPrice.format()}).';
    }
  }

  /// Formatted string representation of remaining units without trailing zero decimals.
  String get formattedRemainingUnits {
    final units = remainingUnitsToBreakEven;
    return units % 1 == 0 ? units.toInt().toString() : units.toStringAsFixed(1);
  }
}
