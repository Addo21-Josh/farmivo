import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_item_with_category.dart';
import 'package:farmivo/features/budgets/domain/models/budget_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testProjectId = 'project-uuid-1';
  const currency = 'GHS';

  const testCategoryFertilizer = BudgetCategory(
    id: 'cat-fertilizer',
    name: 'Fertilizers & Nutrients',
    description: 'Inorganic and organic fertilizer',
    iconName: 'science',
    isSystemDefault: true,
    displayOrder: 3,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testCategoryLabour = BudgetCategory(
    id: 'cat-labour',
    name: 'Labour (Field Operations)',
    description: 'Casual and seasonal farm labour',
    iconName: 'groups',
    isSystemDefault: true,
    displayOrder: 6,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testCategoryTransport = BudgetCategory(
    id: 'cat-transport',
    name: 'Transportation & Haulage',
    description: 'Cartage and transport services',
    iconName: 'local_shipping',
    isSystemDefault: true,
    displayOrder: 10,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const ureaBudgetItem = BudgetItem(
    id: 'b-item-urea',
    projectId: testProjectId,
    categoryId: 'cat-fertilizer',
    name: 'Urea Fertilizer 50kg',
    quantity: 5.0,
    unit: 'Bags',
    unitCostMinor: 40000, // GH₵ 400.00
    plannedAmountMinor: 200000, // GH₵ 2,000.00
    currency: currency,
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const npkBudgetItem = BudgetItem(
    id: 'b-item-npk',
    projectId: testProjectId,
    categoryId: 'cat-fertilizer',
    name: 'NPK 15-15-15',
    quantity: 10.0,
    unit: 'Bags',
    unitCostMinor: 45000, // GH₵ 450.00
    plannedAmountMinor: 450000, // GH₵ 4,500.00
    currency: currency,
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const weedingBudgetItem = BudgetItem(
    id: 'b-item-weeding',
    projectId: testProjectId,
    categoryId: 'cat-labour',
    name: 'Manual Weeding (First Pass)',
    quantity: 10.0,
    unit: 'Days',
    unitCostMinor: 8000, // GH₵ 80.00
    plannedAmountMinor: 80000, // GH₵ 800.00
    currency: currency,
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final budgetItems = [
    const BudgetItemWithCategory(
      item: ureaBudgetItem,
      category: testCategoryFertilizer,
    ),
    const BudgetItemWithCategory(
      item: npkBudgetItem,
      category: testCategoryFertilizer,
    ),
    const BudgetItemWithCategory(
      item: weedingBudgetItem,
      category: testCategoryLabour,
    ),
  ];

  final allCategories = [
    testCategoryFertilizer,
    testCategoryLabour,
    testCategoryTransport,
  ];

  Expense createExpense({
    required String id,
    required String categoryId,
    String? budgetItemId,
    required int amountMinor,
    bool isVoided = false,
    bool isDeleted = false,
  }) {
    return Expense(
      id: id,
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: isDeleted,
      projectId: testProjectId,
      categoryId: categoryId,
      budgetItemId: budgetItemId,
      transactionDate: 0,
      description: 'Test Expense',
      quantity: 1.0,
      amountMinor: amountMinor,
      currency: currency,
      paymentMethod: 'CASH',
      isVoided: isVoided,
    );
  }

  group('ProjectBudgetTracking.compute - Allocation Linking & Calculations', () {
    test(
      'Calculates item-level and category-level actual spent from linked transactions',
      () {
        final expenses = [
          // 2 bags of Urea purchased (linked to b-item-urea)
          createExpense(
            id: 'exp-1',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor: 80000, // GH₵ 800.00
          ),
          // Additional 1 bag of Urea purchased (linked to b-item-urea)
          createExpense(
            id: 'exp-2',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor: 40000, // GH₵ 400.00
          ),
          // Weeding labour (linked to b-item-weeding)
          createExpense(
            id: 'exp-3',
            categoryId: 'cat-labour',
            budgetItemId: 'b-item-weeding',
            amountMinor: 50000, // GH₵ 500.00
          ),
        ];

        final tracking = ProjectBudgetTracking.compute(
          projectId: testProjectId,
          currency: currency,
          budgetItems: budgetItems,
          allCategories: allCategories,
          expenses: expenses,
        );

        // 1. Overall Project Budget Totals
        // Total planned: 2000 + 4500 + 800 = GH₵ 7,300.00 (730,000 minor)
        expect(tracking.totalPlanned.minorUnits, equals(BigInt.from(730000)));
        // Total spent: 800 + 400 + 500 = GH₵ 1,700.00 (170,000 minor)
        expect(tracking.totalSpent.minorUnits, equals(BigInt.from(170000)));
        // Total remaining: 7300 - 1700 = GH₵ 5,600.00
        expect(tracking.totalRemaining.minorUnits, equals(BigInt.from(560000)));
        // Percentage spent: 1700 / 7300 * 100 = 23.287%
        expect(tracking.spentPercentage, closeTo(23.29, 0.1));
        expect(tracking.isOverBudget, isFalse);

        // 2. Fertilizer Category Tracking
        final fertTracking = tracking.categories.firstWhere(
          (c) => c.category.id == 'cat-fertilizer',
        );
        // Planned: 2000 + 4500 = GH₵ 6,500.00
        expect(
          fertTracking.plannedAmount.minorUnits,
          equals(BigInt.from(650000)),
        );
        // Spent: 800 + 400 = GH₵ 1,200.00
        expect(
          fertTracking.actualSpent.minorUnits,
          equals(BigInt.from(120000)),
        );
        expect(
          fertTracking.remainingAmount.minorUnits,
          equals(BigInt.from(530000)),
        );
        // Percentage spent: 1200 / 6500 * 100 = 18.46%
        expect(fertTracking.spentPercentage, closeTo(18.46, 0.1));
        expect(fertTracking.transactionCount, equals(2));
        expect(fertTracking.isOverBudget, isFalse);

        // Urea Line Item Tracking
        final ureaTracking = fertTracking.items.firstWhere(
          (i) => i.item.id == 'b-item-urea',
        );
        expect(
          ureaTracking.plannedAmount.minorUnits,
          equals(BigInt.from(200000)),
        );
        expect(
          ureaTracking.actualSpent.minorUnits,
          equals(BigInt.from(120000)),
        ); // GH₵ 1,200.00
        expect(
          ureaTracking.remainingAmount.minorUnits,
          equals(BigInt.from(80000)),
        ); // GH₵ 800.00
        expect(ureaTracking.spentPercentage, closeTo(60.0, 0.01));
        expect(ureaTracking.transactionCount, equals(2));
        expect(ureaTracking.isOverBudget, isFalse);

        // NPK Line Item Tracking (0 spent)
        final npkTracking = fertTracking.items.firstWhere(
          (i) => i.item.id == 'b-item-npk',
        );
        expect(npkTracking.actualSpent.minorUnits, equals(BigInt.zero));
        expect(npkTracking.spentPercentage, equals(0.0));
        expect(npkTracking.transactionCount, equals(0));

        // 3. Labour Category Tracking
        final labourTracking = tracking.categories.firstWhere(
          (c) => c.category.id == 'cat-labour',
        );
        expect(
          labourTracking.plannedAmount.minorUnits,
          equals(BigInt.from(80000)),
        );
        expect(
          labourTracking.actualSpent.minorUnits,
          equals(BigInt.from(50000)),
        );
        expect(labourTracking.spentPercentage, closeTo(62.5, 0.01));
      },
    );

    test(
      'Strictly excludes voided and deleted transactions from actual expenditure',
      () {
        final expenses = [
          createExpense(
            id: 'exp-valid',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor: 50000, // GH₵ 500.00
          ),
          // Voided expense
          createExpense(
            id: 'exp-voided',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor: 100000,
            isVoided: true,
          ),
          // Deleted expense
          createExpense(
            id: 'exp-deleted',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor: 75000,
            isDeleted: true,
          ),
        ];

        final tracking = ProjectBudgetTracking.compute(
          projectId: testProjectId,
          currency: currency,
          budgetItems: budgetItems,
          allCategories: allCategories,
          expenses: expenses,
        );

        final fertTracking = tracking.categories.firstWhere(
          (c) => c.category.id == 'cat-fertilizer',
        );
        final ureaTracking = fertTracking.items.firstWhere(
          (i) => i.item.id == 'b-item-urea',
        );

        // Only exp-valid (500.00) should be counted
        expect(ureaTracking.actualSpent.minorUnits, equals(BigInt.from(50000)));
        expect(fertTracking.actualSpent.minorUnits, equals(BigInt.from(50000)));
        expect(tracking.totalSpent.minorUnits, equals(BigInt.from(50000)));
        expect(ureaTracking.transactionCount, equals(1));
      },
    );

    test(
      'Identifies over-budget overrun when actual spent exceeds planned',
      () {
        final expenses = [
          createExpense(
            id: 'exp-overrun',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor:
                250000, // GH₵ 2,500.00 spent against GH₵ 2,000.00 planned
          ),
        ];

        final tracking = ProjectBudgetTracking.compute(
          projectId: testProjectId,
          currency: currency,
          budgetItems: budgetItems,
          allCategories: allCategories,
          expenses: expenses,
        );

        final fertTracking = tracking.categories.firstWhere(
          (c) => c.category.id == 'cat-fertilizer',
        );
        final ureaTracking = fertTracking.items.firstWhere(
          (i) => i.item.id == 'b-item-urea',
        );

        expect(ureaTracking.isOverBudget, isTrue);
        expect(ureaTracking.spentPercentage, equals(125.0));
        // Remaining is negative: -500.00
        expect(ureaTracking.remainingAmount.isNegative, isTrue);
        expect(
          ureaTracking.remainingAmount.minorUnits,
          equals(BigInt.from(-50000)),
        );
      },
    );

    test(
      'Tracks unlinked category expenditures not tied to specific budget line items',
      () {
        final expenses = [
          // Linked to Urea
          createExpense(
            id: 'exp-urea',
            categoryId: 'cat-fertilizer',
            budgetItemId: 'b-item-urea',
            amountMinor: 60000,
          ),
          // General fertilizer purchase not linked to any item
          createExpense(
            id: 'exp-unlinked',
            categoryId: 'cat-fertilizer',
            budgetItemId: null,
            amountMinor: 30000,
          ),
        ];

        final tracking = ProjectBudgetTracking.compute(
          projectId: testProjectId,
          currency: currency,
          budgetItems: budgetItems,
          allCategories: allCategories,
          expenses: expenses,
        );

        final fertTracking = tracking.categories.firstWhere(
          (c) => c.category.id == 'cat-fertilizer',
        );
        expect(fertTracking.actualSpent.minorUnits, equals(BigInt.from(90000)));
        expect(
          fertTracking.unlinkedSpent.minorUnits,
          equals(BigInt.from(30000)),
        );
      },
    );

    test(
      'Handles unplanned categories with expenses but no pre-season items',
      () {
        final expenses = [
          // Expense in Transport category (no planned budget items created)
          createExpense(
            id: 'exp-haulage',
            categoryId: 'cat-transport',
            amountMinor: 45000, // GH₵ 450.00
          ),
        ];

        final tracking = ProjectBudgetTracking.compute(
          projectId: testProjectId,
          currency: currency,
          budgetItems: budgetItems,
          allCategories: allCategories,
          expenses: expenses,
        );

        final transportTracking = tracking.categories.firstWhere(
          (c) => c.category.id == 'cat-transport',
        );
        expect(transportTracking.plannedAmount.minorUnits, equals(BigInt.zero));
        expect(
          transportTracking.actualSpent.minorUnits,
          equals(BigInt.from(45000)),
        );
        expect(transportTracking.isOverBudget, isTrue);
        expect(transportTracking.items, isEmpty);
      },
    );
  });
}
