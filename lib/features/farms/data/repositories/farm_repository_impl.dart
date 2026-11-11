import 'package:drift/drift.dart';
import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/repositories/farm_repository.dart';

/// Drift SQLite implementation of [FarmRepository] with soft delete and relational integrity checks.
class FarmRepositoryImpl implements FarmRepository {
  final AppDatabase _db;

  FarmRepositoryImpl(this._db);

  @override
  Future<List<Farm>> getAll() {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.farmsTable)
            ..where((tbl) => tbl.isDeleted.equals(false))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();
    }, operationName: 'fetch all active farms');
  }

  @override
  Stream<List<Farm>> watchAll() {
    return (_db.select(_db.farmsTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  @override
  Future<Farm?> getById(String id) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.farmsTable)
            ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();
    }, operationName: 'fetch farm by ID');
  }

  @override
  Stream<Farm?> watchById(String id) {
    return (_db.select(_db.farmsTable)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  @override
  Future<void> create(Farm entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.into(_db.farmsTable).insert(entity);
    }, operationName: 'create farm');
  }

  @override
  Future<void> update(Farm entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.update(_db.farmsTable).replace(entity);
    }, operationName: 'update farm');
  }

  @override
  Future<void> delete(String id) {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(
        _db.farmsTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        FarmsTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'delete farm');
  }

  @override
  Future<int> getProjectCount(String farmId) {
    return DatabaseExceptionMapper.runSafe(() async {
      final countExpr = _db.projectsTable.id.count();
      final query = _db.selectOnly(_db.projectsTable)
        ..addColumns([countExpr])
        ..where(
          _db.projectsTable.farmId.equals(farmId) &
              _db.projectsTable.isDeleted.equals(false),
        );
      final row = await query.getSingle();
      return row.read(countExpr) ?? 0;
    }, operationName: 'get project count for farm');
  }

  @override
  Future<double> getTotalAllocatedArea(String farmId) {
    return DatabaseExceptionMapper.runSafe(() async {
      final sumExpr = _db.projectsTable.landSize.sum();
      final query = _db.selectOnly(_db.projectsTable)
        ..addColumns([sumExpr])
        ..where(
          _db.projectsTable.farmId.equals(farmId) &
              _db.projectsTable.isDeleted.equals(false),
        );
      final row = await query.getSingle();
      return row.read(sumExpr) ?? 0.0;
    }, operationName: 'get total allocated area for farm');
  }
}
