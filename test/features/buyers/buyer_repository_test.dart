import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/data/repositories/buyer_repository_impl.dart';
import 'package:farmivo/features/buyers/domain/models/debtor_status.dart';

void main() {
  late AppDatabase db;
  late BuyerRepositoryImpl repository;
  const testFarmId = 'farm-uuid-buyer';
  const testProjectId = 'project-uuid-buyer';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BuyerRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Techiman Farm Enterprise',
            location: 'Techiman, Bono East',
            region: 'Bono East',
            totalArea: 60.0,
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
            name: 'Pepper Season 2026',
            projectType: 'CROP',
            commodity: 'Pepper',
            landSize: 8.0,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('BuyerRepository Validation Tests', () {
    test('throws ValidationFailure if buyer name is empty', () async {
      expect(
        () => repository.createBuyer(name: '   '),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure when updating non-existent buyer', () async {
      expect(
        () => repository.updateBuyer(id: 'non-existent-id', name: 'Valid Name'),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('Buyer CRUD Operations', () {
    test('createBuyer registers buyer and retrieves summary', () async {
      final id = await repository.createBuyer(
        name: 'Mama Beatrice Osei',
        phone: '0241234567',
        businessName: 'Stall #14 Makola Market',
        location: 'Makola Market, Accra',
        notes: 'Pays 50% upfront, remainder in 14 days.',
      );

      expect(id, isNotEmpty);

      final buyer = await repository.getBuyerById(id);
      expect(buyer, isNotNull);
      expect(buyer!.name, 'Mama Beatrice Osei');
      expect(buyer.phone, '0241234567');
      expect(buyer.businessName, 'Stall #14 Makola Market');
      expect(buyer.location, 'Makola Market, Accra');

      final summary = await repository.getBuyerSummaryById(id);
      expect(summary, isNotNull);
      expect(
        summary!.displayName,
        'Mama Beatrice Osei (Stall #14 Makola Market)',
      );
      expect(summary.totalPurchased, Money.zero());
      expect(summary.totalPaid, Money.zero());
      expect(summary.outstandingBalance, Money.zero());
      expect(summary.debtorStatus, DebtorStatus.noHistory);
    });

    test('updateBuyer modifies contact details and notes', () async {
      final id = await repository.createBuyer(
        name: 'Kwame Mensah',
        phone: '0501112233',
      );

      await repository.updateBuyer(
        id: id,
        name: 'Kwame Mensah & Sons',
        phone: '0509998877',
        businessName: 'Mensah Grains Co.',
        location: 'Kumasi Central Market',
      );

      final updated = await repository.getBuyerSummaryById(id);
      expect(updated!.name, 'Kwame Mensah & Sons');
      expect(updated.phone, '0509998877');
      expect(updated.businessName, 'Mensah Grains Co.');
      expect(updated.location, 'Kumasi Central Market');
    });

    test('deleteBuyer soft-deletes buyer from active queries', () async {
      final id = await repository.createBuyer(name: 'Kofi Manu');

      var list = await repository.getBuyers();
      expect(list.length, 1);

      await repository.deleteBuyer(id);

      list = await repository.getBuyers();
      expect(list, isEmpty);

      final byId = await repository.getBuyerById(id);
      expect(byId, isNull);
    });
  });

  group('Buyer Debt & Financial Aggregations', () {
    test(
      'computes totalPurchased, totalPaid, outstanding debt, and debtor statuses',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        // 1. Buyer A: Partial Payment (Owes GH₵ 900.00)
        final buyerAId = await repository.createBuyer(
          name: 'Buyer A (Partial)',
          phone: '0240000001',
        );
        // Sale 1: GH₵ 1,000.00
        await db
            .into(db.salesTable)
            .insert(
              SalesTableCompanion.insert(
                id: 'sale-1',
                projectId: testProjectId,
                buyerId: Value(buyerAId),
                saleDate: now,
                productName: 'Pepper',
                quantity: 20.0,
                unit: 'Bag',
                unitPriceMinor: 5000,
                totalAmountMinor: 100000, // GH₵ 1,000.00
                createdAt: now,
                updatedAt: now,
              ),
            );
        // Sale 2: GH₵ 500.00
        await db
            .into(db.salesTable)
            .insert(
              SalesTableCompanion.insert(
                id: 'sale-2',
                projectId: testProjectId,
                buyerId: Value(buyerAId),
                saleDate: now,
                productName: 'Pepper',
                quantity: 10.0,
                unit: 'Bag',
                unitPriceMinor: 5000,
                totalAmountMinor: 50000, // GH₵ 500.00
                createdAt: now,
                updatedAt: now,
              ),
            );
        // Payment 1 for Sale 1: GH₵ 600.00
        await db
            .into(db.paymentsTable)
            .insert(
              PaymentsTableCompanion.insert(
                id: 'payment-1',
                saleId: 'sale-1',
                paymentDate: now,
                amountMinor: 60000, // GH₵ 600.00
                paymentMethod: 'CASH',
                createdAt: now,
                updatedAt: now,
              ),
            );

        // 2. Buyer B: Full Debt / Owing (GH₵ 800.00, 0 paid)
        final buyerBId = await repository.createBuyer(
          name: 'Buyer B (Owing)',
          phone: '0240000002',
        );
        await db
            .into(db.salesTable)
            .insert(
              SalesTableCompanion.insert(
                id: 'sale-3',
                projectId: testProjectId,
                buyerId: Value(buyerBId),
                saleDate: now,
                productName: 'Pepper',
                quantity: 16.0,
                unit: 'Bag',
                unitPriceMinor: 5000,
                totalAmountMinor: 80000, // GH₵ 800.00
                createdAt: now,
                updatedAt: now,
              ),
            );

        // 3. Buyer C: Fully Settled (GH₵ 400.00 purchased, GH₵ 400.00 paid)
        final buyerCId = await repository.createBuyer(
          name: 'Buyer C (Settled)',
          phone: '0240000003',
        );
        await db
            .into(db.salesTable)
            .insert(
              SalesTableCompanion.insert(
                id: 'sale-4',
                projectId: testProjectId,
                buyerId: Value(buyerCId),
                saleDate: now,
                productName: 'Pepper',
                quantity: 8.0,
                unit: 'Bag',
                unitPriceMinor: 5000,
                totalAmountMinor: 40000, // GH₵ 400.00
                createdAt: now,
                updatedAt: now,
              ),
            );
        await db
            .into(db.paymentsTable)
            .insert(
              PaymentsTableCompanion.insert(
                id: 'payment-2',
                saleId: 'sale-4',
                paymentDate: now,
                amountMinor: 40000, // GH₵ 400.00
                paymentMethod: 'MOMO',
                createdAt: now,
                updatedAt: now,
              ),
            );

        // 4. Buyer D: Fresh / No History
        final buyerDId = await repository.createBuyer(
          name: 'Buyer D (New)',
          phone: '0240000004',
        );

        // Verify Buyer A
        final summaryA = await repository.getBuyerSummaryById(buyerAId);
        expect(
          summaryA!.totalPurchased,
          Money(BigInt.from(150000)),
        ); // GH₵ 1,500.00
        expect(summaryA.totalPaid, Money(BigInt.from(60000))); // GH₵ 600.00
        expect(
          summaryA.outstandingBalance,
          Money(BigInt.from(90000)),
        ); // GH₵ 900.00
        expect(summaryA.debtorStatus, DebtorStatus.partial);
        expect(summaryA.hasDebt, isTrue);

        // Verify Buyer B
        final summaryB = await repository.getBuyerSummaryById(buyerBId);
        expect(
          summaryB!.totalPurchased,
          Money(BigInt.from(80000)),
        ); // GH₵ 800.00
        expect(summaryB.totalPaid, Money.zero());
        expect(
          summaryB.outstandingBalance,
          Money(BigInt.from(80000)),
        ); // GH₵ 800.00
        expect(summaryB.debtorStatus, DebtorStatus.owing);
        expect(summaryB.hasDebt, isTrue);

        // Verify Buyer C
        final summaryC = await repository.getBuyerSummaryById(buyerCId);
        expect(
          summaryC!.totalPurchased,
          Money(BigInt.from(40000)),
        ); // GH₵ 400.00
        expect(summaryC.totalPaid, Money(BigInt.from(40000))); // GH₵ 400.00
        expect(summaryC.outstandingBalance, Money.zero());
        expect(summaryC.debtorStatus, DebtorStatus.settled);
        expect(summaryC.hasDebt, isFalse);

        // Verify Buyer D
        final summaryD = await repository.getBuyerSummaryById(buyerDId);
        expect(summaryD!.debtorStatus, DebtorStatus.noHistory);
        expect(summaryD.hasDebt, isFalse);

        // Test onlyDebtors filter
        final debtorsOnly = await repository.getBuyers(onlyDebtors: true);
        expect(debtorsOnly.length, 2);
        expect(debtorsOnly.map((b) => b.id), containsAll([buyerAId, buyerBId]));
        // Debtors sorted with highest debt first (GH₵ 900.00 before GH₵ 800.00)
        expect(debtorsOnly[0].id, buyerAId);
        expect(debtorsOnly[1].id, buyerBId);

        // Test Search filter
        final searchResult = await repository.getBuyers(searchQuery: 'partial');
        expect(searchResult.length, 1);
        expect(searchResult.first.id, buyerAId);

        // Test Directory Summary
        final dirSummary = await repository.getDirectorySummary();
        expect(dirSummary.totalBuyers, 4);
        expect(dirSummary.activeDebtorsCount, 2);
        // Total Receivables = 900 + 800 = 1,700.00
        expect(dirSummary.totalReceivables, Money(BigInt.from(170000)));
        // Total Sales Volume = 1500 + 800 + 400 = 2,700.00
        expect(dirSummary.totalSalesVolume, Money(BigInt.from(270000)));
        // Total Cash Collected = 600 + 400 = 1,000.00
        expect(dirSummary.totalCashCollected, Money(BigInt.from(100000)));
        // Collection rate = (1000 / 2700) * 100 = 37.0%
        expect(dirSummary.collectionRatePercentage, closeTo(37.03, 0.1));
      },
    );
  });
}
