import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_item_with_category.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_item_providers.dart';
import 'package:farmivo/features/budgets/presentation/providers/forecast_providers.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/tabs/project_budget_tab.dart';

void main() {
  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Maize 2026',
    projectType: 'CROP',
    commodity: 'Maize',
    landSize: 5.0,
    landUnit: 'Acres',
    startDate: 0,
    currency: 'GHS',
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testMetrics = ProjectMetrics(
    projectId: 'proj-1',
    daysActive: 10,
    stage: ProjectLifecycleState.active,
    totalBudgeted: Money(BigInt.from(500000)), // GH₵ 5,000.00
    totalSpent: Money(BigInt.from(120000)), // GH₵ 1,200.00
    totalRevenue: Money.zero(),
    netProfit: Money(BigInt.from(-120000)),
    roiPercentage: 0.0,
    projectedYieldDisplay: '100 Bags',
    actualYieldTotal: 0.0,
    actualYieldUnit: 'Bags',
    activitiesCount: 2,
    harvestBatchesCount: 0,
    salesCount: 0,
    unpaidReceivables: Money.zero(),
    budgetSpentPercentage: 24.0,
    healthStatus: ProjectHealthStatus.healthy,
    healthMessage: 'Healthy',
  );

  const testCategory = BudgetCategory(
    id: 'cat-seeds',
    name: 'Seeds & Seedlings',
    description: 'Crop seeds',
    iconName: 'spa',
    isSystemDefault: true,
    displayOrder: 2,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testBudgetItem = BudgetItem(
    id: 'item-1',
    projectId: 'proj-1',
    categoryId: 'cat-seeds',
    name: 'Hybrid Maize Seed',
    quantity: 5.0,
    unit: 'Bags',
    unitCostMinor: 20000,
    plannedAmountMinor: 100000,
    currency: 'GHS',
    status: 'PLANNED',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testGroup = CategoryBudgetGroup(
    category: testCategory,
    items: const [
      BudgetItemWithCategory(item: testBudgetItem, category: testCategory),
    ],
    subtotal: Money(BigInt.from(100000)),
    percentageOfTotal: 100.0,
  );

  testWidgets(
    'ProjectBudgetTab displays empty state when no items are configured',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectGroupedBudgetProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data([])),
            projectLiveForecastCalculationProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data(null)),
            projectBreakEvenAnalysisProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data(null)),
            projectForecastProvider(
              'proj-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProjectBudgetTab(
                project: testProject,
                metrics: testMetrics,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Planned Budget'), findsOneWidget);
      expect(find.text('24% Spent'), findsOneWidget);
      expect(find.text('No Budget Items Configured'), findsOneWidget);
      expect(find.text('Add First Budget Item'), findsOneWidget);
    },
  );

  testWidgets(
    'ProjectBudgetTab displays grouped budget items with subtotal and formula',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectGroupedBudgetProvider(
              'proj-1',
            ).overrideWithValue(AsyncValue.data([testGroup])),
            projectLiveForecastCalculationProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data(null)),
            projectBreakEvenAnalysisProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data(null)),
            projectForecastProvider(
              'proj-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProjectBudgetTab(
                project: testProject,
                metrics: testMetrics,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Planned Budget'), findsOneWidget);
      expect(find.text('PLANNED ALLOCATIONS BY CATEGORY'), findsOneWidget);
      expect(find.text('Seeds & Seedlings'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Hybrid Maize Seed'), findsOneWidget);
      expect(find.text('5 Bags × GH₵ 200.00'), findsOneWidget);
      expect(find.text('GH₵ 1,000.00'), findsWidgets);
      expect(find.text('Add to Seeds & Seedlings'), findsOneWidget);
    },
  );
}
