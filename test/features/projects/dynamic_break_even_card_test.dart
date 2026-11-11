import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/widgets/dynamic_break_even_card.dart';

void main() {
  group('DynamicBreakEvenCard Widget Tests', () {
    testWidgets('Renders in-progress break-even with ON TRACK status', (
      tester,
    ) async {
      final breakEven = DynamicBreakEven(
        actualCosts: Money.fromMajor(8000),
        actualSales: Money.fromMajor(4000),
        cashCollected: Money.fromMajor(3000),
        effectiveUnitPrice: Money.fromMajor(200),
        unit: 'Bags',
        remainingHarvestYield: 30.0,
      );

      final metrics = ProjectMetrics(
        projectId: 'p1',
        daysActive: 30,
        stage: ProjectLifecycleState.harvesting,
        totalBudgeted: Money.fromMajor(10000),
        totalSpent: Money.fromMajor(8000),
        totalRevenue: Money.fromMajor(4000),
        netProfit: Money.fromMajor(-4000),
        roiPercentage: -50.0,
        projectedYieldDisplay: '100 Bags',
        actualYieldTotal: 20.0,
        actualYieldUnit: 'Bags',
        activitiesCount: 5,
        harvestBatchesCount: 1,
        salesCount: 1,
        unpaidReceivables: Money.fromMajor(1000),
        budgetSpentPercentage: 80.0,
        healthStatus: ProjectHealthStatus.healthy,
        healthMessage: 'Operational',
        dynamicBreakEven: breakEven,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: DynamicBreakEvenCard(metrics: metrics),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Header & Badges
      expect(find.text('Dynamic Break-Even Analysis'), findsOneWidget);
      expect(find.text('ON TRACK'), findsOneWidget);

      // Progress indicators
      expect(find.text('Cost Recouped: 50.0%'), findsOneWidget);
      expect(find.text('38% Liquid Cash'), findsOneWidget);

      // Metric Tiles
      expect(find.text('Unrecovered Deficit'), findsOneWidget);
      expect(find.text('GH₵ 4,000.00'), findsOneWidget);
      expect(find.text('Pending Gross Sales'), findsOneWidget);

      expect(find.text('Units to Break-Even'), findsOneWidget);
      expect(find.text('20 Bags'), findsOneWidget);
      expect(find.text('@ GH₵ 200.00 / Bags'), findsOneWidget);

      // Liquid Cash Breakdown
      expect(find.text('Liquid Cash Deficit'), findsOneWidget);
      expect(find.text('GH₵ 5,000.00'), findsOneWidget);
      expect(find.text('Cash Volume Target'), findsOneWidget);
      expect(find.text('25 Bags'), findsOneWidget);

      // Advisory
      expect(find.textContaining('On Track: Need 20 Bags'), findsOneWidget);
      expect(find.textContaining('safety buffer of 10 Bags'), findsOneWidget);
    });

    testWidgets('Renders BREAK-EVEN ACHIEVED status when sales exceed costs', (
      tester,
    ) async {
      final breakEven = DynamicBreakEven(
        actualCosts: Money.fromMajor(5000),
        actualSales: Money.fromMajor(6500),
        cashCollected: Money.fromMajor(5500),
        effectiveUnitPrice: Money.fromMajor(100),
        unit: 'kg',
        remainingHarvestYield: 20.0,
      );

      final metrics = ProjectMetrics(
        projectId: 'p2',
        daysActive: 60,
        stage: ProjectLifecycleState.selling,
        totalBudgeted: Money.fromMajor(5000),
        totalSpent: Money.fromMajor(5000),
        totalRevenue: Money.fromMajor(6500),
        netProfit: Money.fromMajor(1500),
        roiPercentage: 30.0,
        projectedYieldDisplay: '100 kg',
        actualYieldTotal: 65.0,
        actualYieldUnit: 'kg',
        activitiesCount: 6,
        harvestBatchesCount: 2,
        salesCount: 3,
        unpaidReceivables: Money.fromMajor(1000),
        budgetSpentPercentage: 100.0,
        healthStatus: ProjectHealthStatus.healthy,
        healthMessage: 'Operational',
        dynamicBreakEven: breakEven,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: DynamicBreakEvenCard(metrics: metrics),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CASH BREAK-EVEN'), findsOneWidget);
      expect(
        find.text('0 kg'),
        findsNWidgets(2),
      ); // Accrual units & cash volume target both 0
      expect(find.text('100% Incurred Costs Covered'), findsOneWidget);
      expect(find.textContaining('Capital Fully Recouped'), findsOneWidget);
    });

    testWidgets(
      'Renders SHORTFALL RISK badge and advisory warning when harvest is insufficient',
      (tester) async {
        final breakEven = DynamicBreakEven(
          actualCosts: Money.fromMajor(10000),
          actualSales: Money.fromMajor(2000),
          cashCollected: Money.fromMajor(2000),
          effectiveUnitPrice: Money.fromMajor(100),
          unit: 'Bags',
          remainingHarvestYield: 30.0, // Needs 80 bags, but only 30 remain
        );

        final metrics = ProjectMetrics(
          projectId: 'p3',
          daysActive: 40,
          stage: ProjectLifecycleState.harvesting,
          totalBudgeted: Money.fromMajor(10000),
          totalSpent: Money.fromMajor(10000),
          totalRevenue: Money.fromMajor(2000),
          netProfit: Money.fromMajor(-8000),
          roiPercentage: -80.0,
          projectedYieldDisplay: '50 Bags',
          actualYieldTotal: 20.0,
          actualYieldUnit: 'Bags',
          activitiesCount: 4,
          harvestBatchesCount: 1,
          salesCount: 1,
          unpaidReceivables: Money.zero(),
          budgetSpentPercentage: 100.0,
          healthStatus: ProjectHealthStatus.atRisk,
          healthMessage: 'Operational',
          dynamicBreakEven: breakEven,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: DynamicBreakEvenCard(metrics: metrics),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('SHORTFALL RISK'), findsOneWidget);
        expect(find.text('80 Bags'), findsWidgets);
        expect(find.textContaining('Yield Shortfall Risk'), findsOneWidget);
        expect(
          find.textContaining('Projected deficit of 50 Bags'),
          findsOneWidget,
        );
      },
    );
  });
}
