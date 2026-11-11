import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/payments/data/repositories/payment_repository_impl.dart';

void main() {
  late AppDatabase db;
  late PaymentRepositoryImpl repository;

  const testFarmId = 'farm-pay-01';
  const testProjectId = 'proj-pay-01';
  const testBuyerId = 'buyer-pay-01';
  const testSaleId = 'sale-credit-01';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PaymentRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Dawhenya Commercial Irrigation',
            location: 'Dawhenya, Greater Accra',
            region: 'Greater Accra',
            totalArea: 50.0,
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
            name: 'Commercial Tomato 2026',
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
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Credit Sale of GH₵ 3,000.00 (300,000 minor units)
    await db
        .into(db.salesTable)
        .insert(
          SalesTableCompanion.insert(
            id: testSaleId,
            projectId: testProjectId,
            buyerId: const Value(testBuyerId),
            saleDate: now,
            productName: 'Roma Tomato',
            quantity: 20.0,
            unit: 'Crates',
            unitPriceMinor: 15000,
            totalAmountMinor: 300000, // GH₵ 3,000.00
            currency: const Value('GHS'),
            paymentStatus: const Value('UNPAID'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('PaymentRepository - Validations', () {
    test('rejects zero or negative payment amount', () async {
      expect(
        () => repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime.now(),
          amountMinor: 0,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Payment amount must be greater than zero'),
          ),
        ),
      );

      expect(
        () => repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime.now(),
          amountMinor: -500,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Payment amount must be greater than zero'),
          ),
        ),
      );
    });

    test('rejects payment for non-existent sale', () async {
      expect(
        () => repository.recordPayment(
          saleId: 'missing-sale-id',
          paymentDate: DateTime.now(),
          amountMinor: 10000,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Sale transaction not found or deleted'),
          ),
        ),
      );
    });

    test('rejects payment for voided sale', () async {
      await (db.update(
        db.salesTable,
      )..where((s) => s.id.equals(testSaleId))).write(
        const SalesTableCompanion(
          isVoided: Value(true),
          voidReason: Value('Spoiled crop returned'),
        ),
      );

      expect(
        () => repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime.now(),
          amountMinor: 10000,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Cannot record payments against a voided commercial sale'),
          ),
        ),
      );
    });

    test('rejects payment exceeding remaining outstanding balance', () async {
      // Total sale is 300,000 minor units (GH₵ 3,000.00). Attempt to pay 350,000 (GH₵ 3,500.00).
      expect(
        () => repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime.now(),
          amountMinor: 350000,
          paymentMethod: PaymentMethod.cash,
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('exceeds remaining balance'),
          ),
        ),
      );
    });
  });

  group('PaymentRepository - Multiple Installments & Auto-Updating Balances', () {
    test(
      'records multiple installments, auto-updates sale status and remaining balance',
      () async {
        // Initial outstanding balance should be GH₵ 3,000.00
        var balance = await repository.getSaleOutstandingBalance(testSaleId);
        expect(balance, equals(Money.fromMajor(3000)));

        // Installment 1: First deposit of GH₵ 1,000.00 via MTN MoMo
        final payId1 = await repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime(2026, 11, 8),
          amountMinor: 100000, // GH₵ 1,000.00
          paymentMethod: PaymentMethod.mtnMoMo,
          referenceNumber: 'MOMO-TX-10928374',
          notes: 'Deposit paid via MTN MoMo',
        );

        expect(payId1, isNotEmpty);

        // Verify Sale status transitioned to PARTIAL
        var sale = await (db.select(
          db.salesTable,
        )..where((s) => s.id.equals(testSaleId))).getSingle();
        expect(sale.paymentStatus, equals('PARTIAL'));

        // Verify remaining balance dropped to GH₵ 2,000.00
        balance = await repository.getSaleOutstandingBalance(testSaleId);
        expect(balance, equals(Money.fromMajor(2000)));

        // Installment 2: Second payment of GH₵ 800.00 in Cash
        final payId2 = await repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime(2026, 11, 9),
          amountMinor: 80000, // GH₵ 800.00
          paymentMethod: PaymentMethod.cash,
          notes: 'Cash payment at Makola stall',
        );
        expect(payId2, isNotEmpty);

        // Sale status should remain PARTIAL
        sale = await (db.select(
          db.salesTable,
        )..where((s) => s.id.equals(testSaleId))).getSingle();
        expect(sale.paymentStatus, equals('PARTIAL'));

        // Remaining balance should now be GH₵ 1,200.00
        balance = await repository.getSaleOutstandingBalance(testSaleId);
        expect(balance, equals(Money.fromMajor(1200)));

        // Installment 3: Final settlement of GH₵ 1,200.00 via Bank Transfer
        final payId3 = await repository.recordPayment(
          saleId: testSaleId,
          paymentDate: DateTime(2026, 11, 10),
          amountMinor: 120000, // GH₵ 1,200.00
          paymentMethod: PaymentMethod.bankTransfer,
          referenceNumber: 'GCB-TRF-998822',
          notes: 'Final balance clearing',
        );
        expect(payId3, isNotEmpty);

        // Sale status should now transition to PAID
        sale = await (db.select(
          db.salesTable,
        )..where((s) => s.id.equals(testSaleId))).getSingle();
        expect(sale.paymentStatus, equals('PAID'));

        // Remaining balance should be exactly zero
        balance = await repository.getSaleOutstandingBalance(testSaleId);
        expect(balance, equals(Money.zero()));

        // Subsequent payment attempt on fully settled sale must fail
        expect(
          () => repository.recordPayment(
            saleId: testSaleId,
            paymentDate: DateTime.now(),
            amountMinor: 5000,
            paymentMethod: PaymentMethod.cash,
          ),
          throwsA(
            isA<ValidationFailure>().having(
              (e) => e.message,
              'message',
              contains('already fully settled'),
            ),
          ),
        );

        // Fetch all payments for this sale
        final payments = await repository.getPayments(saleId: testSaleId);
        expect(payments.length, equals(3));
        expect(payments[0].method, equals(PaymentMethod.bankTransfer));
        expect(payments[1].method, equals(PaymentMethod.cash));
        expect(payments[2].method, equals(PaymentMethod.mtnMoMo));
      },
    );
  });

  group('PaymentRepository - Soft Voiding & Balance Reversion', () {
    test('voiding payment restores parent sale balance and status', () async {
      // 1. Pay GH₵ 2,000.00
      final payId1 = await repository.recordPayment(
        saleId: testSaleId,
        paymentDate: DateTime.now(),
        amountMinor: 200000,
        paymentMethod: PaymentMethod.cash,
      );

      // 2. Pay remaining GH₵ 1,000.00 -> sale becomes PAID
      final payId2 = await repository.recordPayment(
        saleId: testSaleId,
        paymentDate: DateTime.now(),
        amountMinor: 100000,
        paymentMethod: PaymentMethod.mtnMoMo,
      );

      var sale = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals(testSaleId))).getSingle();
      expect(sale.paymentStatus, equals('PAID'));

      // 3. Void the second payment (GH₵ 1,000.00)
      await repository.voidPayment(
        payId2,
        reason: 'MoMo transaction reversed by telco',
      );

      // Sale status should revert back to PARTIAL
      sale = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals(testSaleId))).getSingle();
      expect(sale.paymentStatus, equals('PARTIAL'));

      // Outstanding balance should revert to GH₵ 1,000.00
      var balance = await repository.getSaleOutstandingBalance(testSaleId);
      expect(balance, equals(Money.fromMajor(1000)));

      // 4. Void the first payment (GH₵ 2,000.00)
      await repository.voidPayment(
        payId1,
        reason: 'Duplicate cash receipt logged',
      );

      // Sale status should revert back to UNPAID
      sale = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals(testSaleId))).getSingle();
      expect(sale.paymentStatus, equals('UNPAID'));

      // Outstanding balance should be full GH₵ 3,000.00
      balance = await repository.getSaleOutstandingBalance(testSaleId);
      expect(balance, equals(Money.fromMajor(3000)));
    });

    test('rejects voiding with empty reason or re-voiding', () async {
      final payId = await repository.recordPayment(
        saleId: testSaleId,
        paymentDate: DateTime.now(),
        amountMinor: 50000,
        paymentMethod: PaymentMethod.cash,
      );

      expect(
        () => repository.voidPayment(payId, reason: '  '),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('A reason is required to void a payment'),
          ),
        ),
      );

      await repository.voidPayment(payId, reason: 'Bounced cheque');

      expect(
        () => repository.voidPayment(payId, reason: 'Already voided attempt'),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.message,
            'message',
            contains('Payment is already voided'),
          ),
        ),
      );
    });
  });
}
