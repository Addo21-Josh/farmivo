import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/activities.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/tabs/project_activities_tab.dart';

void main() {
  const testProject = Project(
    id: 'proj-act-tab-1',
    farmId: 'farm-1',
    name: 'Maize Block 1',
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
    projectId: 'proj-act-tab-1',
    daysActive: 10,
    stage: ProjectLifecycleState.active,
    totalBudgeted: Money(BigInt.from(500000)),
    totalSpent: Money(BigInt.from(120000)),
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

  final testActivity1 = ActivityWithDetails(
    activity: const Activity(
      id: 'act-1',
      projectId: 'proj-act-tab-1',
      activityType: 'LAND_PREPARATION',
      title: 'Tractor Ploughing 1st Pass',
      activityDate: 1773000000000,
      labourCount: 2,
      durationHours: 6.0,
      costMinor: 30000, // GH₵ 300.00
      currency: 'GHS',
      status: 'COMPLETED',
      createdAt: 1773000000000,
      updatedAt: 1773000000000,
      isSynced: false,
      isDeleted: false,
    ),
    project: testProject,
    linkedExpense: const Expense(
      id: 'exp-linked-1',
      projectId: 'proj-act-tab-1',
      categoryId: 'cat-labour',
      activityId: 'act-1',
      transactionDate: 1773000000000,
      description: 'Labour: Tractor Ploughing 1st Pass',
      amountMinor: 30000,
      paymentMethod: 'CASH',
      quantity: 1.0,
      currency: 'GHS',
      isVoided: false,
      isDeleted: false,
      createdAt: 1773000000000,
      updatedAt: 1773000000000,
      isSynced: false,
    ),
  );

  final testActivity2 = ActivityWithDetails(
    activity: const Activity(
      id: 'act-2',
      projectId: 'proj-act-tab-1',
      activityType: 'PLANTING',
      title: 'Direct Sowing Hybrid Seeds',
      activityDate: 1773100000000,
      labourCount: 4,
      durationHours: 8.0,
      costMinor: 40000, // GH₵ 400.00
      currency: 'GHS',
      status: 'COMPLETED',
      createdAt: 1773100000000,
      updatedAt: 1773100000000,
      isSynced: false,
      isDeleted: false,
    ),
    project: testProject,
  );

  Widget createWidget({List<ActivityWithDetails> activities = const []}) {
    return ProviderScope(
      overrides: [
        projectActivitiesWithDetailsProvider(
          'proj-act-tab-1',
        ).overrideWith((ref) => Stream.value(activities)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ProjectActivitiesTab(
            project: testProject,
            metrics: testMetrics,
          ),
        ),
      ),
    );
  }

  group('ProjectActivitiesTab Widget Tests', () {
    testWidgets('Renders empty state when no activities exist', (tester) async {
      await tester.pumpWidget(createWidget(activities: []));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Field Activities Logged'), findsOneWidget);
      expect(find.text('Log Field Activity'), findsOneWidget);
    });

    testWidgets(
      'Renders timeline, summary stats, and ActivityTiles when activities exist',
      (tester) async {
        await tester.pumpWidget(
          createWidget(activities: [testActivity1, testActivity2]),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Header summary
        expect(find.text('2 Operations'), findsOneWidget);
        expect(find.text('6 casual workers engaged'), findsOneWidget);

        // Activity tiles
        expect(find.text('Tractor Ploughing 1st Pass'), findsOneWidget);
        expect(find.text('Direct Sowing Hybrid Seeds'), findsOneWidget);

        // Ledger badge on activity 1
        expect(find.text('Ledger'), findsOneWidget);
      },
    );

    testWidgets('Tapping ActivityTile opens ActivityDetailSheet', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(activities: [testActivity1]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Tractor Ploughing 1st Pass'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityDetailSheet), findsOneWidget);
      expect(find.text('Delete Activity Record'), findsOneWidget);
      expect(find.text('Linked to Financial Ledger'), findsOneWidget);
    });
  });
}
