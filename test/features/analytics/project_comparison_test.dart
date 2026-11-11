import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';

void main() {
  group('Milestone 7.5: Project Comparison Matrix Unit Tests', () {
    test(
      'Computes multi-project comparison matrix with rankings and diagnosis',
      () {
        final p1 = ProjectComparisonRecord.compute(
          projectId: 'p-1',
          projectName: 'Ejura Maize A',
          commodity: 'Maize',
          stage: ProjectLifecycleState.completed,
          status: 'COMPLETED',
          landSize: 4.0,
          landUnit: 'Acres',
          plannedBudget: Money.fromMajor(6000),
          actualSpent: Money.fromMajor(5000),
          actualSales: Money.fromMajor(10000),
          daysActive: 105,
          healthScore: 92,
          healthStatus: ProjectHealthStatus.healthy,
        );

        final p2 = ProjectComparisonRecord.compute(
          projectId: 'p-2',
          projectName: 'Akomadan Pepper',
          commodity: 'Pepper',
          stage: ProjectLifecycleState.harvesting,
          status: 'HARVESTING',
          landSize: 2.0,
          landUnit: 'Acres',
          plannedBudget: Money.fromMajor(8000),
          actualSpent: Money.fromMajor(7000),
          actualSales: Money.fromMajor(12000),
          daysActive: 80,
          healthScore: 85,
          healthStatus: ProjectHealthStatus.healthy,
        );

        final p3 = ProjectComparisonRecord.compute(
          projectId: 'p-3',
          projectName: 'Navrongo Tomato',
          commodity: 'Tomato',
          stage: ProjectLifecycleState.completed,
          status: 'COMPLETED',
          landSize: 1.5,
          landUnit: 'Acres',
          plannedBudget: Money.fromMajor(4000),
          actualSpent: Money.fromMajor(4500),
          actualSales: Money.fromMajor(3000), // Net loss: -1,500
          daysActive: 90,
          healthScore: 52,
          healthStatus: ProjectHealthStatus.atRisk,
        );

        final matrix = FinancialCalculator.compareProjects([p1, p2, p3]);

        // Total Capital Invested = 5,000 + 7,000 + 4,500 = 16,500
        expect(matrix.totalCapitalInvested.toMajor(), 16500.0);
        // Total Revenue = 10,000 + 12,000 + 3,000 = 25,000
        expect(matrix.totalRevenue.toMajor(), 25000.0);
        // Total Net Profit = 25,000 - 16,500 = 8,500
        expect(matrix.totalNetProfit.toMajor(), 8500.0);

        // ROI checks:
        // p1: (5,000 / 5,000) * 100 = 100.0%
        expect(p1.roiPercentage, 100.0);
        // p2: (5,000 / 7,000) * 100 = 71.4%
        expect(p2.roiPercentage, 71.4);
        // p3: (-1,500 / 4,500) * 100 = -33.3%
        expect(p3.roiPercentage, -33.3);

        // Best ROI Project: p1 (100.0%)
        expect(matrix.bestRoiProject?.projectId, 'p-1');

        // Most Profitable Project: p1 and p2 tied at 5,000 net profit
        expect(matrix.mostProfitableProject?.netProfit.toMajor(), 5000.0);

        // Highest Revenue: p2 (12,000)
        expect(matrix.highestRevenueProject?.projectId, 'p-2');

        // Capital Efficiency (Profit per Acre):
        // p1: 5,000 / 4.0 = GH₵ 1,250.00 / Acre
        // p2: 5,000 / 2.0 = GH₵ 2,500.00 / Acre
        expect(p1.profitPerLandUnit.toMajor(), 1250.0);
        expect(p2.profitPerLandUnit.toMajor(), 2500.0);
        expect(matrix.mostCapitalEfficientProject?.projectId, 'p-2');

        // Average ROI across the 3: (100.0 + 71.4 - 33.3) / 3 = 46.03% -> 46.0%
        expect(matrix.averageRoiPercentage, closeTo(46.0, 0.2));

        // Diagnostic Narrative
        expect(
          matrix.summaryDiagnosis,
          contains('Across the 3 compared ventures'),
        );
        expect(
          matrix.summaryDiagnosis,
          contains('Ejura Maize A generated the highest ROI (+100.0%)'),
        );
      },
    );

    test(
      'Safely handles single project comparison without crash or invalid division',
      () {
        final p1 = ProjectComparisonRecord.compute(
          projectId: 'p-single',
          projectName: 'Solo Cassava',
          commodity: 'Cassava',
          stage: ProjectLifecycleState.production,
          status: 'PRODUCTION',
          landSize: 5.0,
          landUnit: 'Hectares',
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(8000),
          actualSales: Money.fromMajor(14000),
          daysActive: 120,
        );

        final matrix = ProjectComparisonMatrix.compute([p1]);

        expect(matrix.records.length, 1);
        expect(matrix.totalCapitalInvested.toMajor(), 8000.0);
        expect(matrix.totalRevenue.toMajor(), 14000.0);
        expect(matrix.totalNetProfit.toMajor(), 6000.0);
        expect(matrix.bestRoiProject?.projectId, 'p-single');
        expect(matrix.summaryDiagnosis, contains('Solo Cassava'));
      },
    );

    test('Safely handles empty project list', () {
      final matrix = ProjectComparisonMatrix.compute([]);

      expect(matrix.records, isEmpty);
      expect(matrix.totalCapitalInvested.isZero, isTrue);
      expect(matrix.totalRevenue.isZero, isTrue);
      expect(matrix.totalNetProfit.isZero, isTrue);
      expect(matrix.averageRoiPercentage, 0.0);
      expect(matrix.bestRoiProject, isNull);
      expect(matrix.summaryDiagnosis, 'No projects selected for comparison.');
    });

    test(
      'Edge case: zero land size and zero capital invested avoids NaN / division by zero',
      () {
        final zeroProject = ProjectComparisonRecord.compute(
          projectId: 'p-zero',
          projectName: 'Micro Greenhouse Experiment',
          commodity: 'Tomato',
          stage: ProjectLifecycleState.planning,
          status: 'PLANNING',
          landSize: 0.0,
          landUnit: 'Plot',
          plannedBudget: Money.zero(),
          actualSpent: Money.zero(),
          actualSales: Money.zero(),
          daysActive: 0,
        );

        expect(zeroProject.profitPerLandUnit.isZero, isTrue);
        expect(zeroProject.capitalPerLandUnit.isZero, isTrue);
        expect(zeroProject.roiPercentage, 0.0);

        final matrix = ProjectComparisonMatrix.compute([zeroProject]);
        expect(matrix.totalCapitalInvested.isZero, isTrue);
        expect(matrix.averageRoiPercentage, 0.0);
      },
    );

    test('Correctly identifies land efficiency and unit formatting', () {
      final record = ProjectComparisonRecord.compute(
        projectId: 'p-ac',
        projectName: 'Yam Farm',
        commodity: 'Yam',
        stage: ProjectLifecycleState.harvesting,
        status: 'HARVESTING',
        landSize: 2.5,
        landUnit: 'Acres',
        plannedBudget: Money.fromMajor(5000),
        actualSpent: Money.fromMajor(5000),
        actualSales: Money.fromMajor(10000),
        daysActive: 200,
        healthScore: 88,
        healthStatus: ProjectHealthStatus.healthy,
      );

      expect(record.formattedLand, '2.5 Acres');
      expect(record.healthBadge, 'HEALTHY (88/100)');
      // Profit: 5,000 / 2.5 = 2,000
      expect(record.profitPerLandUnit.toMajor(), 2000.0);
      // Capital: 5,000 / 2.5 = 2,000
      expect(record.capitalPerLandUnit.toMajor(), 2000.0);
    });
  });
}
