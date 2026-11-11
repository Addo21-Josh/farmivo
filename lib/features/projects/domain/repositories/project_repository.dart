import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/base_repository.dart';
import '../models/project_metrics.dart';
import '../models/project_with_farm.dart';

/// Repository interface governing agricultural project entities and lifecycles.
abstract class ProjectRepository implements BaseRepository<Project, String> {
  /// Emits reactive updates for a specific project by its unique ID.
  Stream<Project?> watchById(String id);

  /// Retrieves all active projects assigned to a specific farm.
  Future<List<Project>> getProjectsByFarm(String farmId);

  /// Emits reactive updates for all active projects assigned to a specific farm.
  Stream<List<Project>> watchProjectsByFarm(String farmId);

  /// Retrieves all active projects joined with their parent farm landholdings.
  Future<List<ProjectWithFarm>> getAllWithFarm();

  /// Emits a reactive stream of all active projects joined with their parent farms.
  Stream<List<ProjectWithFarm>> watchAllWithFarm();

  /// Updates the lifecycle status of a project (e.g. PLANNING -> ACTIVE) with optional audit reason.
  Future<void> updateStatus(String id, String newStatus, {String? reason});

  /// Retrieves all currently active (non-completed, non-archived) projects.
  Future<List<Project>> getActiveProjects();

  /// Emits a reactive aggregated summary of vital project metrics and financial status.
  Stream<ProjectMetrics?> watchProjectMetrics(String projectId);

  /// Calculates a one-time snapshot of vital project metrics.
  Future<ProjectMetrics?> getProjectMetrics(String projectId);

  /// Emits budgeted items allocated to the specified project.
  Stream<List<BudgetItem>> watchBudgetItems(String projectId);

  /// Emits non-voided actual expenses logged for the specified project.
  Stream<List<Expense>> watchExpenses(String projectId);

  /// Emits field activities logged for the specified project.
  Stream<List<Activity>> watchActivities(String projectId);

  /// Emits harvest batches recorded for the specified project.
  Stream<List<Harvest>> watchHarvests(String projectId);

  /// Emits commercial sales recorded for the specified project.
  Stream<List<Sale>> watchSales(String projectId);
}
