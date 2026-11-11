import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_item_with_category.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/expenses/domain/models/expense_with_details.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/reports/domain/models/project_report_data.dart';
import 'package:farmivo/features/reports/domain/services/csv_report_generator.dart';
import 'package:farmivo/features/sales/domain/models/sale_with_details.dart';

void main() {
  const currency = 'GHS';

  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Ejura Maize Commercial Venture',
    projectType: 'CROP',
    commodity: 'Maize',
    variety: 'Pannar 53',
    landSize: 10.0,
    landUnit: 'Acres',
    startDate: 0,
    currency: currency,
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testFarm = Farm(
    id: 'farm-1',
    name: 'Northern Ridge Estates',
    location: 'Ejura',
    region: 'Ashanti',
    country: 'Ghana',
    totalArea: 50.0,
    areaUnit: 'Acres',
    ownershipType: 'OWNED',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testCategory = BudgetCategory(
    id: 'cat-seeds',
    name: 'Seeds & Seedlings',
    description: 'Certified hybrid seeds',
    iconName: 'grass',
    isSystemDefault: true,
    displayOrder: 1,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testBudgetItem = BudgetItem(
    id: 'item-1',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
    projectId: 'proj-1',
    categoryId: 'cat-seeds',
    name: 'Pannar 53 Seed Bags',
    description: '10 bags for 10 acres',
    quantity: 10.0,
    unit: 'Bags',
    unitCostMinor: 25000,
    plannedAmountMinor: 250000,
    currency: currency,
    status: 'ACTIVE',
  );

  final itemVariance = ItemVariance(
    itemWithCategory: const BudgetItemWithCategory(
      item: testBudgetItem,
      category: testCategory,
    ),
    actualSpent: Money.fromMajor(2500.0, currency: currency),
    transactionCount: 1,
  );

  final varianceReport = ProjectVarianceReport(
    projectId: 'proj-1',
    currency: currency,
    totalPlanned: Money.fromMajor(10000.0, currency: currency),
    totalSpent: Money.fromMajor(8500.0, currency: currency),
    totalTransactionsCount: 2,
    categories: [
      CategoryVariance(
        category: testCategory,
        itemVariances: [itemVariance],
        plannedAmount: Money.fromMajor(6000.0, currency: currency),
        actualSpent: Money.fromMajor(4000.0, currency: currency),
        transactionCount: 1,
        percentageOfTotalBudget: 60.0,
      ),
    ],
  );

  final activeExpense = ExpenseWithDetails(
    expense: const Expense(
      id: 'exp-1',
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
      projectId: 'proj-1',
      categoryId: 'cat-seeds',
      budgetItemId: 'item-1',
      transactionDate: 1773187200000, // 2026-03-11 approx
      description: 'Certified Seed Maize',
      quantity: 10.0,
      unit: 'Bags',
      unitCostMinor: 25000,
      amountMinor: 250000, // GHS 2,500.00
      currency: currency,
      paymentMethod: 'MOBILE_MONEY',
      vendorName: 'Agrovet Ltd',
      receiptPhotoPath: '/data/user/0/com.farmivo/app_flutter/receipt_1.jpg',
      notes: 'Purchased for field A',
      isVoided: false,
      voidedAt: null,
      voidReason: null,
    ),
    category: testCategory,
    project: testProject,
  );

  final voidedExpense = ExpenseWithDetails(
    expense: const Expense(
      id: 'exp-2',
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
      projectId: 'proj-1',
      categoryId: 'cat-seeds',
      budgetItemId: null,
      transactionDate: 1773273600000,
      description: 'Faulty Sprayer Purchase',
      quantity: 1.0,
      unit: 'Piece',
      unitCostMinor: 30000,
      amountMinor: 30000,
      currency: currency,
      paymentMethod: 'CASH',
      vendorName: 'Local Hardware',
      receiptPhotoPath: null,
      notes: 'Voided due to return',
      isVoided: true,
      voidedAt: 1773273700000,
      voidReason: 'Defective nozzle returned to supplier',
    ),
    category: testCategory,
    project: testProject,
  );

  const harvest = Harvest(
    id: 'h-1',
    projectId: 'proj-1',
    batchNumber: 'HAR-001',
    harvestDate: 1773187200000,
    productName: 'Maize',
    quantity: 150.0,
    unit: 'Bags',
    grade: 'GRADE_A',
    storageLocation: 'Barn A',
    notes: 'Dried down to 13% moisture',
    createdAt: 0,
    updatedAt: 0,
    isDeleted: false,
    isSynced: false,
  );

  const sale = Sale(
    id: 's-1',
    projectId: 'proj-1',
    productName: 'Maize',
    buyerId: null,
    harvestId: null,
    quantity: 100.0,
    unit: 'Bags',
    unitPriceMinor: 20000,
    totalAmountMinor: 2000000, // GHS 20,000.00
    paymentStatus: 'PARTIAL',
    saleDate: 1773187200000,
    currency: currency,
    isVoided: false,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
    notes: 'Sold to Ejura Grain Wholesalers',
  );

  final metrics = ProjectMetrics.compute(
    project: testProject,
    budgetItems: const [testBudgetItem],
    expenses: [activeExpense.expense],
    activities: const [],
    harvests: const [harvest],
    sales: const [sale],
  );

  group('CsvReportGenerator Unit Tests', () {
    test(
      'generateExpensesCsv includes UTF-8 BOM, headers, and correct values',
      () {
        final csv = CsvReportGenerator.generateExpensesCsv([
          activeExpense,
          voidedExpense,
        ], projectName: 'Ejura Maize Commercial Venture');

        // Verify UTF-8 BOM is prepended for Microsoft Excel
        expect(csv.startsWith('\uFEFF'), isTrue);

        // Verify Header columns
        expect(csv, contains('Expense ID'));
        expect(csv, contains('Date'));
        expect(csv, contains('Project'));
        expect(csv, contains('Category'));
        expect(csv, contains('Description'));
        expect(csv, contains('Quantity'));
        expect(csv, contains('Unit'));
        expect(csv, contains('Amount'));
        expect(csv, contains('Currency'));
        expect(csv, contains('Payment Method'));
        expect(csv, contains('Vendor / Supplier'));
        expect(csv, contains('Has Receipt Attached'));
        expect(csv, contains('Status'));
        expect(csv, contains('Void Reason'));
        expect(csv, contains('Audit Notes'));

        // Verify Active Row
        expect(csv, contains('exp-1'));
        expect(csv, contains('Certified Seed Maize'));
        expect(csv, contains('2500.0'));
        expect(csv, contains('GHS'));
        expect(csv, contains('Agrovet Ltd'));
        expect(csv, contains('YES'));
        expect(csv, contains('ACTIVE'));
        expect(csv, contains('Purchased for field A'));

        // Verify Voided Row
        expect(csv, contains('exp-2'));
        expect(csv, contains('Faulty Sprayer Purchase'));
        expect(csv, contains('NO'));
        expect(csv, contains('VOIDED'));
        expect(csv, contains('Defective nozzle returned to supplier'));
      },
    );

    test(
      'generateSalesCsv includes UTF-8 BOM, headers, and financial values',
      () {
        final saleWithDetails = SaleWithDetails(
          sale: sale,
          totalPaidMinor: 1500000, // GHS 15,000 paid, GHS 5,000 remaining
        );

        final csv = CsvReportGenerator.generateSalesCsv([
          saleWithDetails,
        ], projectName: 'Ejura Maize Commercial Venture');

        expect(csv.startsWith('\uFEFF'), isTrue);

        // Verify Headers
        expect(csv, contains('Sale ID'));
        expect(csv, contains('Commodity / Product'));
        expect(csv, contains('Buyer / Off-Taker'));
        expect(csv, contains('Quantity Sold'));
        expect(csv, contains('Unit Price'));
        expect(csv, contains('Total Agreed Value'));
        expect(csv, contains('Cash Amount Paid'));
        expect(csv, contains('Outstanding Balance'));
        expect(csv, contains('Payment Status'));

        // Verify Row values
        expect(csv, contains('s-1'));
        expect(csv, contains('Maize'));
        expect(csv, contains('100.0'));
        expect(csv, contains('Bags'));
        expect(csv, contains('200.0')); // Unit price
        expect(csv, contains('20000.0')); // Total agreed value
        expect(csv, contains('15000.0')); // Cash paid
        expect(csv, contains('5000.0')); // Outstanding balance
        expect(csv, contains('PARTIAL'));
        expect(csv, contains('Sold to Ejura Grain Wholesalers'));
      },
    );

    test(
      'generateHarvestsCsv includes UTF-8 BOM, headers, and yield details',
      () {
        final harvestWithDetails = const HarvestWithDetails(
          harvest: harvest,
          project: testProject,
        );

        final csv = CsvReportGenerator.generateHarvestsCsv([
          harvestWithDetails,
        ], projectName: 'Ejura Maize Commercial Venture');

        expect(csv.startsWith('\uFEFF'), isTrue);

        // Verify Headers
        expect(csv, contains('Harvest ID'));
        expect(csv, contains('Batch Number'));
        expect(csv, contains('Produce / Crop'));
        expect(csv, contains('Quantity Harvested'));
        expect(csv, contains('Quality Grade'));
        expect(csv, contains('Storage / Destination Facility'));
        expect(csv, contains('Field Notes'));

        // Verify Row values
        expect(csv, contains('h-1'));
        expect(csv, contains('HAR-001'));
        expect(csv, contains('Maize'));
        expect(csv, contains('150.0'));
        expect(csv, contains('Bags'));
        expect(csv, contains('Grade A (Premium)'));
        expect(csv, contains('Barn A'));
        expect(csv, contains('Dried down to 13% moisture'));
      },
    );

    test(
      'generateBudgetVarianceCsv includes UTF-8 BOM, categories, and item rows',
      () {
        final csv = CsvReportGenerator.generateBudgetVarianceCsv(
          varianceReport,
          projectName: 'Ejura Maize Commercial Venture',
        );

        expect(csv.startsWith('\uFEFF'), isTrue);

        // Verify Headers
        expect(csv, contains('Project ID'));
        expect(csv, contains('Project Name'));
        expect(csv, contains('Category'));
        expect(csv, contains('Line Item'));
        expect(csv, contains('Target Quantity'));
        expect(csv, contains('Planned Amount'));
        expect(csv, contains('Actual Spent'));
        expect(csv, contains('Variance (Diff)'));
        expect(csv, contains('% Spent'));
        expect(csv, contains('Alert Status'));

        // Verify Category summary row
        expect(csv, contains('[Category Total]'));
        expect(csv, contains('Seeds & Seedlings'));
        expect(csv, contains('6000.0'));
        expect(csv, contains('4000.0'));

        // Verify Line item row
        expect(csv, contains('Pannar 53 Seed Bags'));
        expect(csv, contains('10.0'));
        expect(csv, contains('2500.0'));
      },
    );

    test(
      'generateAllProjectCsvs exports 4 distinct CSV files with clean filenames',
      () {
        final reportData = ProjectReportData(
          project: testProject,
          farm: testFarm,
          metrics: metrics,
          varianceReport: varianceReport,
          harvests: [const HarvestWithDetails(harvest: harvest)],
          sales: [const SaleWithDetails(sale: sale, totalPaidMinor: 1500000)],
          expenses: [activeExpense],
          generatedAt: DateTime(2026, 3, 15, 10, 30),
        );

        final filesMap = CsvReportGenerator.generateAllProjectCsvs(reportData);

        expect(filesMap.length, 4);
        expect(
          filesMap.containsKey(
            'Ejura_Maize_Commercial_Venture_Expenses_Ledger.csv',
          ),
          isTrue,
        );
        expect(
          filesMap.containsKey(
            'Ejura_Maize_Commercial_Venture_Sales_Ledger.csv',
          ),
          isTrue,
        );
        expect(
          filesMap.containsKey(
            'Ejura_Maize_Commercial_Venture_Harvest_Yield_Log.csv',
          ),
          isTrue,
        );
        expect(
          filesMap.containsKey(
            'Ejura_Maize_Commercial_Venture_Budget_Variance_Ledger.csv',
          ),
          isTrue,
        );

        for (final entry in filesMap.entries) {
          expect(
            entry.value.startsWith('\uFEFF'),
            isTrue,
            reason: '${entry.key} must start with UTF-8 BOM',
          );
          expect(
            entry.value.length,
            greaterThan(50),
            reason: '${entry.key} must contain ledger data',
          );
        }
      },
    );
  });
}
