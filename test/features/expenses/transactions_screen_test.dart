import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_category_providers.dart';
import 'package:farmivo/features/expenses/domain/models/expense_filter.dart';
import 'package:farmivo/features/expenses/domain/models/expense_with_details.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/expenses/presentation/providers/expense_providers.dart';
import 'package:farmivo/features/expenses/presentation/transactions_screen.dart';
import 'package:farmivo/features/expenses/presentation/widgets/expense_filter_sheet.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';

void main() {
  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Maize Season 2026',
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

  const testCategory = BudgetCategory(
    id: 'cat-1',
    name: 'Inputs & Chemicals',
    isSystemDefault: true,
    displayOrder: 1,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testActiveExpense = ExpenseWithDetails(
    expense: const Expense(
      id: 'exp-1',
      projectId: 'proj-1',
      categoryId: 'cat-1',
      transactionDate: 1773000000000,
      description: 'Urea Fertilizer 50kg',
      vendorName: 'Kumasi Agro Hub',
      quantity: 2.0,
      unit: 'Bags',
      unitCostMinor: 25000,
      amountMinor: 50000, // GH₵ 500.00
      currency: 'GHS',
      paymentMethod: 'CASH',
      isVoided: false,
      isDeleted: false,
      createdAt: 1773000000000,
      updatedAt: 1773000000000,
      isSynced: false,
    ),
    category: testCategory,
    project: testProject,
  );

  final testVoidedExpense = ExpenseWithDetails(
    expense: const Expense(
      id: 'exp-2',
      projectId: 'proj-1',
      categoryId: 'cat-1',
      transactionDate: 1773000000000,
      description: 'Wrong input entry',
      vendorName: 'Kwame Agro',
      quantity: 1.0,
      amountMinor: 10000,
      currency: 'GHS',
      paymentMethod: 'MTN_MOMO',
      isVoided: true,
      voidReason: 'Entered wrong invoice number',
      isDeleted: false,
      createdAt: 1773000000000,
      updatedAt: 1773000000000,
      isSynced: false,
    ),
    category: testCategory,
    project: testProject,
  );

  Widget createWidget({
    ExpenseFilter initialFilter = const ExpenseFilter(),
    List<ExpenseWithDetails> expenses = const [],
    List<Project> projects = const [testProject],
    List<BudgetCategory> categories = const [testCategory],
  }) {
    return ProviderScope(
      overrides: [
        expenseFilterProvider.overrideWith((ref) => initialFilter),
        filteredExpensesProvider.overrideWith((ref) => Stream.value(expenses)),
        projectsStreamProvider.overrideWith((ref) => Stream.value(projects)),
        budgetCategoriesStreamProvider.overrideWith(
          (ref) => Stream.value(categories),
        ),
      ],
      child: const MaterialApp(home: TransactionsScreen()),
    );
  }

  group('TransactionsScreen Widget Tests', () {
    testWidgets(
      'Renders app bar, search bar, and empty state when no expenses exist',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // AppBar title
        expect(find.text('Transactions Ledger'), findsOneWidget);
        expect(find.byIcon(Icons.filter_list), findsOneWidget);

        // Search bar
        expect(find.byType(TextField), findsOneWidget);
        expect(
          find.text('Search description, vendor, or notes...'),
          findsOneWidget,
        );

        // Unfiltered empty state
        expect(find.text('No transactions recorded yet'), findsOneWidget);
        expect(find.text('Record First Expense'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders transaction summary and expense tiles when data is present',
      (tester) async {
        await tester.pumpWidget(
          createWidget(expenses: [testActiveExpense, testVoidedExpense]),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Summary Card
        expect(find.text('Total Active Expenditure'), findsOneWidget);
        expect(find.text('1 active • 1 voided'), findsOneWidget);

        // Expense items
        expect(find.text('Urea Fertilizer 50kg'), findsOneWidget);
        expect(find.text('Wrong input entry'), findsOneWidget);
      },
    );

    testWidgets(
      'Shows filtered empty state with Reset button when filters yield 0 items',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            initialFilter: const ExpenseFilter(searchQuery: 'Nonexistent'),
            expenses: const [],
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('No transactions match your filters'), findsOneWidget);
        expect(find.text('Reset All Filters'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      },
    );

    testWidgets(
      'Displays active filter chips and allows clearing them individually',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = ProviderContainer(
          overrides: [
            expenseFilterProvider.overrideWith(
              (ref) => const ExpenseFilter(
                status: ExpenseStatusFilter.activeOnly,
                projectId: 'proj-1',
                categoryId: 'cat-1',
                paymentMethod: PaymentMethod.cash,
              ),
            ),
            filteredExpensesProvider.overrideWith(
              (ref) => Stream.value([testActiveExpense]),
            ),
            projectsStreamProvider.overrideWith(
              (ref) => Stream.value([testProject]),
            ),
            budgetCategoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: TransactionsScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Filter badge count (4 filters active)
        expect(find.text('4'), findsOneWidget);

        // Verify active chips
        expect(find.widgetWithText(Chip, 'Status: Active'), findsOneWidget);
        expect(
          find.widgetWithText(Chip, 'Project: Maize Season 2026'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(Chip, 'Category: Inputs & Chemicals'),
          findsOneWidget,
        );
        expect(find.widgetWithText(Chip, 'Cash'), findsOneWidget);
        expect(find.widgetWithText(ActionChip, 'Clear All'), findsOneWidget);

        // Tapping "Clear All"
        await tester.tap(find.widgetWithText(ActionChip, 'Clear All'));
        await tester.pump();

        expect(container.read(expenseFilterProvider).hasActiveFilters, isFalse);
      },
    );

    testWidgets(
      'Tapping individual chip delete icon removes that filter criterion',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final container = ProviderContainer(
          overrides: [
            expenseFilterProvider.overrideWith(
              (ref) => const ExpenseFilter(
                status: ExpenseStatusFilter.activeOnly,
                projectId: 'proj-1',
              ),
            ),
            filteredExpensesProvider.overrideWith(
              (ref) => Stream.value([testActiveExpense]),
            ),
            projectsStreamProvider.overrideWith(
              (ref) => Stream.value([testProject]),
            ),
            budgetCategoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: TransactionsScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Find delete icon on Project chip (using Icons.close)
        final chipDeleteIcons = find.byIcon(Icons.close);
        expect(chipDeleteIcons, findsWidgets);

        // Delete project chip (second active chip)
        await tester.tap(chipDeleteIcons.at(1));
        await tester.pump();

        expect(container.read(expenseFilterProvider).projectId, isNull);
        expect(
          container.read(expenseFilterProvider).status,
          equals(ExpenseStatusFilter.activeOnly),
        );
      },
    );

    testWidgets('Typing into search field updates expenseFilterProvider', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          expenseFilterProvider.overrideWith((ref) => const ExpenseFilter()),
          filteredExpensesProvider.overrideWith(
            (ref) => Stream.value([testActiveExpense]),
          ),
          projectsStreamProvider.overrideWith(
            (ref) => Stream.value([testProject]),
          ),
          budgetCategoriesStreamProvider.overrideWith(
            (ref) => Stream.value([testCategory]),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TransactionsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'fertilizer');
      await tester.pump();

      expect(
        container.read(expenseFilterProvider).searchQuery,
        equals('fertilizer'),
      );

      // Tapping clear search icon
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(container.read(expenseFilterProvider).searchQuery, isNull);
    });

    testWidgets('Tapping filter icon opens ExpenseFilterSheet modal', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseFilterSheet), findsOneWidget);
      expect(find.text('Filter Transactions'), findsOneWidget);
      expect(find.text('Transaction Status'), findsOneWidget);
      expect(find.text('Farm Project'), findsOneWidget);
      expect(find.text('Budget Category'), findsOneWidget);
      expect(find.text('Payment Channel'), findsOneWidget);
      expect(find.text('Date Range'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });
  });
}
