import '../money/money.dart';
import '../constants/app_constants.dart';
import 'dynamic_break_even.dart';
import 'project_comparison.dart';
import 'project_health_scoring.dart';
import 'project_profitability.dart';
import 'scenario_planning.dart';

export 'dynamic_break_even.dart';
export 'project_comparison.dart';
export 'project_health_scoring.dart';
export 'project_profitability.dart';
export 'scenario_planning.dart';

/// Pure calculation engine for agricultural financials.
/// Operates exclusively on [Money] value objects and doubles for quantities.
class FinancialCalculator {
  FinancialCalculator._();

  /// Computes a 3-scenario sensitivity matrix (Conservative, Expected, Optimistic) (Milestone 7.3).
  static ScenarioPlanningMatrix calculateScenarioMatrix({
    required double baselineYield,
    required String yieldUnit,
    required Money baselineUnitPrice,
    required Money totalBudgetedCost,
    double conservativeYieldMultiplier = 0.80,
    double conservativePriceMultiplier = 0.85,
    double optimisticYieldMultiplier = 1.15,
    double optimisticPriceMultiplier = 1.10,
    String currency = 'GHS',
  }) {
    return ScenarioPlanningMatrix.compute(
      baselineYield: baselineYield,
      yieldUnit: yieldUnit,
      baselineUnitPrice: baselineUnitPrice,
      totalBudgetedCost: totalBudgetedCost,
      conservativeYieldMultiplier: conservativeYieldMultiplier,
      conservativePriceMultiplier: conservativePriceMultiplier,
      optimisticYieldMultiplier: optimisticYieldMultiplier,
      optimisticPriceMultiplier: optimisticPriceMultiplier,
      currency: currency,
    );
  }

  /// Computes live dynamic break-even indicators based on actual costs vs. sales (Milestone 7.2).
  static DynamicBreakEven calculateDynamicBreakEven({
    required Money actualCosts,
    required Money actualSales,
    required Money cashCollected,
    required Money effectiveUnitPrice,
    String unit = 'kg',
    double remainingHarvestYield = 0.0,
    String currency = 'GHS',
  }) {
    return DynamicBreakEven.compute(
      actualCosts: actualCosts,
      actualSales: actualSales,
      cashCollected: cashCollected,
      effectiveUnitPrice: effectiveUnitPrice,
      unit: unit,
      remainingHarvestYield: remainingHarvestYield,
      currency: currency,
    );
  }

  /// Computes multi-dimensional profitability combining actuals, cash-flow, and projections (Milestone 7.1).
  static ProjectProfitability calculateProfitability({
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
    return ProjectProfitability.compute(
      actualRevenue: actualRevenue,
      actualExpenses: actualExpenses,
      cashCollected: cashCollected,
      cashDisbursed: cashDisbursed,
      totalBudgeted: totalBudgeted,
      actualHarvestedYield: actualHarvestedYield,
      expectedYield: expectedYield,
      expectedUnitPrice: expectedUnitPrice,
      currency: currency,
    );
  }

  /// Calculates variance amount (Actual - Planned).
  /// A positive number indicates spending above budget.
  static Money calculateVariance(Money planned, Money actual) {
    return actual - planned;
  }

  /// Calculates variance percentage: ((Actual - Planned) / Planned) * 100.
  static double calculateVariancePercentage(Money planned, Money actual) {
    if (planned.isZero) {
      return actual.isPositive ? 100.0 : 0.0;
    }
    final plannedMinor = planned.minorUnits.toDouble();
    final actualMinor = actual.minorUnits.toDouble();
    return ((actualMinor - plannedMinor) / plannedMinor) * 100.0;
  }

  /// Calculates actual net profit (Sales Revenue - Incurred Costs).
  static Money calculateActualProfit(Money actualRevenue, Money actualCost) {
    return actualRevenue - actualCost;
  }

  /// Calculates cash-basis profit (Collected Cash - Disbursed Cash).
  static Money calculateCashProfit(
    Money collectedRevenue,
    Money cashDisbursed,
  ) {
    return collectedRevenue - cashDisbursed;
  }

  /// Calculates projected final profit.
  static Money calculateProjectedProfit(
    Money projectedRevenue,
    Money projectedCost,
  ) {
    return projectedRevenue - projectedCost;
  }

  /// Calculates actual ROI percentage: (Profit / Cost) * 100.
  static double calculateActualRoi(Money actualProfit, Money actualCost) {
    if (actualCost.isZero || actualCost.isNegative) return 0.0;
    final profitMinor = actualProfit.minorUnits.toDouble();
    final costMinor = actualCost.minorUnits.toDouble();
    return (profitMinor / costMinor) * 100.0;
  }

  /// Calculates projected ROI percentage: (Projected Profit / Budgeted Cost) * 100.
  static double calculateProjectedRoi(
    Money projectedProfit,
    Money plannedCost,
  ) {
    if (plannedCost.isZero || plannedCost.isNegative) return 0.0;
    final profitMinor = projectedProfit.minorUnits.toDouble();
    final costMinor = plannedCost.minorUnits.toDouble();
    return (profitMinor / costMinor) * 100.0;
  }

  /// Calculates break-even output quantity: Total Cost / Unit Selling Price.
  static double calculateBreakEvenQuantity(Money totalCost, Money unitPrice) {
    if (unitPrice.isZero || unitPrice.isNegative) {
      throw ArgumentError(
        'Unit selling price must be greater than zero to calculate break-even quantity.',
      );
    }
    return totalCost.minorUnits.toDouble() / unitPrice.minorUnits.toDouble();
  }

  /// Calculates break-even unit selling price: Total Cost / Expected Quantity.
  static Money calculateBreakEvenPrice(
    Money totalCost,
    double expectedQuantity,
  ) {
    if (expectedQuantity <= 0) {
      throw ArgumentError(
        'Expected quantity must be greater than zero to calculate break-even price.',
      );
    }
    return totalCost.divide(expectedQuantity);
  }

  /// Calculates outstanding credit balance on a sale: Gross Sale - Payments.
  static Money calculateOutstandingReceivable(
    Money grossSale,
    Money totalPaid,
  ) {
    final balance = grossSale - totalPaid;
    return balance.isNegative
        ? Money.zero(currency: grossSale.currency)
        : balance;
  }

  /// Computes algorithmic project health evaluation across 5 weighted criteria (Milestone 7.4).
  static ProjectHealthEvaluation calculateProjectHealth({
    required Money plannedBudget,
    required Money actualSpent,
    required Money expectedRevenue,
    required Money actualSales,
    required Money cashCollected,
    ProjectLifecycleState stage = ProjectLifecycleState.production,
    int totalActivities = 0,
    int completedActivities = 0,
    int overdueActivities = 0,
    double? scheduleProgressRatio,
  }) {
    return ProjectHealthEvaluation.compute(
      plannedBudget: plannedBudget,
      actualSpent: actualSpent,
      expectedRevenue: expectedRevenue,
      actualSales: actualSales,
      cashCollected: cashCollected,
      stage: stage,
      totalActivities: totalActivities,
      completedActivities: completedActivities,
      overdueActivities: overdueActivities,
      scheduleProgressRatio: scheduleProgressRatio,
    );
  }

  /// Computes a side-by-side comparative matrix benchmarking multiple projects (Milestone 7.5).
  static ProjectComparisonMatrix compareProjects(
    List<ProjectComparisonRecord> records, {
    String currency = 'GHS',
  }) {
    return ProjectComparisonMatrix.compute(records, currency: currency);
  }

  /// Computes composite project health score (0 to 100) and diagnostic reason.
  static HealthEvaluation evaluateProjectHealth({
    required Money plannedBudget,
    required Money actualSpent,
    required Money expectedRevenue,
    required Money actualSales,
    required Money collectedRevenue,
    required double scheduleProgressRatio, // 0.0 to 1.0
  }) {
    final eval = calculateProjectHealth(
      plannedBudget: plannedBudget,
      actualSpent: actualSpent,
      expectedRevenue: expectedRevenue,
      actualSales: actualSales,
      cashCollected: collectedRevenue,
      scheduleProgressRatio: scheduleProgressRatio,
    );

    return HealthEvaluation(
      score: eval.score,
      status: eval.status,
      summary: eval.summary,
      budgetScore: eval.breakdown.budgetDisciplineScore.round(),
      revenueScore: eval.breakdown.revenuePerformanceScore.round(),
      collectionScore: eval.breakdown.creditRiskScore.round(),
    );
  }
}

class HealthEvaluation {
  final int score;
  final ProjectHealthStatus status;
  final String summary;
  final int budgetScore;
  final int revenueScore;
  final int collectionScore;

  const HealthEvaluation({
    required this.score,
    required this.status,
    required this.summary,
    required this.budgetScore,
    required this.revenueScore,
    required this.collectionScore,
  });
}
