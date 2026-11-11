import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_item_with_category.dart';
import 'package:farmivo/features/budgets/domain/models/budget_tracking.dart';
import 'package:farmivo/features/budgets/presentation/widgets/budget_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testCategory = BudgetCategory(
    id: 'cat-seeds',
    name: 'Seeds & Seedlings',
    description: 'Crop seeds',
    iconName: 'grass',
    isSystemDefault: true,
    displayOrder: 2,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testBudgetItem = BudgetItem(
    id: 'item-1',
    projectId: 'proj-1',
    categoryId: 'cat-seeds',
    name: 'Hybrid Maize Seed',
    quantity: 10.0,
    unit: 'Bags',
    unitCostMinor: 25000, // GH₵ 250.00
    plannedAmountMinor: 250000, // GH₵ 2,500.00
    currency: 'GHS',
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const itemWithCategory = BudgetItemWithCategory(
    item: testBudgetItem,
    category: testCategory,
  );

  testWidgets(
    'BudgetItemTile displays planned formula without tracking when tracking is null',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetItemTile(itemWithCategory: itemWithCategory),
          ),
        ),
      );

      expect(find.text('Hybrid Maize Seed'), findsOneWidget);
      expect(find.text('GH₵ 2,500.00'), findsOneWidget);
      expect(find.text('10 Bags × GH₵ 250.00'), findsOneWidget);
      expect(find.textContaining('Actual Spent'), findsNothing);
    },
  );

  testWidgets(
    'BudgetItemTile displays actual spent and remaining allocation when tracking is provided',
    (tester) async {
      final tracking = BudgetItemTracking(
        itemWithCategory: itemWithCategory,
        actualSpent: Money(
          BigInt.from(100000),
          currency: 'GHS',
        ), // GH₵ 1,000.00 spent (40%)
        transactionCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetItemTile(
              itemWithCategory: itemWithCategory,
              tracking: tracking,
            ),
          ),
        ),
      );

      expect(find.text('Hybrid Maize Seed'), findsOneWidget);
      expect(find.text('GH₵ 2,500.00'), findsOneWidget);
      expect(find.text('Actual Spent: GH₵ 1,000.00 (40%)'), findsOneWidget);
      expect(find.text('GH₵ 1,500.00 remaining'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'BudgetItemTile displays overrun warning indicator when actual spend exceeds budget',
    (tester) async {
      final tracking = BudgetItemTracking(
        itemWithCategory: itemWithCategory,
        actualSpent: Money(
          BigInt.from(300000),
          currency: 'GHS',
        ), // GH₵ 3,000.00 spent (120% overrun)
        transactionCount: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetItemTile(
              itemWithCategory: itemWithCategory,
              tracking: tracking,
            ),
          ),
        ),
      );

      expect(find.text('Actual Spent: GH₵ 3,000.00 (120%)'), findsOneWidget);
      expect(find.text('Overrun: +GH₵ 500.00'), findsOneWidget);
    },
  );
}
