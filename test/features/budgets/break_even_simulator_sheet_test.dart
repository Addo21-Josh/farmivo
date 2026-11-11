import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/break_even_analysis.dart';
import 'package:farmivo/features/budgets/presentation/widgets/break_even_simulator_sheet.dart';

void main() {
  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Maize 2026',
    projectType: 'CROP',
    commodity: 'Maize',
    landSize: 10.0,
    landUnit: 'Acres',
    startDate: 0,
    currency: 'GHS',
    status: 'PLANNING',
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

  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: BreakEvenSimulatorSheet(
            project: testProject,
            initialAnalysis: testAnalysis,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'BreakEvenSimulatorSheet renders interactive sliders, quick sensitivity presets, and updates thresholds',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Initial State
      expect(find.text('Break-Even & Sensitivity Simulator'), findsOneWidget);
      expect(find.text('CAPITAL PROTECTED (SAFE BUFFER)'), findsOneWidget);
      expect(find.text('80 Bags'), findsOneWidget); // 12,000 / 150 = 80
      expect(
        find.text('GH₵ 120.00 / Bags'),
        findsOneWidget,
      ); // 12,000 / 100 = 120

      // 2. Tap '-25% Shock' quick sensitivity preset
      final shockButton = find.text('-25% Shock');
      expect(shockButton, findsOneWidget);
      await tester.tap(shockButton);
      await tester.pumpAndSettle();

      // With 25% price drop (GH₵ 112.50) and 25% yield drop (75 bags) -> Revenue drops to ~GH₵ 8,437.50
      // Total cost GH₵ 12,000.00 -> Status becomes DEFICIT (CAPITAL AT RISK)
      expect(find.text('DEFICIT (CAPITAL AT RISK)'), findsOneWidget);

      // 3. Tap '+25% Boom' quick preset
      final boomButton = find.text('+25% Boom');
      await tester.tap(boomButton);
      await tester.pumpAndSettle();

      expect(find.text('CAPITAL PROTECTED (SAFE BUFFER)'), findsOneWidget);
      expect(find.text('Save as Target'), findsOneWidget);
      expect(find.text('Save as Conservative'), findsOneWidget);
    },
  );
}
