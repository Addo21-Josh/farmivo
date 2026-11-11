import '../money/money.dart';

/// Synthesized multi-dimensional profitability metrics across actuals, cash flow,
/// and in-season dynamic projections (Milestone 7.1).
class ProjectProfitability {
  /// 1. Actual Net Profit (Accrual basis): Recorded Sales Revenue - Actual Expenses.
  final Money actualNetProfit;
  final Money actualRevenue;
  final Money actualExpenses;
  final double actualRoiPercentage;

  /// 2. Cash Profit (Cash basis): Cash Collected - Cash Disbursed (Actual Expenses).
  final Money cashProfit;
  final Money cashCollected;
  final Money cashDisbursed;
  final double cashRoiPercentage;

  /// 3. Projected Final Profit (Tri-Value Dynamic Projection):
  /// Projected Total Revenue = Actual Sales + Remaining Anticipated Revenue
  /// Projected Total Cost = Actual Expenses + Remaining Budgeted Cost
  /// Projected Final Profit = Projected Total Revenue - Projected Total Cost
  final Money projectedProfit;
  final Money projectedRevenue;
  final Money projectedCost;
  final Money remainingAnticipatedRevenue;
  final Money remainingEstimatedCost;
  final double projectedRoiPercentage;

  /// Currency code.
  final String currency;

  const ProjectProfitability({
    required this.actualNetProfit,
    required this.actualRevenue,
    required this.actualExpenses,
    required this.actualRoiPercentage,
    required this.cashProfit,
    required this.cashCollected,
    required this.cashDisbursed,
    required this.cashRoiPercentage,
    required this.projectedProfit,
    required this.projectedRevenue,
    required this.projectedCost,
    required this.remainingAnticipatedRevenue,
    required this.remainingEstimatedCost,
    required this.projectedRoiPercentage,
    this.currency = 'GHS',
  });

  /// Factory constructing zeroed default profitability.
  factory ProjectProfitability.zero({String currency = 'GHS'}) {
    final zero = Money.zero(currency: currency);
    return ProjectProfitability(
      actualNetProfit: zero,
      actualRevenue: zero,
      actualExpenses: zero,
      actualRoiPercentage: 0.0,
      cashProfit: zero,
      cashCollected: zero,
      cashDisbursed: zero,
      cashRoiPercentage: 0.0,
      projectedProfit: zero,
      projectedRevenue: zero,
      projectedCost: zero,
      remainingAnticipatedRevenue: zero,
      remainingEstimatedCost: zero,
      projectedRoiPercentage: 0.0,
      currency: currency,
    );
  }

  /// Factory computing multi-dimensional profitability from constituent financial elements.
  factory ProjectProfitability.compute({
    required Money actualRevenue,
    required Money actualExpenses,
    required Money cashCollected,
    required Money cashDisbursed,
    required Money totalBudgeted,
    double actualHarvestedYield = 0.0,
    double expectedYield = 0.0,
    Money? expectedUnitPrice,
    String currency = 'GHS',
  }) {
    // 1. Actual Net Profit (Accrual)
    final actualNetProfit = actualRevenue - actualExpenses;
    double actualRoi = 0.0;
    if (actualExpenses.isPositive) {
      actualRoi =
          (actualNetProfit.toMajor() / actualExpenses.toMajor()) * 100.0;
    }

    // 2. Cash Profit (Cash-basis)
    final cashProfit = cashCollected - cashDisbursed;
    double cashRoi = 0.0;
    if (cashDisbursed.isPositive) {
      cashRoi = (cashProfit.toMajor() / cashDisbursed.toMajor()) * 100.0;
    }

    // 3. Projected Final Profit (Tri-Value Dynamic In-Season Projection)
    // Remaining estimated cost to complete season: max(0, totalBudgeted - actualExpenses)
    final remainingCost = totalBudgeted > actualExpenses
        ? totalBudgeted - actualExpenses
        : Money.zero(currency: currency);
    final projectedCost = actualExpenses + remainingCost;

    // Remaining anticipated harvest revenue: max(0, expectedYield - actualHarvestedYield) * expectedUnitPrice
    Money remainingRevenue = Money.zero(currency: currency);
    if (expectedYield > 0 &&
        expectedUnitPrice != null &&
        expectedUnitPrice.isPositive) {
      final remainingYield = expectedYield > actualHarvestedYield
          ? expectedYield - actualHarvestedYield
          : 0.0;
      final minor = BigInt.from(
        (remainingYield * expectedUnitPrice.minorUnits.toDouble()).round(),
      );
      remainingRevenue = Money(minor, currency: currency);
    }

    final projectedRevenue = actualRevenue + remainingRevenue;
    final projectedProfit = projectedRevenue - projectedCost;

    double projectedRoi = 0.0;
    if (projectedCost.isPositive) {
      projectedRoi =
          (projectedProfit.toMajor() / projectedCost.toMajor()) * 100.0;
    } else if (totalBudgeted.isPositive) {
      projectedRoi =
          (projectedProfit.toMajor() / totalBudgeted.toMajor()) * 100.0;
    }

    return ProjectProfitability(
      actualNetProfit: actualNetProfit,
      actualRevenue: actualRevenue,
      actualExpenses: actualExpenses,
      actualRoiPercentage: actualRoi,
      cashProfit: cashProfit,
      cashCollected: cashCollected,
      cashDisbursed: cashDisbursed,
      cashRoiPercentage: cashRoi,
      projectedProfit: projectedProfit,
      projectedRevenue: projectedRevenue,
      projectedCost: projectedCost,
      remainingAnticipatedRevenue: remainingRevenue,
      remainingEstimatedCost: remainingCost,
      projectedRoiPercentage: projectedRoi,
      currency: currency,
    );
  }

  bool get isActualProfitable => actualNetProfit.isPositive;
  bool get isCashProfitable => cashProfit.isPositive;
  bool get isProjectedProfitable => projectedProfit.isPositive;
}
