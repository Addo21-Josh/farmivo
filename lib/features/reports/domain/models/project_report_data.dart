import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../budgets/domain/models/budget_variance.dart';
import '../../../expenses/domain/models/expense_with_details.dart';
import '../../../harvests/domain/models/harvest_with_details.dart';
import '../../../projects/domain/models/project_metrics.dart';
import '../../../sales/domain/models/sale_with_details.dart';

/// Comprehensive aggregate data transfer object (DTO) feeding the Bank-Ready
/// PDF Report Generator and CSV ledger export engine (Milestone 8.2 & 8.3).
class ProjectReportData {
  final Project project;
  final Farm? farm;
  final ProjectMetrics metrics;
  final ProjectVarianceReport varianceReport;
  final List<HarvestWithDetails> harvests;
  final List<SaleWithDetails> sales;
  final List<ExpenseWithDetails> expenses;

  // Document metadata & configuration
  final DateTime generatedAt;
  final String reportTitle;
  final String? preparedBy;
  final String? verifiedBy;
  final String? notes;
  final bool includeSignatureBlocks;

  const ProjectReportData({
    required this.project,
    this.farm,
    required this.metrics,
    required this.varianceReport,
    required this.harvests,
    required this.sales,
    required this.expenses,
    required this.generatedAt,
    this.reportTitle = 'BANK-READY AGRICULTURAL FINANCIAL STATEMENT',
    this.preparedBy,
    this.verifiedBy,
    this.notes,
    this.includeSignatureBlocks = true,
  });

  /// Currency code of the reporting project (e.g. 'GHS').
  String get currency => project.currency;

  /// Human-readable farm title or fallback.
  String get farmDisplayName => farm?.name ?? 'Unassigned Farm';

  /// Farm location or region summary.
  String get farmLocationSummary => farm != null
      ? '${farm!.location}, ${farm!.region}'
      : 'Location Unrecorded';

  /// Project title.
  String get projectTitle => project.name;

  /// Commodity and variety specification.
  String get commoditySummary =>
      project.variety != null && project.variety!.isNotEmpty
      ? '${project.commodity} (${project.variety})'
      : project.commodity;

  /// Land size formatted with unit (e.g., '10.0 Acres').
  String get formattedLandSize =>
      '${project.landSize % 1 == 0 ? project.landSize.toInt() : project.landSize.toStringAsFixed(1)} ${project.landUnit}';

  /// Total count of valid harvest batches.
  int get harvestBatchesCount => harvests.length;

  /// Total harvested yield quantity formatted (e.g., '240 Bags').
  String get totalHarvestYieldFormatted {
    if (harvests.isEmpty) {
      return '0 ${metrics.actualYieldUnit.isNotEmpty ? metrics.actualYieldUnit : "Units"}';
    }
    final total = harvests.fold<double>(0.0, (acc, h) => acc + h.quantity);
    final clean = total % 1 == 0
        ? total.toInt().toString()
        : total.toStringAsFixed(1);
    final unit = harvests.first.unit;
    return '$clean $unit';
  }

  /// Total count of commercial sales transactions.
  int get salesCount => sales.length;

  /// Total gross sales revenue agreed across all sales contracts.
  Money get totalSalesValue => metrics.totalRevenue;

  /// Total liquid cash receipts collected into accounts.
  Money get collectedRevenue => metrics.collectedRevenue;

  /// Total open credit / accounts receivable owed by off-takers and market buyers.
  Money get accountsReceivable => metrics.accountsReceivable;

  /// Cash collection efficiency ratio (Collected / Agreed Sales) * 100.
  double get collectionRatePercentage {
    if (!totalSalesValue.isPositive) return 0.0;
    return (collectedRevenue.toMajor() / totalSalesValue.toMajor()) * 100.0;
  }

  /// Total non-voided operating expenses incurred.
  Money get totalExpenses => metrics.totalSpent;

  /// Pre-season budgeted allocation.
  Money get totalBudgetPlanned => metrics.totalBudgeted;

  /// Variance between actual spent and planned budget.
  Money get budgetVariance => totalExpenses - totalBudgetPlanned;

  /// Budget expenditure utilization percentage.
  double get budgetSpentPercentage => metrics.budgetSpentPercentage;

  /// Accrual net profit (Gross Sales - Total Spent).
  Money get netProfit => metrics.netProfit;

  /// Cash-basis profit (Cash Collected - Cash Spent).
  Money get cashProfit => metrics.cashProfit;

  /// Return on Investment percentage (Accrual ROI %).
  double get roiPercentage => metrics.roiPercentage;

  /// Cash-basis ROI %.
  double get cashRoiPercentage => metrics.cashRoiPercentage;

  /// Net Profit Margin percentage ((Net Profit / Gross Revenue) * 100).
  double get netProfitMargin => totalSalesValue.isPositive
      ? (netProfit.toMajor() / totalSalesValue.toMajor()) * 100.0
      : 0.0;

  /// Accrual net return per unit of land (e.g., GH₵ 1,250.00 / Acre).
  Money get profitPerLandUnit => project.landSize > 0
      ? Money(
          BigInt.from(
            (netProfit.minorUnits.toDouble() / project.landSize).round(),
          ),
          currency: project.currency,
        )
      : netProfit;

  /// Operating expense ratio (Expenses / Revenue).
  double get operatingExpenseRatio => totalSalesValue.isPositive
      ? totalExpenses.toMajor() / totalSalesValue.toMajor()
      : 0.0;

  /// Dynamic Break-Even remaining units required to cover costs.
  String get breakEvenYieldDisplay =>
      '${metrics.dynamicBreakEven.formattedRemainingUnits} ${metrics.dynamicBreakEven.unit}';

  /// Unit cost of production.
  String get unitCostOfProductionDisplay {
    final yieldTotal = metrics.actualYieldTotal;
    if (yieldTotal <= 0) return 'Pending Harvest';
    final costPerUnit = totalExpenses.toMajor() / yieldTotal;
    return '${project.currency} ${costPerUnit.toStringAsFixed(2)} / ${metrics.actualYieldUnit.isNotEmpty ? metrics.actualYieldUnit : "Unit"}';
  }

  /// Break-even capital recovery percentage.
  double get safetyMarginPercentage =>
      metrics.dynamicBreakEven.accrualRecoveryPercentage;

  /// Whether the project has achieved break-even.
  bool get isBreakEvenAchieved =>
      metrics.dynamicBreakEven.isAccrualBreakEvenAchieved;

  /// Algorithmic Project Health Score (0-100).
  int get healthScore => metrics.healthEvaluation.score;

  /// Standardized text health status (Healthy / Watch / At Risk).
  String get healthStatusLabel => metrics.healthStatus.label;

  /// Plain-text diagnostic explanation for credit committee.
  String get healthExplanation => metrics.healthMessage;

  ProjectReportData copyWith({
    Project? project,
    Farm? farm,
    ProjectMetrics? metrics,
    ProjectVarianceReport? varianceReport,
    List<HarvestWithDetails>? harvests,
    List<SaleWithDetails>? sales,
    List<ExpenseWithDetails>? expenses,
    DateTime? generatedAt,
    String? reportTitle,
    String? preparedBy,
    String? verifiedBy,
    String? notes,
    bool? includeSignatureBlocks,
  }) {
    return ProjectReportData(
      project: project ?? this.project,
      farm: farm ?? this.farm,
      metrics: metrics ?? this.metrics,
      varianceReport: varianceReport ?? this.varianceReport,
      harvests: harvests ?? this.harvests,
      sales: sales ?? this.sales,
      expenses: expenses ?? this.expenses,
      generatedAt: generatedAt ?? this.generatedAt,
      reportTitle: reportTitle ?? this.reportTitle,
      preparedBy: preparedBy ?? this.preparedBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      notes: notes ?? this.notes,
      includeSignatureBlocks:
          includeSignatureBlocks ?? this.includeSignatureBlocks,
    );
  }
}
