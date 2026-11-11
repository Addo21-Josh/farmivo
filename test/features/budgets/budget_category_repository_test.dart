import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/data/repositories/budget_category_repository_impl.dart';

void main() {
  late AppDatabase db;
  late BudgetCategoryRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BudgetCategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetCategoryRepository Unit Tests', () {
    test('Seeds 13 standard agricultural categories by default', () async {
      final categories = await repository.getAll();
      expect(categories.length, 13);
      expect(categories.every((c) => c.isSystemDefault), isTrue);

      final names = categories.map((c) => c.name).toList();
      expect(names, contains('Land Preparation'));
      expect(names, contains('Seeds & Seedlings'));
      expect(names, contains('Fertilizers & Nutrients'));
      expect(names, contains('Agro-Chemicals & Spraying'));
      expect(names, contains('Feed & Animal Nutrition'));
      expect(names, contains('Equipment & Machinery'));
      expect(names, contains('Logistics & Transport'));
    });

    test('Prevents deleting system default categories', () async {
      final categories = await repository.getAll();
      final systemCategory = categories.firstWhere((c) => c.isSystemDefault);

      await expectLater(
        repository.delete(systemCategory.id),
        throwsA(isA<FinancialRuleFailure>()),
      );
    });

    test('Creates custom category with unique name validation', () async {
      final custom = await repository.createCustomCategory(
        name: 'Organic Bokashi Compost',
        description: 'Microbial compost inoculated for pepper beds',
        iconName: 'eco',
      );

      expect(custom.id, isNotEmpty);
      expect(custom.name, 'Organic Bokashi Compost');
      expect(custom.isSystemDefault, isFalse);

      final all = await repository.getAll();
      expect(all.length, 14);

      // Attempting to create duplicate (case-insensitive) should throw
      await expectLater(
        repository.createCustomCategory(name: 'organic bokashi compost'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Updates custom category properties cleanly', () async {
      final custom = await repository.createCustomCategory(
        name: 'Solar Pump Hire',
        description: 'Temporary solar pump rental',
        iconName: 'water_drop',
      );

      final updated = custom.copyWith(
        name: 'Solar Irrigation Service',
        description: const Value('Solar pump & drip line hire service'),
      );

      await repository.update(updated);

      final fetched = await repository.getById(custom.id);
      expect(fetched?.name, 'Solar Irrigation Service');
      expect(fetched?.description, 'Solar pump & drip line hire service');
      expect(fetched?.isSystemDefault, isFalse);
    });

    test(
      'Prevents deletion of category if in use by budget items or expenses',
      () async {
        final custom = await repository.createCustomCategory(
          name: 'Trellis Bamboo Stakes',
          description: 'Stakes for staking tomato plants',
        );

        final now = DateTime.now().millisecondsSinceEpoch;

        // Link category to a budget item
        await db
            .into(db.farmsTable)
            .insert(
              FarmsTableCompanion.insert(
                id: 'farm-1',
                name: 'Farm 1',
                location: 'Loc',
                region: 'Ashanti',
                country: const Value('Ghana'),
                totalArea: 5.0,
                areaUnit: const Value('Acres'),
                ownershipType: 'Owned',
                createdAt: now,
                updatedAt: now,
                isSynced: const Value(false),
                isDeleted: const Value(false),
              ),
            );

        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: 'proj-1',
                farmId: 'farm-1',
                name: 'Tomato Venture',
                projectType: 'Crop',
                commodity: 'Tomato',
                landSize: 2.0,
                startDate: now,
                createdAt: now,
                updatedAt: now,
                isSynced: const Value(false),
                isDeleted: const Value(false),
              ),
            );

        await db
            .into(db.budgetItemsTable)
            .insert(
              BudgetItemsTableCompanion.insert(
                id: 'item-1',
                projectId: 'proj-1',
                categoryId: custom.id,
                name: '500 Bamboo Sticks',
                quantity: 500.0,
                unit: 'pcs',
                unitCostMinor: 200,
                plannedAmountMinor: 100000,
                createdAt: now,
                updatedAt: now,
                isSynced: const Value(false),
                isDeleted: const Value(false),
              ),
            );

        expect(await repository.isCategoryInUse(custom.id), isTrue);

        await expectLater(
          repository.delete(custom.id),
          throwsA(isA<FinancialRuleFailure>()),
        );
      },
    );

    test('Deletes custom category when not in use', () async {
      final custom = await repository.createCustomCategory(
        name: 'Unused Test Category',
      );

      expect(await repository.isCategoryInUse(custom.id), isFalse);

      await repository.delete(custom.id);

      final fetched = await repository.getById(custom.id);
      expect(fetched, isNull);

      final all = await repository.getAll();
      expect(all.any((c) => c.id == custom.id), isFalse);
    });
  });
}
