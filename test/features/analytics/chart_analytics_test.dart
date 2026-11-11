import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/reports/domain/models/cash_flow_point.dart';
import 'package:farmivo/features/reports/domain/models/category_expense_share.dart';

void main() {
  group('CashFlowPoint.buildTimeline', () {
    test('returns empty list when no transactions are provided', () {
      final timeline = CashFlowPoint.buildTimeline(
        cashInTransactions: [],
        cashOutTransactions: [],
      );
      expect(timeline, isEmpty);
    });

    test(
      'correctly groups transactions by day and accumulates cash in and out',
      () {
        final day1 = DateTime(2025, 3, 1, 10, 30).millisecondsSinceEpoch;
        final day1Later = DateTime(2025, 3, 1, 15, 00).millisecondsSinceEpoch;
        final day2 = DateTime(2025, 3, 2, 9, 00).millisecondsSinceEpoch;
        final day3 = DateTime(2025, 3, 3, 14, 00).millisecondsSinceEpoch;

        final expenses = [
          (timestamp: day1, amount: Money.fromMajor(100.0)),
          (timestamp: day1Later, amount: Money.fromMajor(50.0)),
          (timestamp: day2, amount: Money.fromMajor(75.0)),
        ];

        final sales = [
          (timestamp: day2, amount: Money.fromMajor(100.0)),
          (timestamp: day3, amount: Money.fromMajor(200.0)),
        ];

        final timeline = CashFlowPoint.buildTimeline(
          cashInTransactions: sales,
          cashOutTransactions: expenses,
          currency: 'GHS',
        );

        expect(timeline.length, 3);

        // Day 1: Only expenses (100 + 50 = 150)
        final p1 = timeline[0];
        expect(p1.cashIn.toMajor(), 0.0);
        expect(p1.cashOut.toMajor(), 150.0);
        expect(p1.cumulativeCashIn.toMajor(), 0.0);
        expect(p1.cumulativeCashOut.toMajor(), 150.0);
        expect(p1.netPosition.toMajor(), -150.0);
        expect(p1.isBreakEvenAchieved, isFalse);

        // Day 2: Expense 75 (cum 225), Sale 100 (cum 100)
        final p2 = timeline[1];
        expect(p2.cashIn.toMajor(), 100.0);
        expect(p2.cashOut.toMajor(), 75.0);
        expect(p2.cumulativeCashIn.toMajor(), 100.0);
        expect(p2.cumulativeCashOut.toMajor(), 225.0);
        expect(p2.netPosition.toMajor(), -125.0);
        expect(p2.isBreakEvenAchieved, isFalse);

        // Day 3: Sale 200 (cum 300), no new expense (cum 225)
        // Cumulative Cash In (300) >= Cumulative Cash Out (225) -> Break even!
        final p3 = timeline[2];
        expect(p3.cashIn.toMajor(), 200.0);
        expect(p3.cashOut.toMajor(), 0.0);
        expect(p3.cumulativeCashIn.toMajor(), 300.0);
        expect(p3.cumulativeCashOut.toMajor(), 225.0);
        expect(p3.netPosition.toMajor(), 75.0);
        expect(p3.isBreakEvenAchieved, isTrue);
      },
    );

    test('break-even is false if expenses are 0 even if cash in exists', () {
      final day1 = DateTime(2025, 3, 1).millisecondsSinceEpoch;
      final timeline = CashFlowPoint.buildTimeline(
        cashInTransactions: [(timestamp: day1, amount: Money.fromMajor(100.0))],
        cashOutTransactions: [],
      );

      expect(timeline.length, 1);
      expect(timeline[0].isBreakEvenAchieved, isFalse);
    });
  });

  group('CategoryExpenseShare', () {
    test('computes percentage and properties correctly', () {
      final share = CategoryExpenseShare(
        categoryId: 'cat-1',
        categoryName: 'Seeds & Seedlings',
        totalSpent: Money.fromMajor(250.0),
        percentage: 25.0,
        color: CategoryExpenseShare.resolveColor(0),
      );

      expect(share.categoryId, 'cat-1');
      expect(share.categoryName, 'Seeds & Seedlings');
      expect(share.totalSpent.toMajor(), 250.0);
      expect(share.percentage, 25.0);
      expect(share.color, const Color(0xFF2E7D32));
    });

    test(
      'resolveColor cycles through palette colors when index exceeds palette length',
      () {
        final c0 = CategoryExpenseShare.resolveColor(0);
        final cPaletteLength = CategoryExpenseShare.resolveColor(
          CategoryExpenseShare.palette.length,
        );
        expect(c0, equals(cPaletteLength));
        expect(CategoryExpenseShare.resolveColor(1), const Color(0xFF1E88E5));
      },
    );
  });
}
