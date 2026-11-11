import 'package:csv/csv.dart';
import '../../../budgets/domain/models/budget_variance.dart';
import '../../../expenses/domain/models/expense_with_details.dart';
import '../../../harvests/domain/models/harvest_with_details.dart';
import '../../../sales/domain/models/sale_with_details.dart';
import '../models/project_report_data.dart';

/// Pure Dart CSV Ledger generator producing Microsoft Excel and Google Sheets
/// compatible spreadsheets (Milestone 8.3).
class CsvReportGenerator {
  CsvReportGenerator._();

  /// UTF-8 Byte Order Mark (BOM) to ensure Microsoft Excel detects UTF-8
  /// encoding seamlessly without character corruption.
  static const String utf8Bom = '\uFEFF';

  static const ListToCsvConverter _csvConverter = ListToCsvConverter();

  /// Generates the Expenses Ledger CSV.
  static String generateExpensesCsv(
    List<ExpenseWithDetails> expenses, {
    String projectName = '',
  }) {
    final rows = <List<dynamic>>[
      // Headers
      [
        'Expense ID',
        'Date',
        'Project',
        'Category',
        'Description',
        'Quantity',
        'Unit',
        'Amount',
        'Currency',
        'Payment Method',
        'Vendor / Supplier',
        'Has Receipt Attached',
        'Status',
        'Void Reason',
        'Audit Notes',
      ],
    ];

    for (final e in expenses) {
      final d = e.transactionDate;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      rows.add([
        e.id,
        dateStr,
        e.project?.name ?? projectName,
        e.category.name,
        e.description,
        e.quantity,
        e.unit ?? 'Units',
        e.amount.toMajor(),
        e.amount.currency,
        e.paymentMethod.displayName,
        e.vendorName ?? '—',
        e.hasReceipt ? 'YES' : 'NO',
        e.isVoided ? 'VOIDED' : 'ACTIVE',
        e.voidReason ?? '—',
        e.notes ?? '—',
      ]);
    }

    return utf8Bom + _csvConverter.convert(rows);
  }

  /// Generates the Commercial Sales & Debtors Ledger CSV.
  static String generateSalesCsv(
    List<SaleWithDetails> sales, {
    String projectName = '',
  }) {
    final rows = <List<dynamic>>[
      // Headers
      [
        'Sale ID',
        'Date',
        'Project',
        'Commodity / Product',
        'Buyer / Off-Taker',
        'Quantity Sold',
        'Unit',
        'Unit Price',
        'Total Agreed Value',
        'Cash Amount Paid',
        'Outstanding Balance',
        'Currency',
        'Payment Status',
        'Notes',
      ],
    ];

    for (final s in sales) {
      final d = s.saleDate;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      rows.add([
        s.sale.id,
        dateStr,
        s.project?.name ?? projectName,
        s.sale.productName,
        s.buyerDisplayName,
        s.sale.quantity,
        s.sale.unit,
        s.unitPrice.toMajor(),
        s.totalAmount.toMajor(),
        s.paidAmount.toMajor(),
        s.remainingBalance.toMajor(),
        s.sale.currency,
        s.effectiveStatus.name.toUpperCase(),
        s.sale.notes ?? '—',
      ]);
    }

    return utf8Bom + _csvConverter.convert(rows);
  }

  /// Generates the Production & Harvest Yield Log CSV.
  static String generateHarvestsCsv(
    List<HarvestWithDetails> harvests, {
    String projectName = '',
  }) {
    final rows = <List<dynamic>>[
      // Headers
      [
        'Harvest ID',
        'Date',
        'Project',
        'Batch Number',
        'Produce / Crop',
        'Quantity Harvested',
        'Unit',
        'Quality Grade',
        'Storage / Destination Facility',
        'Field Notes',
      ],
    ];

    for (final h in harvests) {
      final d = h.harvestDate;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      rows.add([
        h.id,
        dateStr,
        h.projectName.isNotEmpty ? h.projectName : projectName,
        h.batchNumber,
        h.productName,
        h.quantity,
        h.unit,
        h.grade.displayName,
        h.storageLocation ?? 'On-Farm Facility',
        h.notes ?? '—',
      ]);
    }

    return utf8Bom + _csvConverter.convert(rows);
  }

  /// Generates the Budget & Variance Ledger CSV.
  static String generateBudgetVarianceCsv(
    ProjectVarianceReport report, {
    String projectName = '',
  }) {
    final rows = <List<dynamic>>[
      // Headers
      [
        'Project ID',
        'Project Name',
        'Category',
        'Line Item',
        'Target Quantity',
        'Unit',
        'Planned Amount',
        'Actual Spent',
        'Variance (Diff)',
        '% Spent',
        'Alert Status',
        'Currency',
      ],
    ];

    for (final cat in report.categories) {
      // Category Summary Row
      rows.add([
        report.projectId,
        projectName,
        cat.category.name,
        '[Category Total]',
        '',
        '',
        cat.plannedAmount.toMajor(),
        cat.actualSpent.toMajor(),
        cat.variance.toMajor(),
        '${cat.spentPercentage.toStringAsFixed(1)}%',
        cat.threshold.displayName,
        report.currency,
      ]);

      // Line items
      for (final it in cat.itemVariances) {
        rows.add([
          report.projectId,
          projectName,
          cat.category.name,
          it.item.name,
          it.item.quantity,
          it.item.unit,
          it.plannedAmount.toMajor(),
          it.actualSpent.toMajor(),
          it.variance.toMajor(),
          '${it.spentPercentage.toStringAsFixed(1)}%',
          it.threshold.displayName,
          report.currency,
        ]);
      }
    }

    return utf8Bom + _csvConverter.convert(rows);
  }

  /// Generates all 4 project CSV ledgers mapped by clean file name.
  static Map<String, String> generateAllProjectCsvs(ProjectReportData data) {
    final safeName = data.project.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9_\-]'),
      '_',
    );

    return {
      '${safeName}_Expenses_Ledger.csv': generateExpensesCsv(
        data.expenses,
        projectName: data.project.name,
      ),
      '${safeName}_Sales_Ledger.csv': generateSalesCsv(
        data.sales,
        projectName: data.project.name,
      ),
      '${safeName}_Harvest_Yield_Log.csv': generateHarvestsCsv(
        data.harvests,
        projectName: data.project.name,
      ),
      '${safeName}_Budget_Variance_Ledger.csv': generateBudgetVarianceCsv(
        data.varianceReport,
        projectName: data.project.name,
      ),
    };
  }
}
