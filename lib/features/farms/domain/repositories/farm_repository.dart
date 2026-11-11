import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/base_repository.dart';

/// Repository interface governing farm and landholding entities.
abstract class FarmRepository implements BaseRepository<Farm, String> {
  /// Emits reactive updates for a specific farm by its unique ID.
  Stream<Farm?> watchById(String id);

  /// Returns the number of active (non-deleted) agricultural projects operating on this farm.
  Future<int> getProjectCount(String farmId);

  /// Returns the total cumulative land area actively allocated to ongoing projects on this farm.
  Future<double> getTotalAllocatedArea(String farmId);
}
