import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/financial_engine/project_comparison.dart';
import '../../../../core/money/money.dart';
import '../../domain/models/project_with_farm.dart';
import 'project_providers.dart';

/// User selection of project IDs for side-by-side comparison.
final selectedProjectIdsForComparisonProvider =
    StateNotifierProvider<SelectedProjectsNotifier, Set<String>>((ref) {
      return SelectedProjectsNotifier();
    });

class SelectedProjectsNotifier extends StateNotifier<Set<String>> {
  SelectedProjectsNotifier([Set<String>? initial]) : super(initial ?? {});

  void toggleProject(String projectId) {
    if (state.contains(projectId)) {
      state = {...state}..remove(projectId);
    } else {
      state = {...state, projectId};
    }
  }

  void selectProjects(Iterable<String> projectIds) {
    state = projectIds.toSet();
  }

  void selectAll(List<ProjectWithFarm> projects) {
    state = projects.map((p) => p.project.id).toSet();
  }

  void selectActiveOnly(List<ProjectWithFarm> projects) {
    state = projects
        .where(
          (p) =>
              p.project.status.toUpperCase() != 'COMPLETED' &&
              p.project.status.toUpperCase() != 'ARCHIVED',
        )
        .map((p) => p.project.id)
        .toSet();
  }

  void selectPastOnly(List<ProjectWithFarm> projects) {
    state = projects
        .where(
          (p) =>
              p.project.status.toUpperCase() == 'COMPLETED' ||
              p.project.status.toUpperCase() == 'ARCHIVED',
        )
        .map((p) => p.project.id)
        .toSet();
  }

  void clearSelection() {
    state = {};
  }
}

/// Lifecycle filter for comparison view: 'ALL', 'ACTIVE', 'PAST'.
final projectComparisonLifecycleFilterProvider = StateProvider<String>(
  (ref) => 'ALL',
);

/// Reactive provider fetching comparison records for all projects.
final allProjectsComparisonProvider =
    FutureProvider.autoDispose<List<ProjectComparisonRecord>>((ref) async {
      final projectsWithFarm = await ref.watch(
        projectsWithFarmStreamProvider.future,
      );
      final repo = ref.watch(projectRepositoryProvider);

      final records = <ProjectComparisonRecord>[];

      for (final pwf in projectsWithFarm) {
        final p = pwf.project;
        final f = pwf.farm;

        final metrics = await repo.getProjectMetrics(p.id);

        if (metrics != null) {
          records.add(
            ProjectComparisonRecord(
              projectId: p.id,
              projectName: p.name,
              commodity: p.commodity,
              variety: p.variety,
              farmName: f?.name,
              stage: metrics.stage,
              status: p.status,
              landSize: p.landSize,
              landUnit: p.landUnit,
              plannedBudget: metrics.totalBudgeted,
              capitalInvested: metrics.totalSpent,
              totalRevenue: metrics.totalRevenue,
              netProfit: metrics.netProfit,
              roiPercentage: metrics.roiPercentage,
              cycleDurationDays: metrics.daysActive,
              profitPerLandUnit: p.landSize > 0.001
                  ? metrics.netProfit.divide(p.landSize)
                  : metrics.netProfit,
              capitalPerLandUnit: p.landSize > 0.001
                  ? metrics.totalSpent.divide(p.landSize)
                  : metrics.totalSpent,
              healthScore: metrics.healthScore,
              healthStatus: metrics.healthStatus,
            ),
          );
        } else {
          // Fallback if no metrics recorded yet
          records.add(
            ProjectComparisonRecord.compute(
              projectId: p.id,
              projectName: p.name,
              commodity: p.commodity,
              variety: p.variety,
              farmName: f?.name,
              stage: ProjectLifecycleState.planning,
              status: p.status,
              landSize: p.landSize,
              landUnit: p.landUnit,
              plannedBudget: Money.zero(currency: p.currency),
              actualSpent: Money.zero(currency: p.currency),
              actualSales: Money.zero(currency: p.currency),
              daysActive: 0,
            ),
          );
        }
      }

      return records;
    });

/// Computes the [ProjectComparisonMatrix] for the currently selected projects.
final projectComparisonMatrixProvider =
    Provider.autoDispose<AsyncValue<ProjectComparisonMatrix>>((ref) {
      final allRecordsAsync = ref.watch(allProjectsComparisonProvider);
      final selectedIds = ref.watch(selectedProjectIdsForComparisonProvider);

      return allRecordsAsync.whenData((allRecords) {
        List<ProjectComparisonRecord> comparedRecords;
        if (selectedIds.isEmpty) {
          // If nothing explicitly selected, default to all available (or first 4)
          comparedRecords = allRecords.take(4).toList();
        } else {
          comparedRecords = allRecords
              .where((r) => selectedIds.contains(r.projectId))
              .toList();
        }

        return ProjectComparisonMatrix.compute(comparedRecords);
      });
    });
