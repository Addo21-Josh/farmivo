import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/widgets/multi_dimensional_profitability_card.dart';

void main() {
  testWidgets(
    'MultiDimensionalProfitabilityCard displays all 3 dimensions and ROI badges',
    (tester) async {
      final budgeted = Money.fromMajor(8000);
      final expenses = Money.fromMajor(5000);
      final sales = Money.fromMajor(6000);
      final collected = Money.fromMajor(4000);
      final receivables = Money.fromMajor(2000);

      final profitability = ProjectProfitability.compute(
        actualRevenue: sales,
        actualExpenses: expenses,
        cashCollected: collected,
        cashDisbursed: expenses,
        totalBudgeted: budgeted,
        actualHarvestedYield: 30.0,
        expectedYield: 100.0,
        expectedUnitPrice: Money.fromMajor(200),
      );

      final metrics = ProjectMetrics(
        projectId: 'proj-1',
        daysActive: 30,
        stage: ProjectLifecycleState.harvesting,
        totalBudgeted: budgeted,
        totalSpent: expenses,
        totalRevenue: sales,
        collectedRevenue: collected,
        accountsReceivable: receivables,
        netProfit: profitability.actualNetProfit,
        cashProfit: profitability.cashProfit,
        roiPercentage: profitability.actualRoiPercentage,
        cashRoiPercentage: profitability.cashRoiPercentage,
        projectedYieldDisplay: '~100 Bags',
        actualYieldTotal: 30.0,
        actualYieldUnit: 'Bags',
        activitiesCount: 5,
        harvestBatchesCount: 1,
        salesCount: 1,
        unpaidReceivables: receivables,
        budgetSpentPercentage: 62.5,
        healthStatus: ProjectHealthStatus.healthy,
        healthMessage: 'Operational.',
        profitability: profitability,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiDimensionalProfitabilityCard(metrics: metrics),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Card Title
      expect(find.text('Multi-Dimensional Profitability'), findsOneWidget);
      expect(
        find.text('Actuals vs. Liquid Cash vs. Full-Cycle Projection'),
        findsOneWidget,
      );

      // Dimension 1: Actual Net Profit
      expect(find.text('Actual Net Profit (Accrual)'), findsOneWidget);
      expect(find.text('+GH₵ 1,000.00'), findsOneWidget);
      expect(find.text('Actual ROI: +20.0%'), findsOneWidget);

      // Dimension 2: Cash-Basis Profit
      expect(find.text('Cash-Basis Profit (Liquid Cash)'), findsOneWidget);
      expect(find.text('-GH₵ 1,000.00'), findsOneWidget);
      expect(find.text('Cash ROI: -20.0%'), findsOneWidget);

      // Dimension 3: Projected Final Profit
      expect(find.text('Projected Final Profit (Tri-Value)'), findsOneWidget);
      expect(find.text('+GH₵ 12,000.00'), findsOneWidget);
      expect(find.text('Projected ROI: +150.0%'), findsOneWidget);

      // Tri-Value Synthesis Banner
      expect(find.text('Tri-Value Projection Synthesis'), findsOneWidget);
      expect(find.text('Projected Revenue'), findsOneWidget);
      expect(find.text('GH₵ 20,000.00'), findsOneWidget);
      expect(find.text('Projected Costs'), findsOneWidget);
      expect(find.text('GH₵ 8,000.00'), findsOneWidget);
    },
  );
}
