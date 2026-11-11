import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';
import 'package:farmivo/features/activities/domain/models/activity_with_details.dart';
import 'package:farmivo/features/audit/data/repositories/audit_log_repository_impl.dart';
import 'package:farmivo/features/audit/domain/models/audit_action.dart';
import 'package:farmivo/features/authentication/domain/services/security_repository.dart';
import 'package:farmivo/features/backup/domain/services/backup_archive_encoder.dart';
import 'package:farmivo/features/backup/domain/services/backup_restore_service.dart';
import 'package:farmivo/features/budgets/data/repositories/budget_item_repository_impl.dart';
import 'package:farmivo/features/buyers/data/repositories/buyer_repository_impl.dart';
import 'package:farmivo/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/harvests/data/repositories/harvest_repository_impl.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:farmivo/features/reports/domain/services/csv_report_generator.dart';
import 'package:farmivo/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';
import 'package:farmivo/features/settings/domain/services/data_wipe_service.dart';
import '../features/authentication/security_repository_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Milestone 10.1: Full Season Lifecycle End-to-End Integration Test', () {
    late AppDatabase db;
    late FakeFlutterSecureStorage fakeStorage;
    late Directory tempDir;

    // Repositories
    late BudgetItemRepositoryImpl budgetRepo;
    late ActivityRepositoryImpl activityRepo;
    late HarvestRepositoryImpl harvestRepo;
    late BuyerRepositoryImpl buyerRepo;
    late SaleRepositoryImpl saleRepo;
    late PaymentRepositoryImpl paymentRepo;
    late AuditLogRepositoryImpl auditRepo;
    late ExpenseRepositoryImpl expenseRepo;

    // Services
    late SecurityRepository securityRepo;
    late BackupRestoreService backupService;
    late DataWipeService wipeService;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      fakeStorage = FakeFlutterSecureStorage();
      tempDir = Directory.systemTemp.createTempSync('farmivo_e2e_season_');

      // Initialize all repositories & services
      budgetRepo = BudgetItemRepositoryImpl(db);
      activityRepo = ActivityRepositoryImpl(db: db);
      harvestRepo = HarvestRepositoryImpl(db: db);
      buyerRepo = BuyerRepositoryImpl(db: db);
      auditRepo = AuditLogRepositoryImpl(db: db);
      expenseRepo = ExpenseRepositoryImpl(db: db, auditRepository: auditRepo);
      saleRepo = SaleRepositoryImpl(db: db, auditRepository: auditRepo);
      paymentRepo = PaymentRepositoryImpl(db: db, auditRepository: auditRepo);

      securityRepo = SecurityRepository(storage: fakeStorage);
      backupService = BackupRestoreService(
        db: db,
        storage: fakeStorage,
        customBackupsDirectory: tempDir,
      );
      wipeService = DataWipeService(
        db: db,
        securityRepository: securityRepo,
        storage: fakeStorage,
        customBackupsDirectory: tempDir,
      );

      // Seed standard categories
      await db.seedDefaultBudgetCategories();
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'Simulates complete agricultural season lifecycle from setup to harvest, sale, audit, backup and recovery',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        const farmId = 'farm-e2e-1';
        const projectId = 'proj-e2e-1';

        // =======================================================================
        // STEP 1: Farm Landholding Setup
        // =======================================================================
        await db
            .into(db.farmsTable)
            .insert(
              FarmsTableCompanion.insert(
                id: farmId,
                name: 'Volta Green Farms',
                location: 'Ho, Volta Region',
                country: const Value('Ghana'),
                region: 'Volta',
                totalArea: 25.0,
                areaUnit: const Value('Acres'),
                ownershipType: 'OWNED',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final farm = await (db.select(
          db.farmsTable,
        )..where((f) => f.id.equals(farmId))).getSingle();
        expect(farm.name, equals('Volta Green Farms'));

        // =======================================================================
        // STEP 2: Agricultural Project Setup
        // =======================================================================
        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: projectId,
                farmId: farmId,
                name: 'Major Season Commercial Maize 2026',
                projectType: 'CROP',
                commodity: 'Maize',
                landSize: 20.0,
                landUnit: const Value('Acres'),
                currency: const Value('GHS'),
                startDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        final project = await (db.select(
          db.projectsTable,
        )..where((p) => p.id.equals(projectId))).getSingle();
        expect(project.status, equals('PLANNING'));

        // Fetch seeded budget categories
        final categories = await db.select(db.budgetCategoriesTable).get();
        expect(categories, isNotEmpty);
        final catLandPrep = categories.firstWhere(
          (c) => c.name.toLowerCase().contains('land'),
        );
        final catSeeds = categories.firstWhere(
          (c) => c.name.toLowerCase().contains('seed'),
        );
        final catFertilizer = categories.firstWhere(
          (c) => c.name.toLowerCase().contains('fertilizer'),
        );
        final catLabor = categories.firstWhere(
          (c) => c.name.toLowerCase().contains('labour'),
        );

        // =======================================================================
        // STEP 3: Pre-Season Budget Allocation (GH₵ 11,000 Total)
        // =======================================================================
        final bItemLand = await budgetRepo.createBudgetItem(
          projectId: project.id,
          categoryId: catLandPrep.id,
          name: 'Tractor Ploughing & Harrowing',
          quantity: 1.0,
          unit: 'service',
          unitCostMinor: 250000, // GH₵ 2,500
        );
        final bItemSeeds = await budgetRepo.createBudgetItem(
          projectId: project.id,
          categoryId: catSeeds.id,
          name: 'Pannar 53 Certified Hybrid Seed',
          quantity: 10.0,
          unit: 'bags',
          unitCostMinor: 15000, // GH₵ 1,500
        );
        final bItemFertilizer = await budgetRepo.createBudgetItem(
          projectId: project.id,
          categoryId: catFertilizer.id,
          name: 'NPK 15-15-15 & Urea Bags',
          quantity: 10.0,
          unit: 'bags',
          unitCostMinor: 40000, // GH₵ 4,000
        );
        final bItemLabor = await budgetRepo.createBudgetItem(
          projectId: project.id,
          categoryId: catLabor.id,
          name: 'Casual Weeding & Top Dressing Labor',
          quantity: 30.0,
          unit: 'person-days',
          unitCostMinor: 10000, // GH₵ 3,000
        );

        final budgetItems = await budgetRepo.getByProjectWithCategory(
          project.id,
        );
        expect(budgetItems.length, equals(4));
        final totalBudgetMinor = budgetItems.fold<int>(
          0,
          (int sum, item) => sum + item.item.plannedAmountMinor,
        );
        expect(totalBudgetMinor, equals(1100000)); // Exactly GH₵ 11,000

        // =======================================================================
        // STEP 4: Field Operations Logging
        // =======================================================================
        await activityRepo.recordActivity(
          projectId: project.id,
          title: 'Mechanical Land Clearing & Ploughing',
          activityType: ActivityType.landPreparation,
          activityDate: DateTime(2026, 3, 5),
          status: ActivityStatus.completed,
        );
        await activityRepo.recordActivity(
          projectId: project.id,
          title: 'Precision Planting of Maize',
          activityType: ActivityType.planting,
          activityDate: DateTime(2026, 3, 10),
          status: ActivityStatus.completed,
        );
        await activityRepo.recordActivity(
          projectId: project.id,
          title: 'First Fertilizer Application',
          activityType: ActivityType.fertilizing,
          activityDate: DateTime(2026, 3, 25),
          status: ActivityStatus.completed,
        );

        final activities = await activityRepo
            .watchActivities(projectId: project.id)
            .first;
        expect(activities.length, equals(3));
        expect(
          activities.every(
            (ActivityWithDetails a) => a.activity.status == 'COMPLETED',
          ),
          isTrue,
        );

        // =======================================================================
        // STEP 5: Operating Expenses Tracking
        // =======================================================================
        await expenseRepo.recordExpense(
          projectId: project.id,
          categoryId: catLandPrep.id,
          budgetItemId: bItemLand.id,
          transactionDate: DateTime(2026, 3, 7),
          description: 'Tractor Contractor Invoice',
          amountMinor: 250000, // GH₵ 2,500
          paymentMethod: PaymentMethod.bankTransfer,
        );

        await expenseRepo.recordExpense(
          projectId: project.id,
          categoryId: catSeeds.id,
          budgetItemId: bItemSeeds.id,
          transactionDate: DateTime(2026, 3, 9),
          description: 'Pannar Seeds Seedlings Agrico',
          amountMinor: 150000, // GH₵ 1,500
          paymentMethod: PaymentMethod.mtnMoMo,
        );

        final initialFertilizerExpenseId = await expenseRepo.recordExpense(
          projectId: project.id,
          categoryId: catFertilizer.id,
          budgetItemId: bItemFertilizer.id,
          transactionDate: DateTime(2026, 3, 24),
          description: 'Fertilizer Input Depot',
          amountMinor: 400000, // GH₵ 4,000
          paymentMethod: PaymentMethod.mtnMoMo,
        );

        // =======================================================================
        // STEP 6: Mid-Season Forensic Audit Void & Supplier Rebate Adjustment
        // =======================================================================
        // Input supplier gave a GH₵ 500 seasonal subsidy discount voucher
        const voidReason =
            'Replaced invoice with GH₵ 500 government subsidy discount';
        await expenseRepo.voidExpense(
          id: initialFertilizerExpenseId,
          reason: voidReason,
        );

        // Check audit log trail
        final auditTrail = await auditRepo.getAuditTrailForEntity(
          entityTable: 'expenses',
          entityId: initialFertilizerExpenseId,
        );
        expect(auditTrail.length, equals(1));
        expect(auditTrail.first.action, equals(AuditAction.voidRecord));
        expect(auditTrail.first.reason, equals(voidReason));
        expect(
          auditTrail.first.changedFields['isVoided'],
          equals((false, true)),
        );

        // Record adjusted discounted expense
        await expenseRepo.recordExpense(
          projectId: project.id,
          categoryId: catFertilizer.id,
          budgetItemId: bItemFertilizer.id,
          transactionDate: DateTime(2026, 3, 25),
          description: 'Fertilizer Input Depot (Subsidy Voucher Applied)',
          amountMinor: 350000, // GH₵ 3,500 (GH₵ 500 savings)
          paymentMethod: PaymentMethod.mtnMoMo,
        );

        await expenseRepo.recordExpense(
          projectId: project.id,
          categoryId: catLabor.id,
          budgetItemId: bItemLabor.id,
          transactionDate: DateTime(2026, 4, 15),
          description: 'Casual Field Weeding Laborers',
          amountMinor: 300000, // GH₵ 3,000
          paymentMethod: PaymentMethod.cash,
        );

        // Verify active expenses (excluding voided)
        final allExpenses =
            await (db.select(db.expensesTable)..where(
                  (e) =>
                      e.projectId.equals(project.id) &
                      e.isDeleted.equals(false),
                ))
                .get();
        final activeExpenses = allExpenses.where((e) => !e.isVoided).toList();
        expect(activeExpenses.length, equals(4));
        final totalActiveSpentMinor = activeExpenses.fold<int>(
          0,
          (int sum, e) => sum + e.amountMinor,
        );
        expect(
          totalActiveSpentMinor,
          equals(1050000),
        ); // GH₵ 10,500 (under budget by GH₵ 500)

        // Variance Calculation:
        final plannedBudget = Money.fromMajor(11000);
        final actualSpent = Money.fromMajor(10500);
        final variance = FinancialCalculator.calculateVariance(
          plannedBudget,
          actualSpent,
        );
        final variancePct = FinancialCalculator.calculateVariancePercentage(
          plannedBudget,
          actualSpent,
        );
        expect(variance.toMajor(), equals(-500.0)); // GH₵ 500 savings
        expect(variancePct, closeTo(-4.54, 0.01));

        // =======================================================================
        // STEP 7: Crop Harvesting & Yield Batching
        // =======================================================================
        final harvestId = await harvestRepo.recordHarvest(
          projectId: project.id,
          batchNumber: 'HV-MAIZE-26-01',
          harvestDate: DateTime(2026, 6, 20),
          productName: 'White Maize Grain',
          quantity: 200.0,
          unit: 'bags',
          grade: HarvestGrade.gradeA,
          storageLocation: 'Ho Central Silo 2',
        );
        expect(harvestId, isNotEmpty);

        // =======================================================================
        // STEP 8: Commercial Buyer Registration
        // =======================================================================
        final buyerId = await buyerRepo.createBuyer(
          name: 'Agrico Wholesale & Processing Ltd',
          phone: '0244112233',
          businessName: 'Agrico Grains',
          location: 'Accra Central',
        );
        expect(buyerId, isNotEmpty);

        // =======================================================================
        // STEP 9: Commercial Sale Agreement (200 Bags @ GH₵ 150 = GH₵ 30,000)
        // =======================================================================
        // Buyer makes an initial deposit of GH₵ 10,000; GH₵ 20,000 remains outstanding
        final saleId = await saleRepo.recordSale(
          projectId: project.id,
          buyerId: buyerId,
          harvestId: harvestId,
          saleDate: DateTime(2026, 6, 22),
          productName: 'White Maize Grain (Grade A)',
          quantity: 200.0,
          unit: 'bags',
          unitPriceMinor: 15000, // GH₵ 150.00/bag
          paymentStatus: SalePaymentStatus.partial,
          initialPaymentAmountMinor: 1000000, // GH₵ 10,000.00 deposit
          paymentMethod: 'BANK',
        );

        final saleDetails = await saleRepo.getSaleById(saleId);
        expect(saleDetails, isNotNull);
        expect(
          saleDetails!.sale.totalAmountMinor,
          equals(3000000),
        ); // GH₵ 30,000
        expect(saleDetails.totalPaidMinor, equals(1000000)); // GH₵ 10,000 paid

        // =======================================================================
        // STEP 10: Debt Collection & Final Settlement
        // =======================================================================
        await paymentRepo.recordPayment(
          saleId: saleId,
          paymentDate: DateTime(2026, 6, 28),
          amountMinor: 2000000, // Final GH₵ 20,000 installment
          paymentMethod: PaymentMethod.telecelCash,
          referenceNumber: 'MOMO-SETTLE-8899',
          notes: 'Final balance settlement',
        );

        final settledSale = await saleRepo.getSaleById(saleId);
        expect(settledSale!.sale.paymentStatus, equals('PAID'));
        expect(settledSale.totalPaidMinor, equals(3000000)); // 100% paid

        // =======================================================================
        // STEP 11: End-of-Season Profitability & Health Scoring
        // =======================================================================
        final totalRevenue = Money.fromMajor(30000);
        final netProfit = totalRevenue - actualSpent;
        expect(netProfit.toMajor(), equals(19500.0)); // GH₵ 19,500.00 profit

        final roi = FinancialCalculator.calculateProjectedRoi(
          netProfit,
          actualSpent,
        );
        expect(roi, closeTo(185.71, 0.05)); // 185.7% ROI

        final health = ProjectHealthEvaluation.compute(
          plannedBudget: plannedBudget,
          actualSpent: actualSpent,
          expectedRevenue: totalRevenue,
          actualSales: totalRevenue,
          cashCollected: totalRevenue,
          completedActivities: 3,
          totalActivities: 3,
        );
        expect(health.score, greaterThanOrEqualTo(85));
        expect(health.status, equals(ProjectHealthStatus.healthy));

        // =======================================================================
        // STEP 12: Executive CSV Report Generation
        // =======================================================================
        final detailedSales = await saleRepo.getSales(projectId: project.id);
        final salesCsv = CsvReportGenerator.generateSalesCsv(
          detailedSales,
          projectName: project.name,
        );
        expect(salesCsv.contains('White Maize Grain (Grade A)'), isTrue);
        expect(salesCsv.contains('30000'), isTrue); // Commercial agreed amount

        // =======================================================================
        // STEP 13: Encrypted Database Snapshot Backup
        // =======================================================================
        final backupResult = await backupService.createBackup(
          customFileName: 'end_of_season_2026.farmivo',
        );
        expect(backupResult.success, isTrue);
        expect(backupResult.snapshot, isNotNull);
        expect(File(backupResult.snapshot!.filePath).existsSync(), isTrue);

        // Verify backup magic header
        final backupBytes = await File(
          backupResult.snapshot!.filePath,
        ).readAsBytes();
        expect(
          listEquals(
            backupBytes.sublist(0, 8),
            BackupArchiveEncoder.magicHeader,
          ),
          isTrue,
        );

        // =======================================================================
        // STEP 14: Emergency Data Wipe (Factory Reset)
        // =======================================================================
        final wipeResult = await wipeService.executeFactoryReset(
          deleteBackups: false,
        );
        expect(wipeResult.success, isTrue);
        expect(wipeResult.tablesCleared, greaterThanOrEqualTo(16));

        // Confirm all transactional records wiped
        expect(await db.select(db.farmsTable).get(), isEmpty);
        expect(await db.select(db.projectsTable).get(), isEmpty);
        expect(await db.select(db.expensesTable).get(), isEmpty);
        expect(await db.select(db.salesTable).get(), isEmpty);
        expect(await db.select(db.paymentsTable).get(), isEmpty);

        // =======================================================================
        // STEP 15: Database Restoration & Complete Data Recovery Verification
        // =======================================================================
        final restoreResult = await backupService.restoreFromSnapshot(
          backupResult.snapshot!,
        );
        expect(restoreResult.success, isTrue);

        // Verify 100% data fidelity post-restore
        final restoredFarms = await db.select(db.farmsTable).get();
        final restoredProjects = await db.select(db.projectsTable).get();
        final restoredExpenses = await db.select(db.expensesTable).get();
        final restoredSales = await db.select(db.salesTable).get();
        final restoredPayments = await db.select(db.paymentsTable).get();
        final restoredAudit = await db.select(db.auditLogsTable).get();

        expect(restoredFarms.length, equals(1));
        expect(restoredFarms.first.name, equals('Volta Green Farms'));

        expect(restoredProjects.length, equals(1));
        expect(
          restoredProjects.first.name,
          equals('Major Season Commercial Maize 2026'),
        );

        // Both active and voided expenses restored
        expect(restoredExpenses.length, equals(5));

        expect(restoredSales.length, equals(1));
        expect(restoredSales.first.totalAmountMinor, equals(3000000));

        expect(restoredPayments.length, equals(2));

        // Audit log restored
        expect(restoredAudit.length, equals(1));
        expect(restoredAudit.first.action, equals('VOID'));
        expect(restoredAudit.first.reason, equals(voidReason));
      },
    );
  });
}
