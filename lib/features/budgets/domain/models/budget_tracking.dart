import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import 'budget_item_with_category.dart';

/// Tracking metrics for an individual budget line item compared to actual transaction expenditure.
class BudgetItemTracking {
  final BudgetItemWithCategory itemWithCategory;
  final Money actualSpent;
  final int transactionCount;

  const BudgetItemTracking({
    required this.itemWithCategory,
    required this.actualSpent,
    this.transactionCount = 0,
  });

  /// The underlying budget line item.
  BudgetItem get item => itemWithCategory.item;

  /// The parent budget category.
  BudgetCategory get category => itemWithCategory.category;

  /// Total planned amount in minor units.
  Money get plannedAmount => itemWithCategory.plannedAmount;

  /// Remaining allocation available before overrun: Planned - Actual.
  Money get remainingAmount => plannedAmount - actualSpent;

  /// Percentage of planned budget spent: (Actual / Planned) * 100.
  double get spentPercentage {
    if (!plannedAmount.isPositive) return actualSpent.isPositive ? 100.0 : 0.0;
    return (actualSpent.toMajor() / plannedAmount.toMajor()) * 100.0;
  }

  /// Whether expenditure has exceeded the planned line item allocation.
  bool get isOverBudget => actualSpent > plannedAmount;
}

/// Tracking metrics for an entire budget category, aggregating item allocations
/// and all direct category expenditure from transactions.
class CategoryBudgetTracking {
  final BudgetCategory category;
  final List<BudgetItemTracking> items;
  final Money plannedAmount;
  final Money actualSpent;
  final int transactionCount;
  final double percentageOfTotalBudget;

  const CategoryBudgetTracking({
    required this.category,
    required this.items,
    required this.plannedAmount,
    required this.actualSpent,
    required this.transactionCount,
    required this.percentageOfTotalBudget,
  });

  /// Remaining funds in this category: Planned - Actual.
  Money get remainingAmount => plannedAmount - actualSpent;

  /// Percentage of category allocation spent: (Actual / Planned) * 100.
  double get spentPercentage {
    if (!plannedAmount.isPositive) return actualSpent.isPositive ? 100.0 : 0.0;
    return (actualSpent.toMajor() / plannedAmount.toMajor()) * 100.0;
  }

  /// Whether the category spending exceeds the allocated budget.
  bool get isOverBudget => actualSpent > plannedAmount;

  /// Actual spending within this category not linked to any specific line item.
  Money get unlinkedSpent {
    BigInt itemSpentMinor = BigInt.zero;
    for (final it in items) {
      itemSpentMinor += it.actualSpent.minorUnits;
    }
    final diff = actualSpent.minorUnits - itemSpentMinor;
    return Money(
      diff > BigInt.zero ? diff : BigInt.zero,
      currency: actualSpent.currency,
    );
  }
}

/// Comprehensive project-level budget tracking combining all planned allocations
/// and actual operational spending directly from the transaction ledger.
class ProjectBudgetTracking {
  final String projectId;
  final String currency;
  final Money totalPlanned;
  final Money totalSpent;
  final List<CategoryBudgetTracking> categories;
  final int totalTransactionsCount;

  const ProjectBudgetTracking({
    required this.projectId,
    required this.currency,
    required this.totalPlanned,
    required this.totalSpent,
    required this.categories,
    required this.totalTransactionsCount,
  });

  /// Net remaining project budget: Total Planned - Total Spent.
  Money get totalRemaining => totalPlanned - totalSpent;

  /// Overall capital utilization percentage: (Total Spent / Total Planned) * 100.
  double get spentPercentage {
    if (!totalPlanned.isPositive) return totalSpent.isPositive ? 100.0 : 0.0;
    return (totalSpent.toMajor() / totalPlanned.toMajor()) * 100.0;
  }

  /// Whether overall project spending exceeds the total pre-season budget.
  bool get isOverBudget => totalSpent > totalPlanned;

  /// Factory computing budget tracking directly from budget items, categories, and expenses.
  factory ProjectBudgetTracking.compute({
    required String projectId,
    required String currency,
    required List<BudgetItemWithCategory> budgetItems,
    required List<BudgetCategory> allCategories,
    required List<Expense> expenses,
  }) {
    // Only non-deleted and non-voided transactions count towards actual expenditure
    final activeExpenses = expenses
        .where((e) => !e.isDeleted && !e.isVoided)
        .toList();

    // Map spending per budget item id
    final itemSpentMap = <String, BigInt>{};
    final itemTxCountMap = <String, int>{};

    // Map spending per category id
    final categorySpentMap = <String, BigInt>{};
    final categoryTxCountMap = <String, int>{};

    for (final exp in activeExpenses) {
      final amount = BigInt.from(exp.amountMinor);

      // Category spending aggregation
      categorySpentMap[exp.categoryId] =
          (categorySpentMap[exp.categoryId] ?? BigInt.zero) + amount;
      categoryTxCountMap[exp.categoryId] =
          (categoryTxCountMap[exp.categoryId] ?? 0) + 1;

      // Budget item spending aggregation (if linked)
      if (exp.budgetItemId != null && exp.budgetItemId!.isNotEmpty) {
        final bId = exp.budgetItemId!;
        itemSpentMap[bId] = (itemSpentMap[bId] ?? BigInt.zero) + amount;
        itemTxCountMap[bId] = (itemTxCountMap[bId] ?? 0) + 1;
      }
    }

    // Total planned amount across all budget items
    BigInt totalPlannedMinor = BigInt.zero;
    for (final it in budgetItems) {
      totalPlannedMinor += BigInt.from(it.item.plannedAmountMinor);
    }
    final totalPlanned = Money(totalPlannedMinor, currency: currency);

    // Total spent across all active transactions
    BigInt totalSpentMinor = BigInt.zero;
    for (final exp in activeExpenses) {
      totalSpentMinor += BigInt.from(exp.amountMinor);
    }
    final totalSpent = Money(totalSpentMinor, currency: currency);

    // Group budget items by category
    final itemsByCategory = <String, List<BudgetItemWithCategory>>{};
    for (final item in budgetItems) {
      itemsByCategory.putIfAbsent(item.category.id, () => []).add(item);
    }

    // Collect all relevant category IDs (categories with planned items OR categories with expenses)
    final relevantCategoryIds = <String>{
      ...itemsByCategory.keys,
      ...categorySpentMap.keys,
    };

    final categoryMap = {for (final c in allCategories) c.id: c};
    for (final item in budgetItems) {
      categoryMap.putIfAbsent(item.category.id, () => item.category);
    }

    final categoryTrackings = <CategoryBudgetTracking>[];

    for (final catId in relevantCategoryIds) {
      final category = categoryMap[catId];
      if (category == null) continue;

      final catBudgetItems = itemsByCategory[catId] ?? [];

      // Build item trackings
      final itemTrackings = catBudgetItems.map((itemWithCat) {
        final spentMinor = itemSpentMap[itemWithCat.item.id] ?? BigInt.zero;
        final txCount = itemTxCountMap[itemWithCat.item.id] ?? 0;
        return BudgetItemTracking(
          itemWithCategory: itemWithCat,
          actualSpent: Money(spentMinor, currency: currency),
          transactionCount: txCount,
        );
      }).toList();

      // Planned amount for this category
      BigInt catPlannedMinor = BigInt.zero;
      for (final it in catBudgetItems) {
        catPlannedMinor += BigInt.from(it.item.plannedAmountMinor);
      }
      final catPlanned = Money(catPlannedMinor, currency: currency);

      // Actual spent for this category (item-linked + unlinked)
      final catSpentMinor = categorySpentMap[catId] ?? BigInt.zero;
      final catSpent = Money(catSpentMinor, currency: currency);
      final catTxCount = categoryTxCountMap[catId] ?? 0;

      final percentageOfTotal = totalPlannedMinor > BigInt.zero
          ? (catPlannedMinor.toDouble() / totalPlannedMinor.toDouble()) * 100.0
          : 0.0;

      categoryTrackings.add(
        CategoryBudgetTracking(
          category: category,
          items: itemTrackings,
          plannedAmount: catPlanned,
          actualSpent: catSpent,
          transactionCount: catTxCount,
          percentageOfTotalBudget: percentageOfTotal,
        ),
      );
    }

    // Sort category trackings:
    // 1. Categories with planned items first (by displayOrder then name)
    // 2. Categories with only unplanned expenses at the end
    categoryTrackings.sort((a, b) {
      final aHasPlanned = a.items.isNotEmpty;
      final bHasPlanned = b.items.isNotEmpty;
      if (aHasPlanned && !bHasPlanned) return -1;
      if (!aHasPlanned && bHasPlanned) return 1;

      final orderCmp = a.category.displayOrder.compareTo(
        b.category.displayOrder,
      );
      if (orderCmp != 0) return orderCmp;
      return a.category.name.compareTo(b.category.name);
    });

    return ProjectBudgetTracking(
      projectId: projectId,
      currency: currency,
      totalPlanned: totalPlanned,
      totalSpent: totalSpent,
      categories: categoryTrackings,
      totalTransactionsCount: activeExpenses.length,
    );
  }
}
