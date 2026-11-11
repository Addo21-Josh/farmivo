import '../../../../core/money/money.dart';

/// Aggregated commercial performance metrics for a farm project or global ledger.
class SalesSummary {
  final int totalSalesCount;
  final Money totalGrossSales;
  final Money totalCashCollected;
  final Money totalAccountsReceivable;
  final int paidSalesCount;
  final int partialSalesCount;
  final int unpaidSalesCount;
  final int voidedSalesCount;
  final String currency;

  const SalesSummary({
    this.totalSalesCount = 0,
    required this.totalGrossSales,
    required this.totalCashCollected,
    required this.totalAccountsReceivable,
    this.paidSalesCount = 0,
    this.partialSalesCount = 0,
    this.unpaidSalesCount = 0,
    this.voidedSalesCount = 0,
    this.currency = 'GHS',
  });

  /// Factory constructing zeroed default summary.
  factory SalesSummary.zero({String currency = 'GHS'}) {
    return SalesSummary(
      totalSalesCount: 0,
      totalGrossSales: Money.zero(currency: currency),
      totalCashCollected: Money.zero(currency: currency),
      totalAccountsReceivable: Money.zero(currency: currency),
      paidSalesCount: 0,
      partialSalesCount: 0,
      unpaidSalesCount: 0,
      voidedSalesCount: 0,
      currency: currency,
    );
  }

  /// Percentage of gross sales converted into liquid collected cash.
  double get collectionRatePercentage {
    if (totalGrossSales.minorUnits == BigInt.zero) return 0.0;
    return (totalCashCollected.minorUnits.toDouble() /
            totalGrossSales.minorUnits.toDouble()) *
        100.0;
  }
}
