import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/base_repository.dart';

/// Repository interface governing standard and custom agricultural budget categories.
abstract class BudgetCategoryRepository
    implements BaseRepository<BudgetCategory, String> {
  /// Emits reactive updates for a specific budget category by ID.
  Stream<BudgetCategory?> watchById(String id);

  /// Checks whether a category with the specified name already exists (case-insensitive).
  Future<bool> nameExists(String name, {String? excludeId});

  /// Checks whether any active budget items or expenses reference this category.
  Future<bool> isCategoryInUse(String categoryId);

  /// Creates a user-defined custom category.
  Future<BudgetCategory> createCustomCategory({
    required String name,
    String? description,
    String? iconName,
  });
}
