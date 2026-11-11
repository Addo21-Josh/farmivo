import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/reports/domain/models/project_report_data.dart';
import 'package:farmivo/features/reports/domain/services/pdf_report_generator.dart';
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

  const testCategoryOverrun = BudgetCategory(
    id: 'cat-labour',
    name: 'Labour & Operations',
    description: 'Manual weeding & planting',
    iconName: 'people',
    isSystemDefault: true,
    displayOrder: 2,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final varianceReport = ProjectVarianceReport(
    projectId: 'proj-1',
    currency: currency,
    totalPlanned: Money.fromMajor(10000.0, currency: currency),
    totalSpent: Money.fromMajor(8500.0, currency: currency),
    totalTransactionsCount: 4,
    categories: [
      CategoryVariance(
        category: testCategory,
        itemVariances: const [],
        plannedAmount: Money.fromMajor(6000.0, currency: currency),
        actualSpent: Money.fromMajor(4000.0, currency: currency),
        transactionCount: 2,
        percentageOfTotalBudget: 60.0,
      ),
      CategoryVariance(
        category: testCategoryOverrun,
        itemVariances: const [],
        plannedAmount: Money.fromMajor(4000.0, currency: currency),
        actualSpent: Money.fromMajor(
          4500.0,
          currency: currency,
        ), // Overrun by 500
        transactionCount: 2,
        percentageOfTotalBudget: 40.0,
      ),
    ],
  );

  const harvest = Harvest(
    id: 'h-1',
    projectId: 'proj-1',
    batchNumber: 'HAR-001',
    harvestDate: 0,
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
    totalAmountMinor: 2000000, // GH₵ 20,000.00
    paymentStatus: 'PARTIAL',
    saleDate: 0,
    currency: currency,
    isVoided: false,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final metrics = ProjectMetrics.compute(
    project: testProject,
    budgetItems: const [],
    expenses: const [],
    activities: const [],
    harvests: const [harvest],
    sales: const [sale],
  );

  group('PdfReportGenerator Unit Tests', () {
    test(
      'formatPdfMoney outputs standard ASCII currency without Unicode glyph errors',
      () {
        final m1 = Money.fromMajor(1250.50, currency: 'GHS');
        expect(PdfReportGenerator.formatPdfMoney(m1), 'GHS 1,250.50');

        final m2 = Money.fromMajor(-450.00, currency: 'GHS');
        expect(PdfReportGenerator.formatPdfMoney(m2), '-GHS 450.00');

        final mZero = Money.zero(currency: 'GHS');
        expect(PdfReportGenerator.formatPdfMoney(mZero), 'GHS 0.00');

        final mLarge = Money.fromMajor(1000000.00, currency: 'GHS');
        expect(PdfReportGenerator.formatPdfMoney(mLarge), 'GHS 1,000,000.00');
      },
    );

    test('formatPdfDate outputs standard readable date string', () {
      final date = DateTime(2026, 3, 15);
      expect(PdfReportGenerator.formatPdfDate(date), '15 Mar 2026');
    });

    test(
      'generate compiles a valid PDF byte buffer starting with PDF magic header %PDF-',
      () async {
        final reportData = ProjectReportData(
          project: testProject,
          farm: testFarm,
          metrics: metrics,
          varianceReport: varianceReport,
          harvests: [const HarvestWithDetails(harvest: harvest)],
          sales: [const SaleWithDetails(sale: sale, totalPaidMinor: 1500000)],
          expenses: const [],
          generatedAt: DateTime(2026, 3, 15, 10, 30),
          preparedBy: 'Kwame Mensah',
          verifiedBy: 'ADB Agricultural Loan Officer',
          notes: 'Submitted for input credit verification facility.',
          includeSignatureBlocks: true,
        );

        final pdfBytes = await PdfReportGenerator.generate(reportData);

        expect(pdfBytes, isNotEmpty);
        expect(
          pdfBytes.length,
          greaterThan(1000),
        ); // Non-trivial multi-page document

        // Validate standard PDF magic number '%PDF-' in first 5 bytes
        final magicHeader = ascii.decode(pdfBytes.sublist(0, 5));
        expect(magicHeader, '%PDF-');
      },
    );

    test(
      'generate succeeds gracefully when harvests and sales are empty',
      () async {
        final emptyReportData = ProjectReportData(
          project: testProject,
          farm: null, // Null farm test
          metrics: metrics,
          varianceReport: varianceReport,
          harvests: const [],
          sales: const [],
          expenses: const [],
          generatedAt: DateTime.now(),
          includeSignatureBlocks: false, // Omit signatures test
        );

        final pdfBytes = await PdfReportGenerator.generate(emptyReportData);
        expect(pdfBytes, isNotEmpty);
        expect(ascii.decode(pdfBytes.sublist(0, 5)), '%PDF-');
      },
    );
  });

  group('ProjectReportData Unit Tests', () {
    test('computes calculated properties accurately', () {
      final reportData = ProjectReportData(
        project: testProject,
        farm: testFarm,
        metrics: metrics,
        varianceReport: varianceReport,
        harvests: [const HarvestWithDetails(harvest: harvest)],
        sales: [const SaleWithDetails(sale: sale, totalPaidMinor: 1500000)],
        expenses: const [],
        generatedAt: DateTime.now(),
      );

      expect(reportData.currency, 'GHS');
      expect(reportData.farmDisplayName, 'Northern Ridge Estates');
      expect(reportData.farmLocationSummary, 'Ejura, Ashanti');
      expect(reportData.commoditySummary, 'Maize (Pannar 53)');
      expect(reportData.formattedLandSize, '10 Acres');
      expect(reportData.harvestBatchesCount, 1);
      expect(reportData.totalHarvestYieldFormatted, '150 Bags');
      expect(reportData.salesCount, 1);
      expect(reportData.budgetSpentPercentage, metrics.budgetSpentPercentage);
      expect(reportData.healthScore, metrics.healthEvaluation.score);
    });

    test('copyWith updates fields correctly', () {
      final reportData = ProjectReportData(
        project: testProject,
        farm: testFarm,
        metrics: metrics,
        varianceReport: varianceReport,
        harvests: const [],
        sales: const [],
        expenses: const [],
        generatedAt: DateTime.now(),
        preparedBy: 'Initial Name',
      );

      final updated = reportData.copyWith(
        preparedBy: 'Updated Name',
        includeSignatureBlocks: false,
      );
      expect(updated.preparedBy, 'Updated Name');
      expect(updated.includeSignatureBlocks, isFalse);
    });
  });
}
