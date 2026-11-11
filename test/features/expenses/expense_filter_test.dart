import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:farmivo/features/expenses/domain/models/expense_filter.dart';
import 'package:farmivo/features/expenses/domain/models/expense_with_details.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseFilter Domain Model Tests', () {
    test('Default filter is empty with no active filters and zero count', () {
      const filter = ExpenseFilter();

      expect(filter.hasActiveFilters, isFalse);
      expect(filter.activeFilterCount, equals(0));
      expect(filter.status, equals(ExpenseStatusFilter.all));
      expect(filter.searchQuery, isNull);
      expect(filter.projectId, isNull);
      expect(filter.categoryId, isNull);
      expect(filter.paymentMethod, isNull);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.minAmountMinor, isNull);
      expect(filter.maxAmountMinor, isNull);
    });

    test('activeFilterCount and hasActiveFilters reflect active criteria', () {
      expect(
        const ExpenseFilter(searchQuery: 'fertilizer').activeFilterCount,
        equals(1),
      );
      expect(const ExpenseFilter(searchQuery: '   ').hasActiveFilters, isFalse);
      expect(const ExpenseFilter(projectId: 'p1').activeFilterCount, equals(1));
      expect(
        const ExpenseFilter(categoryId: 'c1').activeFilterCount,
        equals(1),
      );
      expect(
        const ExpenseFilter(
          paymentMethod: PaymentMethod.mtnMoMo,
        ).activeFilterCount,
        equals(1),
      );
      expect(
        ExpenseFilter(startDate: DateTime(2026, 1, 1)).activeFilterCount,
        equals(1),
      );
      expect(
        ExpenseFilter(endDate: DateTime(2026, 1, 31)).activeFilterCount,
        equals(1),
      );
      expect(
        ExpenseFilter(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        ).activeFilterCount,
        equals(1), // Date range counts as 1 dimension
      );
      expect(
        const ExpenseFilter(minAmountMinor: 1000).activeFilterCount,
        equals(1),
      );
      expect(
        const ExpenseFilter(maxAmountMinor: 5000).activeFilterCount,
        equals(1),
      );
      expect(
        const ExpenseFilter(
          minAmountMinor: 1000,
          maxAmountMinor: 5000,
        ).activeFilterCount,
        equals(1), // Amount range counts as 1 dimension
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.activeOnly,
        ).activeFilterCount,
        equals(1),
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.voidedOnly,
        ).hasActiveFilters,
        isTrue,
      );

      // Combination of all criteria
      final multiFilter = ExpenseFilter(
        searchQuery: 'Seed',
        projectId: 'p1',
        categoryId: 'c1',
        paymentMethod: PaymentMethod.cash,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
        minAmountMinor: 1000,
        maxAmountMinor: 5000,
        status: ExpenseStatusFilter.activeOnly,
      );
      expect(multiFilter.activeFilterCount, equals(7));
      expect(multiFilter.hasActiveFilters, isTrue);
    });

    test('copyWith copies and selectively clears criteria', () {
      final base = ExpenseFilter(
        searchQuery: 'Herbicide',
        projectId: 'proj-1',
        categoryId: 'cat-1',
        paymentMethod: PaymentMethod.telecelCash,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        minAmountMinor: 2000,
        maxAmountMinor: 10000,
        status: ExpenseStatusFilter.activeOnly,
      );

      // Partial update
      final updated = base.copyWith(searchQuery: 'Fungicide');
      expect(updated.searchQuery, equals('Fungicide'));
      expect(updated.projectId, equals('proj-1'));
      expect(updated.status, equals(ExpenseStatusFilter.activeOnly));

      // Selective clears
      final cleared = base.copyWith(
        clearSearch: true,
        clearProject: true,
        clearCategory: true,
        clearPaymentMethod: true,
        clearDates: true,
        clearAmountRange: true,
        status: ExpenseStatusFilter.all,
      );

      expect(cleared.hasActiveFilters, isFalse);
      expect(cleared.activeFilterCount, equals(0));
      expect(cleared.searchQuery, isNull);
      expect(cleared.projectId, isNull);
      expect(cleared.categoryId, isNull);
      expect(cleared.paymentMethod, isNull);
      expect(cleared.startDate, isNull);
      expect(cleared.endDate, isNull);
      expect(cleared.minAmountMinor, isNull);
      expect(cleared.maxAmountMinor, isNull);
      expect(cleared.status, equals(ExpenseStatusFilter.all));
    });

    test(
      'ExpenseStatusFilter displayName renders correct human-readable strings',
      () {
        expect(ExpenseStatusFilter.all.displayName, equals('All'));
        expect(ExpenseStatusFilter.activeOnly.displayName, equals('Active'));
        expect(ExpenseStatusFilter.voidedOnly.displayName, equals('Voided'));
      },
    );

    test('matches correctly evaluates in-memory ExpenseWithDetails', () {
      final now = DateTime(2026, 6, 15, 10, 0);
      final category = BudgetCategory(
        id: 'cat-seeds',
        name: 'Seeds & Planting Material',
        isSystemDefault: true,
        displayOrder: 1,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        isDeleted: false,
        isSynced: false,
      );

      final activeExpense = ExpenseWithDetails(
        expense: Expense(
          id: 'exp-1',
          projectId: 'p-1',
          categoryId: 'cat-seeds',
          transactionDate: now.millisecondsSinceEpoch,
          description: 'Pioneer Hybrid Maize Seed',
          vendorName: 'Kumasi Input Hub',
          quantity: 1.0,
          currency: 'GHS',
          amountMinor: 15000,
          paymentMethod: 'CASH',
          isVoided: false,
          isDeleted: false,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
          isSynced: false,
        ),
        category: category,
      );

      final voidedExpense = ExpenseWithDetails(
        expense: Expense(
          id: 'exp-2',
          projectId: 'p-2',
          categoryId: 'cat-seeds',
          transactionDate: now
              .subtract(const Duration(days: 10))
              .millisecondsSinceEpoch,
          description: 'Fertilizer delivery fee',
          vendorName: 'Kwame Transport',
          quantity: 1.0,
          currency: 'GHS',
          amountMinor: 5000,
          paymentMethod: 'MTN_MOMO',
          isVoided: true,
          voidReason: 'Mistake in log',
          isDeleted: false,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
          isSynced: false,
        ),
        category: category,
      );

      // Status matching
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.all,
        ).matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.all,
        ).matches(voidedExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.activeOnly,
        ).matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.activeOnly,
        ).matches(voidedExpense),
        isFalse,
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.voidedOnly,
        ).matches(activeExpense),
        isFalse,
      );
      expect(
        const ExpenseFilter(
          status: ExpenseStatusFilter.voidedOnly,
        ).matches(voidedExpense),
        isTrue,
      );

      // Project matching
      expect(
        const ExpenseFilter(projectId: 'p-1').matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(projectId: 'p-2').matches(activeExpense),
        isFalse,
      );

      // Category matching
      expect(
        const ExpenseFilter(categoryId: 'cat-seeds').matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(categoryId: 'cat-other').matches(activeExpense),
        isFalse,
      );

      // Payment method matching
      expect(
        const ExpenseFilter(
          paymentMethod: PaymentMethod.cash,
        ).matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(
          paymentMethod: PaymentMethod.mtnMoMo,
        ).matches(activeExpense),
        isFalse,
      );

      // Amount range matching
      expect(
        const ExpenseFilter(minAmountMinor: 10000).matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(minAmountMinor: 20000).matches(activeExpense),
        isFalse,
      );
      expect(
        const ExpenseFilter(maxAmountMinor: 20000).matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(maxAmountMinor: 10000).matches(activeExpense),
        isFalse,
      );
      expect(
        const ExpenseFilter(
          minAmountMinor: 10000,
          maxAmountMinor: 20000,
        ).matches(activeExpense),
        isTrue,
      );

      // Date range matching
      expect(
        ExpenseFilter(
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 6, 30),
        ).matches(activeExpense),
        isTrue,
      );
      expect(
        ExpenseFilter(startDate: DateTime(2026, 7, 1)).matches(activeExpense),
        isFalse,
      );
      expect(
        ExpenseFilter(endDate: DateTime(2026, 6, 10)).matches(activeExpense),
        isFalse,
      );

      // Full-text search on description and vendor name
      expect(
        const ExpenseFilter(searchQuery: 'hybrid').matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(searchQuery: 'KUMASI').matches(activeExpense),
        isTrue,
      );
      expect(
        const ExpenseFilter(searchQuery: 'transport').matches(activeExpense),
        isFalse,
      );
      expect(
        const ExpenseFilter(searchQuery: 'transport').matches(voidedExpense),
        isTrue,
      );
    });
  });

  group('ExpenseRepository - watchExpensesWithFilter Integration Tests', () {
    late AppDatabase db;
    late ExpenseRepositoryImpl repository;
    const testFarmId = 'farm-uuid-ledger';
    const testProjectIdA = 'project-uuid-a';
    const testProjectIdB = 'project-uuid-b';
    late String testCategoryInputsId;
    late String testCategoryLabourId;

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
              name: 'Sunyani Model Farm',
              location: 'Sunyani, Bono Region',
              region: 'Bono',
              totalArea: 100.0,
              areaUnit: const Value('Acres'),
              ownershipType: 'Owned',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Seed 2 Projects
      await db
          .into(db.projectsTable)
          .insert(
            ProjectsTableCompanion.insert(
              id: testProjectIdA,
              farmId: testFarmId,
              name: 'Maize Block 1',
              projectType: 'CROP',
              commodity: 'Maize',
              landSize: 20.0,
              startDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.projectsTable)
          .insert(
            ProjectsTableCompanion.insert(
              id: testProjectIdB,
              farmId: testFarmId,
              name: 'Soybean Block 2',
              projectType: 'CROP',
              commodity: 'Soybeans',
              landSize: 15.0,
              startDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Fetch or seed categories
      final existingCategories = await db
          .select(db.budgetCategoriesTable)
          .get();
      testCategoryInputsId = existingCategories.first.id;

      testCategoryLabourId = 'cat-labour-custom';
      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: testCategoryLabourId,
              name: 'Field Labour',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final today = DateTime.now();

      // Seed 4 Expenses:
      // Exp 1: Proj A, Inputs, Cash, 5,000 minor (GH₵ 50.00), today, "Urea Fertilizer 50kg", "Kumasi Agro Supplies", active
      await repository.recordExpense(
        projectId: testProjectIdA,
        categoryId: testCategoryInputsId,
        transactionDate: today,
        description: 'Urea Fertilizer 50kg',
        amountMinor: 5000,
        paymentMethod: PaymentMethod.cash,
        vendorName: 'Kumasi Agro Supplies',
      );

      // Exp 2: Proj A, Labour, MTN MoMo, 12,000 minor (GH₵ 120.00), yesterday, "First weeding operation", "Kwame Mensah", active
      await repository.recordExpense(
        projectId: testProjectIdA,
        categoryId: testCategoryLabourId,
        transactionDate: today.subtract(const Duration(days: 1)),
        description: 'First weeding operation',
        amountMinor: 12000,
        paymentMethod: PaymentMethod.mtnMoMo,
        vendorName: 'Kwame Mensah Gang',
      );

      // Exp 3: Proj B, Inputs, Telecel Cash, 30,000 minor (GH₵ 300.00), 5 days ago, "NPK 15-15-15 Compound", "Agricare Inputs Ltd", voided
      final exp3Id = await repository.recordExpense(
        projectId: testProjectIdB,
        categoryId: testCategoryInputsId,
        transactionDate: today.subtract(const Duration(days: 5)),
        description: 'NPK 15-15-15 Compound',
        amountMinor: 30000,
        paymentMethod: PaymentMethod.telecelCash,
        vendorName: 'Agricare Inputs Ltd',
      );
      await repository.voidExpense(
        id: exp3Id,
        reason: 'Duplicate entry entered accidentally',
      );

      // Exp 4: Proj B, Labour, Cash, 8,000 minor (GH₵ 80.00), 10 days ago, "Spraying service", null vendor, active
      await repository.recordExpense(
        projectId: testProjectIdB,
        categoryId: testCategoryLabourId,
        transactionDate: today.subtract(const Duration(days: 10)),
        description: 'Spraying service',
        amountMinor: 8000,
        paymentMethod: PaymentMethod.cash,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'watchExpensesWithFilter returns all transactions when empty filter is passed',
      () async {
        final results = await repository
            .watchExpensesWithFilter(const ExpenseFilter())
            .first;
        expect(results.length, equals(4));
      },
    );

    test('filters by status correctly (activeOnly vs voidedOnly)', () async {
      final active = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(status: ExpenseStatusFilter.activeOnly),
          )
          .first;
      expect(active.length, equals(3));
      expect(active.every((e) => !e.isVoided), isTrue);

      final voided = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(status: ExpenseStatusFilter.voidedOnly),
          )
          .first;
      expect(voided.length, equals(1));
      expect(voided.first.isVoided, isTrue);
      expect(voided.first.description, equals('NPK 15-15-15 Compound'));
    });

    test('filters by projectId', () async {
      final projAResults = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(projectId: testProjectIdA),
          )
          .first;
      expect(projAResults.length, equals(2));
      expect(projAResults.every((e) => e.projectId == testProjectIdA), isTrue);

      final projBResults = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(projectId: testProjectIdB),
          )
          .first;
      expect(projBResults.length, equals(2));
      expect(projBResults.every((e) => e.projectId == testProjectIdB), isTrue);
    });

    test('filters by categoryId', () async {
      final labourExpenses = await repository
          .watchExpensesWithFilter(
            ExpenseFilter(categoryId: testCategoryLabourId),
          )
          .first;
      expect(labourExpenses.length, equals(2));
      expect(
        labourExpenses.every((e) => e.category.id == testCategoryLabourId),
        isTrue,
      );
    });

    test('filters by paymentMethod', () async {
      final momoExpenses = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(paymentMethod: PaymentMethod.mtnMoMo),
          )
          .first;
      expect(momoExpenses.length, equals(1));
      expect(momoExpenses.first.paymentMethod, equals(PaymentMethod.mtnMoMo));
      expect(momoExpenses.first.description, equals('First weeding operation'));

      final cashExpenses = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(paymentMethod: PaymentMethod.cash),
          )
          .first;
      expect(cashExpenses.length, equals(2));
    });

    test('filters by amount range (min and max)', () async {
      final highValue = await repository
          .watchExpensesWithFilter(const ExpenseFilter(minAmountMinor: 10000))
          .first;
      expect(highValue.length, equals(2)); // 12000 and 30000

      final bounded = await repository
          .watchExpensesWithFilter(
            const ExpenseFilter(minAmountMinor: 6000, maxAmountMinor: 15000),
          )
          .first;
      expect(bounded.length, equals(2)); // 8000 and 12000
    });

    test('filters by date range', () async {
      final now = DateTime.now();
      final lastThreeDays = await repository
          .watchExpensesWithFilter(
            ExpenseFilter(
              startDate: now.subtract(const Duration(days: 3)),
              endDate: now,
            ),
          )
          .first;
      expect(lastThreeDays.length, equals(2)); // Today and Yesterday
    });

    test(
      'filters by full-text search across description and vendor name',
      () async {
        // By description match
        final ureaSearch = await repository
            .watchExpensesWithFilter(const ExpenseFilter(searchQuery: 'urea'))
            .first;
        expect(ureaSearch.length, equals(1));
        expect(ureaSearch.first.description, contains('Urea'));

        // By vendor match
        final vendorSearch = await repository
            .watchExpensesWithFilter(const ExpenseFilter(searchQuery: 'mensah'))
            .first;
        expect(vendorSearch.length, equals(1));
        expect(vendorSearch.first.vendorName, contains('Kwame Mensah'));

        // Case-insensitivity
        final caseInsensitiveSearch = await repository
            .watchExpensesWithFilter(
              const ExpenseFilter(searchQuery: 'AGRICARE'),
            )
            .first;
        expect(caseInsensitiveSearch.length, equals(1));
        expect(
          caseInsensitiveSearch.first.vendorName,
          equals('Agricare Inputs Ltd'),
        );

        // No match
        final noMatch = await repository
            .watchExpensesWithFilter(
              const ExpenseFilter(searchQuery: 'Tractor Service'),
            )
            .first;
        expect(noMatch, isEmpty);
      },
    );

    test('combines multi-dimensional filters simultaneously', () async {
      final combined = await repository
          .watchExpensesWithFilter(
            ExpenseFilter(
              projectId: testProjectIdA,
              paymentMethod: PaymentMethod.cash,
              status: ExpenseStatusFilter.activeOnly,
              minAmountMinor: 4000,
              maxAmountMinor: 6000,
            ),
          )
          .first;

      expect(combined.length, equals(1));
      expect(combined.first.description, equals('Urea Fertilizer 50kg'));
    });
  });
}
