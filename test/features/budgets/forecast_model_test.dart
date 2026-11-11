import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/budgets/domain/models/forecast_model.dart';

void main() {
  group('ForecastCalculation Domain Unit Tests', () {
    test('Calculates Projected Gross Revenue: Yield * Unit Price', () {
      // 150 Bags @ GH₵ 180.00 (18000 pesewas) -> Projected Revenue = 2,700,000 pesewas (GH₵ 27,000.00)
      const calc = ForecastCalculation(
        expectedYield: 150.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 18000,
        totalBudgetedCostMinor: 1200000, // GH₵ 12,000.00
        currency: 'GHS',
      );

      expect(calc.projectedRevenueMinor, 2700000);
      expect(calc.projectedRevenue.format(), 'GH₵ 27,000.00');
      expect(calc.formulaDisplay, '150 Bags × GH₵ 180.00 = GH₵ 27,000.00');
    });

    test('Computes Projected Profit: Revenue - Budgeted Cost', () {
      // Revenue GH₵ 27,000.00 - Cost GH₵ 12,000.00 = Profit GH₵ 15,000.00
      const calc = ForecastCalculation(
        expectedYield: 150.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 18000,
        totalBudgetedCostMinor: 1200000,
        currency: 'GHS',
      );

      expect(calc.projectedProfitMinor, 1500000);
      expect(calc.projectedProfit.format(), 'GH₵ 15,000.00');
      expect(calc.isProfitable, isTrue);
      expect(calc.isLoss, isFalse);
      expect(calc.isBreakEven, isFalse);
    });

    test('Computes Pre-season Projected ROI %: (Profit / Cost) * 100', () {
      // Profit GH₵ 15,000.00 / Cost GH₵ 12,000.00 = 1.25 -> 125.0% ROI
      const calc = ForecastCalculation(
        expectedYield: 150.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 18000,
        totalBudgetedCostMinor: 1200000,
        currency: 'GHS',
      );

      expect(calc.projectedRoiPercent, 125.0);
    });

    test('Handles break-even scenario accurately', () {
      // Revenue GH₵ 10,000.00, Cost GH₵ 10,000.00 -> Profit = 0, ROI = 0.0%
      const calc = ForecastCalculation(
        expectedYield: 50.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 20000, // 50 * 200 = 10,000
        totalBudgetedCostMinor: 1000000,
        currency: 'GHS',
      );

      expect(calc.projectedRevenueMinor, 1000000);
      expect(calc.projectedProfitMinor, 0);
      expect(calc.projectedRoiPercent, 0.0);
      expect(calc.isBreakEven, isTrue);
      expect(calc.isProfitable, isFalse);
      expect(calc.isLoss, isFalse);
    });

    test('Handles loss / deficit scenario accurately', () {
      // Expected yield 40 bags @ GH₵ 200.00 = GH₵ 8,000.00 vs Cost GH₵ 10,000.00
      // Profit = -GH₵ 2,000.00 (-200,000 pesewas), ROI = -20.0%
      const calc = ForecastCalculation(
        expectedYield: 40.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 20000,
        totalBudgetedCostMinor: 1000000,
        currency: 'GHS',
      );

      expect(calc.projectedRevenueMinor, 800000);
      expect(calc.projectedProfitMinor, -200000);
      expect(calc.projectedProfit.format(), '-GH₵ 2,000.00');
      expect(calc.projectedRoiPercent, -20.0);
      expect(calc.isLoss, isTrue);
      expect(calc.isProfitable, isFalse);
    });

    test(
      'Safely handles zero total budgeted cost without divide-by-zero crash',
      () {
        const calc = ForecastCalculation(
          expectedYield: 100.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 15000,
          totalBudgetedCostMinor: 0,
          currency: 'GHS',
        );

        expect(calc.projectedRevenueMinor, 1500000);
        expect(calc.projectedProfitMinor, 1500000);
        expect(calc.projectedRoiPercent, 0.0);
      },
    );

    test('Accurately computes break-even yield and break-even unit price', () {
      // Cost GH₵ 12,000.00 (1,200,000 pesewas)
      // Unit Price GH₵ 150.00 (15,000 pesewas) -> Break-even yield = 1,200,000 / 15,000 = 80 Bags
      // Expected Yield 100 Bags -> Break-even price = 1,200,000 / 100 = 12,000 pesewas (GH₵ 120.00)
      const calc = ForecastCalculation(
        expectedYield: 100.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 15000,
        totalBudgetedCostMinor: 1200000,
        currency: 'GHS',
      );

      expect(calc.breakEvenYield, 80.0);
      expect(calc.breakEvenPrice.format(), 'GH₵ 120.00');
    });
  });
}
