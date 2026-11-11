import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_category_providers.dart';
import 'package:farmivo/features/budgets/presentation/widgets/budget_item_form_dialog.dart';

void main() {
  final testCategories = [
    const BudgetCategory(
      id: 'cat-seeds',
      name: 'Seeds & Seedlings',
      description: 'Crop seeds and nursery seedlings',
      iconName: 'spa',
      isSystemDefault: true,
      displayOrder: 2,
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
    ),
    const BudgetCategory(
      id: 'cat-fertilizer',
      name: 'Fertilizers & Nutrients',
      description: 'Inorganic and organic soil inputs',
      iconName: 'eco',
      isSystemDefault: true,
      displayOrder: 3,
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
    ),
  ];

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        budgetCategoriesStreamProvider.overrideWith(
          (ref) => Stream.value(testCategories),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: BudgetItemFormDialog(
            projectId: 'test-project-1',
            currency: 'GHS',
          ),
        ),
      ),
    );
  }

  testWidgets(
    'BudgetItemFormDialog displays form and dynamic formula calculation updates live',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Initial verification of fields and labels
      expect(find.text('Add Pre-Season Budget Item'), findsOneWidget);
      expect(
        find.text('DYNAMIC FORMULA: QUANTITY × UNIT COST'),
        findsOneWidget,
      );
      expect(find.text('Item Name *'), findsOneWidget);
      expect(find.text('Quantity *'), findsOneWidget);
      expect(find.text('Unit Cost (GHS) *'), findsOneWidget);
      expect(find.text('Add to Budget'), findsOneWidget);

      // 2. Initial quantity is '1', unit cost is empty -> prompt text is shown
      expect(
        find.text(
          'Enter a valid quantity and unit cost to calculate planned amount.',
        ),
        findsOneWidget,
      );

      // 3. Enter unit cost: 150.00
      final costField = find.widgetWithText(TextFormField, 'Unit Cost (GHS) *');
      await tester.enterText(costField, '150.00');
      await tester.pumpAndSettle();

      // With quantity 1 and unit cost 150 -> GH₵ 150.00
      expect(find.text('GH₵ 150.00'), findsOneWidget);

      // 4. Update quantity to 4
      final qtyField = find.widgetWithText(TextFormField, 'Quantity *');
      await tester.enterText(qtyField, '4');
      await tester.pumpAndSettle();

      // Live dynamic formula calculation: 4 * 150 = GH₵ 600.00
      expect(find.text('GH₵ 600.00'), findsOneWidget);
      expect(find.text('4 Bags × GH₵ 150.00'), findsOneWidget);

      // 5. Update quantity to fractional: 2.5
      await tester.enterText(qtyField, '2.5');
      await tester.pumpAndSettle();

      // Live dynamic calculation: 2.5 * 150 = GH₵ 375.00
      expect(find.text('GH₵ 375.00'), findsOneWidget);
      expect(find.text('2.5 Bags × GH₵ 150.00'), findsOneWidget);
    },
  );
}
