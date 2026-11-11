import 'expense_with_details.dart';
import 'payment_method.dart';

/// Transaction status filter options.
enum ExpenseStatusFilter {
  all,
  activeOnly,
  voidedOnly;

  String get displayName {
    switch (this) {
      case ExpenseStatusFilter.all:
        return 'All';
      case ExpenseStatusFilter.activeOnly:
        return 'Active';
      case ExpenseStatusFilter.voidedOnly:
        return 'Voided';
    }
  }
}

/// Comprehensive criteria for filtering and searching transactions in the ledger.
class ExpenseFilter {
  final String? searchQuery;
  final String? projectId;
  final String? categoryId;
  final PaymentMethod? paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minAmountMinor;
  final int? maxAmountMinor;
  final ExpenseStatusFilter status;

  const ExpenseFilter({
    this.searchQuery,
    this.projectId,
    this.categoryId,
    this.paymentMethod,
    this.startDate,
    this.endDate,
    this.minAmountMinor,
    this.maxAmountMinor,
    this.status = ExpenseStatusFilter.all,
  });

  /// Whether any filtering criteria (beyond status == all) is actively applied.
  bool get hasActiveFilters {
    return (searchQuery != null && searchQuery!.trim().isNotEmpty) ||
        projectId != null ||
        categoryId != null ||
        paymentMethod != null ||
        startDate != null ||
        endDate != null ||
        minAmountMinor != null ||
        maxAmountMinor != null ||
        status != ExpenseStatusFilter.all;
  }

  /// Total count of active filter dimensions for UI badge indicators.
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) count++;
    if (projectId != null) count++;
    if (categoryId != null) count++;
    if (paymentMethod != null) count++;
    if (startDate != null || endDate != null) count++;
    if (minAmountMinor != null || maxAmountMinor != null) count++;
    if (status != ExpenseStatusFilter.all) count++;
    return count;
  }

  /// Copies this filter with updated parameters. Pass null to keep existing,
  /// or explicit clear sentinel if needed.
  ExpenseFilter copyWith({
    String? searchQuery,
    String? projectId,
    String? categoryId,
    PaymentMethod? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmountMinor,
    int? maxAmountMinor,
    ExpenseStatusFilter? status,
    bool clearSearch = false,
    bool clearProject = false,
    bool clearCategory = false,
    bool clearPaymentMethod = false,
    bool clearDates = false,
    bool clearAmountRange = false,
  }) {
    return ExpenseFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      projectId: clearProject ? null : (projectId ?? this.projectId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      paymentMethod: clearPaymentMethod
          ? null
          : (paymentMethod ?? this.paymentMethod),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      minAmountMinor: clearAmountRange
          ? null
          : (minAmountMinor ?? this.minAmountMinor),
      maxAmountMinor: clearAmountRange
          ? null
          : (maxAmountMinor ?? this.maxAmountMinor),
      status: status ?? this.status,
    );
  }

  /// Evaluates whether an in-memory [ExpenseWithDetails] satisfies all filter criteria.
  bool matches(ExpenseWithDetails expense) {
    // 1. Status Filter
    if (status == ExpenseStatusFilter.activeOnly && expense.isVoided) {
      return false;
    }
    if (status == ExpenseStatusFilter.voidedOnly && !expense.isVoided) {
      return false;
    }

    // 2. Project Filter
    if (projectId != null && expense.projectId != projectId) return false;

    // 3. Category Filter
    if (categoryId != null && expense.category.id != categoryId) return false;

    // 4. Payment Method Filter
    if (paymentMethod != null && expense.paymentMethod != paymentMethod) {
      return false;
    }

    // 5. Date Range Filter
    if (startDate != null) {
      final startEpoch = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
      ).millisecondsSinceEpoch;
      if (expense.expense.transactionDate < startEpoch) return false;
    }
    if (endDate != null) {
      final endEpoch = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        23,
        59,
        59,
        999,
      ).millisecondsSinceEpoch;
      if (expense.expense.transactionDate > endEpoch) return false;
    }

    // 6. Amount Range Filter
    if (minAmountMinor != null &&
        expense.expense.amountMinor < minAmountMinor!) {
      return false;
    }
    if (maxAmountMinor != null &&
        expense.expense.amountMinor > maxAmountMinor!) {
      return false;
    }

    // 7. Full-text Search on Description and Vendor Name
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      final query = searchQuery!.trim().toLowerCase();
      final descMatch = expense.description.toLowerCase().contains(query);
      final vendorMatch =
          expense.vendorName?.toLowerCase().contains(query) ?? false;
      if (!descMatch && !vendorMatch) return false;
    }

    return true;
  }
}
