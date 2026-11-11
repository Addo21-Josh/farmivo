import 'package:farmivo/core/money/money.dart';

/// Aggregated directory-wide debt and sales totals across all commercial buyers.
class BuyersDirectorySummary {
  final int totalBuyers;
  final int activeDebtorsCount;
  final Money totalReceivables;
  final Money totalSalesVolume;
  final Money totalCashCollected;

  const BuyersDirectorySummary({
    required this.totalBuyers,
    required this.activeDebtorsCount,
    required this.totalReceivables,
    required this.totalSalesVolume,
    required this.totalCashCollected,
  });

  factory BuyersDirectorySummary.empty({String currency = 'GHS'}) {
    return BuyersDirectorySummary(
      totalBuyers: 0,
      activeDebtorsCount: 0,
      totalReceivables: Money.zero(currency: currency),
      totalSalesVolume: Money.zero(currency: currency),
      totalCashCollected: Money.zero(currency: currency),
    );
  }

  /// Percentage of total sales that has been collected as liquid cash.
  double get collectionRatePercentage {
    if (totalSalesVolume.minorUnits <= BigInt.zero) return 100.0;
    final collected = totalCashCollected.toMajor();
    final total = totalSalesVolume.toMajor();
    if (total <= 0) return 100.0;
    return ((collected / total) * 100.0).clamp(0.0, 100.0);
  }
}
