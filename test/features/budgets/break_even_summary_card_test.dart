import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/break_even_analysis.dart';
import 'package:farmivo/features/budgets/presentation/providers/forecast_providers.dart';
import 'package:farmivo/features/budgets/presentation/widgets/break_even_summary_card.dart';

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

  const testAnalysis = BreakEvenAnalysis(
    expectedYield: 100.0,
    yieldUnit: 'Bags',
    expectedUnitPriceMinor: 15000, // GH₵ 150.00
    totalBudgetedCostMinor: 1200000, // GH₵ 12,000.00
    currency: 'GHS',
  );

  testWidgets(
    'BreakEvenSummaryCard displays empty prompt when analysis is null',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectBreakEvenAnalysisProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data(null)),
            projectForecastProvider(
              'proj-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BreakEvenSummaryCard(project: testProject)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Break-Even & Capital Protection'), findsOneWidget);
      expect(find.text('Configure Yield & Price Baseline'), findsOneWidget);
    },
  );

  testWidgets(
    'BreakEvenSummaryCard displays thresholds, cushions, and status badge',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectBreakEvenAnalysisProvider(
              'proj-1',
            ).overrideWithValue(const AsyncValue.data(testAnalysis)),
            projectForecastProvider(
              'proj-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BreakEvenSummaryCard(project: testProject)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header & Status
      expect(find.text('Break-Even & Capital Protection'), findsOneWidget);
      expect(find.text('CAPITAL PROTECTED'), findsOneWidget);
      expect(find.text('BREAK-EVEN YIELD'), findsOneWidget);
      expect(find.text('BREAK-EVEN PRICE'), findsOneWidget);

      // 2. Metrics: 80 Bags & GH₵ 120.00
      expect(find.text('80 Bags'), findsOneWidget);
      expect(find.text('GH₵ 120.00 / Bags'), findsOneWidget);

      // 3. Cushions & Simulator button
      expect(find.textContaining('+20% cushion'), findsWidgets);
      expect(find.text('Break-Even Simulator & Sensitivity'), findsOneWidget);
    },
  );
}
