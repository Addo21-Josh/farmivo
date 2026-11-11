import '../../../../data/database/app_database.dart';

/// Repository interface governing pre-season yield, revenue, and sensitivity scenario forecasts.
abstract class ForecastRepository {
  /// Emits reactive updates for the primary forecast scenario (defaulting to 'EXPECTED') of a project.
  Stream<Scenario?> watchForecast(
    String projectId, {
    String scenarioType = 'EXPECTED',
  });

  /// Retrieves the forecast scenario for a project.
  Future<Scenario?> getForecast(
    String projectId, {
    String scenarioType = 'EXPECTED',
  });

  /// Emits all scenarios ('CONSERVATIVE', 'EXPECTED', 'OPTIMISTIC') for a project.
  Stream<List<Scenario>> watchAllScenarios(String projectId);

  /// Retrieves all scenarios for a project.
  Future<List<Scenario>> getAllScenarios(String projectId);

  /// Saves or updates a revenue and yield forecast scenario, calculating revenue, profit, and ROI in minor units.
  Future<Scenario> saveForecast({
    required String projectId,
    String scenarioType = 'EXPECTED',
    required double expectedYield,
    required String yieldUnit,
    required int expectedUnitPriceMinor,
    required int projectedCostMinor,
    String? notes,
  });

  /// Generates and persists the full 3-scenario matrix (Conservative, Expected, Optimistic) (Milestone 7.3).
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
  });

  /// Deletes a forecast scenario by ID.
  Future<void> deleteScenario(String id);
}
