import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/models/budget_tracking.dart';
import 'budget_category_providers.dart';
import 'budget_item_providers.dart';

/// Reactive provider computing real-time budget allocation tracking and actual expenditure
/// per category and line item directly from transactional ledger records.
final projectBudgetTrackingProvider =
    Provider.family<AsyncValue<ProjectBudgetTracking>, String>((
      ref,
      projectId,
    ) {
      final budgetItemsAsync = ref.watch(
        projectBudgetItemsWithCategoryProvider(projectId),
      );
      final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);
      final expensesAsync = ref.watch(
        projectExpensesWithDetailsProvider(projectId),
      );
      final projectAsync = ref.watch(projectDetailProvider(projectId));

      // If any stream is loading and doesn't have data, return loading
      if (budgetItemsAsync.isLoading ||
          categoriesAsync.isLoading ||
          expensesAsync.isLoading ||
          projectAsync.isLoading) {
        return const AsyncValue.loading();
      }

      // Handle errors
      if (budgetItemsAsync.hasError) {
        return AsyncValue.error(
          budgetItemsAsync.error!,
          budgetItemsAsync.stackTrace!,
        );
      }
      if (categoriesAsync.hasError) {
        return AsyncValue.error(
          categoriesAsync.error!,
          categoriesAsync.stackTrace!,
        );
      }
      if (expensesAsync.hasError) {
        return AsyncValue.error(
          expensesAsync.error!,
          expensesAsync.stackTrace!,
        );
      }
      if (projectAsync.hasError) {
        return AsyncValue.error(projectAsync.error!, projectAsync.stackTrace!);
      }

      final budgetItems = budgetItemsAsync.value ?? [];
      final categories = categoriesAsync.value ?? [];
      final expensesWithDetails = expensesAsync.value ?? [];
      final project = projectAsync.value;

      final currency = project?.currency ?? 'GHS';
      final rawExpenses = expensesWithDetails.map((e) => e.expense).toList();

      final tracking = ProjectBudgetTracking.compute(
        projectId: projectId,
        currency: currency,
        budgetItems: budgetItems,
        allCategories: categories,
        expenses: rawExpenses,
      );

      return AsyncValue.data(tracking);
    });
