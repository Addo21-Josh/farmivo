import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/budgets/domain/models/break_even_analysis.dart';

void main() {
  group('BreakEvenAnalysis Domain Unit Tests', () {
    test(
      'Calculates Break-Even Quantity: Total Budgeted Cost / Expected Unit Price',
      () {
        // Total Budgeted Cost: GH₵ 12,000.00 (1,200,000 pesewas)
        // Expected Selling Price: GH₵ 150.00 / Bag (15,000 pesewas)
        // Break-Even Quantity = 1,200,000 / 15,000 = 80 Bags
        const analysis = BreakEvenAnalysis(
          expectedYield: 100.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 15000,
          totalBudgetedCostMinor: 1200000,
          currency: 'GHS',
        );

        expect(analysis.breakEvenQuantity, 80.0);
        expect(analysis.formattedBreakEvenQuantity, '80');
        expect(
          analysis.yieldMarginOfSafety,
          20.0,
        ); // 100 - 80 = 20 Bags safety buffer
        expect(analysis.yieldSafetyPercentage, 20.0); // (20 / 100) * 100 = 20%
      },
    );

    test(
      'Calculates Break-Even Price: Total Budgeted Cost / Expected Yield',
      () {
        // Total Budgeted Cost: GH₵ 12,000.00 (1,200,000 pesewas)
        // Expected Yield: 100 Bags
        // Break-Even Price = 1,200,000 / 100 = 12,000 pesewas (GH₵ 120.00 / Bag)
        const analysis = BreakEvenAnalysis(
          expectedYield: 100.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 15000, // GH₵ 150.00
          totalBudgetedCostMinor: 1200000,
          currency: 'GHS',
        );

        expect(analysis.breakEvenPrice.minorUnits, BigInt.from(12000));
        expect(analysis.breakEvenPrice.format(), 'GH₵ 120.00');
        expect(
          analysis.priceMarginOfSafety.format(),
          'GH₵ 30.00',
        ); // 150 - 120 = 30
        expect(analysis.priceSafetyPercentage, 20.0); // (30 / 150) * 100 = 20%
      },
    );

    test('Evaluates CapitalProtectionStatus.secure when cushion >= 20%', () {
      // Planned: 100 Bags @ GH₵ 150.00 (GH₵ 15,000.00 Revenue)
      // Cost: GH₵ 10,000.00
      // Break-even Quantity = 10,000 / 150 = 66.67 Bags -> 33.33% cushion
      // Break-even Price = 10,000 / 100 = GH₵ 100.00 -> 33.33% cushion
      const analysis = BreakEvenAnalysis(
        expectedYield: 100.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 15000,
        totalBudgetedCostMinor: 1000000,
        currency: 'GHS',
      );

      expect(analysis.protectionStatus, CapitalProtectionStatus.secure);
      expect(analysis.advisoryMessage, contains('Strong Capital Buffer'));
    });

    test(
      'Evaluates CapitalProtectionStatus.moderate when cushion is between 0% and 19.9%',
      () {
        // Planned: 100 Bags @ GH₵ 110.00 (GH₵ 11,000.00 Revenue)
        // Cost: GH₵ 10,000.00
        // Yield buffer = 9.1% -> Moderate
        const analysis = BreakEvenAnalysis(
          expectedYield: 100.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 11000,
          totalBudgetedCostMinor: 1000000,
          currency: 'GHS',
        );

        expect(analysis.protectionStatus, CapitalProtectionStatus.moderate);
        expect(analysis.advisoryMessage, contains('Moderate Capital Buffer'));
      },
    );

    test(
      'Evaluates CapitalProtectionStatus.vulnerable when deficit exists',
      () {
        // Planned: 70 Bags @ GH₵ 100.00 (GH₵ 7,000.00 Revenue)
        // Cost: GH₵ 10,000.00
        // Deficit = -GH₵ 3,000.00
        const analysis = BreakEvenAnalysis(
          expectedYield: 70.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 10000,
          totalBudgetedCostMinor: 1000000,
          currency: 'GHS',
        );

        expect(analysis.protectionStatus, CapitalProtectionStatus.vulnerable);
        expect(analysis.advisoryMessage, contains('Capital at Risk'));
        expect(analysis.yieldMarginOfSafety, isNegative);
      },
    );

    test('Gracefully handles edge cases without dividing by zero', () {
      const analysis = BreakEvenAnalysis(
        expectedYield: 0.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 0,
        totalBudgetedCostMinor: 0,
        currency: 'GHS',
      );

      expect(analysis.breakEvenQuantity, 0.0);
      expect(analysis.breakEvenPrice.isZero, isTrue);
      expect(analysis.protectionStatus, CapitalProtectionStatus.secure);
    });
  });
}
