import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/widgets/project_health_score_card.dart';

void main() {
  group('ProjectHealthScoreCard Widget Tests (Milestone 7.4)', () {
    testWidgets(
      'Renders Healthy state with all 5 criteria bars and explanation',
      (tester) async {
        final healthyEval = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.harvesting,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(7000),
          expectedRevenue: Money.fromMajor(10000),
          actualSales: Money.fromMajor(12000),
          cashCollected: Money.fromMajor(12000),
          totalActivities: 10,
          overdueActivities: 0,
        );

        final healthyMetrics = ProjectMetrics(
          projectId: 'p-1',
          daysActive: 60,
          stage: ProjectLifecycleState.harvesting,
          totalBudgeted: Money.fromMajor(10000),
          totalSpent: Money.fromMajor(7000),
          totalRevenue: Money.fromMajor(12000),
          collectedRevenue: Money.fromMajor(12000),
          accountsReceivable: Money.zero(),
          netProfit: Money.fromMajor(5000),
          cashProfit: Money.fromMajor(5000),
          roiPercentage: 71.4,
          cashRoiPercentage: 71.4,
          projectedYieldDisplay: '~200 Bags',
          actualYieldTotal: 220.0,
          actualYieldUnit: 'Bags',
          activitiesCount: 10,
          harvestBatchesCount: 4,
          salesCount: 5,
          unpaidReceivables: Money.zero(),
          budgetSpentPercentage: 70.0,
          healthStatus: healthyEval.status,
          healthMessage: healthyEval.summary,
          healthEvaluation: healthyEval,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProjectHealthScoreCard(metrics: healthyMetrics),
              ),
            ),
          ),
        );
        await tester.pump();

        // Card Header
        expect(find.text('Algorithmic Health Score'), findsOneWidget);
        expect(
          find.text('5-factor composite viability rating (0–100)'),
          findsOneWidget,
        );
        expect(find.textContaining('HEALTHY'), findsWidgets);

        // Score Display
        expect(find.text('100'), findsOneWidget);
        expect(find.text(' / 100'), findsOneWidget);

        // 5 Criteria
        expect(find.text('Budget Discipline'), findsOneWidget);
        expect(find.text('(30% Weight)'), findsOneWidget);

        expect(find.text('Revenue Performance'), findsOneWidget);
        expect(find.text('(25% Weight)'), findsOneWidget);

        expect(find.text('Cash Liquidity'), findsOneWidget);
        expect(find.text('(20% Weight)'), findsOneWidget);

        expect(find.text('Operational Schedule Drift'), findsOneWidget);
        expect(find.text('(15% Weight)'), findsOneWidget);

        expect(find.text('Credit Risk (Receivables)'), findsOneWidget);
        expect(find.text('(10% Weight)'), findsOneWidget);

        // Explanation Engine
        expect(find.text('Algorithmic Diagnostics'), findsOneWidget);
        expect(
          find.textContaining(
            'fully profitable with strong budget and revenue discipline',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Renders At Risk state with explicit budget overrun explanation',
      (tester) async {
        final atRiskEval = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.harvesting,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(13500), // 35% overrun
          expectedRevenue: Money.fromMajor(15000),
          actualSales: Money.fromMajor(8000),
          cashCollected: Money.fromMajor(4000), // 50% receivables
          totalActivities: 8,
          overdueActivities: 3, // 3 overdue activities
        );

        final atRiskMetrics = ProjectMetrics(
          projectId: 'p-2',
          daysActive: 80,
          stage: ProjectLifecycleState.harvesting,
          totalBudgeted: Money.fromMajor(10000),
          totalSpent: Money.fromMajor(13500),
          totalRevenue: Money.fromMajor(8000),
          collectedRevenue: Money.fromMajor(4000),
          accountsReceivable: Money.fromMajor(4000),
          netProfit: Money.fromMajor(-5500),
          cashProfit: Money.fromMajor(-9500),
          roiPercentage: -40.7,
          cashRoiPercentage: -70.4,
          projectedYieldDisplay: '~200 Bags',
          actualYieldTotal: 90.0,
          actualYieldUnit: 'Bags',
          activitiesCount: 8,
          harvestBatchesCount: 2,
          salesCount: 2,
          unpaidReceivables: Money.fromMajor(4000),
          budgetSpentPercentage: 135.0,
          healthStatus: atRiskEval.status,
          healthMessage: atRiskEval.summary,
          healthEvaluation: atRiskEval,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProjectHealthScoreCard(metrics: atRiskMetrics),
              ),
            ),
          ),
        );
        await tester.pump();

        // Badge displays AT RISK
        expect(find.textContaining('AT RISK'), findsWidgets);

        // Score is < 60
        expect(find.text('${atRiskEval.score}'), findsOneWidget);

        // Explanations contain explicit reasons
        expect(find.text('Algorithmic Diagnostics'), findsOneWidget);
        expect(find.textContaining('Budget overrun by 35.0%'), findsOneWidget);
        expect(
          find.textContaining('50.0% of sales remain uncollected'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Renders Watch state with cautionary progress bars', (
      tester,
    ) async {
      final watchEval = ProjectHealthEvaluation.compute(
        stage: ProjectLifecycleState.harvesting,
        plannedBudget: Money.fromMajor(10000),
        actualSpent: Money.fromMajor(9200),
        expectedRevenue: Money.fromMajor(8000),
        actualSales: Money.fromMajor(5000),
        cashCollected: Money.fromMajor(3750),
        totalActivities: 6,
        overdueActivities: 1,
      );

      final watchMetrics = ProjectMetrics(
        projectId: 'p-3',
        daysActive: 50,
        stage: ProjectLifecycleState.harvesting,
        totalBudgeted: Money.fromMajor(10000),
        totalSpent: Money.fromMajor(9200),
        totalRevenue: Money.fromMajor(5000),
        collectedRevenue: Money.fromMajor(3750),
        accountsReceivable: Money.fromMajor(1250),
        netProfit: Money.fromMajor(-4200),
        cashProfit: Money.fromMajor(-5450),
        roiPercentage: -45.6,
        cashRoiPercentage: -59.2,
        projectedYieldDisplay: '~150 Bags',
        actualYieldTotal: 70.0,
        actualYieldUnit: 'Bags',
        activitiesCount: 6,
        harvestBatchesCount: 2,
        salesCount: 3,
        unpaidReceivables: Money.fromMajor(1250),
        budgetSpentPercentage: 92.0,
        healthStatus: watchEval.status,
        healthMessage: watchEval.summary,
        healthEvaluation: watchEval,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProjectHealthScoreCard(metrics: watchMetrics),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('WATCH'), findsWidgets);
      expect(find.text('${watchEval.score}'), findsOneWidget);
      expect(find.text('Algorithmic Diagnostics'), findsOneWidget);
    });
  });
}
