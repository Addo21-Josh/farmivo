import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';

void main() {
  group('ProjectMetrics Unit Tests', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final sevenDaysAgo = DateTime.now()
        .subtract(const Duration(days: 7))
        .millisecondsSinceEpoch;

    final testProject = Project(
      id: 'proj-1',
      farmId: 'farm-1',
      name: 'Test Pepper Venture',
      projectType: 'Crop',
      commodity: 'Pepper',
      variety: 'Scotch Bonnet',
      landSize: 2.0,
      landUnit: 'Acres',
      startDate: sevenDaysAgo,
      expectedCompletionDate: null,
      expectedFirstHarvestDate: null,
      currency: 'GHS',
      status: 'PRODUCTION',
      description: 'Pepper test project',
      notes: null,
      createdAt: sevenDaysAgo,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );

    test('Computes days active and stages correctly', () {
      final metrics = ProjectMetrics.compute(
        project: testProject,
        budgetItems: const [],
        expenses: const [],
        activities: const [],
        harvests: const [],
        sales: const [],
      );

      expect(metrics.daysActive, 7);
      expect(metrics.stage, ProjectLifecycleState.production);
      expect(metrics.totalBudgeted.minorUnits, BigInt.zero);
      expect(metrics.totalSpent.minorUnits, BigInt.zero);
      expect(metrics.totalRevenue.minorUnits, BigInt.zero);
      expect(metrics.netProfit.minorUnits, BigInt.zero);
      expect(
        metrics.projectedYieldDisplay,
        '~240 Bags',
      ); // 2.0 acres * 120 bags/acre
      expect(metrics.healthStatus, ProjectHealthStatus.healthy);
    });

    test('Sums budget items accurately in minor units', () {
      final budgetItems = [
        BudgetItem(
          id: 'b-1',
          projectId: 'proj-1',
          categoryId: 'cat-1',
          name: 'Seeds',
          description: null,
          quantity: 2.0,
          unit: 'packets',
          unitCostMinor: 5000, // 50.00 GHS
          plannedAmountMinor: 10000, // 100.00 GHS
          currency: 'GHS',
          status: 'PLANNED',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
        BudgetItem(
          id: 'b-2',
          projectId: 'proj-1',
          categoryId: 'cat-2',
          name: 'Fertilizer',
          description: null,
          quantity: 4.0,
          unit: 'bags',
          unitCostMinor: 25000, // 250.00 GHS
          plannedAmountMinor: 100000, // 1,000.00 GHS
          currency: 'GHS',
          status: 'PLANNED',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
        // Deleted item should be ignored
        BudgetItem(
          id: 'b-deleted',
          projectId: 'proj-1',
          categoryId: 'cat-2',
          name: 'Old Fertilizer',
          description: null,
          quantity: 1.0,
          unit: 'bags',
          unitCostMinor: 20000,
          plannedAmountMinor: 20000,
          currency: 'GHS',
          status: 'PLANNED',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: true,
        ),
      ];

      final metrics = ProjectMetrics.compute(
        project: testProject,
        budgetItems: budgetItems,
        expenses: const [],
        activities: const [],
        harvests: const [],
        sales: const [],
      );

      // 10,000 + 100,000 = 110,000 minor units = 1,100.00 GHS
      expect(metrics.totalBudgeted.minorUnits, BigInt.from(110000));
      expect(metrics.totalBudgeted.format(), 'GH₵ 1,100.00');
    });

    test(
      'Sums expenses excluding voided and calculates budget utilization',
      () {
        final budgetItems = [
          BudgetItem(
            id: 'b-1',
            projectId: 'proj-1',
            categoryId: 'cat-1',
            name: 'Land Prep',
            description: null,
            quantity: 1.0,
            unit: 'service',
            unitCostMinor: 100000, // 1,000.00 GHS
            plannedAmountMinor: 100000,
            currency: 'GHS',
            status: 'PLANNED',
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final expenses = [
          Expense(
            id: 'e-1',
            projectId: 'proj-1',
            categoryId: 'cat-1',
            budgetItemId: 'b-1',
            activityId: null,
            transactionDate: now,
            description: 'Tractor Ploughing',
            quantity: 1.0,
            unit: 'service',
            unitCostMinor: 85000,
            amountMinor: 85000, // 850.00 GHS (85% of budget)
            currency: 'GHS',
            paymentMethod: 'MOMO',
            vendorName: 'Operator',
            receiptPhotoPath: null,
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
          Expense(
            id: 'e-voided',
            projectId: 'proj-1',
            categoryId: 'cat-1',
            budgetItemId: 'b-1',
            activityId: null,
            transactionDate: now,
            description: 'Accidental Duplicate',
            quantity: 1.0,
            unit: null,
            unitCostMinor: null,
            amountMinor: 85000,
            currency: 'GHS',
            paymentMethod: 'CASH',
            vendorName: null,
            receiptPhotoPath: null,
            notes: null,
            isVoided: true,
            voidedAt: now,
            voidReason: 'Duplicate entry',
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final metrics = ProjectMetrics.compute(
          project: testProject,
          budgetItems: budgetItems,
          expenses: expenses,
          activities: const [],
          harvests: const [],
          sales: const [],
        );

        expect(metrics.totalSpent.minorUnits, BigInt.from(85000));
        expect(metrics.totalSpent.format(), 'GH₵ 850.00');
        expect(metrics.budgetSpentPercentage, 85.0);
        expect(
          metrics.healthStatus,
          ProjectHealthStatus.watch,
        ); // >= 80% triggers watch
      },
    );

    test('Triggers atRisk health on budget overrun (> 100%)', () {
      final budgetItems = [
        BudgetItem(
          id: 'b-1',
          projectId: 'proj-1',
          categoryId: 'cat-1',
          name: 'Inputs',
          description: null,
          quantity: 1.0,
          unit: 'lot',
          unitCostMinor: 50000, // 500.00 GHS
          plannedAmountMinor: 50000,
          currency: 'GHS',
          status: 'PLANNED',
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final expenses = [
        Expense(
          id: 'e-1',
          projectId: 'proj-1',
          categoryId: 'cat-1',
          budgetItemId: 'b-1',
          activityId: null,
          transactionDate: now,
          description: 'Emergency input purchase',
          quantity: 1.0,
          unit: 'lot',
          unitCostMinor: 65000,
          amountMinor: 65000, // 650.00 GHS (130% of budget)
          currency: 'GHS',
          paymentMethod: 'CASH',
          vendorName: null,
          receiptPhotoPath: null,
          notes: null,
          isVoided: false,
          voidedAt: null,
          voidReason: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final metrics = ProjectMetrics.compute(
        project: testProject,
        budgetItems: budgetItems,
        expenses: expenses,
        activities: const [],
        harvests: const [],
        sales: const [],
      );

      expect(metrics.budgetSpentPercentage, 130.0);
      expect(metrics.healthStatus, ProjectHealthStatus.atRisk);
      expect(metrics.healthMessage, contains('Budget overrun by 30.0%'));
    });

    test('Calculates sales revenue, unpaid receivables, and ROI %', () {
      final expenses = [
        Expense(
          id: 'e-1',
          projectId: 'proj-1',
          categoryId: 'cat-1',
          budgetItemId: null,
          activityId: null,
          transactionDate: now,
          description: 'Total Operational Costs',
          quantity: 1.0,
          unit: null,
          unitCostMinor: 100000,
          amountMinor: 100000, // 1,000.00 GHS spent
          currency: 'GHS',
          paymentMethod: 'CASH',
          vendorName: null,
          receiptPhotoPath: null,
          notes: null,
          isVoided: false,
          voidedAt: null,
          voidReason: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final sales = [
        Sale(
          id: 's-1',
          projectId: 'proj-1',
          buyerId: null,
          harvestId: null,
          saleDate: now,
          productName: 'Pepper',
          quantity: 20.0,
          unit: 'Bags',
          unitPriceMinor: 5000,
          totalAmountMinor: 100000, // 1,000.00 GHS
          currency: 'GHS',
          paymentStatus: 'PAID',
          notes: null,
          isVoided: false,
          voidedAt: null,
          voidReason: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
        Sale(
          id: 's-2',
          projectId: 'proj-1',
          buyerId: null,
          harvestId: null,
          saleDate: now,
          productName: 'Pepper',
          quantity: 10.0,
          unit: 'Bags',
          unitPriceMinor: 5000,
          totalAmountMinor: 50000, // 500.00 GHS (unpaid credit)
          currency: 'GHS',
          paymentStatus: 'UNPAID',
          notes: null,
          isVoided: false,
          voidedAt: null,
          voidReason: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        ),
      ];

      final metrics = ProjectMetrics.compute(
        project: testProject,
        budgetItems: const [],
        expenses: expenses,
        activities: const [],
        harvests: const [],
        sales: sales,
      );

      // Total Revenue = 1,000 + 500 = 1,500.00 GHS (150,000 minor)
      expect(metrics.totalRevenue.minorUnits, BigInt.from(150000));
      // Net Profit = 1,500 - 1,000 = +500.00 GHS
      expect(metrics.netProfit.minorUnits, BigInt.from(50000));
      expect(metrics.netProfit.isPositive, true);
      // ROI = 500 / 1,000 * 100 = 50.0%
      expect(metrics.roiPercentage, 50.0);
      // Unpaid = 500.00 GHS
      expect(metrics.unpaidReceivables.minorUnits, BigInt.from(50000));
      expect(metrics.healthStatus, ProjectHealthStatus.healthy);
    });

    test(
      'Switches projected yield to actual harvested once harvests exist',
      () {
        final harvests = [
          Harvest(
            id: 'h-1',
            projectId: 'proj-1',
            batchNumber: 'BATCH-001',
            harvestDate: now,
            productName: 'Fresh Pepper',
            quantity: 35.0,
            unit: 'Bags',
            grade: 'Grade A',
            storageLocation: 'Shed 1',
            notes: null,
            photoPath: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final metrics = ProjectMetrics.compute(
          project: testProject,
          budgetItems: const [],
          expenses: const [],
          activities: const [],
          harvests: harvests,
          sales: const [],
        );

        expect(metrics.harvestBatchesCount, 1);
        expect(metrics.actualYieldTotal, 35.0);
        expect(metrics.actualYieldUnit, 'Bags');
        expect(metrics.projectedYieldDisplay, '35 Bags');
      },
    );

    test(
      'Strictly separates gross sales, collected cash, and accounts receivable (Milestone 6.4)',
      () {
        final expenses = [
          Expense(
            id: 'exp-1',
            projectId: 'proj-1',
            categoryId: 'cat-1',
            budgetItemId: null,
            activityId: null,
            transactionDate: now,
            description: 'Fertilizers and fuel',
            quantity: 1.0,
            unit: 'lot',
            unitCostMinor: 100000, // 1,000.00 GHS
            amountMinor: 100000,
            currency: 'GHS',
            paymentMethod: 'CASH',
            vendorName: null,
            receiptPhotoPath: null,
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final sales = [
          Sale(
            id: 'sale-1',
            projectId: 'proj-1',
            harvestId: null,
            buyerId: 'buyer-1',
            saleDate: now,
            productName: 'Pepper Bags',
            quantity: 20.0,
            unit: 'Bags',
            unitPriceMinor: 10000, // 100.00 GHS per bag = 2,000.00 GHS total
            totalAmountMinor: 200000,
            currency: 'GHS',
            paymentStatus: 'PARTIAL',
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final payments = [
          Payment(
            id: 'pay-1',
            saleId: 'sale-1',
            paymentDate: now,
            amountMinor: 80000, // 800.00 GHS active installment
            currency: 'GHS',
            paymentMethod: 'MOMO',
            referenceNumber: 'TX-01',
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
          Payment(
            id: 'pay-2',
            saleId: 'sale-1',
            paymentDate: now,
            amountMinor: 40000, // 400.00 GHS active installment
            currency: 'GHS',
            paymentMethod: 'CASH',
            referenceNumber: null,
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
          Payment(
            id: 'pay-void',
            saleId: 'sale-1',
            paymentDate: now,
            amountMinor: 30000, // 300.00 GHS voided
            currency: 'GHS',
            paymentMethod: 'CASH',
            referenceNumber: null,
            notes: 'Erroneous entry',
            isVoided: true,
            voidedAt: now,
            voidReason: 'Disputed MoMo slip',
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final metrics = ProjectMetrics.compute(
          project: testProject,
          budgetItems: const [],
          expenses: expenses,
          activities: const [],
          harvests: const [],
          sales: sales,
          payments: payments,
        );

        // 1. Gross Sales Value
        expect(metrics.grossSales.minorUnits, BigInt.from(200000));
        expect(metrics.totalRevenue.format(), 'GH₵ 2,000.00');

        // 2. Collected Revenue (Liquid Cash) = 800 + 400 = 1,200.00 GHS (voided 300 ignored)
        expect(metrics.collectedRevenue.minorUnits, BigInt.from(120000));
        expect(metrics.collectedRevenue.format(), 'GH₵ 1,200.00');

        // 3. Accounts Receivable (Money owed) = 2,000 - 1,200 = 800.00 GHS
        expect(metrics.accountsReceivable.minorUnits, BigInt.from(80000));
        expect(metrics.accountsReceivable.format(), 'GH₵ 800.00');
        expect(metrics.unpaidReceivables.minorUnits, BigInt.from(80000));

        // 4. Collection Rate % = 1,200 / 2,000 = 60.0%
        expect(metrics.collectionRatePercentage, 60.0);

        // 5. Net Profit (Accrual) = 2,000 - 1,000 = +1,000.00 GHS
        expect(metrics.accrualProfit.minorUnits, BigInt.from(100000));
        expect(metrics.roiPercentage, 100.0);

        // 6. Cash Profit (Cash Basis) = 1,200 - 1,000 = +200.00 GHS
        expect(metrics.cashProfit.minorUnits, BigInt.from(20000));
        expect(metrics.cashRoiPercentage, 20.0);
      },
    );

    test(
      'Computes DynamicBreakEven indicators accurately in ProjectMetrics.compute',
      () {
        // Setup:
        // Total expenses: GH₵ 3,000.00
        // Sales: 10 bags for GH₵ 1,500.00 (Price = GH₵ 150/bag)
        // Collected: GH₵ 1,000.00
        // Forecast Scenario: Expected 30 bags @ GH₵ 150/bag
        // Harvested to date: 10 bags
        final expenses = [
          Expense(
            id: 'exp-1',
            projectId: 'proj-1',
            categoryId: 'cat-1',
            budgetItemId: null,
            activityId: null,
            transactionDate: now,
            description: 'Fertilizers',
            quantity: 1.0,
            unit: 'lot',
            unitCostMinor: 300000, // 3,000.00 GHS
            amountMinor: 300000,
            currency: 'GHS',
            paymentMethod: 'CASH',
            vendorName: null,
            receiptPhotoPath: null,
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final sales = [
          Sale(
            id: 's-1',
            projectId: 'proj-1',
            harvestId: null,
            buyerId: 'buyer-1',
            saleDate: now,
            productName: 'Pepper Bags',
            quantity: 10.0,
            unit: 'Bags',
            unitPriceMinor: 15000, // 150.00 GHS
            totalAmountMinor: 150000, // 1,500.00 GHS
            currency: 'GHS',
            paymentStatus: 'PARTIAL',
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final payments = [
          Payment(
            id: 'pay-1',
            saleId: 's-1',
            paymentDate: now,
            amountMinor: 100000, // 1,000.00 GHS
            currency: 'GHS',
            paymentMethod: 'MOMO',
            referenceNumber: null,
            notes: null,
            isVoided: false,
            voidedAt: null,
            voidReason: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final harvests = [
          Harvest(
            id: 'h-1',
            projectId: 'proj-1',
            batchNumber: 'BATCH-001',
            harvestDate: now,
            productName: 'Fresh Pepper',
            quantity: 10.0,
            unit: 'Bags',
            grade: 'Grade A',
            storageLocation: 'Shed 1',
            notes: null,
            photoPath: null,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ];

        final forecast = Scenario(
          id: 'sc-1',
          projectId: 'proj-1',
          scenarioType: 'EXPECTED',
          expectedYield: 30.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 15000,
          projectedRevenueMinor: 450000,
          projectedCostMinor: 300000,
          projectedProfitMinor: 150000,
          projectedRoiPercent: 50.0,
          notes: null,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        );

        final metrics = ProjectMetrics.compute(
          project: testProject,
          budgetItems: const [],
          expenses: expenses,
          activities: const [],
          harvests: harvests,
          sales: sales,
          payments: payments,
          forecastScenario: forecast,
        );

        // Verify dynamic break-even:
        // Costs: 3,000, Sales: 1,500, Cash: 1,000
        // Accrual deficit = 3,000 - 1,500 = 1,500.00 GHS
        expect(metrics.isBreakEvenAchieved, isFalse);
        expect(metrics.unrecoveredCostDeficit.toMajor(), 1500.0);
        expect(metrics.dynamicBreakEven.cashDeficit.toMajor(), 2000.0);

        // Effective unit price = 1,500 / 10 = GH₵ 150.00
        expect(metrics.dynamicBreakEven.effectiveUnitPrice.toMajor(), 150.0);

        // Remaining units to break-even = 1,500 / 150 = 10 Bags
        expect(metrics.remainingUnitsToBreakEven, 10.0);
        expect(metrics.dynamicBreakEven.formattedRemainingUnits, '10');

        // Remaining harvest yield = 30 - 10 = 20 Bags
        expect(metrics.dynamicBreakEven.remainingHarvestYield, 20.0);

        // Feasibility: Remaining harvest (20) >= required (10) -> onTrack
        expect(
          metrics.dynamicBreakEven.feasibility,
          BreakEvenFeasibility.onTrack,
        );
        expect(
          metrics.dynamicBreakEven.advisoryMessage,
          contains('safety buffer of 10 Bags'),
        );
      },
    );
  });
}
