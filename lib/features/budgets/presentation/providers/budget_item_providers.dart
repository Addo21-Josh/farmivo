import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../data/repositories/budget_item_repository_impl.dart';
import '../../domain/models/budget_item_with_category.dart';
import '../../domain/models/budget_tracking.dart';
import '../../domain/repositories/budget_item_repository.dart';

/// Provider exposing the [BudgetItemRepository] singleton.
final budgetItemRepositoryProvider = Provider<BudgetItemRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetItemRepositoryImpl(db);
});

/// Reactive stream of budget items joined with category metadata for a project.
final projectBudgetItemsWithCategoryProvider =
    StreamProvider.family<List<BudgetItemWithCategory>, String>((
      ref,
      projectId,
    ) {
      final repository = ref.watch(budgetItemRepositoryProvider);
      return repository.watchByProjectWithCategory(projectId);
    });

/// Reactive stream of raw budget items for a project.
final projectBudgetItemsProvider =
    StreamProvider.family<List<BudgetItem>, String>((ref, projectId) {
      final repository = ref.watch(budgetItemRepositoryProvider);
      return repository.watchByProject(projectId);
    });

/// Reactive stream of total planned budget money for a project.
final projectTotalPlannedMoneyProvider = StreamProvider.family<Money, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(budgetItemRepositoryProvider);
  return repository.watchTotalPlannedMinor(projectId).map((minor) {
    return Money(BigInt.from(minor), currency: 'GHS');
  });
});

/// Grouped structure of budget items organized by category with subtotal calculations
/// and real-time actual expenditure tracking from transactional ledger records.
class CategoryBudgetGroup {
  final BudgetCategory category;
  final List<BudgetItemWithCategory> items;
  final Money subtotal;
  final double percentageOfTotal;
  final Money? actualSpent;
  final int transactionCount;
  final List<BudgetItemTracking>? itemTrackings;

  const CategoryBudgetGroup({
    required this.category,
    required this.items,
    required this.subtotal,
    required this.percentageOfTotal,
    this.actualSpent,
    this.transactionCount = 0,
    this.itemTrackings,
  });

  Money get effectiveActualSpent =>
      actualSpent ?? Money.zero(currency: subtotal.currency);
  Money get remaining => subtotal - effectiveActualSpent;
  double get spentPercentage => subtotal.isPositive
      ? (effectiveActualSpent.toMajor() / subtotal.toMajor()) * 100.0
      : (effectiveActualSpent.isPositive ? 100.0 : 0.0);
  bool get isOverBudget => effectiveActualSpent > subtotal;
}

/// Reactive provider grouping budget items under their categories with subtotals and actual tracking.
final projectGroupedBudgetProvider =
    Provider.family<AsyncValue<List<CategoryBudgetGroup>>, String>((
      ref,
      projectId,
    ) {
      final asyncItems = ref.watch(
        projectBudgetItemsWithCategoryProvider(projectId),
      );
      final asyncExpenses = ref.watch(
        projectExpensesWithDetailsProvider(projectId),
      );

      return asyncItems.whenData((items) {
        if (items.isEmpty) return const [];

        final totalMinor = items.fold<int>(
          0,
          (acc, item) => acc + item.item.plannedAmountMinor,
        );
        final currency = items.first.item.currency;

        // Track active, non-voided transactional spending
        final expenses = asyncExpenses.asData?.value ?? [];
        final activeExpenses = expenses.where((e) => !e.isVoided).toList();

        final itemSpentMap = <String, BigInt>{};
        final itemTxCountMap = <String, int>{};
        final categorySpentMap = <String, BigInt>{};
        final categoryTxCountMap = <String, int>{};

        for (final exp in activeExpenses) {
          final amt = exp.amount.minorUnits;
          categorySpentMap[exp.category.id] =
              (categorySpentMap[exp.category.id] ?? BigInt.zero) + amt;
          categoryTxCountMap[exp.category.id] =
              (categoryTxCountMap[exp.category.id] ?? 0) + 1;

          if (exp.expense.budgetItemId != null &&
              exp.expense.budgetItemId!.isNotEmpty) {
            final bId = exp.expense.budgetItemId!;
            itemSpentMap[bId] = (itemSpentMap[bId] ?? BigInt.zero) + amt;
            itemTxCountMap[bId] = (itemTxCountMap[bId] ?? 0) + 1;
          }
        }

        // Group items by categoryId maintaining display order
        final map = <String, List<BudgetItemWithCategory>>{};
        final categoryMap = <String, BudgetCategory>{};

        for (final itemWithCat in items) {
          final catId = itemWithCat.category.id;
          map.putIfAbsent(catId, () => []).add(itemWithCat);
          categoryMap[catId] = itemWithCat.category;
        }

        final groups = <CategoryBudgetGroup>[];
        for (final entry in map.entries) {
          final category = categoryMap[entry.key]!;
          final groupItems = entry.value;
          final groupSubtotalMinor = groupItems.fold<int>(
            0,
            (acc, i) => acc + i.item.plannedAmountMinor,
          );
          final subtotal = Money(
            BigInt.from(groupSubtotalMinor),
            currency: currency,
          );
          final percentage = totalMinor > 0
              ? (groupSubtotalMinor / totalMinor) * 100.0
              : 0.0;

          final catSpentMinor = categorySpentMap[category.id] ?? BigInt.zero;
          final catSpent = Money(catSpentMinor, currency: currency);
          final catTxCount = categoryTxCountMap[category.id] ?? 0;

          final itemTrackings = groupItems.map((it) {
            final iSpent = itemSpentMap[it.item.id] ?? BigInt.zero;
            final iTx = itemTxCountMap[it.item.id] ?? 0;
            return BudgetItemTracking(
              itemWithCategory: it,
              actualSpent: Money(iSpent, currency: currency),
              transactionCount: iTx,
            );
          }).toList();

          groups.add(
            CategoryBudgetGroup(
              category: category,
              items: groupItems,
              subtotal: subtotal,
              percentageOfTotal: percentage,
              actualSpent: catSpent,
              transactionCount: catTxCount,
              itemTrackings: itemTrackings,
            ),
          );
        }

        // Sort by category displayOrder then name
        groups.sort((a, b) {
          final orderCmp = a.category.displayOrder.compareTo(
            b.category.displayOrder,
          );
          if (orderCmp != 0) return orderCmp;
          return a.category.name.compareTo(b.category.name);
        });

        return groups;
      });
    });

/// Controller handling user actions (create, edit, delete) on budget line items.
class BudgetItemController extends StateNotifier<AsyncValue<void>> {
  final BudgetItemRepository _repository;

  BudgetItemController(this._repository) : super(const AsyncValue.data(null));

  /// Adds a new line item to a project's budget.
  Future<BudgetItem?> createBudgetItem({
    required String projectId,
    required String categoryId,
    required String name,
    required double quantity,
    required String unit,
    required int unitCostMinor,
    String currency = 'GHS',
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final item = await _repository.createBudgetItem(
        projectId: projectId,
        categoryId: categoryId,
        name: name,
        quantity: quantity,
        unit: unit,
        unitCostMinor: unitCostMinor,
        currency: currency,
        description: description,
      );
      state = const AsyncValue.data(null);
      return item;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates an existing budget line item.
  Future<void> updateBudgetItem({
    required String id,
    String? categoryId,
    String? name,
    double? quantity,
    String? unit,
    int? unitCostMinor,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBudgetItem(
        id: id,
        categoryId: categoryId,
        name: name,
        quantity: quantity,
        unit: unit,
        unitCostMinor: unitCostMinor,
        description: description,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Deletes a budget item.
  Future<void> deleteBudgetItem(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBudgetItem(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider managing the state and operations for budget line items.
final budgetItemControllerProvider =
    StateNotifierProvider<BudgetItemController, AsyncValue<void>>((ref) {
      final repository = ref.watch(budgetItemRepositoryProvider);
      return BudgetItemController(repository);
    });
