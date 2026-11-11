import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Drift SQLite Database Integration Tests (Milestone 10.1)', () {
    late AppDatabase db;
    late SaleRepositoryImpl saleRepo;

    const farmId = 'farm-int-1';
    const projectId = 'proj-int-1';
    const catId = 'cat-int-1';
    const buyerId = 'buyer-int-1';

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      saleRepo = SaleRepositoryImpl(db: db);

      final now = DateTime.now().millisecondsSinceEpoch;

      // Seed standard farm and category
      await db
          .into(db.farmsTable)
          .insert(
            FarmsTableCompanion.insert(
              id: farmId,
              name: 'Integration Farm',
              location: 'Ho',
              country: const Value('Ghana'),
              region: 'Volta',
              totalArea: 20.0,
              areaUnit: const Value('Acres'),
              ownershipType: 'OWNED',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: catId,
              name: 'Crop Protection',
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
              name: 'Maize 2026',
              projectType: 'CROP',
              commodity: 'Maize',
              landSize: 10.0,
              startDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.buyersTable)
          .insert(
            BuyersTableCompanion.insert(
              id: buyerId,
              name: 'Volta Grains Ltd',
              phone: const Value('0240001122'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Foreign key constraints reject inserting project with nonexistent farm',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        expect(
          () => db
              .into(db.projectsTable)
              .insert(
                ProjectsTableCompanion.insert(
                  id: 'orphan-project',
                  farmId: 'NON_EXISTENT_FARM_UUID',
                  name: 'Orphan Crop',
                  projectType: 'CROP',
                  commodity: 'Cassava',
                  landSize: 2.0,
                  startDate: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test(
      'Drift transaction guarantees full rollback upon failure in multi-step operation',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        final countBefore = (await db.select(db.budgetItemsTable).get()).length;

        try {
          await db.transaction(() async {
            // Step 1: Insert valid budget item
            await db
                .into(db.budgetItemsTable)
                .insert(
                  BudgetItemsTableCompanion.insert(
                    id: 'valid-item-1',
                    projectId: projectId,
                    categoryId: catId,
                    name: 'Insecticide Spray',
                    quantity: 1.0,
                    unit: 'liters',
                    unitCostMinor: 25000,
                    plannedAmountMinor: 25000,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );

            // Step 2: Simulate failure (e.g. invalid foreign key or deliberate throw)
            throw Exception('Simulated mid-transaction failure');
          });
        } catch (_) {
          // Expected transaction exception
        }

        // Verify that Step 1 was completely rolled back and not persisted
        final countAfter = (await db.select(db.budgetItemsTable).get()).length;
        expect(countAfter, equals(countBefore));

        final rolledBackItem = await (db.select(
          db.budgetItemsTable,
        )..where((i) => i.id.equals('valid-item-1'))).getSingleOrNull();
        expect(rolledBackItem, isNull);
      },
    );

    test(
      'voidSale cascade soft-voids linked payments while preserving historical rows',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        // 1. Record a sale
        final saleId = await saleRepo.recordSale(
          projectId: projectId,
          buyerId: buyerId,
          saleDate: DateTime(2026, 5, 10),
          productName: 'Yellow Maize',
          quantity: 100.0,
          unit: 'bags',
          unitPriceMinor: 15000, // 15,000 GHS
          paymentStatus: SalePaymentStatus.paid,
        );

        // 2. Add an explicit payment linked to this sale
        await db
            .into(db.paymentsTable)
            .insert(
              PaymentsTableCompanion.insert(
                id: 'payment-linked-1',
                saleId: saleId,
                paymentDate: now,
                amountMinor: 500000,
                paymentMethod: 'CASH',
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Verify both are active and not voided
        var sale = await (db.select(
          db.salesTable,
        )..where((s) => s.id.equals(saleId))).getSingle();
        var payment = await (db.select(
          db.paymentsTable,
        )..where((p) => p.id.equals('payment-linked-1'))).getSingle();
        expect(sale.isVoided, isFalse);
        expect(payment.isVoided, isFalse);

        // 3. Void the sale
        await saleRepo.voidSale(saleId, reason: 'Buyer cancelled delivery');

        // 4. Verify that sale AND linked payments are now soft-voided with reasons
        sale = await (db.select(
          db.salesTable,
        )..where((s) => s.id.equals(saleId))).getSingle();
        payment = await (db.select(
          db.paymentsTable,
        )..where((p) => p.id.equals('payment-linked-1'))).getSingle();

        expect(sale.isVoided, isTrue);
        expect(sale.voidReason, equals('Buyer cancelled delivery'));

        expect(payment.isVoided, isTrue);
        expect(payment.voidReason?.contains('Sale voided'), isTrue);

        // Crucial: records still exist in database for forensic accounting (NOT hard-deleted)
        final allSales = await db.select(db.salesTable).get();
        final allPayments = await db.select(db.paymentsTable).get();
        expect(allSales.any((s) => s.id == saleId), isTrue);
        expect(allPayments.any((p) => p.id == 'payment-linked-1'), isTrue);
      },
    );
  });
}
