import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';

void main() {
  late AppDatabase db;
  late SaleRepositoryImpl repository;
  const testFarmId = 'farm-sale-01';
  const testProjectId = 'project-sale-01';
  const testBuyerId = 'buyer-sale-01';
  const testHarvestId = 'harvest-sale-01';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SaleRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Dawhenya Irrigation Farm',
            location: 'Dawhenya, Greater Accra',
            region: 'Greater Accra',
            totalArea: 100.0,
            areaUnit: const Value('Acres'),
            ownershipType: 'Leased',
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
            name: 'Dry Season Commercial Tomato 2026',
            projectType: 'CROP',
            commodity: 'Tomato',
            landSize: 5.0,
            currency: const Value('GHS'),
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Buyer
    await db
        .into(db.buyersTable)
        .insert(
          BuyersTableCompanion.insert(
            id: testBuyerId,
            name: 'Madam Akosua Agbogbloshie',
            phone: const Value('0244112233'),
            businessName: const Value('Akosua & Sons Produce'),
            location: const Value('Agbogbloshie Market'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Harvest
    await db
        .into(db.harvestsTable)
        .insert(
          HarvestsTableCompanion.insert(
            id: testHarvestId,
            projectId: testProjectId,
            batchNumber: 'HV-TOM-2611-01',
            harvestDate: now,
            productName: 'Roma Tomato',
            quantity: 200.0,
            unit: 'Crates',
            grade: const Value('Grade A'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('SaleRepository - Validations', () {
    test('rejects empty product name', () async {
      expect(
        () => repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: '   ',
          quantity: 10,
          unit: 'Crates',
          unitPriceMinor: 15000,
          paymentStatus: SalePaymentStatus.paid,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Product name cannot be empty'),
          ),
        ),
      );
    });

    test('rejects zero or negative quantity', () async {
      expect(
        () => repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 0,
          unit: 'Crates',
          unitPriceMinor: 15000,
          paymentStatus: SalePaymentStatus.paid,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Quantity must be greater than zero'),
          ),
        ),
      );
    });

    test('rejects empty unit', () async {
      expect(
        () => repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 10,
          unit: '',
          unitPriceMinor: 15000,
          paymentStatus: SalePaymentStatus.paid,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Unit of measure cannot be empty'),
          ),
        ),
      );
    });

    test('rejects negative unit price', () async {
      expect(
        () => repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 10,
          unit: 'Crates',
          unitPriceMinor: -500,
          paymentStatus: SalePaymentStatus.paid,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Unit price cannot be negative'),
          ),
        ),
      );
    });

    test('rejects invalid project ID', () async {
      expect(
        () => repository.recordSale(
          projectId: 'non-existent-proj',
          saleDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 10,
          unit: 'Crates',
          unitPriceMinor: 15000,
          paymentStatus: SalePaymentStatus.paid,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Project not found or deleted'),
          ),
        ),
      );
    });

    test('rejects partial payment without valid initial amount', () async {
      expect(
        () => repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 10,
          unit: 'Crates',
          unitPriceMinor: 10000, // Total = 100,000 minor (GHS 1000)
          paymentStatus: SalePaymentStatus.partial,
          initialPaymentAmountMinor: 0,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Partial payments require an initial payment amount'),
          ),
        ),
      );
    });

    test('rejects partial payment meeting or exceeding total amount', () async {
      expect(
        () => repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 10,
          unit: 'Crates',
          unitPriceMinor: 10000, // Total = 100,000 minor
          paymentStatus: SalePaymentStatus.partial,
          initialPaymentAmountMinor: 100000,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains(
              'Initial deposit cannot meet or exceed the total sale amount',
            ),
          ),
        ),
      );
    });
  });

  group('SaleRepository - Core Record, Retrieve, and Calculation', () {
    test(
      'records paid sale and auto-creates matching settlement payment',
      () async {
        final saleId = await repository.recordSale(
          projectId: testProjectId,
          buyerId: testBuyerId,
          harvestId: testHarvestId,
          saleDate: DateTime(2026, 11, 8),
          productName: 'Roma Tomato',
          quantity: 20.0,
          unit: 'Crates',
          unitPriceMinor: 15000, // GHS 150.00 / Crate
          paymentStatus: SalePaymentStatus.paid,
          paymentMethod: 'MOMO_MTN',
          notes: 'Delivered at farm gate',
        );

        final retrieved = await repository.getSaleById(saleId);
        expect(retrieved, isNotNull);
        expect(retrieved!.sale.id, equals(saleId));
        expect(retrieved.sale.productName, equals('Roma Tomato'));
        expect(retrieved.sale.quantity, equals(20.0));
        // Total = 20 * 15000 = 300,000 minor units (GHS 3,000.00)
        expect(retrieved.sale.totalAmountMinor, equals(300000));
        expect(retrieved.totalAmount, equals(Money.fromMajor(3000)));
        expect(retrieved.totalPaidMinor, equals(300000));
        expect(retrieved.paidAmount, equals(Money.fromMajor(3000)));
        expect(retrieved.remainingBalance, equals(Money.fromMajor(0)));
        expect(retrieved.isFullyPaid, isTrue);
        expect(retrieved.isPartiallyPaid, isFalse);
        expect(retrieved.isUnpaid, isFalse);
        expect(retrieved.isCredit, isFalse);
        expect(retrieved.effectiveStatus, equals(SalePaymentStatus.paid));
        expect(retrieved.buyer?.name, equals('Madam Akosua Agbogbloshie'));
        expect(retrieved.harvest?.batchNumber, equals('HV-TOM-2611-01'));
        expect(retrieved.formattedQuantity, equals('20 Crates'));
      },
    );

    test('records credit sale (unpaid) with zero payments logged', () async {
      final saleId = await repository.recordSale(
        projectId: testProjectId,
        buyerId: testBuyerId,
        saleDate: DateTime(2026, 11, 8),
        productName: 'Fresh Cabbage',
        quantity: 50.0,
        unit: 'Bags',
        unitPriceMinor: 8000, // GHS 80.00 / Bag
        paymentStatus: SalePaymentStatus.unpaid,
      );

      final retrieved = await repository.getSaleById(saleId);
      expect(retrieved, isNotNull);
      // Total = 50 * 8000 = 400,000 minor units (GHS 4,000.00)
      expect(retrieved!.sale.totalAmountMinor, equals(400000));
      expect(retrieved.totalPaidMinor, equals(0));
      expect(retrieved.remainingBalance, equals(Money.fromMajor(4000)));
      expect(retrieved.isFullyPaid, isFalse);
      expect(retrieved.isUnpaid, isTrue);
      expect(retrieved.isCredit, isTrue);
      expect(retrieved.effectiveStatus, equals(SalePaymentStatus.unpaid));
    });

    test(
      'records partial deposit sale with remaining accounts receivable',
      () async {
        final saleId = await repository.recordSale(
          projectId: testProjectId,
          buyerId: testBuyerId,
          saleDate: DateTime(2026, 11, 8),
          productName: 'Bell Peppers',
          quantity: 10.0,
          unit: 'Boxes',
          unitPriceMinor: 20000, // Total = 200,000 minor (GHS 2,000.00)
          paymentStatus: SalePaymentStatus.partial,
          initialPaymentAmountMinor: 50000, // GHS 500.00 deposit
          paymentMethod: 'CASH',
        );

        final retrieved = await repository.getSaleById(saleId);
        expect(retrieved, isNotNull);
        expect(retrieved!.sale.totalAmountMinor, equals(200000));
        expect(retrieved.totalPaidMinor, equals(50000));
        expect(retrieved.paidAmount, equals(Money.fromMajor(500)));
        expect(retrieved.remainingBalance, equals(Money.fromMajor(1500)));
        expect(retrieved.isPartiallyPaid, isTrue);
        expect(retrieved.isFullyPaid, isFalse);
        expect(retrieved.isCredit, isTrue);
        expect(retrieved.effectiveStatus, equals(SalePaymentStatus.partial));
      },
    );
  });

  group('SaleRepository - Updates and Soft Voiding', () {
    test('updates sale details and recomputes total amount', () async {
      final saleId = await repository.recordSale(
        projectId: testProjectId,
        saleDate: DateTime(2026, 11, 8),
        productName: 'Yellow Corn',
        quantity: 10.0,
        unit: 'Bags',
        unitPriceMinor: 10000,
        paymentStatus: SalePaymentStatus.unpaid,
      );

      await repository.updateSale(
        id: saleId,
        saleDate: DateTime(2026, 11, 9),
        productName: 'Yellow Corn (Dried)',
        quantity: 15.0,
        unit: 'Bags',
        unitPriceMinor: 12000, // 15 * 12000 = 180,000
        notes: 'Price adjustment for dry grain',
      );

      final updated = await repository.getSaleById(saleId);
      expect(updated!.sale.productName, equals('Yellow Corn (Dried)'));
      expect(updated.sale.quantity, equals(15.0));
      expect(updated.sale.totalAmountMinor, equals(180000));
      expect(updated.totalAmount, equals(Money.fromMajor(1800)));
      expect(updated.sale.notes, equals('Price adjustment for dry grain'));
    });

    test('soft voids sale and voids associated payments immutably', () async {
      final saleId = await repository.recordSale(
        projectId: testProjectId,
        buyerId: testBuyerId,
        saleDate: DateTime(2026, 11, 8),
        productName: 'Habanero Pepper',
        quantity: 5.0,
        unit: 'Sacks',
        unitPriceMinor: 25000,
        paymentStatus: SalePaymentStatus.paid,
      );

      // Verify payment exists
      final preVoid = await repository.getSaleById(saleId);
      expect(preVoid!.totalPaidMinor, equals(125000));

      // Void sale
      await repository.voidSale(saleId, reason: 'Accidental duplicate entry');

      // Default getSales excludes voided
      final activeSales = await repository.getSales(projectId: testProjectId);
      expect(activeSales.any((s) => s.sale.id == saleId), isFalse);

      // Including voided finds the record
      final allSales = await repository.getSales(
        projectId: testProjectId,
        includeVoided: true,
      );
      final voided = allSales.firstWhere((s) => s.sale.id == saleId);
      expect(voided.sale.isVoided, isTrue);
      expect(voided.sale.voidReason, equals('Accidental duplicate entry'));
      expect(voided.sale.voidedAt, isNotNull);

      // Payments for voided sales are voided and ignored in balances
      expect(voided.totalPaidMinor, equals(0));
      expect(voided.remainingBalance, equals(Money.zero()));
    });

    test('rejects voiding with empty reason or re-voiding', () async {
      final saleId = await repository.recordSale(
        projectId: testProjectId,
        saleDate: DateTime.now(),
        productName: 'Carrots',
        quantity: 5,
        unit: 'Sacks',
        unitPriceMinor: 5000,
        paymentStatus: SalePaymentStatus.unpaid,
      );

      expect(
        () => repository.voidSale(saleId, reason: '  '),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('A reason is required to void a sale'),
          ),
        ),
      );

      await repository.voidSale(saleId, reason: 'First void');

      expect(
        () => repository.voidSale(saleId, reason: 'Second void attempt'),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Sale is already voided'),
          ),
        ),
      );
    });
  });

  group('SaleRepository - Aggregated Summary Metrics', () {
    test(
      'accurately calculates gross sales, cash collected, and receivables',
      () async {
        // 1. Paid sale: 10 * GHS 100 = GHS 1,000 (100,000 minor)
        await repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Lettuce',
          quantity: 10,
          unit: 'Heads',
          unitPriceMinor: 10000,
          paymentStatus: SalePaymentStatus.paid,
        );

        // 2. Unpaid credit sale: 20 * GHS 50 = GHS 1,000 (100,000 minor)
        await repository.recordSale(
          projectId: testProjectId,
          buyerId: testBuyerId,
          saleDate: DateTime.now(),
          productName: 'Cabbage',
          quantity: 20,
          unit: 'Heads',
          unitPriceMinor: 5000,
          paymentStatus: SalePaymentStatus.unpaid,
        );

        // 3. Partial sale: 10 * GHS 200 = GHS 2,000 (200,000 minor) with GHS 600 (60,000 minor) deposit
        await repository.recordSale(
          projectId: testProjectId,
          buyerId: testBuyerId,
          saleDate: DateTime.now(),
          productName: 'Watermelon',
          quantity: 10,
          unit: 'Pieces',
          unitPriceMinor: 20000,
          paymentStatus: SalePaymentStatus.partial,
          initialPaymentAmountMinor: 60000,
        );

        // 4. Voided sale (should NOT count toward active financial totals)
        final voidedId = await repository.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Rotten Cucumbers',
          quantity: 5,
          unit: 'Baskets',
          unitPriceMinor: 5000,
          paymentStatus: SalePaymentStatus.unpaid,
        );
        await repository.voidSale(voidedId, reason: 'Spoiled produce returned');

        final summary = await repository.getSalesSummary(
          projectId: testProjectId,
        );

        // Total Active: 3 sales
        expect(summary.totalSalesCount, equals(3));
        // Voided: 1 sale
        expect(summary.voidedSalesCount, equals(1));
        // Paid: 1, Partial: 1, Unpaid: 1
        expect(summary.paidSalesCount, equals(1));
        expect(summary.partialSalesCount, equals(1));
        expect(summary.unpaidSalesCount, equals(1));

        // Gross Sales: 1,000 + 1,000 + 2,000 = GHS 4,000
        expect(summary.totalGrossSales, equals(Money.fromMajor(4000)));
        // Cash Collected: 1,000 + 600 = GHS 1,600
        expect(summary.totalCashCollected, equals(Money.fromMajor(1600)));
        // Receivables: 1,000 + 1,400 = GHS 2,400
        expect(summary.totalAccountsReceivable, equals(Money.fromMajor(2400)));
        // Collection rate: 1,600 / 4,000 = 40%
        expect(summary.collectionRatePercentage, closeTo(40.0, 0.01));
      },
    );
  });
}
