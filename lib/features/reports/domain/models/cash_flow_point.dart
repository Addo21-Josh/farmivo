import '../../../../core/money/money.dart';

/// Chronological time-series point capturing cumulative cash-in vs. cash-out (Milestone 8.1).
class CashFlowPoint {
  final int timestamp;
  final DateTime date;
  final Money cashIn;
  final Money cashOut;
  final Money cumulativeCashIn;
  final Money cumulativeCashOut;
  final Money netPosition;
  final bool isBreakEvenAchieved;

  const CashFlowPoint({
    required this.timestamp,
    required this.date,
    required this.cashIn,
    required this.cashOut,
    required this.cumulativeCashIn,
    required this.cumulativeCashOut,
    required this.netPosition,
    required this.isBreakEvenAchieved,
  });

  /// Factory computing a sorted list of cumulative cash flow points from transactions.
  static List<CashFlowPoint> buildTimeline({
    required List<({int timestamp, Money amount})> cashInTransactions,
    required List<({int timestamp, Money amount})> cashOutTransactions,
    String currency = 'GHS',
  }) {
    // 1. Group transactions by day (midnight timestamp)
    final dailyIn = <int, BigInt>{};
    for (final t in cashInTransactions) {
      final dayMs = _toMidnight(t.timestamp);
      dailyIn[dayMs] = (dailyIn[dayMs] ?? BigInt.zero) + t.amount.minorUnits;
    }

    final dailyOut = <int, BigInt>{};
    for (final t in cashOutTransactions) {
      final dayMs = _toMidnight(t.timestamp);
      dailyOut[dayMs] = (dailyOut[dayMs] ?? BigInt.zero) + t.amount.minorUnits;
    }

    final allDays = {...dailyIn.keys, ...dailyOut.keys}.toList()..sort();

    if (allDays.isEmpty) {
      return const [];
    }

    BigInt runningInMinor = BigInt.zero;
    BigInt runningOutMinor = BigInt.zero;

    final points = <CashFlowPoint>[];

    for (final dayMs in allDays) {
      final inMinor = dailyIn[dayMs] ?? BigInt.zero;
      final outMinor = dailyOut[dayMs] ?? BigInt.zero;

      runningInMinor += inMinor;
      runningOutMinor += outMinor;

      final cumIn = Money(runningInMinor, currency: currency);
      final cumOut = Money(runningOutMinor, currency: currency);
      final net = Money(runningInMinor - runningOutMinor, currency: currency);

      points.add(
        CashFlowPoint(
          timestamp: dayMs,
          date: DateTime.fromMillisecondsSinceEpoch(dayMs),
          cashIn: Money(inMinor, currency: currency),
          cashOut: Money(outMinor, currency: currency),
          cumulativeCashIn: cumIn,
          cumulativeCashOut: cumOut,
          netPosition: net,
          isBreakEvenAchieved:
              runningInMinor >= runningOutMinor &&
              runningOutMinor > BigInt.zero,
        ),
      );
    }

    return points;
  }

  static int _toMidnight(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }
}
