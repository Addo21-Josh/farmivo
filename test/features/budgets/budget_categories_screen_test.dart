import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/budgets.dart';

void main() {
  final now = DateTime.now().millisecondsSinceEpoch;

  final standardCat1 = BudgetCategory(
    id: 'cat-1',
    name: 'Land Preparation',
    description: 'Bush clearing, tractor ploughing, and seedbeds',
    iconName: 'agriculture',
    isSystemDefault: true,
    displayOrder: 1,
    createdAt: now,
    updatedAt: now,
    isSynced: false,
    isDeleted: false,
  );

  final standardCat2 = BudgetCategory(
    id: 'cat-2',
    name: 'Seeds & Seedlings',
    description: 'Certified seeds and plantlets',
    iconName: 'grass',
    isSystemDefault: true,
    displayOrder: 2,
    createdAt: now,
    updatedAt: now,
    isSynced: false,
    isDeleted: false,
  );

  final standardCat3 = BudgetCategory(
    id: 'cat-3',
    name: 'Irrigation & Water',
    description: 'Water pump fuel and drip lines',
    iconName: 'water_drop',
    isSystemDefault: true,
    displayOrder: 3,
    createdAt: now,
    updatedAt: now,
    isSynced: false,
    isDeleted: false,
  );

  final customCat = BudgetCategory(
    id: 'cat-custom-1',
    name: 'Solar Drying Mats',
    description: 'Mats for drying harvested pepper and cocoa',
    iconName: 'category',
    isSystemDefault: false,
    displayOrder: 14,
    createdAt: now,
    updatedAt: now,
    isSynced: false,
    isDeleted: false,
  );

  Widget createTestWidget({List<BudgetCategory>? categories}) {
    final list =
        categories ?? [standardCat1, standardCat2, standardCat3, customCat];
    return ProviderScope(
      overrides: [
        budgetCategoriesStreamProvider.overrideWith(
          (ref) => Stream.value(list),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const BudgetCategoriesScreen(),
      ),
    );
  }

  group('BudgetCategoriesScreen Widget Tests', () {
    testWidgets('Renders standard taxonomy and custom enterprise categories', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Budget Categories'), findsOneWidget);
      expect(find.text('Standard Agricultural Taxonomy'), findsOneWidget);
      expect(find.text('STANDARD AGRICULTURAL TAXONOMY'), findsOneWidget);
      expect(find.text('CUSTOM ENTERPRISE CATEGORIES'), findsOneWidget);

      // Check standard category items
      expect(find.text('Land Preparation'), findsOneWidget);
      expect(find.text('Seeds & Seedlings'), findsOneWidget);

      // Check custom category items
      expect(find.text('Solar Drying Mats'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Standard'), findsWidgets);
    });

    testWidgets('Search filters categories dynamically by keyword', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Enter search term
      await tester.enterText(find.byType(TextField), 'Irrigation');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Irrigation & Water'), findsOneWidget);
      expect(find.text('Land Preparation'), findsNothing);
      expect(find.text('Seeds & Seedlings'), findsNothing);
      expect(find.text('Solar Drying Mats'), findsNothing);
    });

    testWidgets('Can open CreateBudgetCategoryDialog from FAB', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap FAB to add new category
      await tester.tap(find.text('New Category'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('New Custom Category'), findsOneWidget);
      expect(find.text('Category Name *'), findsOneWidget);
      expect(find.text('CHOOSE AN ICON'), findsOneWidget);
      expect(find.text('Create Category'), findsOneWidget);
    });
  });
}
