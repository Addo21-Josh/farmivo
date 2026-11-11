import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/csv_export_service.dart';

/// Supported types of agricultural ledgers available for CSV export (Milestone 8.3).
enum CsvLedgerType {
  all,
  expenses,
  sales,
  harvests,
  budgetVariance;

  String get displayName {
    switch (this) {
      case CsvLedgerType.all:
        return 'All Ledgers (Complete Audit Pack)';
      case CsvLedgerType.expenses:
        return 'Expenses Ledger';
      case CsvLedgerType.sales:
        return 'Sales & Debtors Ledger';
      case CsvLedgerType.harvests:
        return 'Harvest Yield Log';
      case CsvLedgerType.budgetVariance:
        return 'Budget & Variance Ledger';
    }
  }

  String get subtitle {
    switch (this) {
      case CsvLedgerType.all:
        return 'Exports all 4 CSV ledgers together in one share action';
      case CsvLedgerType.expenses:
        return 'Operational costs, vendor names, and receipt status';
      case CsvLedgerType.sales:
        return 'Sales contracts, collections, and buyer accounts receivable';
      case CsvLedgerType.harvests:
        return 'Harvest batches, produce quantities, and quality grading';
      case CsvLedgerType.budgetVariance:
        return 'Allocations, actual expenditures, and overrun analysis';
    }
  }
}

/// Provider exposing the [CsvExportService] instance.
final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return const CsvExportService();
});

/// Currently selected CSV ledger type for export.
final selectedCsvLedgerTypeProvider = StateProvider<CsvLedgerType>((ref) {
  return CsvLedgerType.all;
});
