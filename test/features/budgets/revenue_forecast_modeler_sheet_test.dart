import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_item_providers.dart';
import 'package:farmivo/features/budgets/presentation/widgets/revenue_forecast_modeler_sheet.dart';

void main() {
  const testProject = Project(
    id: 'proj-123',
    farmId: 'farm-1',
    name: 'Maize Season 2026',
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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        // Planned budget cost: GH₵ 10,000.00
        projectTotalPlannedMoneyProvider(
          'proj-123',
        ).overrideWith((ref) => Stream.value(Money(BigInt.from(1000000)))),
      ],
      child: const MaterialApp(
        home: Scaffold(body: RevenueForecastModelerSheet(project: testProject)),
      ),
    );
  }

  testWidgets(
    'RevenueForecastModelerSheet calculates Gross Revenue, Net Profit, and ROI % live',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Check title & headers
      expect(find.text('Revenue & Yield Forecast Modeler'), findsOneWidget);
      expect(find.text('EXPECTED TARGET SCENARIO'), findsOneWidget);
      expect(find.text('Expected Yield *'), findsOneWidget);
      expect(find.text('Save Forecast Modeler'), findsOneWidget);

      // 2. Set Yield to 200
      final yieldField = find.widgetWithText(TextFormField, 'Expected Yield *');
      await tester.enterText(yieldField, '200');
      await tester.pumpAndSettle();

      // 3. Set Unit Price to 150.00 (GH₵ 150.00 / Bag)
      // 200 bags * GH₵ 150.00 = GH₵ 30,000.00 Gross Revenue
      // Planned Cost = GH₵ 10,000.00
      // Net Profit = GH₵ 20,000.00
      // ROI % = (20,000 / 10,000) * 100 = 200.0%
      final priceField = find.widgetWithText(
        TextFormField,
        'Estimated Unit Selling Price (GHS) *',
      );
      expect(priceField, findsOneWidget);

      await tester.enterText(priceField, '150.00');
      await tester.pumpAndSettle();

      // Verify live calculation displays
      expect(find.text('GH₵ 30,000.00'), findsOneWidget);
      expect(find.text('GH₵ 10,000.00'), findsOneWidget);
      expect(find.text('GH₵ 20,000.00'), findsOneWidget);
      expect(find.text('+200.0% ROI'), findsOneWidget);
      expect(find.text('Projected Net Profit'), findsOneWidget);

      // 4. Change price to 40.00 (Below cost -> Deficit)
      // 200 bags * GH₵ 40.00 = GH₵ 8,000.00 Gross Revenue
      // Planned Cost = GH₵ 10,000.00
      // Deficit = -GH₵ 2,000.00
      // ROI % = (-2,000 / 10,000) * 100 = -20.0%
      await tester.enterText(priceField, '40.00');
      await tester.pumpAndSettle();

      expect(find.text('GH₵ 8,000.00'), findsOneWidget);
      expect(find.text('-GH₵ 2,000.00'), findsOneWidget);
      expect(find.text('-20.0% ROI'), findsOneWidget);
      expect(find.text('Projected Deficit'), findsOneWidget);
    },
  );

  testWidgets(
    'RevenueForecastModelerSheet dynamically recalculates when switching scenario type',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Baseline: 100 bags @ GH₵ 200.00 = GH₵ 20,000.00
      // Cost: GH₵ 10,000.00 -> Net Profit = GH₵ 10,000.00 (+100.0% ROI)
      final yieldField = find.widgetWithText(TextFormField, 'Expected Yield *');
      await tester.enterText(yieldField, '100');
      final priceField = find.widgetWithText(
        TextFormField,
        'Estimated Unit Selling Price (GHS) *',
      );
      await tester.enterText(priceField, '200.00');
      await tester.pumpAndSettle();

      expect(find.text('EXPECTED TARGET SCENARIO'), findsOneWidget);
      expect(find.text('GH₵ 20,000.00'), findsOneWidget); // Gross Revenue
      expect(
        find.text('GH₵ 10,000.00'),
        findsNWidgets(2),
      ); // Planned Cost & Net Profit
      expect(find.text('+100.0% ROI'), findsOneWidget);

      // Switch to Conservative: -20% yield (80 bags), -15% price (GH₵ 170.00)
      // Gross Revenue = 80 * 170 = GH₵ 13,600.00
      // Net Profit = 13,600 - 10,000 = GH₵ 3,600.00
      // ROI = (3,600 / 10,000) * 100 = +36.0%
      await tester.tap(find.text('Conservative'));
      await tester.pumpAndSettle();

      expect(
        find.text('CONSERVATIVE SCENARIO (-20% YIELD, -15% PRICE)'),
        findsOneWidget,
      );
      expect(find.text('GH₵ 13,600.00'), findsOneWidget);
      expect(find.text('GH₵ 3,600.00'), findsOneWidget);
      expect(find.text('+36.0% ROI'), findsOneWidget);

      // Switch to Optimistic: +15% yield (115 bags), +10% price (GH₵ 220.00)
      // Gross Revenue = 115 * 220 = GH₵ 25,300.00
      // Net Profit = 25,300 - 10,000 = GH₵ 15,300.00
      // ROI = (15,300 / 10,000) * 100 = +153.0%
      await tester.tap(find.text('Optimistic'));
      await tester.pumpAndSettle();

      expect(
        find.text('OPTIMISTIC SCENARIO (+15% YIELD, +10% PRICE)'),
        findsOneWidget,
      );
      expect(find.text('GH₵ 25,300.00'), findsOneWidget);
      expect(find.text('GH₵ 15,300.00'), findsOneWidget);
      expect(find.text('+153.0% ROI'), findsOneWidget);
    },
  );
}
