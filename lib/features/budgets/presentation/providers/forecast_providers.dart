import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/financial_engine/scenario_planning.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../data/repositories/forecast_repository_impl.dart';
import '../../domain/models/break_even_analysis.dart';
import '../../domain/models/forecast_model.dart';
import '../../domain/repositories/forecast_repository.dart';
import 'budget_item_providers.dart';

export '../../../../core/financial_engine/scenario_planning.dart';

/// Provider exposing the [ForecastRepository] singleton.
final forecastRepositoryProvider = Provider<ForecastRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ForecastRepositoryImpl(db);
});

/// Reactive stream of the active 'EXPECTED' forecast scenario for a project.
final projectForecastProvider = StreamProvider.family<Scenario?, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(forecastRepositoryProvider);
  return repository.watchForecast(projectId);
});

/// Reactive stream of all sensitivity scenarios ('EXPECTED', 'CONSERVATIVE', 'OPTIMISTIC') for a project.
final projectScenariosProvider = StreamProvider.family<List<Scenario>, String>((
  ref,
  projectId,
) {
  final repository = ref.watch(forecastRepositoryProvider);
  return repository.watchAllScenarios(projectId);
});

/// Computes a reactive [ForecastCalculation] combining saved forecast yield/price with live budget item costs.
final projectLiveForecastCalculationProvider =
    Provider.family<AsyncValue<ForecastCalculation?>, String>((ref, projectId) {
      final forecastAsync = ref.watch(projectForecastProvider(projectId));
      final budgetCostAsync = ref.watch(
        projectTotalPlannedMoneyProvider(projectId),
      );

      if (forecastAsync.isLoading || budgetCostAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (forecastAsync.hasError) {
        return AsyncValue.error(
          forecastAsync.error!,
          forecastAsync.stackTrace!,
        );
      }

      final scenario = forecastAsync.valueOrNull;
      if (scenario == null) {
        return const AsyncValue.data(null);
      }

      final liveCostMoney = budgetCostAsync.valueOrNull;
      // Use live budgeted cost if available, otherwise fallback to the cost saved in the scenario
      final costMinor = liveCostMoney != null
          ? liveCostMoney.minorUnits.toInt()
          : scenario.projectedCostMinor;

      return AsyncValue.data(
        ForecastCalculation(
          expectedYield: scenario.expectedYield,
          yieldUnit: scenario.yieldUnit,
          expectedUnitPriceMinor: scenario.expectedUnitPriceMinor,
          totalBudgetedCostMinor: costMinor,
          currency: liveCostMoney?.currency ?? 'GHS',
        ),
      );
    });

/// Computes a reactive [BreakEvenAnalysis] for a project combining forecast assumptions with budgeted cost.
final projectBreakEvenAnalysisProvider =
    Provider.family<AsyncValue<BreakEvenAnalysis?>, String>((ref, projectId) {
      final liveCalcAsync = ref.watch(
        projectLiveForecastCalculationProvider(projectId),
      );

      return liveCalcAsync.whenData((calc) {
        if (calc == null) return null;
        return BreakEvenAnalysis(
          expectedYield: calc.expectedYield,
          yieldUnit: calc.yieldUnit,
          expectedUnitPriceMinor: calc.expectedUnitPriceMinor,
          totalBudgetedCostMinor: calc.totalBudgetedCostMinor,
          currency: calc.currency,
        );
      });
    });

/// Computes a reactive [ScenarioPlanningMatrix] (Milestone 7.3) combining saved sensitivity scenarios
/// or dynamically deriving Conservative (-20% yield, -15% price) and Optimistic (+15% yield, +10% price)
/// from the baseline EXPECTED scenario and live budgeted cost.
final projectScenarioPlanningMatrixProvider =
    Provider.family<AsyncValue<ScenarioPlanningMatrix?>, String>((
      ref,
      projectId,
    ) {
      final scenariosAsync = ref.watch(projectScenariosProvider(projectId));
      final budgetCostAsync = ref.watch(
        projectTotalPlannedMoneyProvider(projectId),
      );

      if (scenariosAsync.isLoading || budgetCostAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (scenariosAsync.hasError) {
        return AsyncValue.error(
          scenariosAsync.error!,
          scenariosAsync.stackTrace!,
        );
      }

      final scenarios = scenariosAsync.valueOrNull ?? [];
      final liveCostMoney = budgetCostAsync.valueOrNull ?? Money.zero();

      if (scenarios.isEmpty) {
        return const AsyncValue.data(null);
      }

      final matrix = ScenarioPlanningMatrix.fromScenarios(
        scenarios: scenarios,
        liveBudgetedCost: liveCostMoney,
        currency: liveCostMoney.currency,
      );

      return AsyncValue.data(matrix);
    });

/// Controller handling user actions (save, update, delete) on pre-season revenue forecasts.
class ForecastController extends StateNotifier<AsyncValue<void>> {
  final ForecastRepository _repository;

  ForecastController(this._repository) : super(const AsyncValue.data(null));

  /// Saves or updates a revenue and yield forecast scenario.
  Future<Scenario?> saveForecast({
    required String projectId,
    String scenarioType = 'EXPECTED',
    required double expectedYield,
    required String yieldUnit,
    required int expectedUnitPriceMinor,
    required int projectedCostMinor,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final scenario = await _repository.saveForecast(
        projectId: projectId,
        scenarioType: scenarioType,
        expectedYield: expectedYield,
        yieldUnit: yieldUnit,
        expectedUnitPriceMinor: expectedUnitPriceMinor,
        projectedCostMinor: projectedCostMinor,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return scenario;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Generates and persists the full 3-scenario matrix (Milestone 7.3).
  Future<List<Scenario>> saveScenarioMatrix({
    required String projectId,
    required double expectedYield,
    required String yieldUnit,
    required int expectedUnitPriceMinor,
    required int projectedCostMinor,
    double conservativeYieldMultiplier = 0.80,
    double conservativePriceMultiplier = 0.85,
    double optimisticYieldMultiplier = 1.15,
    double optimisticPriceMultiplier = 1.10,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final scenarios = await _repository.saveScenarioMatrix(
        projectId: projectId,
        expectedYield: expectedYield,
        yieldUnit: yieldUnit,
        expectedUnitPriceMinor: expectedUnitPriceMinor,
        projectedCostMinor: projectedCostMinor,
        conservativeYieldMultiplier: conservativeYieldMultiplier,
        conservativePriceMultiplier: conservativePriceMultiplier,
        optimisticYieldMultiplier: optimisticYieldMultiplier,
        optimisticPriceMultiplier: optimisticPriceMultiplier,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return scenarios;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Deletes a forecast scenario.
  Future<void> deleteScenario(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteScenario(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider managing the controller for forecast scenarios.
final forecastControllerProvider =
    StateNotifierProvider<ForecastController, AsyncValue<void>>((ref) {
      final repository = ref.watch(forecastRepositoryProvider);
      return ForecastController(repository);
    });
