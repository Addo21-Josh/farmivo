import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ActivityRepositoryImpl repository;
  const testFarmId = 'farm-uuid-act';
  const testProjectId = 'project-uuid-act';
  late String testLabourCategoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ActivityRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Ejura Agro Enterprise',
            location: 'Ejura, Ashanti Region',
            region: 'Ashanti',
            totalArea: 40.0,
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
            name: 'Maize Season 2026',
            projectType: 'CROP',
            commodity: 'Maize',
            landSize: 10.0,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Find or seed Labour Category
    final existingCategories = await db.select(db.budgetCategoriesTable).get();
    final labourCategory = existingCategories
        .cast<BudgetCategory?>()
        .firstWhere(
          (c) => c != null && c.name.toLowerCase().contains('labour'),
          orElse: () => null,
        );

    if (labourCategory != null) {
      testLabourCategoryId = labourCategory.id;
    } else {
      testLabourCategoryId = 'cat-labour-seed';
      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: testLabourCategoryId,
              name: 'Labour (Field Operations)',
              description: const Value('Casual wages for operations'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  group('ActivityRepository - Validations', () {
    test('Throws ValidationFailure when title is empty', () async {
      expect(
        () => repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.landPreparation,
          title: '   ',
          activityDate: DateTime.now(),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when cost is negative', () async {
      expect(
        () => repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.weeding,
          title: 'Manual Weeding',
          activityDate: DateTime.now(),
          costMinor: -1500,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when labourCount is negative', () async {
      expect(
        () => repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.planting,
          title: 'Direct Sowing',
          activityDate: DateTime.now(),
          labourCount: -3,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when durationHours is <= 0', () async {
      expect(
        () => repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.fertilizing,
          title: 'Urea Top Dressing',
          activityDate: DateTime.now(),
          durationHours: 0,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when projectId does not exist', () async {
      expect(
        () => repository.recordActivity(
          projectId: 'nonexistent-project-id',
          activityType: ActivityType.maintenance,
          title: 'Fence Repair',
          activityDate: DateTime.now(),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('ActivityRepository - CRUD and Expense Linking', () {
    test('Records activity without expense linking', () async {
      final now = DateTime.now();
      final id = await repository.recordActivity(
        projectId: testProjectId,
        activityType: ActivityType.landPreparation,
        title: 'Tractor Ploughing 1st Pass',
        activityDate: now,
        description: 'Deep ploughing after initial rains',
        labourCount: 2,
        durationHours: 5.5,
        costMinor: 35000, // GH₵ 350.00
        status: ActivityStatus.completed,
        notes: 'Moist red soil conditions',
        createLinkedExpense: false,
      );

      final retrieved = await repository.getActivityById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Tractor Ploughing 1st Pass'));
      expect(retrieved.type, equals(ActivityType.landPreparation));
      expect(retrieved.labourCount, equals(2));
      expect(retrieved.durationHours, equals(5.5));
      expect(retrieved.formattedDuration, equals('5.5 hrs'));
      expect(retrieved.costMinor, equals(35000));
      expect(retrieved.cost.toMajor(), equals(350.0));
      expect(retrieved.status, equals(ActivityStatus.completed));
      expect(retrieved.hasLabour, isTrue);
      expect(retrieved.hasLinkedExpense, isFalse);

      // Verify no expense was created in database
      final expenses = await db.select(db.expensesTable).get();
      expect(expenses, isEmpty);
    });

    test(
      'Records activity WITH auto-generated linked financial expense',
      () async {
        final now = DateTime.now();
        final id = await repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.weeding,
          title: 'First Hand Weeding Campaign',
          activityDate: now,
          labourCount: 6,
          durationHours: 8.0,
          costMinor: 60000, // GH₵ 600.00
          createLinkedExpense: true,
          expensePaymentMethod: PaymentMethod.mtnMoMo,
        );

        // Verify Activity
        final retrieved = await repository.getActivityById(id);
        expect(retrieved, isNotNull);
        expect(retrieved!.hasLinkedExpense, isTrue);
        expect(retrieved.linkedExpense, isNotNull);
        expect(retrieved.linkedExpense!.amountMinor, equals(60000));
        expect(retrieved.linkedExpense!.paymentMethod, equals('MOMO_MTN'));
        expect(
          retrieved.linkedExpense!.description,
          equals('Labour: First Hand Weeding Campaign'),
        );
        expect(retrieved.linkedExpense!.activityId, equals(id));
        expect(
          retrieved.linkedExpense!.categoryId,
          equals(testLabourCategoryId),
        );

        // Verify stream contains the linked detail
        final activitiesList = await repository
            .watchActivities(projectId: testProjectId)
            .first;
        expect(activitiesList.length, equals(1));
        expect(activitiesList.first.hasLinkedExpense, isTrue);
      },
    );

    test(
      'Updates activity and automatically syncs linked expense amount and date',
      () async {
        final now = DateTime.now();
        final id = await repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.spraying,
          title: 'Selective Herbicide Spray',
          activityDate: now,
          labourCount: 2,
          costMinor: 20000,
          createLinkedExpense: true,
          expensePaymentMethod: PaymentMethod.cash,
        );

        final newDate = now.add(const Duration(days: 1));
        await repository.updateActivity(
          id: id,
          projectId: testProjectId,
          activityType: ActivityType.spraying,
          title: 'Selective Herbicide Spray - Adjusted',
          activityDate: newDate,
          labourCount: 3,
          durationHours: 4.0,
          costMinor: 25000, // Adjusted cost
          status: ActivityStatus.completed,
        );

        final updated = await repository.getActivityById(id);
        expect(updated, isNotNull);
        expect(updated!.title, equals('Selective Herbicide Spray - Adjusted'));
        expect(updated.costMinor, equals(25000));
        expect(updated.labourCount, equals(3));
        expect(updated.durationHours, equals(4.0));

        // Linked expense should reflect the adjusted cost and date
        expect(updated.linkedExpense, isNotNull);
        expect(updated.linkedExpense!.amountMinor, equals(25000));
        expect(
          updated.linkedExpense!.description,
          equals('Labour: Selective Herbicide Spray - Adjusted'),
        );
        expect(
          updated.linkedExpense!.transactionDate,
          equals(newDate.millisecondsSinceEpoch),
        );
      },
    );

    test('Deletes activity and optionally deletes linked expense', () async {
      final now = DateTime.now();
      final id = await repository.recordActivity(
        projectId: testProjectId,
        activityType: ActivityType.fertilizing,
        title: 'NPK Application',
        activityDate: now,
        costMinor: 15000,
        createLinkedExpense: true,
      );

      // Verify it exists
      expect(await repository.getActivityById(id), isNotNull);

      // Delete with deleteLinkedExpense = true
      await repository.deleteActivity(id, deleteLinkedExpense: true);

      // Activity should no longer appear in query
      expect(await repository.getActivityById(id), isNull);

      // Linked expense should also be soft deleted
      final expenseInDb =
          await (db.select(db.expensesTable)..where(
                (e) => e.activityId.equals(id) & e.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      expect(expenseInDb, isNull);
    });

    test(
      'getSuggestedTitles aggregates type suggestions with saved titles',
      () async {
        await repository.recordActivity(
          projectId: testProjectId,
          activityType: ActivityType.planting,
          title: 'Pioneer 30Y87 Hybrid Planting',
          activityDate: DateTime.now(),
        );

        final suggestions = await repository.getSuggestedTitles(
          ActivityType.planting,
        );
        expect(suggestions, contains('Pioneer 30Y87 Hybrid Planting'));
        expect(suggestions, contains('Direct Seed Sowing'));
      },
    );
  });
}
