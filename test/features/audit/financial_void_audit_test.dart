import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/audit/data/repositories/audit_log_repository_impl.dart';
import 'package:farmivo/features/audit/domain/models/audit_action.dart';
import 'package:farmivo/features/audit/domain/repositories/audit_log_repository.dart';
import 'package:farmivo/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';
import 'package:farmivo/features/payments/data/repositories/payment_repository_impl.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Financial Voiding Audit Trail Integration Tests (Milestone 9.3)', () {
    late AppDatabase db;
    late AuditLogRepository auditRepository;
    late ExpenseRepositoryImpl expenseRepository;
    late SaleRepositoryImpl saleRepository;
    late PaymentRepositoryImpl paymentRepository;

    const projectId = 'proj-audit-1';
    const farmId = 'farm-audit-1';
    const catId = 'cat-seeds';
    const buyerId = 'buyer-audit-1';

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      auditRepository = AuditLogRepositoryImpl(db: db);
      expenseRepository = ExpenseRepositoryImpl(
        db: db,
        auditRepository: auditRepository,
      );
      saleRepository = SaleRepositoryImpl(
        db: db,
        auditRepository: auditRepository,
      );
      paymentRepository = PaymentRepositoryImpl(
        db: db,
        auditRepository: auditRepository,
      );

      final now = DateTime.now().millisecondsSinceEpoch;

      // Seed prerequisite foreign keys
      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: catId,
              name: 'Seedlings & Nursery',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.farmsTable)
          .insert(
            FarmsTableCompanion.insert(
              id: farmId,
              name: 'Audit Test Farm',
              location: 'Koforidua',
              country: const Value('Ghana'),
              region: 'Eastern',
              totalArea: 10.0,
              areaUnit: const Value('Acres'),
              ownershipType: 'OWNED',
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
              name: 'Tomato Harvest 2026',
              projectType: 'CROP',
              commodity: 'Tomato',
              landSize: 10.0,
              startDate: now,
              currency: const Value('GHS'),
              status: const Value('ACTIVE'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.buyersTable)
          .insert(
            BuyersTableCompanion.insert(
              id: buyerId,
              name: 'Agrico Wholesale',
              phone: const Value('0241234567'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('voidExpense immutably captures forensic audit log entry', () async {
      // 1. Record an active expense
      final expenseId = await expenseRepository.recordExpense(
        projectId: projectId,
        categoryId: catId,
        transactionDate: DateTime(2026, 4, 1),
        description: 'Certified Seedlings Purchase',
        amountMinor: 75000,
        paymentMethod: PaymentMethod.mtnMoMo,
      );

      // Verify no audit entry yet for this expense
      final preAudit = await auditRepository.getAuditTrailForEntity(
        entityTable: 'expenses',
        entityId: expenseId,
      );
      expect(preAudit, isEmpty);

      // 2. Void the expense with forensic reason
      const voidReason = 'Erroneously double-billed by nursery supplier';
      await expenseRepository.voidExpense(id: expenseId, reason: voidReason);

      // 3. Verify expense status
      final expense = await (db.select(
        db.expensesTable,
      )..where((e) => e.id.equals(expenseId))).getSingle();
      expect(expense.isVoided, isTrue);
      expect(expense.voidReason, equals(voidReason));

      // 4. Verify immutable audit log
      final postAudit = await auditRepository.getAuditTrailForEntity(
        entityTable: 'expenses',
        entityId: expenseId,
      );
      expect(postAudit.length, equals(1));

      final auditEntry = postAudit.first;
      expect(auditEntry.action, equals(AuditAction.voidRecord));
      expect(auditEntry.entityTable, equals('expenses'));
      expect(auditEntry.reason, equals(voidReason));
      expect(auditEntry.previousState?['isVoided'], isFalse);
      expect(auditEntry.previousState?['amountMinor'], equals(75000));
      expect(auditEntry.newState?['isVoided'], isTrue);
      expect(auditEntry.newState?['voidReason'], equals(voidReason));

      final diff = auditEntry.changedFields;
      expect(diff['isVoided'], equals((false, true)));
    });

    test(
      'voidSale immutably records audit log with product and agreed value',
      () async {
        // 1. Record an active commercial sale
        final saleId = await saleRepository.recordSale(
          projectId: projectId,
          buyerId: buyerId,
          saleDate: DateTime(2026, 4, 5),
          productName: 'Roma Tomatoes Grade A',
          quantity: 50.0,
          unit: 'crates',
          unitPriceMinor: 2000, // 20.00 GHS per crate = 1,000 GHS total
          paymentStatus: SalePaymentStatus.unpaid,
          notes: 'Delivered to market stall',
        );

        // 2. Void the commercial sale
        const voidReason = 'Consignment rejected due to transport damage';
        await saleRepository.voidSale(saleId, reason: voidReason);

        // 3. Verify sale status
        final sale = await (db.select(
          db.salesTable,
        )..where((s) => s.id.equals(saleId))).getSingle();
        expect(sale.isVoided, isTrue);
        expect(sale.voidReason, equals(voidReason));

        // 4. Verify immutable audit entry
        final auditTrail = await auditRepository.getAuditTrailForEntity(
          entityTable: 'sales',
          entityId: saleId,
        );
        expect(auditTrail.length, equals(1));

        final entry = auditTrail.first;
        expect(entry.action, equals(AuditAction.voidRecord));
        expect(entry.entityTable, equals('sales'));
        expect(entry.reason, equals(voidReason));
        expect(
          entry.previousState?['productName'],
          equals('Roma Tomatoes Grade A'),
        );
        expect(entry.previousState?['totalAmountMinor'], equals(100000));
        expect(entry.previousState?['isVoided'], isFalse);
        expect(entry.newState?['isVoided'], isTrue);
        expect(entry.newState?['voidReason'], equals(voidReason));
      },
    );

    test(
      'voidPayment immutably records payment cancellation audit log',
      () async {
        // 1. Record a sale first
        final saleId = await saleRepository.recordSale(
          projectId: projectId,
          buyerId: buyerId,
          saleDate: DateTime(2026, 4, 5),
          productName: 'Sweet Bell Peppers',
          quantity: 20.0,
          unit: 'bags',
          unitPriceMinor: 5000, // 1,000 GHS
          paymentStatus: SalePaymentStatus.unpaid,
        );

        // 2. Record a partial payment
        final paymentId = await paymentRepository.recordPayment(
          saleId: saleId,
          paymentDate: DateTime(2026, 4, 6),
          amountMinor: 40000, // 400 GHS
          paymentMethod: PaymentMethod.bankTransfer,
          referenceNumber: 'TXN-998822',
          notes: 'Wire transfer advance',
        );

        // 3. Void the payment
        const voidReason = 'Dishonored wire transfer by bank';
        await paymentRepository.voidPayment(paymentId, reason: voidReason);

        // 4. Verify payment status
        final payment = await (db.select(
          db.paymentsTable,
        )..where((p) => p.id.equals(paymentId))).getSingle();
        expect(payment.isVoided, isTrue);
        expect(payment.voidReason, equals(voidReason));

        // 5. Verify immutable audit entry
        final auditTrail = await auditRepository.getAuditTrailForEntity(
          entityTable: 'payments',
          entityId: paymentId,
        );
        expect(auditTrail.length, equals(1));

        final entry = auditTrail.first;
        expect(entry.action, equals(AuditAction.voidRecord));
        expect(entry.entityTable, equals('payments'));
        expect(entry.reason, equals(voidReason));
        expect(entry.previousState?['amountMinor'], equals(40000));
        expect(entry.previousState?['isVoided'], isFalse);
        expect(entry.newState?['isVoided'], isTrue);
        expect(entry.newState?['voidReason'], equals(voidReason));
      },
    );
  });
}
