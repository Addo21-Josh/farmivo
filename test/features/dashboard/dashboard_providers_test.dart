import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/dashboard/domain/models/dashboard_financial_summary.dart';
import 'package:farmivo/features/dashboard/presentation/providers/dashboard_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'Dashboard financial summary starts zeroed when no data exists',
    () async {
      final summary = await container.read(
        dashboardFinancialSummaryProvider.future,
      );

      expect(summary.grossSalesValue.minorUnits, BigInt.zero);
      expect(summary.collectedRevenue.minorUnits, BigInt.zero);
      expect(summary.accountsReceivable.minorUnits, BigInt.zero);
      expect(summary.totalInvested.minorUnits, BigInt.zero);
      expect(summary.cashProfit.minorUnits, BigInt.zero);
      expect(summary.accrualProfit.minorUnits, BigInt.zero);
      expect(summary.collectionRatePercentage, 0.0);
      expect(summary.activeProjectsCount, 0);
    },
  );

  test(
    'Separates Gross Sales Value, Collected Revenue, and Accounts Receivable accurately',
    () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 0. Insert Farm & Category for FK constraints
      await db
          .into(db.farmsTable)
          .insert(
            FarmsTableCompanion.insert(
              id: 'farm-1',
              name: 'Main Ashanti Farm',
              location: 'Kumasi',
              region: 'Ashanti',
              ownershipType: 'OWNED',
              totalArea: 10.0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: 'cat-1',
              name: 'Inputs',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 1. Insert active project
      await db
          .into(db.projectsTable)
          .insert(
            ProjectsTableCompanion.insert(
              id: 'proj-1',
              farmId: 'farm-1',
              name: 'Kumasi Maize Venture',
              projectType: 'Crop',
              commodity: 'Maize',
              landSize: 5.0,
              startDate: now,
              currency: const Value('GHS'),
              status: const Value('ACTIVE'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 2. Insert Expenses: 1 active (1,000.00 GHS) and 1 voided (500.00 GHS)
      await db
          .into(db.expensesTable)
          .insert(
            ExpensesTableCompanion.insert(
              id: 'exp-1',
              projectId: 'proj-1',
              categoryId: 'cat-1',
              transactionDate: now,
              description: 'Fertilizers',
              amountMinor: 100000, // 1,000.00 GHS
              currency: const Value('GHS'),
              paymentMethod: 'CASH',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.expensesTable)
          .insert(
            ExpensesTableCompanion.insert(
              id: 'exp-void',
              projectId: 'proj-1',
              categoryId: 'cat-1',
              transactionDate: now,
              description: 'Duplicate expense',
              amountMinor: 50000,
              currency: const Value('GHS'),
              paymentMethod: 'CASH',
              isVoided: const Value(true),
              voidedAt: Value(now),
              voidReason: const Value('Duplicate voucher'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 3. Insert Sales:
      // Sale 1: GHS 3,000.00 (active)
      // Sale 2: GHS 2,000.00 (active)
      // Sale 3: GHS 1,000.00 (voided)
      await db
          .into(db.salesTable)
          .insert(
            SalesTableCompanion.insert(
              id: 'sale-1',
              projectId: 'proj-1',
              saleDate: now,
              productName: 'Yellow Maize',
              quantity: 30.0,
              unit: 'Bags',
              unitPriceMinor: 10000,
              totalAmountMinor: 300000, // 3,000.00 GHS
              currency: const Value('GHS'),
              paymentStatus: const Value('PARTIAL'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.salesTable)
          .insert(
            SalesTableCompanion.insert(
              id: 'sale-2',
              projectId: 'proj-1',
              saleDate: now,
              productName: 'White Maize',
              quantity: 20.0,
              unit: 'Bags',
              unitPriceMinor: 10000,
              totalAmountMinor: 200000, // 2,000.00 GHS
              currency: const Value('GHS'),
              paymentStatus: const Value('UNPAID'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.salesTable)
          .insert(
            SalesTableCompanion.insert(
              id: 'sale-void',
              projectId: 'proj-1',
              saleDate: now,
              productName: 'Spoiled Maize',
              quantity: 10.0,
              unit: 'Bags',
              unitPriceMinor: 10000,
              totalAmountMinor: 100000, // 1,000.00 GHS (voided)
              currency: const Value('GHS'),
              paymentStatus: const Value('UNPAID'),
              isVoided: const Value(true),
              voidedAt: Value(now),
              voidReason: const Value('Spoiled crop'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 4. Insert Payments for Sale 1:
      // Installment 1: GHS 1,500.00 (active)
      // Installment 2: GHS 500.00 (voided)
      await db
          .into(db.paymentsTable)
          .insert(
            PaymentsTableCompanion.insert(
              id: 'pay-1',
              saleId: 'sale-1',
              paymentDate: now,
              amountMinor: 150000, // 1,500.00 GHS
              currency: const Value('GHS'),
              paymentMethod: 'MOMO',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.paymentsTable)
          .insert(
            PaymentsTableCompanion.insert(
              id: 'pay-void',
              saleId: 'sale-1',
              paymentDate: now,
              amountMinor: 50000, // 500.00 GHS (voided)
              currency: const Value('GHS'),
              paymentMethod: 'CASH',
              isVoided: const Value(true),
              voidedAt: Value(now),
              voidReason: const Value('Test void'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final summary = await container.read(
        dashboardFinancialSummaryProvider.future,
      );

      // Gross Sales Value = 3,000 + 2,000 = 5,000.00 GHS (voided 1,000 excluded)
      expect(summary.grossSalesValue.minorUnits, BigInt.from(500000));
      expect(summary.grossSalesValue.format(), 'GH₵ 5,000.00');

      // Collected Revenue (Liquid Cash) = 1,500.00 GHS (voided 500 excluded)
      expect(summary.collectedRevenue.minorUnits, BigInt.from(150000));
      expect(summary.collectedRevenue.format(), 'GH₵ 1,500.00');

      // Accounts Receivable = 5,000 - 1,500 = 3,500.00 GHS
      expect(summary.accountsReceivable.minorUnits, BigInt.from(350000));
      expect(summary.accountsReceivable.format(), 'GH₵ 3,500.00');

      // Total Invested = 1,000.00 GHS (voided 500 excluded)
      expect(summary.totalInvested.minorUnits, BigInt.from(100000));
      expect(summary.totalInvested.format(), 'GH₵ 1,000.00');

      // Cash Profit = 1,500 - 1,000 = +500.00 GHS
      expect(summary.cashProfit.minorUnits, BigInt.from(50000));
      expect(summary.cashProfit.format(), 'GH₵ 500.00');
      expect(summary.cashRoiPercentage, 50.0);

      // Accrual Net Profit = 5,000 - 1,000 = +4,000.00 GHS
      expect(summary.accrualProfit.minorUnits, BigInt.from(400000));
      expect(summary.accrualProfit.format(), 'GH₵ 4,000.00');
      expect(summary.accrualRoiPercentage, 400.0);

      // Collection Rate = 1,500 / 5,000 * 100 = 30.0%
      expect(summary.collectionRatePercentage, 30.0);
      expect(summary.activeProjectsCount, 1);

      // 5. Reactive update test: Record another installment of GHS 1,000.00
      final emissions = <DashboardFinancialSummary>[];
      final sub = container.listen<AsyncValue<DashboardFinancialSummary>>(
        dashboardFinancialSummaryProvider,
        (previous, next) {
          next.whenData(emissions.add);
        },
      );

      await db
          .into(db.paymentsTable)
          .insert(
            PaymentsTableCompanion.insert(
              id: 'pay-2',
              saleId: 'sale-1',
              paymentDate: now,
              amountMinor: 100000, // 1,000.00 GHS
              currency: const Value('GHS'),
              paymentMethod: 'CASH',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Allow SQLite table update event to propagate
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final updatedSummary = emissions.last;

      // Collected cash now = 1,500 + 1,000 = 2,500.00 GHS
      expect(updatedSummary.collectedRevenue.minorUnits, BigInt.from(250000));
      expect(updatedSummary.collectedRevenue.format(), 'GH₵ 2,500.00');

      // Accounts receivable now = 5,000 - 2,500 = 2,500.00 GHS
      expect(updatedSummary.accountsReceivable.minorUnits, BigInt.from(250000));
      expect(updatedSummary.accountsReceivable.format(), 'GH₵ 2,500.00');

      // Cash profit now = 2,500 - 1,000 = +1,500.00 GHS
      expect(updatedSummary.cashProfit.minorUnits, BigInt.from(150000));

      // Collection rate now = 2,500 / 5,000 * 100 = 50.0%
      expect(updatedSummary.collectionRatePercentage, 50.0);

      sub.close();
    },
  );
}
