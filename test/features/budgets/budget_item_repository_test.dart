import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/data/repositories/budget_item_repository_impl.dart';

void main() {
  late AppDatabase db;
  late BudgetItemRepositoryImpl repository;
  const testFarmId = 'farm-uuid-1';
  const testProjectId = 'project-uuid-1';
  late String seedCategoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BudgetItemRepositoryImpl(db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Asante Agribusiness Farm',
            location: 'Ejura, Ashanti Region',
            region: 'Ashanti',
            totalArea: 25.0,
            areaUnit: const Value('Acres'),
            ownershipType: 'Owned',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Project
    await db
        .into(db.projectsTable)
        .insert(
          ProjectsTableCompanion.insert(
            id: testProjectId,
            farmId: testFarmId,
            name: 'Major Maize Season 2026',
            projectType: 'CROP',
            commodity: 'Maize',
            landSize: 10.0,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Get an existing seeded standard category ID
    final categories = await (db.select(
      db.budgetCategoriesTable,
    )..where((tbl) => tbl.isDeleted.equals(false))).get();
    seedCategoryId = categories.first.id;
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetItemRepository Unit Tests', () {
    test(
      'Creates budget item and computes Planned Amount = Quantity * Unit Cost in minor units',
      () async {
        // 10 bags of seed @ GH₵ 250.00 each = 25000 pesewas unit cost -> 250000 pesewas total
        final item = await repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Hybrid White Maize Seed (Pannar 53)',
          quantity: 10.0,
          unit: 'Bags',
          unitCostMinor: 25000, // GH₵ 250.00
          currency: 'GHS',
          description: 'High-yielding drought-tolerant hybrid',
        );

        expect(item.id, isNotEmpty);
        expect(item.projectId, testProjectId);
        expect(item.categoryId, seedCategoryId);
        expect(item.name, 'Hybrid White Maize Seed (Pannar 53)');
        expect(item.quantity, 10.0);
        expect(item.unit, 'Bags');
        expect(item.unitCostMinor, 25000);
        expect(item.plannedAmountMinor, 250000); // 10 * 25000
        expect(item.status, 'PLANNED');
      },
    );

    test('Accurately handles fractional quantities in minor units', () async {
      // 2.5 acres of tractor ploughing @ GH₵ 180.00 = 18000 pesewas -> 45000 pesewas total
      final item = await repository.createBudgetItem(
        projectId: testProjectId,
        categoryId: seedCategoryId,
        name: 'Tractor Disc Ploughing',
        quantity: 2.5,
        unit: 'Acres',
        unitCostMinor: 18000,
      );

      expect(item.quantity, 2.5);
      expect(item.plannedAmountMinor, 45000); // 2.5 * 18000 = 45000
    });

    test('Throws ValidationFailure when quantity <= 0', () async {
      await expectLater(
        repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Invalid Item',
          quantity: 0.0,
          unit: 'Kg',
          unitCostMinor: 5000,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      await expectLater(
        repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Negative Quantity Item',
          quantity: -3.0,
          unit: 'Kg',
          unitCostMinor: 5000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when unitCostMinor < 0', () async {
      await expectLater(
        repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Negative Cost Item',
          quantity: 5.0,
          unit: 'Bags',
          unitCostMinor: -100,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when item name or unit is empty', () async {
      await expectLater(
        repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: '   ',
          quantity: 5.0,
          unit: 'Bags',
          unitCostMinor: 1000,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      await expectLater(
        repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Valid Name',
          quantity: 5.0,
          unit: '  ',
          unitCostMinor: 1000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Updates budget item and recomputes planned amount', () async {
      final item = await repository.createBudgetItem(
        projectId: testProjectId,
        categoryId: seedCategoryId,
        name: 'NPK 15:15:15 Fertilizer',
        quantity: 5.0,
        unit: 'Bags',
        unitCostMinor: 40000, // GH₵ 400.00 -> 200000 planned
      );
      expect(item.plannedAmountMinor, 200000);

      // Increase quantity to 8 bags and price increases to GH₵ 420.00
      await repository.updateBudgetItem(
        id: item.id,
        quantity: 8.0,
        unitCostMinor: 42000,
      );

      final updated = await repository.getById(item.id);
      expect(updated, isNotNull);
      expect(updated!.quantity, 8.0);
      expect(updated.unitCostMinor, 42000);
      expect(updated.plannedAmountMinor, 336000); // 8 * 42000 = 336000
    });

    test(
      'Prevents deletion if recorded expenses are linked to the budget item',
      () async {
        final item = await repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Knapsack Sprayer',
          quantity: 2.0,
          unit: 'Pieces',
          unitCostMinor: 35000,
        );

        final now = DateTime.now().millisecondsSinceEpoch;
        // Record an active expense linked to this budget item
        await db
            .into(db.expensesTable)
            .insert(
              ExpensesTableCompanion.insert(
                id: 'expense-1',
                projectId: testProjectId,
                categoryId: seedCategoryId,
                budgetItemId: Value(item.id),
                description: 'Purchased knapsack sprayer from agro-dealer',
                quantity: const Value(2.0),
                amountMinor: 70000,
                paymentMethod: 'CASH',
                transactionDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await expectLater(
          repository.deleteBudgetItem(item.id),
          throwsA(isA<FinancialRuleFailure>()),
        );
      },
    );

    test(
      'Performs clean soft deletion when no linked expenses exist',
      () async {
        final item = await repository.createBudgetItem(
          projectId: testProjectId,
          categoryId: seedCategoryId,
          name: 'Unused Seed Variety',
          quantity: 1.0,
          unit: 'Bags',
          unitCostMinor: 15000,
        );

        await repository.deleteBudgetItem(item.id);

        final fetched = await repository.getById(item.id);
        expect(fetched, isNull);

        final projectItems = await repository.getByProject(testProjectId);
        expect(projectItems.any((i) => i.id == item.id), isFalse);
      },
    );

    test('Queries items joined with category metadata correctly', () async {
      await repository.createBudgetItem(
        projectId: testProjectId,
        categoryId: seedCategoryId,
        name: 'Foliar Fertilizer Boost',
        quantity: 4.0,
        unit: 'Litres',
        unitCostMinor: 8500,
      );

      final itemsWithCat = await repository.getByProjectWithCategory(
        testProjectId,
      );
      expect(itemsWithCat.length, 1);
      expect(itemsWithCat.first.item.name, 'Foliar Fertilizer Boost');
      expect(itemsWithCat.first.category.id, seedCategoryId);
      expect(
        itemsWithCat.first.formulaDisplay,
        '4 Litres @ GH₵ 85.00 = GH₵ 340.00',
      );
    });

    test('Calculates and watches project total planned budget', () async {
      await repository.createBudgetItem(
        projectId: testProjectId,
        categoryId: seedCategoryId,
        name: 'Item 1',
        quantity: 2.0,
        unit: 'Bags',
        unitCostMinor: 10000, // 20000
      );

      await repository.createBudgetItem(
        projectId: testProjectId,
        categoryId: seedCategoryId,
        name: 'Item 2',
        quantity: 3.0,
        unit: 'Bags',
        unitCostMinor: 15000, // 45000
      );

      final total = await repository.getTotalPlannedMinor(testProjectId);
      expect(total, 65000); // 20000 + 45000
    });
  });
}
