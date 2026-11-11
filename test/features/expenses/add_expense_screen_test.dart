import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_item_with_category.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_category_providers.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_item_providers.dart';
import 'package:farmivo/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:farmivo/features/expenses/presentation/add_expense_screen.dart';
import 'package:farmivo/features/expenses/presentation/providers/expense_providers.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;

void main() {
  late AppDatabase db;
  const testFarmId = 'farm-uuid-1';
  const testProjectId = 'project-uuid-1';

  final testProject = Project(
    id: testProjectId,
    farmId: testFarmId,
    name: 'Major Maize 2026',
    projectType: 'CROP',
    commodity: 'Maize',
    landSize: 15.0,
    landUnit: 'Acres',
    startDate: DateTime.now().millisecondsSinceEpoch,
    currency: 'GHS',
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testCategories = [
    const BudgetCategory(
      id: 'cat-land-prep',
      name: 'Land Preparation',
      description: 'Bush clearing and ploughing',
      iconName: 'agriculture',
      isSystemDefault: true,
      displayOrder: 1,
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
    ),
    const BudgetCategory(
      id: 'cat-seeds',
      name: 'Seeds & Seedlings',
      description: 'Certified seeds',
      iconName: 'grass',
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
      description: 'Soil fertilizers',
      iconName: 'science',
      isSystemDefault: true,
      displayOrder: 3,
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
    ),
  ];

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm in SQLite
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Ejura Farms Enterprise',
            location: 'Ejura, Ashanti Region',
            region: 'Ashanti',
            totalArea: 30.0,
            areaUnit: const Value('Acres'),
            ownershipType: 'Owned',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Project in SQLite
    await db
        .into(db.projectsTable)
        .insert(
          ProjectsTableCompanion.insert(
            id: testProjectId,
            farmId: testFarmId,
            name: 'Major Maize 2026',
            projectType: 'CROP',
            commodity: 'Maize',
            landSize: 15.0,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Categories in SQLite
    for (final cat in testCategories) {
      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: cat.id,
              name: cat.name,
              description: Value(cat.description),
              iconName: Value(cat.iconName),
              isSystemDefault: const Value(true),
              displayOrder: Value(cat.displayOrder),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp({String? initialProjectId}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        projectsStreamProvider.overrideWith(
          (ref) => Stream.value([testProject]),
        ),
        budgetCategoriesStreamProvider.overrideWith(
          (ref) => Stream.value(testCategories),
        ),
        frequentVendorsProvider.overrideWith(
          (ref) async => ['Agricare Inputs'],
        ),
        projectBudgetItemsWithCategoryProvider.overrideWith(
          (ref, arg) => Stream.value(<BudgetItemWithCategory>[]),
        ),
        expenseRepositoryProvider.overrideWithValue(
          ExpenseRepositoryImpl(db: db),
        ),
      ],
      child: MaterialApp(
        home: AddExpenseScreen(initialProjectId: initialProjectId),
      ),
    );
  }

  testWidgets('Renders fast expense entry form with all optimized elements', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(initialProjectId: testProjectId));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Title
    expect(find.text('Record Expense'), findsOneWidget);

    // 2. Pre-selected Project Card
    expect(find.text('Project: Major Maize 2026'), findsOneWidget);

    // 3. Prominent Amount Field with GH₵
    expect(find.text('EXPENSE AMOUNT *'), findsOneWidget);
    expect(find.text('GH₵'), findsOneWidget);

    // 4. Budget Category Selector Chips
    expect(find.text('Budget Category *'), findsOneWidget);
    expect(find.text('Land Preparation'), findsOneWidget);
    expect(find.text('Seeds & Seedlings'), findsOneWidget);
    expect(find.text('Fertilizers & Nutrients'), findsOneWidget);

    // 5. West African Payment Methods
    expect(find.text('Payment Method *'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('MTN MoMo'), findsOneWidget);
    expect(find.text('Telecel Cash'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);
    expect(find.text('Credit / Due'), findsOneWidget);

    // 6. Vendor & Receipt sections
    expect(find.text('Vendor / Merchant (Optional)'), findsOneWidget);
    expect(find.text('Receipt Photo (Optional)'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('From Gallery'), findsOneWidget);

    // 7. Large Save Button
    expect(find.text('Save Expense'), findsOneWidget);
  });

  testWidgets('Validates required fields on submission', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(initialProjectId: testProjectId));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Save button without entering amount or description
    await tester.tap(find.text('Save Expense'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Enter amount'), findsOneWidget);
    expect(find.text('Please describe the expense.'), findsOneWidget);
  });

  testWidgets('Successfully completes fast expense entry flow in record time', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(initialProjectId: testProjectId));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Enter Amount: "350.50"
    final amountFinder = find.widgetWithText(TextFormField, '0.00');
    await tester.enterText(amountFinder, '350.50');
    await tester.pump();

    // 2. Select Category: "Fertilizers & Nutrients"
    await tester.tap(find.text('Fertilizers & Nutrients'));
    await tester.pump();

    // 3. Enter Description: "2 bags of NPK fertilizer"
    final descFinder = find.widgetWithText(
      TextFormField,
      'e.g., 2 bags of NPK, casual labour weeding',
    );
    await tester.enterText(descFinder, '2 bags of NPK fertilizer');
    await tester.pump();

    // 4. Select Payment Method: "MTN MoMo"
    await tester.tap(find.text('MTN MoMo'));
    await tester.pump();

    // 5. Enter Vendor: "Agricare Inputs"
    final vendorFinder = find.widgetWithText(
      TextFormField,
      'e.g. Agricare Inputs, Kumasi Depot',
    );
    await tester.enterText(vendorFinder, 'Agricare Inputs');
    await tester.pump();

    // 6. Submit Expense
    await tester.tap(find.text('Save Expense'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify expense record was persisted to database
    final recordedExpenses = await db.select(db.expensesTable).get();
    expect(recordedExpenses.length, equals(1));

    final exp = recordedExpenses.first;
    expect(exp.projectId, equals(testProjectId));
    expect(exp.description, equals('2 bags of NPK fertilizer'));
    expect(exp.amountMinor, equals(35050)); // 350.50 GHS = 35050 pesewas
    expect(exp.paymentMethod, equals('MOMO_MTN'));
    expect(exp.vendorName, equals('Agricare Inputs'));
    expect(exp.isVoided, isFalse);
  });
}
