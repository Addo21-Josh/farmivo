import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/presentation/providers/forecast_providers.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/tabs/project_financials_tab.dart';

void main() {
  testWidgets(
    'ProjectFinancialsTab strictly displays Gross Sales, Collected Cash, and Receivables',
    (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch;

      final testProject = Project(
        id: 'proj-1',
        farmId: 'farm-1',
        name: 'Ashanti Maize Farm',
        projectType: 'Crop',
        commodity: 'Maize',
        variety: null,
        landSize: 4.0,
        landUnit: 'Acres',
        startDate: now,
        expectedCompletionDate: null,
        expectedFirstHarvestDate: null,
        currency: 'GHS',
        status: 'SELLING',
        description: null,
        notes: null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final testMetrics = ProjectMetrics(
        projectId: 'proj-1',
        daysActive: 45,
        stage: ProjectLifecycleState.selling,
        totalBudgeted: Money.fromMajor(6000),
        totalSpent: Money.fromMajor(4500),
        totalRevenue: Money.fromMajor(9000), // Gross Sales Value
        collectedRevenue: Money.fromMajor(6000), // Liquid Cash In
        accountsReceivable: Money.fromMajor(3000), // Debtor Credit Due
        netProfit: Money.fromMajor(4500), // Accrual Net Profit (9,000 - 4,500)
        cashProfit: Money.fromMajor(1500), // Cash Profit (6,000 - 4,500)
        roiPercentage: 100.0,
        cashRoiPercentage: 33.3,
        projectedYieldDisplay: '~100 Bags',
        actualYieldTotal: 95.0,
        actualYieldUnit: 'Bags',
        activitiesCount: 8,
        harvestBatchesCount: 2,
        salesCount: 3,
        unpaidReceivables: Money.fromMajor(3000),
        budgetSpentPercentage: 75.0,
        healthStatus: ProjectHealthStatus.healthy,
        healthMessage: 'Harvest sales active.',
      );

      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectScenarioPlanningMatrixProvider(
              testProject.id,
            ).overrideWithValue(const AsyncValue.data(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ProjectFinancialsTab(
                project: testProject,
                metrics: testMetrics,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Executive P&L Header
      expect(find.text('Executive Profit & Loss'), findsOneWidget);
      expect(find.text('NET PROFIT'), findsOneWidget);

      // 2. Algorithmic Health Score Card (Milestone 7.4)
      expect(find.text('Algorithmic Health Score'), findsOneWidget);
      expect(
        find.text('5-factor composite viability rating (0–100)'),
        findsOneWidget,
      );

      // 3. Gross Sales Value
      expect(find.text('Gross Sales Value'), findsOneWidget);
      expect(find.text('GH₵ 9,000.00'), findsWidgets);

      // 3. Multi-Dimensional Profitability Card
      expect(find.text('Multi-Dimensional Profitability'), findsOneWidget);
      expect(
        find.text('Actuals vs. Liquid Cash vs. Full-Cycle Projection'),
        findsOneWidget,
      );

      // 4. Total Expenditures
      expect(find.text('Total Expenditures'), findsOneWidget);
      expect(find.text('GH₵ 4,500.00'), findsWidgets);

      // 4. Collected Cash
      expect(find.text('Collected Cash'), findsOneWidget);
      expect(find.text('GH₵ 6,000.00'), findsOneWidget);

      // 5. Accounts Receivable
      expect(find.text('Accounts Receivable'), findsOneWidget);
      expect(find.text('GH₵ 3,000.00'), findsOneWidget);

      // 6. Cash-Basis Profit
      expect(find.text('Cash-Basis Profit'), findsOneWidget);
      expect(find.text('+GH₵ 1,500.00'), findsWidgets);

      // 7. Collection percentage
      expect(find.text('67% Liquid Cash'), findsOneWidget);

      // 8. Dynamic Break-Even Card (Milestone 7.2)
      expect(find.text('Dynamic Break-Even Analysis'), findsOneWidget);
      expect(
        find.text('In-season cost recoupment & volume targets'),
        findsOneWidget,
      );

      // 9. Scenario Planning Matrix Card (Milestone 7.3)
      expect(find.text('Scenario Planning Matrix'), findsOneWidget);
      expect(find.text('Model Sensitivity Scenarios'), findsOneWidget);
    },
  );
}
