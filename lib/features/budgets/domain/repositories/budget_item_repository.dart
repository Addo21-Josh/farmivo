import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/base_repository.dart';
import '../models/budget_item_with_category.dart';

/// Repository interface governing pre-season budget items and allocations.
abstract class BudgetItemRepository
    implements BaseRepository<BudgetItem, String> {
  /// Emits reactive updates for budget items belonging to a project.
  Stream<List<BudgetItem>> watchByProject(String projectId);

  /// Retrieves active budget items belonging to a project.
  Future<List<BudgetItem>> getByProject(String projectId);

  /// Emits reactive updates for budget items joined with their category details.
  Stream<List<BudgetItemWithCategory>> watchByProjectWithCategory(
    String projectId,
  );

  /// Retrieves active budget items joined with their category details.
  Future<List<BudgetItemWithCategory>> getByProjectWithCategory(
    String projectId,
  );

  /// Creates and persists a new budget item enforcing the formula Planned Amount = Quantity * Unit Cost.
  Future<BudgetItem> createBudgetItem({
    required String projectId,
    required String categoryId,
    required String name,
    required double quantity,
    required String unit,
    required int unitCostMinor,
    String currency = 'GHS',
    String? description,
  });

  /// Updates an existing budget item and recalculates the planned amount.
  Future<void> updateBudgetItem({
    required String id,
    String? categoryId,
    String? name,
    double? quantity,
    String? unit,
    int? unitCostMinor,
    String? description,
    String? status,
  });

  /// Deletes a budget item if no active expenses are linked to it.
  Future<void> deleteBudgetItem(String id);

  /// Retrieves the total planned budget amount for a project in minor units.
  Future<int> getTotalPlannedMinor(String projectId);

  /// Emits reactive updates for the total planned budget amount for a project in minor units.
  Stream<int> watchTotalPlannedMinor(String projectId);
}
