import '../../../../core/constants/app_constants.dart';
import '../../../../core/financial_engine/dynamic_break_even.dart';
import '../../../../core/financial_engine/project_health_scoring.dart';
import '../../../../core/financial_engine/project_profitability.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../state_machine/project_state_machine.dart';

export '../../../../core/financial_engine/dynamic_break_even.dart';
export '../../../../core/financial_engine/project_health_scoring.dart';
export '../../../../core/financial_engine/project_profitability.dart';

/// Aggregated real-time metrics and financial indicators for an individual farm project.
class ProjectMetrics {
  final String projectId;
  final int daysActive;
  final ProjectLifecycleState stage;
  final Money totalBudgeted;
  final Money totalSpent;
  final Money totalRevenue; // Gross Sales Value (Total value of produce sold)
  final Money collectedRevenue; // Liquid cash received into accounts
  final Money accountsReceivable; // Money owed by market buyers
  final Money netProfit; // Accrual Net Profit (Gross Sales - Total Spent)
  final Money
  cashProfit; // Cash Profit (Cash Collected - Cash Disbursed / Spent)
  final double roiPercentage; // Accrual ROI %
  final double cashRoiPercentage; // Cash-basis ROI %
  final String projectedYieldDisplay;
  final double actualYieldTotal;
  final String actualYieldUnit;
  final int activitiesCount;
  final int harvestBatchesCount;
  final int salesCount;
  final Money unpaidReceivables; // Alias for accountsReceivable
  final double budgetSpentPercentage;
  final ProjectHealthStatus healthStatus;
  final String healthMessage;
  final ProjectHealthEvaluation healthEvaluation;
  final ProjectProfitability profitability;
  final DynamicBreakEven dynamicBreakEven;

  ProjectMetrics({
    required this.projectId,
    required this.daysActive,
    required this.stage,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRevenue,
    Money? collectedRevenue,
    Money? accountsReceivable,
    required this.netProfit,
    Money? cashProfit,
    required this.roiPercentage,
    double? cashRoiPercentage,
    required this.projectedYieldDisplay,
    required this.actualYieldTotal,
    required this.actualYieldUnit,
    required this.activitiesCount,
    required this.harvestBatchesCount,
    required this.salesCount,
    required this.unpaidReceivables,
    required this.budgetSpentPercentage,
    ProjectHealthStatus? healthStatus,
    String? healthMessage,
    ProjectHealthEvaluation? healthEvaluation,
    ProjectProfitability? profitability,
    DynamicBreakEven? dynamicBreakEven,
  }) : collectedRevenue = collectedRevenue ?? totalRevenue,
       accountsReceivable = accountsReceivable ?? unpaidReceivables,
       cashProfit =
           cashProfit ??
           (collectedRevenue != null
               ? collectedRevenue - totalSpent
               : netProfit),
       cashRoiPercentage = cashRoiPercentage ?? roiPercentage,
       healthEvaluation =
           healthEvaluation ??
           ProjectHealthEvaluation.compute(
             plannedBudget: totalBudgeted,
             actualSpent: totalSpent,
             expectedRevenue: totalRevenue,
             actualSales: totalRevenue,
             cashCollected: collectedRevenue ?? totalRevenue,
             stage: stage,
           ),
       healthStatus =
           healthStatus ??
           (healthEvaluation?.status ??
               (totalBudgeted.isPositive &&
                       (totalSpent.toMajor() / totalBudgeted.toMajor()) > 1.0
                   ? ProjectHealthStatus.atRisk
                   : (netProfit.isPositive
                         ? ProjectHealthStatus.healthy
                         : ProjectHealthStatus.watch))),
       healthMessage =
           healthMessage ?? (healthEvaluation?.summary ?? 'Operational'),
       profitability =
           profitability ??
           ProjectProfitability(
             actualNetProfit: netProfit,
             actualRevenue: totalRevenue,
             actualExpenses: totalSpent,
             actualRoiPercentage: roiPercentage,
             cashProfit: cashProfit ?? netProfit,
             cashCollected: collectedRevenue ?? totalRevenue,
             cashDisbursed: totalSpent,
             cashRoiPercentage: cashRoiPercentage ?? roiPercentage,
             projectedProfit: netProfit,
             projectedRevenue: totalRevenue,
             projectedCost: totalSpent,
             remainingAnticipatedRevenue: Money.zero(
               currency: totalRevenue.currency,
             ),
             remainingEstimatedCost: Money.zero(
               currency: totalRevenue.currency,
             ),
             projectedRoiPercentage: roiPercentage,
             currency: totalRevenue.currency,
           ),
       dynamicBreakEven =
           dynamicBreakEven ??
           DynamicBreakEven.zero(currency: totalRevenue.currency);

  /// Algorithmic Project Health Engine (Milestone 7.4)
  int get healthScore => healthEvaluation.score;
  ProjectHealthBreakdown get healthBreakdown => healthEvaluation.breakdown;
  List<String> get healthDiagnosticReasons =>
      healthEvaluation.diagnosticReasons;

  /// Dynamic break-even metrics (Milestone 7.2)
  bool get isBreakEvenAchieved => dynamicBreakEven.isAccrualBreakEvenAchieved;
  double get remainingUnitsToBreakEven =>
      dynamicBreakEven.remainingUnitsToBreakEven;
  Money get unrecoveredCostDeficit => dynamicBreakEven.accrualDeficit;

  /// Multi-dimensional profit metrics (Milestone 7.1)
  Money get actualNetProfit => profitability.actualNetProfit;
  Money get projectedFinalProfit => profitability.projectedProfit;
  double get actualRoiPercentage => profitability.actualRoiPercentage;
  double get projectedRoiPercentage => profitability.projectedRoiPercentage;

  /// Alias for totalRevenue representing gross value of commercial contracts.
  Money get grossSales => totalRevenue;

  /// Alias for netProfit representing accrual return.
  Money get accrualProfit => netProfit;

  /// Alias for roiPercentage.
  double get accrualRoiPercentage => roiPercentage;

  /// Percentage of gross sales converted into liquid collected cash.
  double get collectionRatePercentage {
    if (totalRevenue.minorUnits == BigInt.zero) return 0.0;
    return (collectedRevenue.toMajor() / totalRevenue.toMajor()) * 100.0;
  }

  /// Factory computing metrics from live database aggregates.
  factory ProjectMetrics.compute({
    required Project project,
    required List<BudgetItem> budgetItems,
    required List<Expense> expenses,
    required List<Activity> activities,
    required List<Harvest> harvests,
    required List<Sale> sales,
    List<Payment> payments = const [],
    Scenario? forecastScenario,
  }) {
    final currency = project.currency.isNotEmpty ? project.currency : 'GHS';
    final startDate = DateTime.fromMillisecondsSinceEpoch(project.startDate);
    final daysActive = DateTime.now()
        .difference(startDate)
        .inDays
        .clamp(0, 99999);
    final stage = ProjectLifecycleStateStateMachineX.parse(project.status);

    // 1. Budget Total
    final activeBudget = budgetItems.where((b) => !b.isDeleted).toList();
    final totalBudgetMinor = activeBudget.fold<BigInt>(
      BigInt.zero,
      (acc, item) => acc + BigInt.from(item.plannedAmountMinor),
    );
    final totalBudgeted = Money(totalBudgetMinor, currency: currency);

    // 2. Expenses Total
    final activeExpenses = expenses
        .where((e) => !e.isDeleted && !e.isVoided)
        .toList();
    final totalSpentMinor = activeExpenses.fold<BigInt>(
      BigInt.zero,
      (acc, exp) => acc + BigInt.from(exp.amountMinor),
    );
    final totalSpent = Money(totalSpentMinor, currency: currency);

    // 3. Sales, Collected Cash & Receivables (Milestone 6.4)
    final activeSales = sales
        .where((s) => !s.isDeleted && !s.isVoided)
        .toList();
    final totalRevMinor = activeSales.fold<BigInt>(
      BigInt.zero,
      (acc, s) => acc + BigInt.from(s.totalAmountMinor),
    );
    final totalRevenue = Money(totalRevMinor, currency: currency);

    // Calculate collected cash from active payments on active sales
    final activeSaleIds = activeSales.map((s) => s.id).toSet();
    final activePayments = payments
        .where((p) => !p.isVoided && activeSaleIds.contains(p.saleId))
        .toList();

    BigInt collectedMinor = BigInt.zero;
    if (activePayments.isNotEmpty) {
      collectedMinor = activePayments.fold<BigInt>(
        BigInt.zero,
        (acc, p) => acc + BigInt.from(p.amountMinor),
      );
    } else {
      // Fallback when payments list is not provided (e.g. legacy test mocks)
      for (final s in activeSales) {
        if (s.paymentStatus.toUpperCase() == 'PAID') {
          collectedMinor += BigInt.from(s.totalAmountMinor);
        }
      }
    }

    if (collectedMinor > totalRevMinor) {
      collectedMinor = totalRevMinor;
    }

    final receivablesMinor = totalRevMinor > collectedMinor
        ? totalRevMinor - collectedMinor
        : BigInt.zero;

    final collectedRevenue = Money(collectedMinor, currency: currency);
    final accountsReceivable = Money(receivablesMinor, currency: currency);
    final unpaidReceivables = accountsReceivable;

    // 4. Financial Calculations
    // Accrual Net Profit: Gross Sales - Total Incurred
    final netProfit = totalRevenue - totalSpent;

    // Cash-Basis Profit: Cash Collected - Total Incurred
    final cashProfit = collectedRevenue - totalSpent;

    double roiPercentage = 0.0;
    if (totalSpent.isPositive) {
      final spentDouble = totalSpent.toMajor();
      final profitDouble = netProfit.toMajor();
      roiPercentage = (profitDouble / spentDouble) * 100.0;
    }

    double cashRoiPercentage = 0.0;
    if (totalSpent.isPositive) {
      final spentDouble = totalSpent.toMajor();
      final cashProfitDouble = cashProfit.toMajor();
      cashRoiPercentage = (cashProfitDouble / spentDouble) * 100.0;
    }

    double budgetSpentPercentage = 0.0;
    if (totalBudgeted.isPositive) {
      budgetSpentPercentage =
          (totalSpent.toMajor() / totalBudgeted.toMajor()) * 100.0;
    }

    // 5. Harvest Yield Calculations
    final activeHarvests = harvests.where((h) => !h.isDeleted).toList();
    double actualYieldTotal = 0.0;
    String actualYieldUnit = '';
    for (final h in activeHarvests) {
      actualYieldTotal += h.quantity;
      if (actualYieldUnit.isEmpty) {
        actualYieldUnit = h.unit;
      }
    }

    final projectedYieldDisplay = _resolveProjectedYield(
      project: project,
      actualYield: actualYieldTotal,
      actualUnit: actualYieldUnit,
      harvestCount: activeHarvests.length,
    );

    // 6. Algorithmic Project Health Scoring Engine (Milestone 7.4)
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final activeActivities = activities.where((a) => !a.isDeleted).toList();
    final totalActivities = activeActivities.length;
    final completedActivities = activeActivities
        .where((a) => a.status.toUpperCase() == 'COMPLETED')
        .length;
    final overdueActivities = activeActivities.where((a) {
      final s = a.status.toUpperCase();
      return s == 'OVERDUE' || (s != 'COMPLETED' && a.activityDate < nowMs);
    }).length;

    final expectedRevMoney = forecastScenario != null
        ? Money(
            BigInt.from(forecastScenario.projectedRevenueMinor),
            currency: currency,
          )
        : Money.zero(currency: currency);

    final healthEvaluation = ProjectHealthEvaluation.compute(
      plannedBudget: totalBudgeted,
      actualSpent: totalSpent,
      expectedRevenue: expectedRevMoney,
      actualSales: totalRevenue,
      cashCollected: collectedRevenue,
      stage: stage,
      totalActivities: totalActivities,
      completedActivities: completedActivities,
      overdueActivities: overdueActivities,
    );

    final healthStatus = healthEvaluation.status;
    final healthMessage = healthEvaluation.summary;

    // Multi-Dimensional Profitability Engine (Milestone 7.1)
    final profitability = ProjectProfitability.compute(
      actualRevenue: totalRevenue,
      actualExpenses: totalSpent,
      cashCollected: collectedRevenue,
      cashDisbursed: totalSpent,
      totalBudgeted: totalBudgeted,
      actualHarvestedYield: actualYieldTotal,
      expectedYield: forecastScenario?.expectedYield ?? 0.0,
      expectedUnitPrice: forecastScenario != null
          ? Money(
              BigInt.from(forecastScenario.expectedUnitPriceMinor),
              currency: currency,
            )
          : null,
      currency: currency,
    );

    // Dynamic Break-Even Analysis Engine (Milestone 7.2)
    final totalSoldQuantity = activeSales.fold<double>(
      0.0,
      (acc, s) => acc + s.quantity,
    );

    Money effectiveUnitPrice;
    if (totalSoldQuantity > 0 && totalRevenue.isPositive) {
      final unitPriceMinor =
          (totalRevenue.minorUnits.toDouble() / totalSoldQuantity).round();
      effectiveUnitPrice = Money(
        BigInt.from(unitPriceMinor),
        currency: currency,
      );
    } else if (forecastScenario != null &&
        forecastScenario.expectedUnitPriceMinor > 0) {
      effectiveUnitPrice = Money(
        BigInt.from(forecastScenario.expectedUnitPriceMinor),
        currency: currency,
      );
    } else {
      effectiveUnitPrice = Money.zero(currency: currency);
    }

    String resolvedBreakEvenUnit = actualYieldUnit;
    if (resolvedBreakEvenUnit.isEmpty &&
        forecastScenario != null &&
        forecastScenario.yieldUnit.isNotEmpty) {
      resolvedBreakEvenUnit = forecastScenario.yieldUnit;
    }
    if (resolvedBreakEvenUnit.isEmpty) {
      resolvedBreakEvenUnit = 'kg';
    }

    double remainingHarvestYield = 0.0;
    if (forecastScenario != null && forecastScenario.expectedYield > 0) {
      final diff = forecastScenario.expectedYield - actualYieldTotal;
      remainingHarvestYield = diff > 0 ? diff : 0.0;
    }

    final dynamicBreakEven = DynamicBreakEven.compute(
      actualCosts: totalSpent,
      actualSales: totalRevenue,
      cashCollected: collectedRevenue,
      effectiveUnitPrice: effectiveUnitPrice,
      unit: resolvedBreakEvenUnit,
      remainingHarvestYield: remainingHarvestYield,
      currency: currency,
    );

    return ProjectMetrics(
      projectId: project.id,
      daysActive: daysActive,
      stage: stage,
      totalBudgeted: totalBudgeted,
      totalSpent: totalSpent,
      totalRevenue: totalRevenue,
      collectedRevenue: collectedRevenue,
      accountsReceivable: accountsReceivable,
      netProfit: netProfit,
      cashProfit: cashProfit,
      roiPercentage: roiPercentage,
      cashRoiPercentage: cashRoiPercentage,
      projectedYieldDisplay: projectedYieldDisplay,
      actualYieldTotal: actualYieldTotal,
      actualYieldUnit: actualYieldUnit,
      activitiesCount: activities.where((a) => !a.isDeleted).length,
      harvestBatchesCount: activeHarvests.length,
      salesCount: activeSales.length,
      unpaidReceivables: unpaidReceivables,
      budgetSpentPercentage: budgetSpentPercentage,
      healthStatus: healthStatus,
      healthMessage: healthMessage,
      healthEvaluation: healthEvaluation,
      profitability: profitability,
      dynamicBreakEven: dynamicBreakEven,
    );
  }

  static String _resolveProjectedYield({
    required Project project,
    required double actualYield,
    required String actualUnit,
    required int harvestCount,
  }) {
    if (harvestCount > 0 && actualYield > 0) {
      final formatted = actualYield.truncateToDouble() == actualYield
          ? actualYield.toInt().toString()
          : actualYield.toStringAsFixed(1);
      return '$formatted $actualUnit';
    }

    // Benchmark estimates based on commodity and land size
    final commodity = project.commodity.toLowerCase();
    final size = project.landSize;

    if (commodity.contains('maize') || commodity.contains('corn')) {
      final bags = (size * 25).round();
      return '~$bags Bags (50kg)';
    } else if (commodity.contains('pepper')) {
      final bags = (size * 120).round();
      return '~$bags Bags';
    } else if (commodity.contains('tomato')) {
      final crates = (size * 250).round();
      return '~$crates Crates';
    } else if (commodity.contains('poultry') || commodity.contains('broiler')) {
      return '${size.round()} Birds';
    } else if (commodity.contains('tilapia') || commodity.contains('catfish')) {
      return '${size.round()} Fingerlings';
    } else if (commodity.contains('rice')) {
      final bags = (size * 30).round();
      return '~$bags Bags (50kg)';
    } else if (commodity.contains('cassava')) {
      final tonnes = (size * 8).toStringAsFixed(1);
      return '~$tonnes Tonnes';
    }

    return 'Pending estimate';
  }
}
