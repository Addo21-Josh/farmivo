import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../data/repositories/budget_category_repository_impl.dart';
import '../../domain/repositories/budget_category_repository.dart';

/// Provider exposing the [BudgetCategoryRepository] singleton.
final budgetCategoryRepositoryProvider = Provider<BudgetCategoryRepository>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return BudgetCategoryRepositoryImpl(db);
});

/// Reactive stream of all active budget categories (system defaults + custom).
final budgetCategoriesStreamProvider = StreamProvider<List<BudgetCategory>>((
  ref,
) {
  final repository = ref.watch(budgetCategoryRepositoryProvider);
  return repository.watchAll();
});

/// Reactive list of standard system categories.
final systemBudgetCategoriesProvider = Provider<List<BudgetCategory>>((ref) {
  final allAsync = ref.watch(budgetCategoriesStreamProvider);
  return allAsync.maybeWhen(
    data: (categories) => categories.where((c) => c.isSystemDefault).toList(),
    orElse: () => const [],
  );
});

/// Reactive list of user-created custom categories.
final customBudgetCategoriesProvider = Provider<List<BudgetCategory>>((ref) {
  final allAsync = ref.watch(budgetCategoriesStreamProvider);
  return allAsync.maybeWhen(
    data: (categories) => categories.where((c) => !c.isSystemDefault).toList(),
    orElse: () => const [],
  );
});

/// Reactive stream of an individual budget category by ID.
final budgetCategoryDetailProvider =
    StreamProvider.family<BudgetCategory?, String>((ref, id) {
      final repository = ref.watch(budgetCategoryRepositoryProvider);
      return repository.watchById(id);
    });

/// Controller handling stateful operations (create, update, delete) for budget categories.
class BudgetCategoryController extends StateNotifier<AsyncValue<void>> {
  final BudgetCategoryRepository _repository;

  BudgetCategoryController(this._repository)
    : super(const AsyncValue.data(null));

  /// Creates a custom category with duplicate name validation.
  Future<BudgetCategory?> createCustomCategory({
    required String name,
    String? description,
    String? iconName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final category = await _repository.createCustomCategory(
        name: name,
        description: description,
        iconName: iconName,
      );
      state = const AsyncValue.data(null);
      return category;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Updates an existing category's properties.
  Future<bool> updateCategory(BudgetCategory category) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(category);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Deletes a custom category (verifying delete protection and referential integrity).
  Future<bool> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider exposing [BudgetCategoryController].
final budgetCategoryControllerProvider =
    StateNotifierProvider<BudgetCategoryController, AsyncValue<void>>((ref) {
      final repository = ref.watch(budgetCategoryRepositoryProvider);
      return BudgetCategoryController(repository);
    });
