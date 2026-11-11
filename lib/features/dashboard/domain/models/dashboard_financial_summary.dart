import '../../../../core/money/money.dart';

/// Aggregated multi-project financial performance and cash-vs-accrual metrics
/// for the farm enterprise executive dashboard (Milestone 6.4).
class DashboardFinancialSummary {
  /// Total expenses incurred across all active farm projects.
  final Money totalInvested;

  /// Gross value of all recorded produce sales (accrual basis).
  final Money grossSalesValue;

  /// Total liquid cash collected into cash / MoMo / bank accounts.
  final Money collectedRevenue;

  /// Total unpaid credit owed by commercial buyers (accounts receivable).
  final Money accountsReceivable;

  /// Number of active projects.
  final int activeProjectsCount;

  /// Number of buyers who have an outstanding debtor balance.
  final int debtorsCount;

  /// Currency code (default 'GHS').
  final String currency;

  const DashboardFinancialSummary({
    required this.totalInvested,
    required this.grossSalesValue,
    required this.collectedRevenue,
    required this.accountsReceivable,
    this.activeProjectsCount = 0,
    this.debtorsCount = 0,
    this.currency = 'GHS',
  });

  /// Factory constructing a zeroed summary.
  factory DashboardFinancialSummary.zero({String currency = 'GHS'}) {
    return DashboardFinancialSummary(
      totalInvested: Money.zero(currency: currency),
      grossSalesValue: Money.zero(currency: currency),
      collectedRevenue: Money.zero(currency: currency),
      accountsReceivable: Money.zero(currency: currency),
      activeProjectsCount: 0,
      debtorsCount: 0,
      currency: currency,
    );
  }

  /// True liquid cash position: Cash Collected - Cash Disbursed/Spent (PRD Section 9.1).
  Money get cashProfit => collectedRevenue - totalInvested;

  /// Accrual net return: Total Gross Sales - Total Incurred Expenses (PRD Section 9.1).
  Money get accrualProfit => grossSalesValue - totalInvested;

  /// Cash-basis ROI percentage.
  double get cashRoiPercentage {
    if (totalInvested.minorUnits == BigInt.zero) return 0.0;
    return (cashProfit.toMajor() / totalInvested.toMajor()) * 100.0;
  }

  /// Accrual-basis ROI percentage.
  double get accrualRoiPercentage {
    if (totalInvested.minorUnits == BigInt.zero) return 0.0;
    return (accrualProfit.toMajor() / totalInvested.toMajor()) * 100.0;
  }

  /// Percentage of commercial sales converted into cash collected.
  double get collectionRatePercentage {
    if (grossSalesValue.minorUnits == BigInt.zero) return 0.0;
    return (collectedRevenue.toMajor() / grossSalesValue.toMajor()) * 100.0;
  }
}
