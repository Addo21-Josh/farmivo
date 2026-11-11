import '../models/expense_filter.dart';
import '../models/expense_with_details.dart';
import '../models/payment_method.dart';

/// Repository contract managing transactional expenses, vendor suggestions, and receipts.
abstract class ExpenseRepository {
  /// Records a new expenditure into the transactional ledger.
  ///
  /// Enforces business rules:
  /// - [amountMinor] must be strictly positive (> 0).
  /// - [description] cannot be empty or whitespace.
  /// - [projectId] and [categoryId] must reference valid non-deleted records.
  Future<String> recordExpense({
    required String projectId,
    required String categoryId,
    String? budgetItemId,
    String? activityId,
    required DateTime transactionDate,
    required String description,
    double quantity = 1.0,
    String? unit,
    int? unitCostMinor,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? vendorName,
    String? receiptPhotoPath,
    String? notes,
  });

  /// Soft-voids a transaction while strictly preserving the audit log and historic record.
  ///
  /// Throws [ValidationFailure] if the transaction is already voided or does not exist.
  Future<void> voidExpense({required String id, required String reason});

  /// Retrieves a single expense with its associated category, project, and budget item.
  Future<ExpenseWithDetails?> getExpenseById(String id);

  /// Reactive stream of all active (non-deleted) expenses for a specific project.
  Stream<List<ExpenseWithDetails>> watchExpensesByProject(String projectId);

  /// Reactive stream of all active expenses across all projects (for the main ledger).
  Stream<List<ExpenseWithDetails>> watchAllExpenses();

  /// Reactive stream of expenses matching the specified multi-dimensional filter and search criteria.
  Stream<List<ExpenseWithDetails>> watchExpensesWithFilter(
    ExpenseFilter filter,
  );

  /// Retrieves distinct vendor names ordered by usage frequency for auto-completion.
  Future<List<String>> getFrequentVendors({int limit = 10});

  /// Soft deletes an expense record (sets `isDeleted = true`).
  Future<void> deleteExpense(String id);
}
