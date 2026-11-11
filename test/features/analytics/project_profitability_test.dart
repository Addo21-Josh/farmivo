import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';

void main() {
  group('Milestone 7.1: Multi-Dimensional Profitability Engine Tests', () {
    test(
      'Calculates all 3 profitability dimensions accurately in positive scenario',
      () {
        // 1. Inputs:
        // Budget: GH₵ 8,000.00
        // Incurred expenses to date: GH₵ 5,000.00
        // Actual sales to date: GH₵ 6,000.00 (from 30 bags harvested)
        // Cash collected on sales: GH₵ 4,000.00 (GH₵ 2,000 still in receivables)
        // Expected total yield: 100 bags
        // Actual harvested yield: 30 bags (remaining: 70 bags)
        // Forecast price: GH₵ 200.00 / bag
        final budgeted = Money.fromMajor(8000);
        final expenses = Money.fromMajor(5000);
        final sales = Money.fromMajor(6000);
        final cashCollected = Money.fromMajor(4000);
        final expectedPrice = Money.fromMajor(200);

        final p = ProjectProfitability.compute(
          actualRevenue: sales,
          actualExpenses: expenses,
          cashCollected: cashCollected,
          cashDisbursed: expenses,
          totalBudgeted: budgeted,
          actualHarvestedYield: 30.0,
          expectedYield: 100.0,
          expectedUnitPrice: expectedPrice,
        );

        // --- Dimension 1: Actual Net Profit (Accrual basis) ---
        // Actual Profit = 6,000 - 5,000 = +GH₵ 1,000.00
        expect(p.actualNetProfit.toMajor(), 1000.0);
        expect(p.actualNetProfit.format(), 'GH₵ 1,000.00');
        // Actual ROI = (1,000 / 5,000) * 100 = 20.0%
        expect(p.actualRoiPercentage, 20.0);
        expect(p.isActualProfitable, isTrue);

        // --- Dimension 2: Cash-Basis Profit (Liquid Cash) ---
        // Cash Profit = 4,000 - 5,000 = -GH₵ 1,000.00 (Temporary liquidity deficit before debt collection)
        expect(p.cashProfit.toMajor(), -1000.0);
        expect(p.cashProfit.format(), '-GH₵ 1,000.00');
        // Cash ROI = (-1,000 / 5,000) * 100 = -20.0%
        expect(p.cashRoiPercentage, -20.0);
        expect(p.isCashProfitable, isFalse);

        // --- Dimension 3: Projected Final Profit (Tri-Value Dynamic Projection) ---
        // Remaining Budget Cost = 8,000 - 5,000 = GH₵ 3,000.00
        expect(p.remainingEstimatedCost.toMajor(), 3000.0);
        // Projected Total Cost = 5,000 (actual) + 3,000 (remaining budget) = GH₵ 8,000.00
        expect(p.projectedCost.toMajor(), 8000.0);

        // Remaining Harvest Yield = 100 - 30 = 70 bags
        // Remaining Anticipated Revenue = 70 bags * GH₵ 200 = GH₵ 14,000.00
        expect(p.remainingAnticipatedRevenue.toMajor(), 14000.0);
        // Projected Total Revenue = 6,000 (actual sales) + 14,000 (remaining) = GH₵ 20,000.00
        expect(p.projectedRevenue.toMajor(), 20000.0);

        // Projected Final Profit = 20,000 - 8,000 = +GH₵ 12,000.00
        expect(p.projectedProfit.toMajor(), 12000.0);
        expect(p.projectedProfit.format(), 'GH₵ 12,000.00');
        // Projected ROI = (12,000 / 8,000) * 100 = 150.0%
        expect(p.projectedRoiPercentage, 150.0);
        expect(p.isProjectedProfitable, isTrue);
      },
    );

    test('Edge Case: Zero revenue and early stage with only expenses', () {
      final budgeted = Money.fromMajor(10000);
      final expenses = Money.fromMajor(2500);
      final zeroRevenue = Money.zero();

      final p = ProjectProfitability.compute(
        actualRevenue: zeroRevenue,
        actualExpenses: expenses,
        cashCollected: zeroRevenue,
        cashDisbursed: expenses,
        totalBudgeted: budgeted,
        actualHarvestedYield: 0.0,
        expectedYield: 50.0,
        expectedUnitPrice: Money.fromMajor(400),
      );

      // Actual profit is negative equal to expenses
      expect(p.actualNetProfit.toMajor(), -2500.0);
      expect(p.actualRoiPercentage, -100.0);
      expect(p.isActualProfitable, isFalse);

      // Cash profit is negative equal to cash disbursed
      expect(p.cashProfit.toMajor(), -2500.0);
      expect(p.cashRoiPercentage, -100.0);

      // Projected: 50 bags * 400 = 20,000 expected revenue
      // Projected Cost = 2,500 + 7,500 = 10,000
      // Projected Profit = 20,000 - 10,000 = 10,000
      expect(p.projectedProfit.toMajor(), 10000.0);
      expect(p.projectedRoiPercentage, 100.0);
      expect(p.isProjectedProfitable, isTrue);
    });

    test(
      'Edge Case: Division by zero prevention when actual expenses are zero',
      () {
        final zero = Money.zero();
        final p = ProjectProfitability.compute(
          actualRevenue: zero,
          actualExpenses: zero,
          cashCollected: zero,
          cashDisbursed: zero,
          totalBudgeted: zero,
        );

        // ROI should gracefully return 0.0 without throwing or resulting in NaN / Infinity
        expect(p.actualRoiPercentage, 0.0);
        expect(p.cashRoiPercentage, 0.0);
        expect(p.projectedRoiPercentage, 0.0);
        expect(p.actualNetProfit.minorUnits, BigInt.zero);
        expect(p.projectedProfit.minorUnits, BigInt.zero);
      },
    );

    test(
      'Edge Case: Actual harvest exceeds projected yield (clamps remaining yield to 0)',
      () {
        final budgeted = Money.fromMajor(5000);
        final expenses = Money.fromMajor(5000);
        final sales = Money.fromMajor(12000);
        final collected = Money.fromMajor(12000);

        final p = ProjectProfitability.compute(
          actualRevenue: sales,
          actualExpenses: expenses,
          cashCollected: collected,
          cashDisbursed: expenses,
          totalBudgeted: budgeted,
          actualHarvestedYield: 120.0, // Exceeded expected 100.0
          expectedYield: 100.0,
          expectedUnitPrice: Money.fromMajor(100),
        );

        // Remaining anticipated revenue should clamp to 0 rather than becoming negative
        expect(p.remainingAnticipatedRevenue.minorUnits, BigInt.zero);
        expect(p.projectedRevenue.toMajor(), 12000.0);
        expect(p.projectedProfit.toMajor(), 7000.0);
        expect(p.projectedRoiPercentage, 140.0);
      },
    );

    test(
      'Edge Case: Actual expenses exceed budget (clamps remaining budget cost to 0)',
      () {
        final budgeted = Money.fromMajor(5000);
        final expenses = Money.fromMajor(6500); // Exceeded budget by 1,500
        final sales = Money.fromMajor(8000);
        final collected = Money.fromMajor(8000);

        final p = ProjectProfitability.compute(
          actualRevenue: sales,
          actualExpenses: expenses,
          cashCollected: collected,
          cashDisbursed: expenses,
          totalBudgeted: budgeted,
          actualHarvestedYield: 50.0,
          expectedYield: 50.0,
          expectedUnitPrice: Money.fromMajor(160),
        );

        // Remaining estimated cost should clamp to 0
        expect(p.remainingEstimatedCost.minorUnits, BigInt.zero);
        expect(p.projectedCost.toMajor(), 6500.0);
        expect(p.projectedProfit.toMajor(), 1500.0); // 8,000 - 6,500
        expect(p.projectedRoiPercentage, closeTo(23.07, 0.01));
      },
    );

    test('Integration with FinancialCalculator.calculateProfitability', () {
      final profitability = FinancialCalculator.calculateProfitability(
        actualRevenue: Money.fromMajor(10000),
        actualExpenses: Money.fromMajor(4000),
        cashCollected: Money.fromMajor(7000),
        cashDisbursed: Money.fromMajor(4000),
        totalBudgeted: Money.fromMajor(5000),
      );

      expect(profitability.actualNetProfit.toMajor(), 6000.0);
      expect(profitability.actualRoiPercentage, 150.0);
      expect(profitability.cashProfit.toMajor(), 3000.0);
      expect(profitability.cashRoiPercentage, 75.0);
    });
  });
}
