import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/repositories/farm_repository.dart';
import '../../data/repositories/farm_repository_impl.dart';

/// Provider exposing the [FarmRepository] singleton.
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FarmRepositoryImpl(db);
});

/// Reactive stream of all active, non-deleted farms.
final farmsStreamProvider = StreamProvider<List<Farm>>((ref) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.watchAll();
});

/// Reactive stream of a single farm by its unique identifier.
final farmDetailProvider = StreamProvider.family<Farm?, String>((ref, farmId) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.watchById(farmId);
});

/// Asynchronous count of projects operating on a given farm.
final farmProjectsCountProvider = FutureProvider.family<int, String>((
  ref,
  farmId,
) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.getProjectCount(farmId);
});

/// Asynchronous calculation of allocated land area on a given farm.
final farmAllocatedAreaProvider = FutureProvider.family<double, String>((
  ref,
  farmId,
) {
  final repository = ref.watch(farmRepositoryProvider);
  return repository.getTotalAllocatedArea(farmId);
});

/// Controller handling stateful operations (create, update, delete) for farms.
class FarmController extends StateNotifier<AsyncValue<void>> {
  final FarmRepository _repository;
  final Uuid _uuid;

  FarmController(this._repository, {Uuid uuid = const Uuid()})
    : _uuid = uuid,
      super(const AsyncValue.data(null));

  /// Registers a new farm in the local SQLite database.
  Future<Farm?> createFarm({
    required String name,
    required String location,
    String? district,
    required String region,
    String country = 'Ghana',
    double? latitude,
    double? longitude,
    required double totalArea,
    String areaUnit = 'Acres',
    required String ownershipType,
    String? notes,
    String? photoPath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final farm = Farm(
        id: _uuid.v4(),
        name: name.trim(),
        location: location.trim(),
        district: district?.trim().isNotEmpty == true ? district!.trim() : null,
        region: region.trim(),
        country: country.trim(),
        latitude: latitude,
        longitude: longitude,
        totalArea: totalArea,
        areaUnit: areaUnit.trim(),
        ownershipType: ownershipType.trim(),
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
        photoPath: photoPath,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await _repository.create(farm);
      state = const AsyncValue.data(null);
      return farm;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Updates an existing farm's attributes.
  Future<bool> updateFarm(Farm farm) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = farm.copyWith(updatedAt: now, isSynced: false);
      await _repository.update(updated);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Soft deletes a farm from local database.
  Future<bool> deleteFarm(String farmId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(farmId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

/// Riverpod provider for [FarmController].
final farmControllerProvider =
    StateNotifierProvider<FarmController, AsyncValue<void>>((ref) {
      final repository = ref.watch(farmRepositoryProvider);
      return FarmController(repository);
    });
