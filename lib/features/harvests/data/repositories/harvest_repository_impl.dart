import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:uuid/uuid.dart';

import 'package:farmivo/core/errors/database_exception_mapper.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_yield_summary.dart';
import 'package:farmivo/features/harvests/domain/repositories/harvest_repository.dart';

/// Concrete Drift SQLite implementation of [HarvestRepository].
class HarvestRepositoryImpl implements HarvestRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  HarvestRepositoryImpl({required AppDatabase db, Uuid uuid = const Uuid()})
    : _db = db,
      _uuid = uuid;

  @override
  Stream<List<HarvestWithDetails>> watchHarvests({String? projectId}) {
    var query = _db.select(_db.harvestsTable).join([
      leftOuterJoin(
        _db.projectsTable,
        _db.projectsTable.id.equalsExp(_db.harvestsTable.projectId),
      ),
    ]);

    Expression<bool> predicate = _db.harvestsTable.isDeleted.equals(false);
    if (projectId != null) {
      predicate = predicate & _db.harvestsTable.projectId.equals(projectId);
    }

    query = query
      ..where(predicate)
      ..orderBy([
        OrderingTerm.desc(_db.harvestsTable.harvestDate),
        OrderingTerm.desc(_db.harvestsTable.createdAt),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return HarvestWithDetails(
          harvest: row.readTable(_db.harvestsTable),
          project: row.readTableOrNull(_db.projectsTable),
        );
      }).toList();
    });
  }

  @override
  Future<HarvestWithDetails?> getHarvestById(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final query =
          _db.select(_db.harvestsTable).join([
            leftOuterJoin(
              _db.projectsTable,
              _db.projectsTable.id.equalsExp(_db.harvestsTable.projectId),
            ),
          ])..where(
            _db.harvestsTable.id.equals(id) &
                _db.harvestsTable.isDeleted.equals(false),
          );

      final row = await query.getSingleOrNull();
      if (row == null) return null;

      return HarvestWithDetails(
        harvest: row.readTable(_db.harvestsTable),
        project: row.readTableOrNull(_db.projectsTable),
      );
    }, operationName: 'getHarvestById');
  }

  @override
  Future<String> generateNextBatchNumber(
    String projectId, {
    String? commodity,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    String code = 'LOT';

    if (commodity != null && commodity.trim().isNotEmpty) {
      final clean = commodity
          .replaceAll(RegExp(r'[^a-zA-Z]'), '')
          .toUpperCase();
      if (clean.length >= 3) {
        code = clean.substring(0, 3);
      } else if (clean.isNotEmpty) {
        code = clean.padRight(3, 'X');
      }
    } else {
      final project = await (_db.select(
        _db.projectsTable,
      )..where((t) => t.id.equals(projectId))).getSingleOrNull();
      if (project != null && project.commodity.trim().isNotEmpty) {
        final clean = project.commodity
            .replaceAll(RegExp(r'[^a-zA-Z]'), '')
            .toUpperCase();
        if (clean.length >= 3) {
          code = clean.substring(0, 3);
        } else if (clean.isNotEmpty) {
          code = clean.padRight(3, 'X');
        }
      }
    }

    final yy = (targetDate.year % 100).toString().padLeft(2, '0');
    final mm = targetDate.month.toString().padLeft(2, '0');
    final prefix = 'HV-$code-$yy$mm-';

    final existing =
        await (_db.select(_db.harvestsTable)..where(
              (t) =>
                  t.projectId.equals(projectId) &
                  t.batchNumber.like('$prefix%'),
            ))
            .get();

    final existingSet = existing.map((h) => h.batchNumber).toSet();
    int seq = existing.length + 1;
    String candidate = '$prefix${seq.toString().padLeft(2, '0')}';

    while (existingSet.contains(candidate)) {
      seq++;
      candidate = '$prefix${seq.toString().padLeft(2, '0')}';
    }

    return candidate;
  }

  @override
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
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedProduct = productName.trim();
      if (trimmedProduct.isEmpty) {
        throw const ValidationFailure(
          'Produce / product name cannot be empty.',
        );
      }
      if (quantity <= 0) {
        throw const ValidationFailure(
          'Harvest quantity must be greater than zero.',
        );
      }
      final trimmedUnit = unit.trim();
      if (trimmedUnit.isEmpty) {
        throw const ValidationFailure('Harvest unit cannot be empty.');
      }

      final project =
          await (_db.select(_db.projectsTable)..where(
                (t) => t.id.equals(projectId) & t.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      if (project == null) {
        throw const ValidationFailure('Project not found or deleted.');
      }

      String finalBatchNumber = batchNumber?.trim() ?? '';
      if (finalBatchNumber.isEmpty) {
        finalBatchNumber = await generateNextBatchNumber(
          projectId,
          commodity: project.commodity,
          date: harvestDate,
        );
      }

      final id = _uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      await _db
          .into(_db.harvestsTable)
          .insert(
            HarvestsTableCompanion.insert(
              id: id,
              projectId: projectId,
              batchNumber: finalBatchNumber,
              harvestDate: harvestDate.millisecondsSinceEpoch,
              productName: trimmedProduct,
              quantity: quantity,
              unit: trimmedUnit,
              grade: Value(grade.code),
              storageLocation: Value(
                storageLocation?.trim().isEmpty == true
                    ? null
                    : storageLocation?.trim(),
              ),
              notes: Value(
                notes?.trim().isEmpty == true ? null : notes?.trim(),
              ),
              photoPath: Value(
                photoPath?.trim().isEmpty == true ? null : photoPath?.trim(),
              ),
              createdAt: now,
              updatedAt: now,
              isSynced: const Value(false),
              isDeleted: const Value(false),
            ),
          );

      return id;
    }, operationName: 'recordHarvest');
  }

  @override
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
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final existing =
          await (_db.select(_db.harvestsTable)
                ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
              .getSingleOrNull();

      if (existing == null) {
        throw const ValidationFailure('Harvest batch not found.');
      }

      if (quantity != null && quantity <= 0) {
        throw const ValidationFailure(
          'Harvest quantity must be greater than zero.',
        );
      }
      if (productName != null && productName.trim().isEmpty) {
        throw const ValidationFailure(
          'Produce / product name cannot be empty.',
        );
      }
      if (unit != null && unit.trim().isEmpty) {
        throw const ValidationFailure('Harvest unit cannot be empty.');
      }
      if (batchNumber != null && batchNumber.trim().isEmpty) {
        throw const ValidationFailure('Batch number cannot be empty.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      await (_db.update(
        _db.harvestsTable,
      )..where((t) => t.id.equals(id))).write(
        HarvestsTableCompanion(
          batchNumber: batchNumber != null
              ? Value(batchNumber.trim())
              : const Value.absent(),
          harvestDate: harvestDate != null
              ? Value(harvestDate.millisecondsSinceEpoch)
              : const Value.absent(),
          productName: productName != null
              ? Value(productName.trim())
              : const Value.absent(),
          quantity: quantity != null ? Value(quantity) : const Value.absent(),
          unit: unit != null ? Value(unit.trim()) : const Value.absent(),
          grade: grade != null ? Value(grade.code) : const Value.absent(),
          storageLocation: storageLocation != null
              ? Value(
                  storageLocation.trim().isEmpty
                      ? null
                      : storageLocation.trim(),
                )
              : const Value.absent(),
          notes: notes != null
              ? Value(notes.trim().isEmpty ? null : notes.trim())
              : const Value.absent(),
          photoPath: photoPath != null
              ? Value(photoPath.trim().isEmpty ? null : photoPath.trim())
              : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'updateHarvest');
  }

  @override
  Future<void> deleteHarvest(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(
        _db.harvestsTable,
      )..where((t) => t.id.equals(id))).write(
        HarvestsTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'deleteHarvest');
  }

  @override
  Future<HarvestYieldSummary> getProjectYieldSummary(String projectId) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final project = await (_db.select(
        _db.projectsTable,
      )..where((t) => t.id.equals(projectId))).getSingleOrNull();

      final scenario =
          await (_db.select(_db.scenariosTable)
                ..where(
                  (t) =>
                      t.projectId.equals(projectId) & t.isDeleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.scenarioType)]))
              .getSingleOrNull();

      final harvests =
          await (_db.select(_db.harvestsTable)..where(
                (t) =>
                    t.projectId.equals(projectId) & t.isDeleted.equals(false),
              ))
              .get();

      double totalQty = 0.0;
      String primaryUnit = '';
      final gradeMap = <HarvestGrade, double>{
        for (final g in HarvestGrade.values) g: 0.0,
      };

      for (final h in harvests) {
        totalQty += h.quantity;
        if (primaryUnit.isEmpty && h.unit.trim().isNotEmpty) {
          primaryUnit = h.unit.trim();
        }
        final grade = HarvestGrade.fromCode(h.grade);
        gradeMap[grade] = (gradeMap[grade] ?? 0.0) + h.quantity;
      }

      return HarvestYieldSummary(
        projectId: projectId,
        totalQuantity: totalQty,
        unit: primaryUnit.isNotEmpty
            ? primaryUnit
            : (scenario?.yieldUnit ?? 'Units'),
        totalBatches: harvests.length,
        quantityByGrade: gradeMap,
        projectedYield: scenario?.expectedYield,
        projectedYieldUnit: scenario?.yieldUnit,
        landSize: project?.landSize,
        landUnit: project?.landUnit,
      );
    }, operationName: 'getProjectYieldSummary');
  }

  @override
  Stream<HarvestYieldSummary> watchProjectYieldSummary(
    String projectId,
  ) async* {
    yield await getProjectYieldSummary(projectId);
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.harvestsTable,
            _db.projectsTable,
            _db.scenariosTable,
          ]),
        )
        .asyncMap((_) => getProjectYieldSummary(projectId));
  }

  @override
  Future<List<String>> getSuggestedStorageLocations({int limit = 10}) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final rows =
          await (_db.selectOnly(_db.harvestsTable, distinct: true)
                ..addColumns([_db.harvestsTable.storageLocation])
                ..where(
                  _db.harvestsTable.storageLocation.isNotNull() &
                      _db.harvestsTable.isDeleted.equals(false),
                )
                ..limit(limit))
              .get();

      final recorded = rows
          .map((r) => r.read(_db.harvestsTable.storageLocation))
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList();

      const defaults = [
        'Main Barn',
        'Silo 1',
        'Cold Room',
        'Packhouse',
        'Field Shed',
        'Grain Store',
        'Warehouse A',
        'Farm Store',
      ];

      final combined = {...recorded, ...defaults}.take(limit).toList();
      return combined;
    }, operationName: 'getSuggestedStorageLocations');
  }
}
