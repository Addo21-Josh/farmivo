import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/project_metrics.dart';
import '../../domain/models/project_with_farm.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';

/// Provider exposing the [ProjectRepository] singleton.
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProjectRepositoryImpl(db);
});

/// Reactive stream of all active projects.
final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchAll();
});

/// Reactive stream of all active projects joined with their parent farms.
final projectsWithFarmStreamProvider = StreamProvider<List<ProjectWithFarm>>((
  ref,
) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchAllWithFarm();
});

/// Reactive stream of all active projects on a specific farm.
final farmProjectsStreamProvider = StreamProvider.family<List<Project>, String>(
  (ref, farmId) {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.watchProjectsByFarm(farmId);
  },
);

/// Reactive stream of a single project by its ID.
final projectDetailProvider = StreamProvider.family<Project?, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchById(projectId);
});

/// Reactive stream of aggregated vital metrics and financial health for a project.
final projectMetricsProvider = StreamProvider.family<ProjectMetrics?, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjectMetrics(projectId);
});

/// Reactive stream of multi-dimensional profitability metrics (Milestone 7.1) for a project.
final projectProfitabilityProvider =
    StreamProvider.family<ProjectProfitability?, String>((ref, projectId) {
      final repository = ref.watch(projectRepositoryProvider);
      return repository
          .watchProjectMetrics(projectId)
          .map((m) => m?.profitability);
    });

/// Reactive stream of dynamic break-even metrics (Milestone 7.2) for a project.
final projectDynamicBreakEvenProvider =
    StreamProvider.family<DynamicBreakEven?, String>((ref, projectId) {
      final repository = ref.watch(projectRepositoryProvider);
      return repository
          .watchProjectMetrics(projectId)
          .map((m) => m?.dynamicBreakEven);
    });

/// Reactive stream of algorithmic health evaluations (Milestone 7.4) for a project.
final projectHealthEvaluationProvider =
    StreamProvider.family<ProjectHealthEvaluation?, String>((ref, projectId) {
      final repository = ref.watch(projectRepositoryProvider);
      return repository
          .watchProjectMetrics(projectId)
          .map((m) => m?.healthEvaluation);
    });

/// Reactive stream of budget items allocated to a project.
final projectBudgetItemsProvider =
    StreamProvider.family<List<BudgetItem>, String>((ref, projectId) {
      final repository = ref.watch(projectRepositoryProvider);
      return repository.watchBudgetItems(projectId);
    });

/// Reactive stream of actual expenses recorded for a project.
final projectExpensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchExpenses(projectId);
});

/// Reactive stream of field agronomic activities logged for a project.
final projectActivitiesProvider = StreamProvider.family<List<Activity>, String>(
  (ref, projectId) {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.watchActivities(projectId);
  },
);

/// Reactive stream of harvest batches recorded for a project.
final projectHarvestsProvider = StreamProvider.family<List<Harvest>, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchHarvests(projectId);
});

/// Reactive stream of sales recorded for a project.
final projectSalesProvider = StreamProvider.family<List<Sale>, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchSales(projectId);
});

/// Controller handling stateful operations (create, update, delete, status transition) for projects.
class ProjectController extends StateNotifier<AsyncValue<void>> {
  final ProjectRepository _repository;
  final Uuid _uuid;

  ProjectController(this._repository, {Uuid uuid = const Uuid()})
    : _uuid = uuid,
      super(const AsyncValue.data(null));

  /// Registers a new agricultural venture or crop/livestock cycle.
  Future<Project?> createProject({
    required String farmId,
    required String name,
    required String projectType,
    required String commodity,
    String? variety,
    required double landSize,
    String landUnit = 'Acres',
    required int startDate,
    int? expectedFirstHarvestDate,
    int? expectedCompletionDate,
    String currency = 'GHS',
    String status = 'PLANNING',
    String? description,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final project = Project(
        id: _uuid.v4(),
        farmId: farmId,
        name: name.trim(),
        projectType: projectType.trim(),
        commodity: commodity.trim(),
        variety: variety?.trim().isNotEmpty == true ? variety!.trim() : null,
        landSize: landSize,
        landUnit: landUnit.trim(),
        startDate: startDate,
        expectedFirstHarvestDate: expectedFirstHarvestDate,
        expectedCompletionDate: expectedCompletionDate,
        currency: currency.trim(),
        status: status.trim().toUpperCase(),
        description: description?.trim().isNotEmpty == true
            ? description!.trim()
            : null,
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await _repository.create(project);
      state = const AsyncValue.data(null);
      return project;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Updates an existing project's attributes.
  Future<bool> updateProject(Project project) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = project.copyWith(updatedAt: now, isSynced: false);
      await _repository.update(updated);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Soft deletes a project from local database.
  Future<bool> deleteProject(String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(projectId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Updates a project's lifecycle state machine status with an optional audit reason.
  Future<bool> updateStatus(
    String projectId,
    String newStatus, {
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(
        projectId,
        newStatus.toUpperCase(),
        reason: reason,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

/// Riverpod provider for [ProjectController].
final projectControllerProvider =
    StateNotifierProvider<ProjectController, AsyncValue<void>>((ref) {
      final repository = ref.watch(projectRepositoryProvider);
      return ProjectController(repository);
    });
