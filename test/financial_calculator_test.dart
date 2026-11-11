import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/constants/app_constants.dart';

void main() {
  group('Money Value Object Precision Tests', () {
    test('Stores pesewas accurately from major units', () {
      final m1 = Money.fromMajor(100.50);
      expect(m1.minorUnits, BigInt.from(10050));
      expect(m1.toMajor(), 100.50);
    });

    test('Zero floating-point inaccuracies on addition and subtraction', () {
      final m1 = Money.fromMajor(10.10);
      final m2 = Money.fromMajor(20.20);
      final sum = m1 + m2;
      expect(sum.minorUnits, BigInt.from(3030));
      expect(sum.toMajor(), 30.30);
    });

    test('Rejects cross-currency arithmetic without explicit conversion', () {
      final ghs = Money.fromMajor(100, currency: 'GHS');
      final usd = Money.fromMajor(100, currency: 'USD');
      expect(() => ghs + usd, throwsArgumentError);
    });
  });

  group('PRD Section 64 Example Calculation: 2 Acres Pepper', () {
    final budgetedCost = Money.fromMajor(7000); // GH₵ 7,000
    const expectedYieldKg = 3500.0; // 3,500 kg
    final expectedPricePerKg = Money.fromMajor(10); // GH₵ 10/kg

    test('Calculates projected revenue correctly', () {
      final projectedRevenue = expectedPricePerKg.multiply(expectedYieldKg);
      expect(projectedRevenue.toMajor(), 35000.0); // GH₵ 35,000
    });

    test('Calculates projected profit correctly', () {
      final projectedRevenue = expectedPricePerKg.multiply(expectedYieldKg);
      final projectedProfit = FinancialCalculator.calculateProjectedProfit(
        projectedRevenue,
        budgetedCost,
      );
      expect(projectedProfit.toMajor(), 28000.0); // GH₵ 28,000
    });

    test('Calculates projected ROI percentage correctly (400%)', () {
      final projectedRevenue = expectedPricePerKg.multiply(expectedYieldKg);
      final projectedProfit = FinancialCalculator.calculateProjectedProfit(
        projectedRevenue,
        budgetedCost,
      );
      final roi = FinancialCalculator.calculateProjectedRoi(
        projectedProfit,
        budgetedCost,
      );
      expect(roi, 400.0); // 400%
    });

    test('Calculates break-even output quantity correctly (700 kg)', () {
      final breakEvenKg = FinancialCalculator.calculateBreakEvenQuantity(
        budgetedCost,
        expectedPricePerKg,
      );
      expect(breakEvenKg, 700.0); // 700 kg
    });

    test('Calculates break-even unit selling price correctly (GH₵ 2.00)', () {
      final breakEvenPrice = FinancialCalculator.calculateBreakEvenPrice(
        budgetedCost,
        expectedYieldKg,
      );
      expect(breakEvenPrice.toMajor(), 2.00); // GH₵ 2.00/kg
    });
  });

  group('Variance and Health Engine Tests', () {
    test('Calculates budget overrun variance percentage accurately', () {
      final planned = Money.fromMajor(1000);
      final actual = Money.fromMajor(1250);
      final variance = FinancialCalculator.calculateVariance(planned, actual);
      final variancePct = FinancialCalculator.calculateVariancePercentage(
        planned,
        actual,
      );

      expect(variance.toMajor(), 250.0);
      expect(variancePct, 25.0);
    });

    test('Detects project at risk when budget is significantly breached', () {
      final evaluation = FinancialCalculator.evaluateProjectHealth(
        plannedBudget: Money.fromMajor(10000),
        actualSpent: Money.fromMajor(14000), // +40% overrun
        expectedRevenue: Money.fromMajor(25000),
        actualSales: Money.fromMajor(5000),
        collectedRevenue: Money.fromMajor(1000), // High credit outstanding
        scheduleProgressRatio: 0.5,
      );

      expect(evaluation.status, ProjectHealthStatus.atRisk);
      expect(evaluation.summary.contains('above budget'), isTrue);
    });
  });
}
