import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_yield_summary.dart';

/// Contract governing physical harvest inventory, batch numbering, and yield aggregation.
abstract class HarvestRepository {
  /// Reactive stream of harvest lots, optionally filtered by [projectId].
  Stream<List<HarvestWithDetails>> watchHarvests({String? projectId});

  /// Retrieves a single harvest record by ID with project details.
  Future<HarvestWithDetails?> getHarvestById(String id);

  /// Records a new physical harvest lot.
  ///
  /// If [batchNumber] is omitted or blank, an intelligent batch number
  /// (e.g., `HV-MAI-2611-01`) is auto-generated.
  Future<String> recordHarvest({
    required String projectId,
    String? batchNumber,
    required DateTime harvestDate,
    required String productName,
    required double quantity,
    required String unit,
    HarvestGrade grade = HarvestGrade.ungraded,
    String? storageLocation,
    String? notes,
    String? photoPath,
  });

  /// Updates an existing harvest batch.
  Future<void> updateHarvest({
    required String id,
    required String projectId,
    String? batchNumber,
    DateTime? harvestDate,
    String? productName,
    double? quantity,
    String? unit,
    HarvestGrade? grade,
    String? storageLocation,
    String? notes,
    String? photoPath,
  });

  /// Soft deletes a harvest batch from inventory.
  Future<void> deleteHarvest(String id);

  /// Generates the next sequential batch code for a project (e.g., `HV-MAI-2611-01`).
  Future<String> generateNextBatchNumber(
    String projectId, {
    String? commodity,
    DateTime? date,
  });

  /// Reactive stream of cumulative yield aggregates and grade distribution for a project.
  Stream<HarvestYieldSummary> watchProjectYieldSummary(String projectId);

  /// Computes a one-time snapshot of the project's cumulative yield and grade metrics.
  Future<HarvestYieldSummary> getProjectYieldSummary(String projectId);

  /// Returns commonly used storage locations for rapid form input.
  Future<List<String>> getSuggestedStorageLocations({int limit = 10});
}
