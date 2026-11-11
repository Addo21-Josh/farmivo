import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/presentation/record_activity_screen.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_category_providers.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';

void main() {
  const testProject = Project(
    id: 'proj-act-1',
    farmId: 'farm-1',
    name: 'Maize Block Alpha',
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

  const testCategory = BudgetCategory(
    id: 'cat-labour-1',
    name: 'Labour (Field Operations)',
    isSystemDefault: true,
    displayOrder: 1,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  Widget createWidget({
    String? initialProjectId = 'proj-act-1',
    List<Project> projects = const [testProject],
    List<BudgetCategory> categories = const [testCategory],
  }) {
    return ProviderScope(
      overrides: [
        projectsStreamProvider.overrideWith((ref) => Stream.value(projects)),
        budgetCategoriesStreamProvider.overrideWith(
          (ref) => Stream.value(categories),
        ),
      ],
      child: MaterialApp(
        home: RecordActivityScreen(initialProjectId: initialProjectId),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RecordActivityScreen Widget Tests', () {
    testWidgets('Renders all input fields and standard controls', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Log Field Activity'), findsOneWidget);
      expect(find.text('Farm Project *'), findsOneWidget);
      expect(find.text('Activity Type *'), findsOneWidget);
      expect(find.text('Activity Title / Operation *'), findsOneWidget);
      expect(find.text('Casual Labour & Manpower'), findsOneWidget);
      expect(find.text('Labour Cost & Expenditure'), findsOneWidget);
      expect(find.text('Record as Expense in Project Ledger'), findsOneWidget);
      expect(find.text('Save Field Activity'), findsOneWidget);
    });

    testWidgets(
      'Tapping activity type chip updates suggested operation chips',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(createWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap on 'Weeding & Slashing' chip
        final weedingChip = find.text('Weeding & Slashing');
        expect(weedingChip, findsOneWidget);
        await tester.tap(weedingChip);
        await tester.pump();

        // Check that suggestion chips for weeding appear
        final suggestionChip = find.widgetWithText(
          ActionChip,
          'Bush Slashing & Clearing',
        );
        expect(suggestionChip, findsOneWidget);

        // Tapping suggestion fills the text field
        await tester.tap(suggestionChip);
        await tester.pump();

        expect(
          find.widgetWithText(TextFormField, 'Bush Slashing & Clearing'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Adjusts labour worker count using stepper buttons', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially 0
      expect(find.text('0'), findsOneWidget);

      // Tap + button twice
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Tap - button once
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Entering a cost > 0 toggles the ledger expense switch on', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the cost field (labeled Total Operation / Labour Cost)
      final costField = find.widgetWithText(
        TextFormField,
        'Total Operation / Labour Cost',
      );
      expect(costField, findsOneWidget);
      await tester.enterText(costField, '250.00');
      await tester.pump();

      // Switch should now be toggled on and payment method chips visible
      expect(find.text('Payment Channel'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Cash'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'MTN MoMo'), findsOneWidget);
    });

    testWidgets('Validates title input when attempting to submit empty form', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Clear title text field
      final titleField = find.widgetWithText(
        TextFormField,
        'e.g. Tractor Ploughing, Urea Top Dressing',
      );
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, '');
      await tester.pump();

      // Tap Save Field Activity button
      await tester.tap(find.text('Save Field Activity'));
      await tester.pump();

      expect(find.text('Please enter an activity title'), findsOneWidget);
    });

    testWidgets(
      'Guarantees zero layout or pixel overflows across mobile screen dimensions',
      (tester) async {
        final screenSizes = [
          const Size(320, 640), // Small entry-level phone
          const Size(360, 800), // Standard Android
          const Size(375, 812), // iPhone SE / standard iPhone
          const Size(390, 844), // iPhone 12/13/14
          const Size(412, 915), // High-res Android
        ];

        for (final size in screenSizes) {
          tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
          tester.view.devicePixelRatio = 2.0;

          final errors = <FlutterErrorDetails>[];
          FlutterError.onError = (details) {
            errors.add(details);
          };

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                projectsStreamProvider.overrideWith(
                  (ref) => Stream.value([testProject]),
                ),
                budgetCategoriesStreamProvider.overrideWith(
                  (ref) => Stream.value([testCategory]),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: const RecordActivityScreen(
                  initialProjectId: 'proj-act-1',
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Scroll down to the expense switch
          final scrollable = find.byType(Scrollable).first;
          await tester.scrollUntilVisible(
            find.byType(Switch),
            200,
            scrollable: scrollable,
          );
          await tester.pumpAndSettle();

          // Toggle switch
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          // Assert ZERO layout or render overflows occurred
          expect(
            errors,
            isEmpty,
            reason:
                'Screen size $size generated layout overflows: ${errors.map((e) => e.exceptionAsString()).join('\n')}',
          );
        }
      },
    );
  });
}
