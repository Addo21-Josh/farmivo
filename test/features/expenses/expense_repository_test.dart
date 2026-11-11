import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepositoryImpl repository;
  const testFarmId = 'farm-uuid-1';
  const testProjectId = 'project-uuid-1';
  late String testCategoryId;
  late String testBudgetItemId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ExpenseRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Ejura Maize Enterprise',
            location: 'Ejura, Ashanti Region',
            region: 'Ashanti',
            totalArea: 50.0,
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
            name: 'Major Season Maize 2026',
            projectType: 'CROP',
            commodity: 'Maize',
            landSize: 20.0,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Get seeded category
    final categories = await db.select(db.budgetCategoriesTable).get();
    testCategoryId = categories.first.id;

    // Seed a budget item
    testBudgetItemId = 'budget-item-uuid-1';
    await db
        .into(db.budgetItemsTable)
        .insert(
          BudgetItemsTableCompanion.insert(
            id: testBudgetItemId,
            projectId: testProjectId,
            categoryId: testCategoryId,
            name: 'Urea Fertilizer 50kg Bags',
            quantity: 10.0,
            unit: 'Bags',
            unitCostMinor: 40000,
            plannedAmountMinor: 400000,
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('ExpenseRepository - Validations', () {
    test('Throws ValidationFailure when amount is zero or negative', () async {
      expect(
        () => repository.recordExpense(
          projectId: testProjectId,
          categoryId: testCategoryId,
          transactionDate: DateTime.now(),
          description: 'Fertilizer Purchase',
          amountMinor: 0,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(
        () => repository.recordExpense(
          projectId: testProjectId,
          categoryId: testCategoryId,
          transactionDate: DateTime.now(),
          description: 'Fertilizer Purchase',
          amountMinor: -5000,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when description is blank', () async {
      expect(
        () => repository.recordExpense(
          projectId: testProjectId,
          categoryId: testCategoryId,
          transactionDate: DateTime.now(),
          description: '   ',
          amountMinor: 10000,
          paymentMethod: PaymentMethod.mtnMoMo,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test(
      'Throws ValidationFailure when projectId or categoryId is empty',
      () async {
        expect(
          () => repository.recordExpense(
            projectId: '   ',
            categoryId: testCategoryId,
            transactionDate: DateTime.now(),
            description: 'Chemicals',
            amountMinor: 10000,
            paymentMethod: PaymentMethod.telecelCash,
          ),
          throwsA(isA<ValidationFailure>()),
        );

        expect(
          () => repository.recordExpense(
            projectId: testProjectId,
            categoryId: '   ',
            transactionDate: DateTime.now(),
            description: 'Chemicals',
            amountMinor: 10000,
            paymentMethod: PaymentMethod.telecelCash,
          ),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );
  });

  group('ExpenseRepository - Core Operations', () {
    test(
      'Successfully records expense with full details and linking',
      () async {
        final date = DateTime.now();
        final expenseId = await repository.recordExpense(
          projectId: testProjectId,
          categoryId: testCategoryId,
          budgetItemId: testBudgetItemId,
          transactionDate: date,
          description: 'Bought 5 bags of Urea',
          quantity: 5.0,
          unit: 'Bags',
          unitCostMinor: 40000,
          amountMinor: 200000, // 2,000.00 GHS in pesewas
          currency: 'GHS',
          paymentMethod: PaymentMethod.mtnMoMo,
          vendorName: 'Agricare Inputs Ltd',
          receiptPhotoPath: '/app/documents/receipts/receipt_001.jpg',
          notes: 'Delivered directly to farm gate',
        );

        expect(expenseId, isNotEmpty);

        final retrieved = await repository.getExpenseById(expenseId);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(expenseId));
        expect(retrieved.description, equals('Bought 5 bags of Urea'));
        expect(retrieved.amount.minorUnits, equals(BigInt.from(200000)));
        expect(retrieved.amount.format(), equals('GH₵ 2,000.00'));
        expect(retrieved.paymentMethod, equals(PaymentMethod.mtnMoMo));
        expect(retrieved.vendorName, equals('Agricare Inputs Ltd'));
        expect(
          retrieved.receiptPhotoPath,
          equals('/app/documents/receipts/receipt_001.jpg'),
        );
        expect(retrieved.hasReceipt, isTrue);
        expect(retrieved.category.id, equals(testCategoryId));
        expect(retrieved.project?.id, equals(testProjectId));
        expect(retrieved.budgetItem?.id, equals(testBudgetItemId));
        expect(retrieved.isVoided, isFalse);
      },
    );

    test(
      'Soft voids an expense with audit reason and preserves record',
      () async {
        final expenseId = await repository.recordExpense(
          projectId: testProjectId,
          categoryId: testCategoryId,
          transactionDate: DateTime.now(),
          description: 'Wrong labour wage entry',
          amountMinor: 15000,
          paymentMethod: PaymentMethod.cash,
        );

        // Void the transaction
        await repository.voidExpense(
          id: expenseId,
          reason: 'Duplicate payment record submitted by mistake',
        );

        final voided = await repository.getExpenseById(expenseId);
        expect(voided, isNotNull);
        expect(voided!.isVoided, isTrue);
        expect(
          voided.voidReason,
          equals('Duplicate payment record submitted by mistake'),
        );
        expect(voided.voidedAt, isNotNull);

        // Attempting to re-void throws ValidationFailure
        expect(
          () => repository.voidExpense(id: expenseId, reason: 'Again'),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test('getFrequentVendors returns distinct vendor names', () async {
      await repository.recordExpense(
        projectId: testProjectId,
        categoryId: testCategoryId,
        transactionDate: DateTime.now(),
        description: 'Seeds',
        amountMinor: 5000,
        paymentMethod: PaymentMethod.cash,
        vendorName: 'Kumasi Seed Depot',
      );

      await repository.recordExpense(
        projectId: testProjectId,
        categoryId: testCategoryId,
        transactionDate: DateTime.now(),
        description: 'Herbicide',
        amountMinor: 8000,
        paymentMethod: PaymentMethod.mtnMoMo,
        vendorName: 'Agricare Inputs Ltd',
      );

      await repository.recordExpense(
        projectId: testProjectId,
        categoryId: testCategoryId,
        transactionDate: DateTime.now(),
        description: 'More Seeds',
        amountMinor: 7000,
        paymentMethod: PaymentMethod.cash,
        vendorName: 'Kumasi Seed Depot', // Duplicate
      );

      final vendors = await repository.getFrequentVendors();
      expect(
        vendors,
        containsAll(['Kumasi Seed Depot', 'Agricare Inputs Ltd']),
      );
      expect(vendors.where((v) => v == 'Kumasi Seed Depot').length, equals(1));
    });

    test('watchExpensesByProject streams ordered project expenses', () async {
      final now = DateTime.now();

      await repository.recordExpense(
        projectId: testProjectId,
        categoryId: testCategoryId,
        transactionDate: now.subtract(const Duration(days: 2)),
        description: 'First Expense (2 days ago)',
        amountMinor: 3000,
        paymentMethod: PaymentMethod.cash,
      );

      await repository.recordExpense(
        projectId: testProjectId,
        categoryId: testCategoryId,
        transactionDate: now,
        description: 'Second Expense (Today)',
        amountMinor: 5000,
        paymentMethod: PaymentMethod.mtnMoMo,
      );

      final streamExpenses = await repository
          .watchExpensesByProject(testProjectId)
          .first;
      expect(streamExpenses.length, equals(2));
      // Ordered descending by date
      expect(
        streamExpenses.first.description,
        equals('Second Expense (Today)'),
      );
      expect(
        streamExpenses.last.description,
        equals('First Expense (2 days ago)'),
      );
    });

    test('deleteExpense soft deletes the expense record', () async {
      final expenseId = await repository.recordExpense(
        projectId: testProjectId,
        categoryId: testCategoryId,
        transactionDate: DateTime.now(),
        description: 'Tractor Service',
        amountMinor: 80000,
        paymentMethod: PaymentMethod.bankTransfer,
      );

      await repository.deleteExpense(expenseId);

      final retrieved = await repository.getExpenseById(expenseId);
      expect(retrieved, isNull);

      final all = await repository.watchExpensesByProject(testProjectId).first;
      expect(all.any((e) => e.id == expenseId), isFalse);
    });
  });
}
