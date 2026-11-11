import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/presentation/providers/forecast_providers.dart';
import 'package:farmivo/features/projects/presentation/widgets/scenario_planning_card.dart';

void main() {
  group('ScenarioPlanningCard Widget Tests', () {
    final now = DateTime.now().millisecondsSinceEpoch;

    final testProject = Project(
      id: 'proj-1',
      farmId: 'farm-1',
      name: 'Ashanti Maize',
      projectType: 'Crop',
      commodity: 'Maize',
      variety: null,
      landSize: 2.0,
      landUnit: 'Acres',
      startDate: now,
      expectedCompletionDate: null,
      expectedFirstHarvestDate: null,
      currency: 'GHS',
      status: 'PLANNING',
      description: null,
      notes: null,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    testWidgets(
      'Renders empty state with action button when no forecast is present',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              projectScenarioPlanningMatrixProvider(
                'proj-1',
              ).overrideWithValue(const AsyncValue.data(null)),
              projectForecastProvider(
                'proj-1',
              ).overrideWith((ref) => Stream.value(null)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ScenarioPlanningCard(project: testProject),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Scenario Planning Matrix'), findsOneWidget);
        expect(
          find.textContaining(
            'Simulate 3-way agricultural sensitivity scenarios',
          ),
          findsOneWidget,
        );
        expect(find.text('Model Sensitivity Scenarios'), findsOneWidget);
      },
    );

    testWidgets('Renders full 3-scenario matrix with ROBUST DOWNSIDE DEFENSE', (
      tester,
    ) async {
      final matrix = ScenarioPlanningMatrix.compute(
        baselineYield: 100.0,
        yieldUnit: 'Bags',
        baselineUnitPrice: Money.fromMajor(200),
        totalBudgetedCost: Money.fromMajor(10000),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectScenarioPlanningMatrixProvider(
              'proj-1',
            ).overrideWithValue(AsyncValue.data(matrix)),
            projectForecastProvider(
              'proj-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ScenarioPlanningCard(project: testProject),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Title & Badge
      expect(find.text('Sensitivity Scenario Matrix'), findsOneWidget);
      expect(find.text('ROBUST DOWNSIDE DEFENSE'), findsOneWidget);

      // 3 Columns Headers
      expect(find.text('CONSERVATIVE'), findsOneWidget);
      expect(find.text('EXPECTED CASE'), findsOneWidget);
      expect(find.text('OPTIMISTIC'), findsOneWidget);

      // Quantities
      expect(find.text('80 Bags'), findsOneWidget);
      expect(find.text('100 Bags'), findsOneWidget);
      expect(find.text('115 Bags'), findsOneWidget);

      // Profits
      expect(find.text('+GH₵ 3,600.00'), findsOneWidget);
      expect(find.text('+GH₵ 10,000.00'), findsOneWidget);
      expect(find.text('+GH₵ 15,300.00'), findsOneWidget);

      // ROIs
      expect(find.text('+36.0%'), findsOneWidget);
      expect(find.text('+100.0%'), findsOneWidget);
      expect(find.text('+153.0%'), findsOneWidget);

      // Defense Banner
      expect(find.text('Resilient Downside Defense'), findsOneWidget);
      expect(
        find.textContaining(
          'Even under worst-case yield (-20%) and price (-15%) conditions',
        ),
        findsOneWidget,
      );
      expect(find.text('Adjust Scenarios'), findsOneWidget);
    });

    testWidgets(
      'Renders HIGH DOWNSIDE EXPOSURE when conservative scenario has deficit',
      (tester) async {
        final matrix = ScenarioPlanningMatrix.compute(
          baselineYield: 100.0,
          yieldUnit: 'Bags',
          baselineUnitPrice: Money.fromMajor(100),
          totalBudgetedCost: Money.fromMajor(9500),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              projectScenarioPlanningMatrixProvider(
                'proj-1',
              ).overrideWithValue(AsyncValue.data(matrix)),
              projectForecastProvider(
                'proj-1',
              ).overrideWith((ref) => Stream.value(null)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ScenarioPlanningCard(project: testProject),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('HIGH DOWNSIDE EXPOSURE'), findsOneWidget);
        expect(find.text('High Downside Vulnerability'), findsOneWidget);
        expect(find.text('At Risk: GH₵ 2,700.00'), findsOneWidget);
        expect(
          find.textContaining('substantial capital loss of GH₵ 2,700.00'),
          findsOneWidget,
        );
      },
    );
  });
}
