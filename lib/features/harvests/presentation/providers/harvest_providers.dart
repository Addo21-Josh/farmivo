import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/data/repositories/harvest_repository_impl.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_yield_summary.dart';
import 'package:farmivo/features/harvests/domain/repositories/harvest_repository.dart';

/// Provider for [HarvestRepository].
final harvestRepositoryProvider = Provider<HarvestRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HarvestRepositoryImpl(db: db);
});

/// Reactive stream of all harvest lots across all projects.
final allHarvestsProvider = StreamProvider<List<HarvestWithDetails>>((ref) {
  final repository = ref.watch(harvestRepositoryProvider);
  return repository.watchHarvests();
});

/// Reactive stream of harvest lots for a specific project.
final projectHarvestsWithDetailsProvider =
    StreamProvider.family<List<HarvestWithDetails>, String>((ref, projectId) {
      final repository = ref.watch(harvestRepositoryProvider);
      return repository.watchHarvests(projectId: projectId);
    });

/// Reactive stream of project cumulative yield aggregates and grade metrics.
final projectYieldSummaryProvider =
    StreamProvider.family<HarvestYieldSummary, String>((ref, projectId) {
      final repository = ref.watch(harvestRepositoryProvider);
      return repository.watchProjectYieldSummary(projectId);
    });

/// Single harvest detail provider.
final harvestDetailProvider =
    FutureProvider.family<HarvestWithDetails?, String>((ref, id) {
      final repository = ref.watch(harvestRepositoryProvider);
      return repository.getHarvestById(id);
    });

/// Suggested storage locations provider.
final suggestedStorageLocationsProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.watch(harvestRepositoryProvider);
  return repository.getSuggestedStorageLocations();
});

/// Controller handling stateful operations (record, update, delete) for harvests.
class HarvestController extends StateNotifier<AsyncValue<void>> {
  final HarvestRepository _repository;

  HarvestController(this._repository) : super(const AsyncValue.data(null));

  Future<String?> recordHarvest({
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
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.recordHarvest(
        projectId: projectId,
        batchNumber: batchNumber,
        harvestDate: harvestDate,
        productName: productName,
        quantity: quantity,
        unit: unit,
        grade: grade,
        storageLocation: storageLocation,
        notes: notes,
        photoPath: photoPath,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateHarvest({
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
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateHarvest(
        id: id,
        projectId: projectId,
        batchNumber: batchNumber,
        harvestDate: harvestDate,
        productName: productName,
        quantity: quantity,
        unit: unit,
        grade: grade,
        storageLocation: storageLocation,
        notes: notes,
        photoPath: photoPath,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteHarvest(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteHarvest(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String> generateNextBatchNumber(
    String projectId, {
    String? commodity,
    DateTime? date,
  }) {
    return _repository.generateNextBatchNumber(
      projectId,
      commodity: commodity,
      date: date,
    );
  }
}

/// Provider for [HarvestController].
final harvestControllerProvider =
    StateNotifierProvider<HarvestController, AsyncValue<void>>((ref) {
      final repository = ref.watch(harvestRepositoryProvider);
      return HarvestController(repository);
    });
