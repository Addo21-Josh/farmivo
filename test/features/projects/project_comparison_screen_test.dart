import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/financial_engine/project_comparison.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/projects/domain/models/project_with_farm.dart';
import 'package:farmivo/features/projects/presentation/project_comparison_screen.dart';
import 'package:farmivo/features/projects/presentation/providers/project_comparison_providers.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/features/projects/presentation/widgets/project_comparison_matrix_card.dart';

void main() {
  group('Project Comparison Matrix Tests (Milestone 7.5)', () {
    final now = DateTime.now().millisecondsSinceEpoch;

    final p1 = ProjectComparisonRecord.compute(
      projectId: 'p-1',
      projectName: 'Ejura Maize A',
      commodity: 'Maize',
      variety: 'Pannar 53',
      farmName: 'Northern Ridge Farm',
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
      variety: 'Scotch Bonnet',
      farmName: 'Valley Plot B',
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
      farmName: 'Northern Ridge Farm',
      stage: ProjectLifecycleState.completed,
      status: 'COMPLETED',
      landSize: 1.5,
      landUnit: 'Acres',
      plannedBudget: Money.fromMajor(4000),
      actualSpent: Money.fromMajor(4500),
      actualSales: Money.fromMajor(3000),
      daysActive: 90,
      healthScore: 52,
      healthStatus: ProjectHealthStatus.atRisk,
    );

    testWidgets(
      'ProjectComparisonMatrixCard renders side-by-side columns and benchmarks',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final matrix = ProjectComparisonMatrix.compute([p1, p2, p3]);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProjectComparisonMatrixCard(matrix: matrix),
              ),
            ),
          ),
        );
        await tester.pump();

        // Card Header
        expect(find.text('Project Comparison Matrix'), findsOneWidget);
        expect(find.text('3 VENTURES'), findsOneWidget);

        // Projects
        expect(find.text('Ejura Maize A'), findsOneWidget);
        expect(find.text('Akomadan Pepper'), findsOneWidget);
        expect(find.text('Navrongo Tomato'), findsOneWidget);

        // Top ROI indicator
        expect(find.text('TOP ROI'), findsOneWidget);

        // Metric Labels
        expect(find.text('Lifecycle Stage'), findsOneWidget);
        expect(find.text('Health Rating'), findsOneWidget);
        expect(find.text('Land Size'), findsOneWidget);
        expect(find.text('Cycle Duration'), findsOneWidget);
        expect(find.text('Capital Invested'), findsOneWidget);
        expect(find.text('Total Revenue'), findsWidgets);
        expect(find.text('Net Profit'), findsOneWidget);
        expect(find.text('ROI %'), findsOneWidget);
        expect(find.text('Profit / Land Unit'), findsOneWidget);

        // Comparative values
        expect(find.text('4 Acres'), findsOneWidget);
        expect(find.text('2 Acres'), findsOneWidget);
        expect(find.text('1.5 Acres'), findsOneWidget);

        expect(find.text('105 Days'), findsOneWidget);
        expect(find.text('80 Days'), findsOneWidget);
        expect(find.text('90 Days'), findsOneWidget);

        expect(find.text('GH₵ 5,000.00'), findsWidgets);
        expect(find.text('GH₵ 7,000.00'), findsWidgets);
        expect(find.text('GH₵ 10,000.00'), findsWidgets);
        expect(find.text('GH₵ 12,000.00'), findsWidgets);

        // Aggregate totals
        expect(find.text('Combined Portfolio Totals'), findsOneWidget);
        expect(find.text('GH₵ 16,500.00'), findsOneWidget); // Total Invested
        expect(find.text('GH₵ 25,000.00'), findsOneWidget); // Total Revenue
        expect(find.text('GH₵ 8,500.00'), findsOneWidget); // Total Net Profit

        // Insights narrative
        expect(find.text('Comparative Performance Insights'), findsOneWidget);
        expect(
          find.textContaining(
            'Ejura Maize A generated the highest ROI (+100.0%)',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ProjectComparisonScreen renders guidance when < 2 projects selected',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final dummyProject = Project(
          id: 'p-1',
          farmId: 'farm-1',
          name: 'Ejura Maize A',
          projectType: 'Crop',
          commodity: 'Maize',
          variety: null,
          landSize: 4.0,
          landUnit: 'Acres',
          startDate: now,
          expectedCompletionDate: null,
          expectedFirstHarvestDate: null,
          currency: 'GHS',
          status: 'COMPLETED',
          description: null,
          notes: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              allProjectsComparisonProvider.overrideWith((ref) => [p1]),
              selectedProjectIdsForComparisonProvider.overrideWith(
                (ref) => SelectedProjectsNotifier({'p-1'}),
              ),
              projectsWithFarmStreamProvider.overrideWith(
                (ref) => Stream.value([
                  ProjectWithFarm(project: dummyProject, farm: null),
                ]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ProjectComparisonScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('Select at least 2 ventures to compare'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Choose two or more active or past farm projects',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ProjectComparisonScreen renders matrix when multiple projects selected',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final dummyProject1 = Project(
          id: 'p-1',
          farmId: 'farm-1',
          name: 'Ejura Maize A',
          projectType: 'Crop',
          commodity: 'Maize',
          variety: null,
          landSize: 4.0,
          landUnit: 'Acres',
          startDate: now,
          expectedCompletionDate: null,
          expectedFirstHarvestDate: null,
          currency: 'GHS',
          status: 'COMPLETED',
          description: null,
          notes: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        );

        final dummyProject2 = Project(
          id: 'p-2',
          farmId: 'farm-1',
          name: 'Akomadan Pepper',
          projectType: 'Crop',
          commodity: 'Pepper',
          variety: null,
          landSize: 2.0,
          landUnit: 'Acres',
          startDate: now,
          expectedCompletionDate: null,
          expectedFirstHarvestDate: null,
          currency: 'GHS',
          status: 'HARVESTING',
          description: null,
          notes: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              allProjectsComparisonProvider.overrideWith((ref) => [p1, p2]),
              selectedProjectIdsForComparisonProvider.overrideWith(
                (ref) => SelectedProjectsNotifier({'p-1', 'p-2'}),
              ),
              projectsWithFarmStreamProvider.overrideWith(
                (ref) => Stream.value([
                  ProjectWithFarm(project: dummyProject1, farm: null),
                  ProjectWithFarm(project: dummyProject2, farm: null),
                ]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ProjectComparisonScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Project Comparison Matrix'), findsWidgets);
        expect(find.text('2 VENTURES'), findsOneWidget);
        expect(find.text('Ejura Maize A'), findsWidgets);
        expect(find.text('Akomadan Pepper'), findsWidgets);
      },
    );
  });
}
