import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';

void main() {
  group('Milestone 10.1: Comprehensive Financial Math & Precision Tests', () {
    group('Minor-Unit Precision & Extreme Bounds', () {
      test(
        'Accurately converts major units to minor units without IEEE-754 drift',
        () {
          final m1 = Money.fromMajor(0.01);
          expect(m1.minorUnits, BigInt.from(1));

          final m2 = Money.fromMajor(100.99);
          expect(m2.minorUnits, BigInt.from(10099));

          final m3 = Money.fromMajor(0.00);
          expect(m3.minorUnits, BigInt.zero);
        },
      );

      test(
        'Accumulates 10,000 micro-transactions without a single cent of rounding drift',
        () {
          Money runningTotal = Money.zero();
          final unitPrice = Money.fromMajor(
            1.10,
          ); // 1.10 has infamous float representation issues

          for (int i = 0; i < 10000; i++) {
            runningTotal = runningTotal + unitPrice;
          }

          expect(runningTotal.minorUnits, BigInt.from(1100000));
          expect(runningTotal.toMajor(), 11000.0);
        },
      );

      test(
        'Handles multi-million and billion agricultural capitalizations safely',
        () {
          // 500 million GHS = 50,000,000,000 minor units
          final massiveCost = Money.fromMajor(500000000);
          expect(massiveCost.minorUnits, BigInt.from(50000000000));
          expect(massiveCost.toMajor(), 500000000.0);

          final revenue = Money.fromMajor(750000000);
          final profit = revenue - massiveCost;
          expect(profit.toMajor(), 250000000.0);
        },
      );

      test('Accurately handles negative amounts and deficit arithmetic', () {
        final revenue = Money.fromMajor(5000);
        final expense = Money.fromMajor(8500);
        final deficit = revenue - expense;

        expect(deficit.minorUnits, BigInt.from(-350000));
        expect(deficit.toMajor(), -3500.0);
        expect(deficit.isNegative, isTrue);
      });
    });

    group('Robust Monetary String Parsing & Error Tolerance', () {
      test('Parses Ghanaian Cedi strings with diverse symbols and spaces', () {
        expect(Money.parse('GH₵ 1,250.50').toMajor(), 1250.50);
        expect(Money.parse('GH¢1250.50').toMajor(), 1250.50);
        expect(Money.parse('GHS 500').toMajor(), 500.00);
        expect(Money.parse('  GH₵  7,500.25  ').toMajor(), 7500.25);
      });

      test('Parses negative accounting format with parentheses', () {
        final negativeMoney = Money.parse('(GH₵ 1,200.00)');
        expect(negativeMoney.isNegative, isTrue);
        expect(negativeMoney.toMajor(), -1200.00);

        final dashNegative = Money.parse('- 450.75');
        expect(dashNegative.isNegative, isTrue);
        expect(dashNegative.toMajor(), -450.75);
      });

      test('Parses international currencies with symbol stripping', () {
        expect(Money.parse(r'$ 1,500.00', currency: 'USD').toMajor(), 1500.0);
        expect(Money.parse('€ 3,200.50', currency: 'EUR').toMajor(), 3200.50);
        expect(Money.parse('₦ 250,000', currency: 'NGN').toMajor(), 250000.0);
        expect(
          Money.parse('KSh 15,000.00', currency: 'KES').toMajor(),
          15000.0,
        );
      });

      test('tryParse safely returns null on malformed or empty input', () {
        expect(Money.tryParse(null), isNull);
        expect(Money.tryParse(''), isNull);
        expect(Money.tryParse('   '), isNull);
        expect(Money.tryParse('INVALID_STRING'), isNull);
      });

      test('parse throws FormatException on invalid input', () {
        expect(() => Money.parse('abc'), throwsFormatException);
        expect(() => Money.parse(''), throwsFormatException);
      });
    });

    group('Financial Engine: Variance, ROI & Break-Even Calculus', () {
      test('Calculates budget variance and overrun percentages accurately', () {
        final budget = Money.fromMajor(10000);
        final actual = Money.fromMajor(12000);

        final variance = FinancialCalculator.calculateVariance(budget, actual);
        final pct = FinancialCalculator.calculateVariancePercentage(
          budget,
          actual,
        );

        expect(variance.toMajor(), 2000.0);
        expect(pct, 20.0); // +20% overrun
      });

      test('Calculates budget savings when under budget', () {
        final budget = Money.fromMajor(10000);
        final actual = Money.fromMajor(8000);

        final variance = FinancialCalculator.calculateVariance(budget, actual);
        final pct = FinancialCalculator.calculateVariancePercentage(
          budget,
          actual,
        );

        expect(variance.toMajor(), -2000.0);
        expect(pct, -20.0); // -20% savings
      });

      test(
        'Zero planned budget edge case does not crash variance calculus',
        () {
          final zeroBudget = Money.zero();
          final actual = Money.fromMajor(1500);

          final pct = FinancialCalculator.calculateVariancePercentage(
            zeroBudget,
            actual,
          );
          expect(pct, 100.0);
        },
      );

      test('Calculates projected ROI and handles operating loss', () {
        final cost = Money.fromMajor(10000);
        final profit = Money.fromMajor(5000);
        expect(
          FinancialCalculator.calculateProjectedRoi(profit, cost),
          50.0,
        ); // 50% ROI

        // Loss scenario
        final loss = Money.fromMajor(-2000);
        expect(
          FinancialCalculator.calculateProjectedRoi(loss, cost),
          -20.0,
        ); // -20% ROI

        // Zero cost scenario
        expect(
          FinancialCalculator.calculateProjectedRoi(profit, Money.zero()),
          0.0,
        );
      });

      test(
        'Break-even quantity with zero or near-zero price handled safely with ArgumentError',
        () {
          final cost = Money.fromMajor(5000);
          final zeroPrice = Money.zero();

          expect(
            () =>
                FinancialCalculator.calculateBreakEvenQuantity(cost, zeroPrice),
            throwsArgumentError,
          );
        },
      );

      test(
        'Break-even selling price with zero yield handled safely with ArgumentError',
        () {
          final cost = Money.fromMajor(5000);
          expect(
            () => FinancialCalculator.calculateBreakEvenPrice(cost, 0.0),
            throwsArgumentError,
          );
        },
      );
    });

    group('Project Health Scoring 5-Factor Weighted Engine', () {
      test(
        'Perfect project under 80% capital utilization yields score of 100 with Healthy status',
        () {
          final evaluation = ProjectHealthEvaluation.compute(
            plannedBudget: Money.fromMajor(10000),
            actualSpent: Money.fromMajor(
              7500,
            ), // 75% utilization (< 80% threshold)
            expectedRevenue: Money.fromMajor(30000),
            actualSales: Money.fromMajor(30000), // 100% target met
            cashCollected: Money.fromMajor(30000), // 100% cash collected
            completedActivities: 10,
            totalActivities: 10, // 100% on schedule
          );

          expect(evaluation.score, equals(100));
          expect(evaluation.status, ProjectHealthStatus.healthy);
          expect(evaluation.breakdown.budgetDisciplineScore, 100.0);
        },
      );

      test(
        'Capital utilization between 80% and 100% applies calibrated caution penalty',
        () {
          final evaluation = ProjectHealthEvaluation.compute(
            plannedBudget: Money.fromMajor(10000),
            actualSpent: Money.fromMajor(9500), // 95% utilization
            expectedRevenue: Money.fromMajor(30000),
            actualSales: Money.fromMajor(30000),
            cashCollected: Money.fromMajor(30000),
            completedActivities: 10,
            totalActivities: 10,
          );

          // 68.0 - ((0.95 - 0.80) * 100) = 53.0
          expect(
            evaluation.breakdown.budgetDisciplineScore,
            closeTo(53.0, 0.001),
          );
          // Composite: (0.30 * 53) + 70 = 15.9 + 70 = 85.9 -> 86 (Healthy)
          expect(evaluation.score, equals(86));
          expect(evaluation.status, ProjectHealthStatus.healthy);
        },
      );

      test(
        'Severe cost overrun and uncollected credit downgrades status to At Risk',
        () {
          final evaluation = ProjectHealthEvaluation.compute(
            plannedBudget: Money.fromMajor(10000),
            actualSpent: Money.fromMajor(16000), // +60% overrun
            expectedRevenue: Money.fromMajor(20000),
            actualSales: Money.fromMajor(5000), // 25% revenue
            cashCollected: Money.fromMajor(1000), // GHS 4,000 uncollected debt
            completedActivities: 2,
            totalActivities: 10, // 20% progress
          );

          expect(evaluation.score, lessThan(60));
          expect(evaluation.status, ProjectHealthStatus.atRisk);
          expect(
            evaluation.diagnosticReasons.any(
              (String r) => r.toLowerCase().contains('budget'),
            ),
            isTrue,
          );
        },
      );

      test(
        'Breakdown weighted composite math conforms exactly to PRD formula',
        () {
          // (0.30 * 80) + (0.25 * 70) + (0.20 * 90) + (0.15 * 60) + (0.10 * 50)
          // 24 + 17.5 + 18 + 9 + 5 = 73.5 -> round = 74
          const breakdown = ProjectHealthBreakdown(
            budgetDisciplineScore: 80.0,
            revenuePerformanceScore: 70.0,
            cashLiquidityScore: 90.0,
            scheduleDriftScore: 60.0,
            creditRiskScore: 50.0,
          );

          expect(breakdown.compositeScore, equals(74));
        },
      );
    });
  });
}
