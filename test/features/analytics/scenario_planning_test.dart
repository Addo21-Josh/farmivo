import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';

void main() {
  group('Milestone 7.3: Scenario Planning Modeler Tests', () {
    test('Computes full 3-scenario matrix with robust downside defense', () {
      // Inputs:
      // Baseline Expected Yield: 100 Bags
      // Expected Selling Price: GH₵ 200.00 / Bag
      // Total Budgeted Cost: GH₵ 10,000.00
      final expectedPrice = Money.fromMajor(200);
      final budgetedCost = Money.fromMajor(10000);

      final matrix = ScenarioPlanningMatrix.compute(
        baselineYield: 100.0,
        yieldUnit: 'Bags',
        baselineUnitPrice: expectedPrice,
        totalBudgetedCost: budgetedCost,
      );

      // --- 1. Expected Scenario ---
      // Revenue = 100 * 200 = GH₵ 20,000.00
      // Profit = 20,000 - 10,000 = +GH₵ 10,000.00
      // ROI = (10,000 / 10,000) * 100 = +100.0%
      expect(matrix.expected.expectedYield, 100.0);
      expect(matrix.expected.formattedYield, '100');
      expect(matrix.expected.expectedUnitPrice.toMajor(), 200.0);
      expect(matrix.expected.projectedRevenue.toMajor(), 20000.0);
      expect(matrix.expected.projectedProfit.toMajor(), 10000.0);
      expect(matrix.expected.projectedRoiPercent, 100.0);
      expect(matrix.expected.formattedRoi, '+100.0%');
      expect(matrix.expected.isProfitable, isTrue);

      // --- 2. Conservative Scenario (-20% Yield, -15% Price) ---
      // Yield = 100 * 0.80 = 80 Bags
      // Price = 200 * 0.85 = GH₵ 170.00
      // Revenue = 80 * 170 = GH₵ 13,600.00
      // Profit = 13,600 - 10,000 = +GH₵ 3,600.00
      // ROI = (3,600 / 10,000) * 100 = +36.0%
      expect(matrix.conservative.expectedYield, 80.0);
      expect(matrix.conservative.formattedYield, '80');
      expect(matrix.conservative.expectedUnitPrice.toMajor(), 170.0);
      expect(matrix.conservative.projectedRevenue.toMajor(), 13600.0);
      expect(matrix.conservative.projectedProfit.toMajor(), 3600.0);
      expect(matrix.conservative.projectedRoiPercent, 36.0);
      expect(matrix.conservative.formattedRoi, '+36.0%');
      expect(matrix.conservative.isProfitable, isTrue);

      // --- 3. Optimistic Scenario (+15% Yield, +10% Price) ---
      // Yield = 100 * 1.15 = 115 Bags
      // Price = 200 * 1.10 = GH₵ 220.00
      // Revenue = 115 * 220 = GH₵ 25,300.00
      // Profit = 25,300 - 10,000 = +GH₵ 15,300.00
      // ROI = (15,300 / 10,000) * 100 = +153.0%
      expect(matrix.optimistic.expectedYield, 115.0);
      expect(matrix.optimistic.formattedYield, '115');
      expect(matrix.optimistic.expectedUnitPrice.toMajor(), 220.0);
      expect(matrix.optimistic.projectedRevenue.toMajor(), 25300.0);
      expect(matrix.optimistic.projectedProfit.toMajor(), 15300.0);
      expect(matrix.optimistic.projectedRoiPercent, 153.0);
      expect(matrix.optimistic.formattedRoi, '+153.0%');
      expect(matrix.optimistic.isProfitable, isTrue);

      // --- Downside Exposure & Metrics ---
      // Conservative is profitable -> Downside Deficit = 0.0
      expect(matrix.downsideDeficit.minorUnits, BigInt.zero);
      expect(matrix.downsideCapitalExposurePercent, 0.0);
      expect(matrix.riskRating, DownsideExposureRisk.robust);
      expect(matrix.riskBadgeLabel, 'ROBUST DOWNSIDE DEFENSE');
      expect(matrix.profitSpread.toMajor(), 11700.0); // 15,300 - 3,600
      expect(matrix.advisoryMessage, contains('Resilient Capital Defense'));
    });

    test(
      'Identifies moderate capital risk when conservative deficit <= 25% of capital',
      () {
        // Expected: 100 Bags @ GH₵ 100 = GH₵ 10,000 Revenue
        // Budgeted Cost: GH₵ 8,000.00
        // Conservative:
        // Yield = 80 Bags, Price = GH₵ 85.00
        // Revenue = 80 * 85 = GH₵ 6,800.00
        // Cost = GH₵ 8,000.00
        // Deficit = 6,800 - 8,000 = -GH₵ 1,200.00
        // Capital exposure = (1,200 / 8,000) * 100 = 15.0% (<= 25%) -> Moderate
        final matrix = ScenarioPlanningMatrix.compute(
          baselineYield: 100.0,
          yieldUnit: 'Bags',
          baselineUnitPrice: Money.fromMajor(100),
          totalBudgetedCost: Money.fromMajor(8000),
        );

        expect(matrix.conservative.projectedProfit.toMajor(), -1200.0);
        expect(matrix.conservative.isLoss, isTrue);
        expect(matrix.downsideDeficit.toMajor(), 1200.0);
        expect(matrix.downsideCapitalExposurePercent, 15.0);
        expect(matrix.riskRating, DownsideExposureRisk.moderate);
        expect(matrix.riskBadgeLabel, 'MODERATE CAPITAL RISK');
        expect(
          matrix.advisoryMessage,
          contains('Manageable Downside Exposure'),
        );
        expect(matrix.advisoryMessage, contains('15.0% of capital'));
      },
    );

    test(
      'Identifies high downside vulnerability when conservative deficit > 25% of capital',
      () {
        // Expected: 100 Bags @ GH₵ 100 = GH₵ 10,000 Revenue
        // Budgeted Cost: GH₵ 9,500.00
        // Conservative:
        // Revenue = 80 * 85 = GH₵ 6,800.00
        // Deficit = 6,800 - 9,500 = -GH₵ 2,700.00
        // Exposure = (2,700 / 9,500) * 100 = 28.4% (> 25%) -> High
        final matrix = ScenarioPlanningMatrix.compute(
          baselineYield: 100.0,
          yieldUnit: 'Bags',
          baselineUnitPrice: Money.fromMajor(100),
          totalBudgetedCost: Money.fromMajor(9500),
        );

        expect(matrix.conservative.projectedProfit.toMajor(), -2700.0);
        expect(matrix.downsideDeficit.toMajor(), 2700.0);
        expect(matrix.downsideCapitalExposurePercent, closeTo(28.42, 0.01));
        expect(matrix.riskRating, DownsideExposureRisk.high);
        expect(matrix.riskBadgeLabel, 'HIGH DOWNSIDE EXPOSURE');
        expect(matrix.advisoryMessage, contains('High Downside Vulnerability'));
        expect(
          matrix.advisoryMessage,
          contains('substantial capital loss of GH₵ 2,700.00'),
        );
      },
    );

    test(
      'Edge Case: Zero yield or zero price handled cleanly without division by zero',
      () {
        final zeroMatrix = ScenarioPlanningMatrix.compute(
          baselineYield: 0.0,
          yieldUnit: 'kg',
          baselineUnitPrice: Money.zero(),
          totalBudgetedCost: Money.fromMajor(5000),
        );

        expect(zeroMatrix.expected.projectedRevenue.minorUnits, BigInt.zero);
        expect(
          zeroMatrix.conservative.projectedRevenue.minorUnits,
          BigInt.zero,
        );
        expect(zeroMatrix.optimistic.projectedRevenue.minorUnits, BigInt.zero);
        expect(zeroMatrix.expected.projectedProfit.toMajor(), -5000.0);
        expect(
          zeroMatrix.advisoryMessage,
          contains('Enter baseline yield and price assumptions'),
        );
      },
    );

    test('Edge Case: Zero budgeted cost handled cleanly', () {
      final matrix = ScenarioPlanningMatrix.compute(
        baselineYield: 50.0,
        yieldUnit: 'kg',
        baselineUnitPrice: Money.fromMajor(10),
        totalBudgetedCost: Money.zero(),
      );

      expect(matrix.expected.projectedRoiPercent, 0.0);
      expect(matrix.conservative.projectedRoiPercent, 0.0);
      expect(matrix.optimistic.projectedRoiPercent, 0.0);
      expect(matrix.advisoryMessage, contains('Finalize pre-season budget'));
    });

    test('Constructs accurately from a list of Drift Scenario records', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expectedScenario = Scenario(
        id: 'sc-exp',
        projectId: 'p1',
        scenarioType: 'EXPECTED',
        expectedYield: 100.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 20000,
        projectedRevenueMinor: 2000000,
        projectedCostMinor: 1000000,
        projectedProfitMinor: 1000000,
        projectedRoiPercent: 100.0,
        notes: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final matrix = ScenarioPlanningMatrix.fromScenarios(
        scenarios: [expectedScenario],
        liveBudgetedCost: Money.fromMajor(10000),
      );

      expect(matrix.expected.expectedYield, 100.0);
      expect(matrix.conservative.expectedYield, 80.0);
      expect(matrix.optimistic.expectedYield, 115.0);
      expect(matrix.riskRating, DownsideExposureRisk.robust);
    });

    test('FinancialCalculator delegates calculateScenarioMatrix properly', () {
      final matrix = FinancialCalculator.calculateScenarioMatrix(
        baselineYield: 200.0,
        yieldUnit: 'Crates',
        baselineUnitPrice: Money.fromMajor(50),
        totalBudgetedCost: Money.fromMajor(6000),
      );

      expect(matrix.expected.expectedYield, 200.0);
      expect(matrix.conservative.expectedYield, 160.0);
      expect(matrix.optimistic.expectedYield, 230.0);
      expect(matrix.expected.projectedProfit.toMajor(), 4000.0);
      expect(matrix.conservative.projectedProfit.toMajor(), 800.0);
      expect(matrix.riskRating, DownsideExposureRisk.robust);
    });
  });
}
