import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/harvests.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/tabs/project_harvests_tab.dart';

void main() {
  const testProject = Project(
    id: 'proj-harv-tab-1',
    farmId: 'farm-1',
    name: 'Maize Season 2026',
    projectType: 'CROP',
    commodity: 'Maize',
    landSize: 10.0,
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
    projectId: 'proj-harv-tab-1',
    daysActive: 45,
    stage: ProjectLifecycleState.active,
    totalBudgeted: Money(BigInt.from(600000)),
    totalSpent: Money(BigInt.from(400000)),
    totalRevenue: Money.zero(),
    netProfit: Money(BigInt.from(-400000)),
    roiPercentage: 0.0,
    projectedYieldDisplay: '500 Bags',
    actualYieldTotal: 300.0,
    actualYieldUnit: '50kg Bag',
    activitiesCount: 6,
    harvestBatchesCount: 2,
    salesCount: 0,
    unpaidReceivables: Money.zero(),
    budgetSpentPercentage: 66.6,
    healthStatus: ProjectHealthStatus.healthy,
    healthMessage: 'Healthy',
  );

  final testSummary = HarvestYieldSummary(
    projectId: 'proj-harv-tab-1',
    totalQuantity: 300.0,
    unit: '50kg Bag',
    totalBatches: 2,
    quantityByGrade: {
      HarvestGrade.gradeA: 200.0,
      HarvestGrade.gradeB: 100.0,
      HarvestGrade.rejects: 0.0,
      HarvestGrade.ungraded: 0.0,
    },
    projectedYield: 500.0,
    projectedYieldUnit: '50kg Bag',
    landSize: 10.0,
    landUnit: 'Acres',
  );

  final testHarvest1 = HarvestWithDetails(
    harvest: const Harvest(
      id: 'harv-1',
      projectId: 'proj-harv-tab-1',
      batchNumber: 'HV-MAI-2611-01',
      harvestDate: 1773000000000,
      productName: 'Yellow Maize',
      quantity: 200.0,
      unit: '50kg Bag',
      grade: 'GRADE_A',
      storageLocation: 'Main Barn Silo A',
      notes: 'Pristine grain',
      createdAt: 1773000000000,
      updatedAt: 1773000000000,
      isSynced: false,
      isDeleted: false,
    ),
    project: testProject,
  );

  final testHarvest2 = HarvestWithDetails(
    harvest: const Harvest(
      id: 'harv-2',
      projectId: 'proj-harv-tab-1',
      batchNumber: 'HV-MAI-2611-02',
      harvestDate: 1773100000000,
      productName: 'Yellow Maize',
      quantity: 100.0,
      unit: '50kg Bag',
      grade: 'GRADE_B',
      storageLocation: 'Field Shed',
      notes: null,
      createdAt: 1773100000000,
      updatedAt: 1773100000000,
      isSynced: false,
      isDeleted: false,
    ),
    project: testProject,
  );

  Widget createWidget({
    HarvestYieldSummary? summary,
    List<HarvestWithDetails> harvests = const [],
  }) {
    return ProviderScope(
      overrides: [
        projectYieldSummaryProvider('proj-harv-tab-1').overrideWith(
          (ref) => Stream.value(
            summary ?? HarvestYieldSummary.empty(projectId: 'proj-harv-tab-1'),
          ),
        ),
        projectHarvestsWithDetailsProvider(
          'proj-harv-tab-1',
        ).overrideWith((ref) => Stream.value(harvests)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ProjectHarvestsTab(project: testProject, metrics: testMetrics),
        ),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('ProjectHarvestsTab Widget Tests', () {
    testWidgets('Renders empty state when no harvests exist', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget(harvests: []));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Harvest Batches Recorded'), findsOneWidget);
      expect(find.text('Record Harvest Batch'), findsOneWidget);
    });

    testWidgets(
      'Renders HarvestYieldCard and HarvestTiles when batches exist',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(
          createWidget(
            summary: testSummary,
            harvests: [testHarvest1, testHarvest2],
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Yield summary card
        expect(find.text('Total Harvest Production'), findsOneWidget);
        expect(find.text('300 50kg Bag'), findsOneWidget);
        expect(find.text('2 Batches'), findsOneWidget);
        expect(find.text('60.0% achieved'), findsOneWidget);
        expect(find.text('Target: 500 50kg Bag'), findsOneWidget);
        expect(find.text('(30 50kg Bag / Acres)'), findsOneWidget);

        // Harvest tiles
        expect(find.text('HV-MAI-2611-01'), findsOneWidget);
        expect(find.text('HV-MAI-2611-02'), findsOneWidget);
        expect(find.text('200 50kg Bag'), findsOneWidget);
        expect(find.text('100 50kg Bag'), findsOneWidget);
        expect(find.text('Main Barn Silo A'), findsOneWidget);
        expect(find.text('Field Shed'), findsOneWidget);
      },
    );

    testWidgets('Tapping HarvestTile opens HarvestDetailSheet', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(
        createWidget(summary: testSummary, harvests: [testHarvest1]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('HV-MAI-2611-01'));
      await tester.pumpAndSettle();

      expect(find.byType(HarvestDetailSheet), findsOneWidget);
      expect(find.text('Delete Harvest Batch'), findsOneWidget);
      expect(find.text('Pristine grain'), findsOneWidget);
    });
  });
}
