import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';

void main() {
  group('Milestone 7.2: Dynamic Break-Even Analysis Engine Tests', () {
    test(
      'Computes break-even in progress with positive remaining units and onTrack feasibility',
      () {
        // Setup:
        // Incurred Costs: GH₵ 6,000.00
        // Sales to date: GH₵ 4,000.00 (from 20 bags sold @ GH₵ 200/bag)
        // Cash Collected: GH₵ 3,000.00
        // Effective Unit Price: GH₵ 200.00 / bag
        // Remaining Harvest Yield: 15 bags
        final costs = Money.fromMajor(6000);
        final sales = Money.fromMajor(4000);
        final cashCollected = Money.fromMajor(3000);
        final unitPrice = Money.fromMajor(200);

        final be = DynamicBreakEven.compute(
          actualCosts: costs,
          actualSales: sales,
          cashCollected: cashCollected,
          effectiveUnitPrice: unitPrice,
          unit: 'Bags',
          remainingHarvestYield: 15.0,
        );

        // Deficits:
        // Accrual Deficit = 6,000 - 4,000 = GH₵ 2,000.00
        expect(be.accrualDeficit.toMajor(), 2000.0);
        expect(be.accrualDeficit.format(), 'GH₵ 2,000.00');
        expect(be.isAccrualBreakEvenAchieved, isFalse);

        // Cash Deficit = 6,000 - 3,000 = GH₵ 3,000.00
        expect(be.cashDeficit.toMajor(), 3000.0);
        expect(be.cashDeficit.format(), 'GH₵ 3,000.00');
        expect(be.isCashBreakEvenAchieved, isFalse);

        // Recovery Percentages:
        // Accrual Recovery = (4,000 / 6,000) * 100 = 66.666...%
        expect(be.accrualRecoveryPercentage, closeTo(66.67, 0.01));
        // Cash Recovery = (3,000 / 6,000) * 100 = 50.0%
        expect(be.cashRecoveryPercentage, 50.0);

        // Remaining Units:
        // Accrual Remaining Units = 2,000 / 200 = 10 Bags
        expect(be.remainingUnitsToBreakEven, 10.0);
        expect(be.formattedRemainingUnits, '10');

        // Cash Remaining Units = 3,000 / 200 = 15 Bags
        expect(be.remainingUnitsCashBreakEven, 15.0);

        // Feasibility:
        // Remaining harvest yield (15 bags) >= remaining units needed (10 bags) -> onTrack
        expect(be.feasibility, BreakEvenFeasibility.onTrack);
        expect(be.advisoryMessage, contains('On Track'));
        expect(be.advisoryMessage, contains('safety buffer of 5 Bags'));
      },
    );

    test('Computes break-even achieved when sales exceed incurred costs', () {
      // Incurred Costs: GH₵ 5,000.00
      // Sales: GH₵ 6,000.00
      // Cash Collected: GH₵ 6,000.00
      final costs = Money.fromMajor(5000);
      final sales = Money.fromMajor(6000);
      final cash = Money.fromMajor(6000);
      final price = Money.fromMajor(100);

      final be = DynamicBreakEven.compute(
        actualCosts: costs,
        actualSales: sales,
        cashCollected: cash,
        effectiveUnitPrice: price,
        unit: 'kg',
        remainingHarvestYield: 10.0,
      );

      expect(be.accrualDeficit.minorUnits, BigInt.zero);
      expect(be.cashDeficit.minorUnits, BigInt.zero);
      expect(be.isAccrualBreakEvenAchieved, isTrue);
      expect(be.isCashBreakEvenAchieved, isTrue);
      expect(be.accrualRecoveryPercentage, 120.0);
      expect(be.cashRecoveryPercentage, 120.0);
      expect(be.remainingUnitsToBreakEven, 0.0);
      expect(be.remainingUnitsCashBreakEven, 0.0);
      expect(be.feasibility, BreakEvenFeasibility.achieved);
      expect(be.advisoryMessage, contains('Capital Fully Recouped'));
    });

    test(
      'Differentiates Accrual Break-Even vs. Cash Break-Even with outstanding receivables',
      () {
        // Incurred Costs: GH₵ 5,000.00
        // Sales: GH₵ 5,000.00 (Accrual Break-Even Achieved)
        // Cash Collected: GH₵ 3,500.00 (Outstanding receivables: GH₵ 1,500.00)
        final costs = Money.fromMajor(5000);
        final sales = Money.fromMajor(5000);
        final cash = Money.fromMajor(3500);
        final price = Money.fromMajor(50);

        final be = DynamicBreakEven.compute(
          actualCosts: costs,
          actualSales: sales,
          cashCollected: cash,
          effectiveUnitPrice: price,
          unit: 'Crates',
        );

        expect(be.isAccrualBreakEvenAchieved, isTrue);
        expect(be.accrualDeficit.minorUnits, BigInt.zero);
        expect(be.remainingUnitsToBreakEven, 0.0);

        expect(be.isCashBreakEvenAchieved, isFalse);
        expect(be.cashDeficit.toMajor(), 1500.0);
        expect(be.remainingUnitsCashBreakEven, 30.0);
        expect(be.cashRecoveryPercentage, 70.0);

        expect(be.feasibility, BreakEvenFeasibility.achieved);
        expect(be.advisoryMessage, contains('Accrual Break-Even Achieved'));
        expect(
          be.advisoryMessage,
          contains('Collect GH₵ 1,500.00 in outstanding buyer receivables'),
        );
      },
    );

    test(
      'Detects shortfall risk when remaining yield is less than units needed',
      () {
        // Incurred Costs: GH₵ 10,000.00
        // Sales: GH₵ 2,000.00
        // Deficit: GH₵ 8,000.00
        // Price: GH₵ 100 / bag -> Need 80 bags
        // Remaining harvest yield: only 50 bags -> Shortfall of 30 bags
        final costs = Money.fromMajor(10000);
        final sales = Money.fromMajor(2000);
        final cash = Money.fromMajor(2000);
        final price = Money.fromMajor(100);

        final be = DynamicBreakEven.compute(
          actualCosts: costs,
          actualSales: sales,
          cashCollected: cash,
          effectiveUnitPrice: price,
          unit: 'Bags',
          remainingHarvestYield: 50.0,
        );

        expect(be.remainingUnitsToBreakEven, 80.0);
        expect(be.feasibility, BreakEvenFeasibility.shortfallRisk);
        expect(be.advisoryMessage, contains('Yield Shortfall Risk'));
        expect(
          be.advisoryMessage,
          contains(
            'Need 80 Bags to break even, but only 50.0 Bags remains expected',
          ),
        );
        expect(be.advisoryMessage, contains('Projected deficit of 30 Bags'));
      },
    );

    test('Edge Case: Zero costs recorded', () {
      final zero = Money.zero();
      final be = DynamicBreakEven.compute(
        actualCosts: zero,
        actualSales: zero,
        cashCollected: zero,
        effectiveUnitPrice: Money.fromMajor(100),
      );

      expect(be.accrualRecoveryPercentage, 0.0);
      expect(be.cashRecoveryPercentage, 0.0);
      expect(be.isAccrualBreakEvenAchieved, isFalse);
      expect(be.remainingUnitsToBreakEven, 0.0);
      expect(be.advisoryMessage, 'No operational expenditures recorded yet.');
    });

    test('Edge Case: Zero effective unit price prevents division by zero', () {
      final costs = Money.fromMajor(5000);
      final zero = Money.zero();

      final be = DynamicBreakEven.compute(
        actualCosts: costs,
        actualSales: zero,
        cashCollected: zero,
        effectiveUnitPrice: zero, // Division by zero protection
        remainingHarvestYield: 100.0,
      );

      expect(be.accrualDeficit.toMajor(), 5000.0);
      expect(be.remainingUnitsToBreakEven, 0.0);
      expect(be.remainingUnitsCashBreakEven, 0.0);
      expect(be.feasibility, BreakEvenFeasibility.onTrack);
    });

    test(
      'FinancialCalculator delegates calculateDynamicBreakEven correctly',
      () {
        final be = FinancialCalculator.calculateDynamicBreakEven(
          actualCosts: Money.fromMajor(4000),
          actualSales: Money.fromMajor(2000),
          cashCollected: Money.fromMajor(1500),
          effectiveUnitPrice: Money.fromMajor(50),
          unit: 'kg',
          remainingHarvestYield: 60.0,
        );

        expect(be.accrualDeficit.toMajor(), 2000.0);
        expect(be.remainingUnitsToBreakEven, 40.0);
        expect(be.feasibility, BreakEvenFeasibility.onTrack);
      },
    );
  });
}
