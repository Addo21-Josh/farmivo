import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/farms/presentation/providers/farm_providers.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/project_details_screen.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';

void main() {
  group('Project Detail Hub & Sub-Navigation Widget Tests', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tenDaysAgo = DateTime.now()
        .subtract(const Duration(days: 10))
        .millisecondsSinceEpoch;

    final testFarm = Farm(
      id: 'farm-101',
      name: 'Ashanti Green Acres',
      location: 'Ejura',
      district: 'Ejura-Sekyedumase',
      region: 'Ashanti',
      country: 'Ghana',
      latitude: 7.38,
      longitude: -1.36,
      totalArea: 10.0,
      areaUnit: 'Acres',
      ownershipType: 'Owned',
      notes: null,
      photoPath: null,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final testProject = Project(
      id: 'proj-101',
      farmId: 'farm-101',
      name: 'Ejura Maize Season A',
      projectType: 'Crop',
      commodity: 'Maize',
      variety: 'Obatanpa',
      landSize: 5.0,
      landUnit: 'Acres',
      startDate: tenDaysAgo,
      expectedCompletionDate: null,
      expectedFirstHarvestDate: null,
      currency: 'GHS',
      status: 'PRODUCTION',
      description: 'Commercial maize production',
      notes: null,
      createdAt: tenDaysAgo,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    final testMetrics = ProjectMetrics(
      projectId: 'proj-101',
      daysActive: 10,
      stage: ProjectLifecycleState.production,
      totalBudgeted: Money(
        BigInt.from(500000),
        currency: 'GHS',
      ), // 5,000.00 GHS
      totalSpent: Money(BigInt.from(125000), currency: 'GHS'), // 1,250.00 GHS
      totalRevenue: Money(BigInt.from(200000), currency: 'GHS'), // 2,000.00 GHS
      netProfit: Money(BigInt.from(75000), currency: 'GHS'), // +750.00 GHS
      roiPercentage: 60.0,
      projectedYieldDisplay: '~125 Bags (50kg)',
      actualYieldTotal: 0.0,
      actualYieldUnit: 'Bags',
      activitiesCount: 3,
      harvestBatchesCount: 0,
      salesCount: 1,
      unpaidReceivables: Money.zero(),
      budgetSpentPercentage: 25.0,
      healthStatus: ProjectHealthStatus.healthy,
      healthMessage: 'Field operations proceeding as planned.',
    );

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          projectDetailProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value(testProject)),
          projectMetricsProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value(testMetrics)),
          farmDetailProvider(
            'farm-101',
          ).overrideWith((ref) => Stream.value(testFarm)),
          projectBudgetItemsProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value([])),
          projectExpensesProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value([])),
          projectActivitiesProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value([])),
          projectHarvestsProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value([])),
          projectSalesProvider(
            'proj-101',
          ).overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProjectDetailsScreen(projectId: 'proj-101'),
        ),
      );
    }

    testWidgets('Renders vital metrics dashboard header accurately', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check Dashboard Header title
      expect(find.text('Ejura Maize Season A'), findsOneWidget);

      // Check 4 Vital Metrics in header
      expect(find.text('DAYS ACTIVE'), findsOneWidget);
      expect(find.text('10 Days'), findsWidgets);

      expect(find.text('CURRENT STAGE'), findsOneWidget);
      expect(find.text('Production'), findsWidgets);

      expect(find.text('TOTAL SPENT'), findsOneWidget);
      expect(find.text('GH₵ 1,250.00'), findsOneWidget);

      expect(find.text('PROJECTED YIELD'), findsOneWidget);
      expect(find.text('~125 Bags (50kg)'), findsOneWidget);

      // Check Health status banner
      expect(
        find.text('Field operations proceeding as planned.'),
        findsOneWidget,
      );
      expect(find.text('Healthy'), findsOneWidget);
    });

    testWidgets('Renders all 7 sub-navigation tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Harvests'), findsOneWidget);
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Financials'), findsOneWidget);
    });

    testWidgets('Switches tabs and displays respective sub-module views', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Initial tab is Overview
      expect(find.text('Lifecycle Progress'), findsOneWidget);

      // 2. Switch to Budget tab
      await tester.tap(find.text('Budget'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Total Planned Budget'), findsOneWidget);
      expect(find.text('GH₵ 5,000.00'), findsOneWidget);

      // 3. Switch to Expenses tab
      await tester.tap(find.text('Expenses'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Total Actual Expenditure'), findsOneWidget);

      // 4. Switch to Activities tab
      await tester.tap(find.text('Activities'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Agronomic Operations'), findsOneWidget);

      // 5. Switch to Harvests tab
      await tester.tap(find.text('Harvests'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Total Harvest Production'), findsOneWidget);

      // 6. Switch to Sales tab
      await tester.tap(find.text('Sales'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Commercial Revenue'), findsOneWidget);

      // 7. Switch to Financials tab
      await tester.tap(find.text('Financials'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Executive Profit & Loss'), findsOneWidget);
      expect(find.text('Algorithmic Health Score'), findsOneWidget);
      expect(find.text('Dynamic Break-Even Analysis'), findsOneWidget);
      expect(find.text('Decision Recommendation'), findsOneWidget);
    });
  });
}
