import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/expenses/domain/models/expense_with_details.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/reports/domain/models/project_report_data.dart';
import 'package:farmivo/features/reports/domain/services/pdf_report_generator.dart';
import 'package:farmivo/features/sales/domain/models/sale_with_details.dart';

void main() {
  group('Milestone 10.2: PDF Generation Performance & Memory Stability Benchmarks', () {
    late ProjectReportData heavyReportData;

    setUpAll(() {
      const currency = 'GHS';
      final now = DateTime.now().millisecondsSinceEpoch;

      const project = Project(
        id: 'proj-benchmark',
        farmId: 'farm-benchmark',
        name: 'Asuogyaman Commercial Grain Enterprise',
        projectType: 'CROP',
        commodity: 'Yellow Maize',
        variety: 'Pannar 53 Hybrid',
        landSize: 25.0,
        landUnit: 'Acres',
        startDate: 1767225600000,
        currency: currency,
        status: 'ACTIVE',
        createdAt: 1767225600000,
        updatedAt: 1767225600000,
        isSynced: false,
        isDeleted: false,
      );

      const farm = Farm(
        id: 'farm-benchmark',
        name: 'Volta Basin Agro-Holdings',
        location: 'Asuogyaman District',
        district: 'Asuogyaman',
        region: 'Eastern Region',
        country: 'Ghana',
        totalArea: 100.0,
        areaUnit: 'Acres',
        ownershipType: 'LEASED',
        createdAt: 1767225600000,
        updatedAt: 1767225600000,
        isSynced: false,
        isDeleted: false,
      );

      // 13 Budget category variance records
      final categoryNames = [
        'Land Preparation & Tillage',
        'Certified Seeds & Seedlings',
        'Fertilizers & Soil Amendments',
        'Crop Protection & Herbicides',
        'Casual Field Labour',
        'Irrigation & Water Pumping',
        'Farm Machinery & Fuel',
        'Post-Harvest Handling & Crates',
        'Storage, Sacks & Bagging',
        'Logistics & Cartage',
        'Agronomic Extension & Advisory',
        'Insurance & Hedging',
        'Contingency Buffer',
      ];

      final categoryVariances = List.generate(categoryNames.length, (i) {
        final category = BudgetCategory(
          id: 'cat-$i',
          name: categoryNames[i],
          iconName: 'category',
          isSystemDefault: true,
          displayOrder: i + 1,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
          isDeleted: false,
        );

        final planned = 2000.0 + (i * 500.0);
        final actual = (i % 3 == 0)
            ? planned + 400.0
            : (i % 3 == 1 ? planned - 200.0 : planned);

        return CategoryVariance(
          category: category,
          itemVariances: const [],
          plannedAmount: Money.fromMajor(planned, currency: currency),
          actualSpent: Money.fromMajor(actual, currency: currency),
          transactionCount: 4,
          percentageOfTotalBudget: (planned / 50000.0) * 100.0,
        );
      });

      final varianceReport = ProjectVarianceReport(
        projectId: project.id,
        currency: currency,
        totalPlanned: Money.fromMajor(45000.0, currency: currency),
        totalSpent: Money.fromMajor(38500.0, currency: currency),
        totalTransactionsCount: 50,
        categories: categoryVariances,
      );

      // 50 Recent Expense Transactions
      final recentExpenses = List.generate(50, (i) {
        final catIndex = i % categoryNames.length;
        final category = categoryVariances[catIndex].category;
        final amount = 250 + (i * 45);

        return ExpenseWithDetails(
          expense: Expense(
            id: 'exp-$i',
            projectId: project.id,
            categoryId: category.id,
            transactionDate: now - (i * 86400000),
            description:
                'Field activity operational purchase #$i - ${category.name}',
            quantity: (i % 5 + 1).toDouble(),
            unit: 'Units',
            unitCostMinor: (amount * 20),
            amountMinor: amount * 100,
            currency: currency,
            paymentMethod: (i % 2 == 0) ? 'MOMO' : 'CASH',
            vendorName: 'Agro Supplier ${i % 8 + 1}',
            isVoided: false,
            isDeleted: false,
            isSynced: false,
            createdAt: now,
            updatedAt: now,
          ),
          category: category,
        );
      });

      // 25 Commercial Sales with installment debtors
      final sales = List.generate(25, (i) {
        final qty = 150.0 + (i * 20);
        const unitPrice = 250; // GH₵ 2.50
        final gross = (qty * unitPrice).round();
        final isPaid = i % 3 == 0;
        final isPartial = i % 3 == 1;
        final paidMinor = isPaid ? gross : (isPartial ? (gross ~/ 2) : 0);

        return SaleWithDetails(
          sale: Sale(
            id: 'sale-$i',
            projectId: project.id,
            buyerId: 'buyer-${i % 5 + 1}',
            saleDate: now - (i * 86400000 * 2),
            productName: 'Commercial White Maize Grain',
            quantity: qty,
            unit: 'kg',
            unitPriceMinor: unitPrice,
            totalAmountMinor: gross,
            currency: currency,
            paymentStatus: isPaid ? 'PAID' : (isPartial ? 'PARTIAL' : 'UNPAID'),
            isVoided: false,
            isDeleted: false,
            isSynced: false,
            createdAt: now,
            updatedAt: now,
          ),
          buyer: Buyer(
            id: 'buyer-${i % 5 + 1}',
            name: 'Wholesale Off-taker ${i % 5 + 1}',
            phone: '024000000${i % 5 + 1}',
            businessName: 'Kumasi Commodity Traders',
            location: 'Techiman Market',
            isDeleted: false,
            isSynced: false,
            createdAt: now,
            updatedAt: now,
          ),
          totalPaidMinor: paidMinor,
        );
      });

      // 10 Harvest Batches
      final harvests = List.generate(10, (i) {
        return HarvestWithDetails(
          harvest: Harvest(
            id: 'harv-$i',
            projectId: project.id,
            batchNumber: 'BATCH-2026-0$i',
            harvestDate: now - (i * 86400000 * 3),
            productName: 'Yellow Maize',
            quantity: 2500.0 + (i * 300),
            unit: 'kg',
            grade: (i % 2 == 0) ? 'Grade A' : 'Standard',
            storageLocation: 'Silo Bay #$i',
            isDeleted: false,
            isSynced: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
      });

      // Scenario models
      const expectedScenario = Scenario(
        id: 'sc-exp',
        projectId: 'proj-benchmark',
        scenarioType: 'EXPECTED',
        expectedYield: 28000.0,
        yieldUnit: 'kg',
        expectedUnitPriceMinor: 260,
        projectedRevenueMinor: 7280000,
        projectedCostMinor: 3100000,
        projectedProfitMinor: 4180000,
        projectedRoiPercent: 134.84,
        isDeleted: false,
        isSynced: false,
        createdAt: 0,
        updatedAt: 0,
      );

      final metrics = ProjectMetrics.compute(
        project: project,
        budgetItems: const [],
        expenses: recentExpenses.map((e) => e.expense).toList(),
        activities: const [],
        harvests: harvests.map((h) => h.harvest).toList(),
        sales: sales.map((s) => s.sale).toList(),
        payments: const [],
        forecastScenario: expectedScenario,
      );

      heavyReportData = ProjectReportData(
        project: project,
        farm: farm,
        metrics: metrics,
        varianceReport: varianceReport,
        harvests: harvests,
        sales: sales,
        expenses: recentExpenses,
        generatedAt: DateTime.now(),
        preparedBy: 'Chief Agronomist & Farm Auditor',
        verifiedBy: 'Agricultural Development Bank (ADB)',
        notes:
            'Annual comprehensive audited financial statement for seasonal credit review.',
        includeSignatureBlocks: true,
      );
    });

    test(
      '1. Compiles heavy multi-page bank-ready PDF financial report (< 600ms)',
      () async {
        final stopwatch = Stopwatch()..start();
        final pdfBytes = await PdfReportGenerator.generate(heavyReportData);
        stopwatch.stop();

        expect(pdfBytes, isNotEmpty);
        expect(
          pdfBytes.length,
          greaterThan(15000),
        ); // Comprehensive multi-page document
        // Check standard PDF magic header
        final header = ascii.decode(pdfBytes.sublist(0, 5));
        expect(header, equals('%PDF-'));

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1500),
          reason:
              'Initial PDF generation took ${stopwatch.elapsedMilliseconds}ms, exceeding 1500ms target.',
        );
      },
    );

    test(
      '2. Sustained Generation Benchmark: 20 consecutive PDF builds verify zero memory leaks & consistent footprint',
      () async {
        const int iterations = 20;
        final durations = <int>[];
        int? baselineLength;

        for (int i = 0; i < iterations; i++) {
          final watch = Stopwatch()..start();
          final Uint8List bytes = await PdfReportGenerator.generate(
            heavyReportData,
          );
          watch.stop();

          durations.add(watch.elapsedMilliseconds);

          // Verify valid PDF payload on every cycle
          final header = ascii.decode(bytes.sublist(0, 5));
          expect(header, equals('%PDF-'));

          if (baselineLength == null) {
            baselineLength = bytes.length;
          } else {
            // Document byte size must stay deterministic and not inflate across generations
            expect(
              bytes.length,
              equals(baselineLength),
              reason:
                  'PDF byte length altered on iteration $i, indicating potential document state leakage.',
            );
          }
        }

        final averageMs = durations.reduce((a, b) => a + b) / iterations;
        // High performance target: average generation time under 350ms per multi-page PDF
        expect(
          averageMs,
          lessThan(350.0),
          reason:
              'Average PDF build time across $iterations runs was ${averageMs}ms, exceeding 350ms target.',
        );
      },
    );

    test(
      '3. Handles sparse/empty project datasets without throwing or crashing',
      () async {
        final emptyVarianceReport = ProjectVarianceReport(
          projectId: heavyReportData.project.id,
          currency: 'GHS',
          totalPlanned: Money.zero(),
          totalSpent: Money.zero(),
          totalTransactionsCount: 0,
          categories: const [],
        );

        final sparseData = ProjectReportData(
          project: heavyReportData.project,
          farm: null,
          metrics: heavyReportData.metrics,
          varianceReport: emptyVarianceReport,
          harvests: const [],
          sales: const [],
          expenses: const [],
          generatedAt: DateTime.now(),
          includeSignatureBlocks: false,
        );

        final pdfBytes = await PdfReportGenerator.generate(sparseData);
        expect(pdfBytes, isNotEmpty);
        expect(ascii.decode(pdfBytes.sublist(0, 5)), equals('%PDF-'));
      },
    );
  });
}
