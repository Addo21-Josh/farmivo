import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'package:farmivo/data/database/app_database.dart';

void main() {
  late AppDatabase db;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift AppDatabase Initialization & Seed Tests', () {
    test(
      'Database creates tables and seeds default budget categories',
      () async {
        final categories = await db.select(db.budgetCategoriesTable).get();

        // Verify that default agricultural categories were seeded
        expect(categories.isNotEmpty, isTrue);
        expect(categories.length, 13);

        final categoryNames = categories.map((c) => c.name).toList();
        expect(categoryNames.contains('Land Preparation'), isTrue);
        expect(categoryNames.contains('Fertilizers & Nutrients'), isTrue);
        expect(categoryNames.contains('Seeds & Seedlings'), isTrue);
      },
    );
  });

  group('Relational Integrity & Foreign Keys', () {
    test('Inserts a Farm and a Project linked to that Farm', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final farmId = uuid.v4();
      final projectId = uuid.v4();

      // 1. Insert Farm
      await db
          .into(db.farmsTable)
          .insert(
            FarmsTableCompanion.insert(
              id: farmId,
              name: 'Juaboso Valley Farm',
              location: 'Juaboso, Western North',
              region: 'Western North',
              totalArea: 25.0,
              ownershipType: 'Family Land',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final farms = await db.select(db.farmsTable).get();
      expect(farms.length, 1);
      expect(farms.first.name, 'Juaboso Valley Farm');

      // 2. Insert Project
      await db
          .into(db.projectsTable)
          .insert(
            ProjectsTableCompanion.insert(
              id: projectId,
              farmId: farmId,
              name: '2-Acre Pepper Farm',
              projectType: 'Crop',
              commodity: 'Pepper',
              variety: const Value('Shito Pepper'),
              landSize: 2.0,
              startDate: now,
              status: const Value('ACTIVE'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final projects = await db.select(db.projectsTable).get();
      expect(projects.length, 1);
      expect(projects.first.commodity, 'Pepper');
      expect(projects.first.farmId, farmId);
    });

    test(
      'Foreign key constraint restricts inserting project with non-existent farm',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        expect(
          () async => await db
              .into(db.projectsTable)
              .insert(
                ProjectsTableCompanion.insert(
                  id: uuid.v4(),
                  farmId: 'non-existent-farm-id',
                  name: 'Invalid Project',
                  projectType: 'Crop',
                  commodity: 'Maize',
                  landSize: 1.0,
                  startDate: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('Financial Transactions & Soft Voiding', () {
    test(
      'Records expense and performs soft-voiding preserving audit history',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final farmId = uuid.v4();
        final projectId = uuid.v4();
        final categoryId = uuid.v4();
        final expenseId = uuid.v4();

        // Setup dependencies
        await db
            .into(db.farmsTable)
            .insert(
              FarmsTableCompanion.insert(
                id: farmId,
                name: 'Test Farm',
                location: 'Accra',
                region: 'Greater Accra',
                totalArea: 5.0,
                ownershipType: 'Owned',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: projectId,
                farmId: farmId,
                name: 'Test Project',
                projectType: 'Crop',
                commodity: 'Tomato',
                landSize: 1.0,
                startDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.budgetCategoriesTable)
            .insert(
              BudgetCategoriesTableCompanion.insert(
                id: categoryId,
                name: 'Fertilizers',
                createdAt: now,
                updatedAt: now,
              ),
            );

        // 1. Record expense of GH₵ 1,200.00 (120,000 pesewas)
        await db
            .into(db.expensesTable)
            .insert(
              ExpensesTableCompanion.insert(
                id: expenseId,
                projectId: projectId,
                categoryId: categoryId,
                transactionDate: now,
                description: '2 Bags NPK 15:15:15',
                amountMinor: 120000,
                paymentMethod: 'MOMO',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final activeExpenses = await (db.select(
          db.expensesTable,
        )..where((tbl) => tbl.isVoided.equals(false))).get();
        expect(activeExpenses.length, 1);
        expect(activeExpenses.first.amountMinor, 120000);

        // 2. Soft-void the expense
        final voidTimestamp = DateTime.now().millisecondsSinceEpoch;
        await (db.update(
          db.expensesTable,
        )..where((tbl) => tbl.id.equals(expenseId))).write(
          ExpensesTableCompanion(
            isVoided: const Value(true),
            voidedAt: Value(voidTimestamp),
            voidReason: const Value('Duplicate entry recorded by error'),
            updatedAt: Value(voidTimestamp),
          ),
        );

        // Verify active query excludes the voided expense
        final remainingActive = await (db.select(
          db.expensesTable,
        )..where((tbl) => tbl.isVoided.equals(false))).get();
        expect(remainingActive.isEmpty, isTrue);

        // Verify record still exists in database for forensic audit
        final allExpenses = await db.select(db.expensesTable).get();
        expect(allExpenses.length, 1);
        expect(allExpenses.first.isVoided, isTrue);
        expect(
          allExpenses.first.voidReason,
          'Duplicate entry recorded by error',
        );
      },
    );
  });
}
