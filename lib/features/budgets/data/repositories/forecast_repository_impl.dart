import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/repositories/forecast_repository.dart';

/// Concrete SQLite implementation of [ForecastRepository] using Drift.
class ForecastRepositoryImpl implements ForecastRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  ForecastRepositoryImpl(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  Stream<Scenario?> watchForecast(
    String projectId, {
    String scenarioType = 'EXPECTED',
  }) {
    return (_db.select(_db.scenariosTable)..where(
          (tbl) =>
              tbl.projectId.equals(projectId) &
              tbl.scenarioType.equals(scenarioType) &
              tbl.isDeleted.equals(false),
        ))
        .watchSingleOrNull();
  }

  @override
  Future<Scenario?> getForecast(
    String projectId, {
    String scenarioType = 'EXPECTED',
  }) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.scenariosTable)..where(
            (tbl) =>
                tbl.projectId.equals(projectId) &
                tbl.scenarioType.equals(scenarioType) &
                tbl.isDeleted.equals(false),
          ))
          .getSingleOrNull();
    }, operationName: 'get forecast for project');
  }

  @override
  Stream<List<Scenario>> watchAllScenarios(String projectId) {
    return (_db.select(_db.scenariosTable)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.scenarioType)]))
        .watch();
  }

  @override
  Future<List<Scenario>> getAllScenarios(String projectId) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.scenariosTable)
            ..where(
              (tbl) =>
                  tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.scenarioType)]))
          .get();
    }, operationName: 'get all forecast scenarios');
  }

  @override
  Future<Scenario> saveForecast({
    required String projectId,
    String scenarioType = 'EXPECTED',
    required double expectedYield,
    required String yieldUnit,
    required int expectedUnitPriceMinor,
    required int projectedCostMinor,
    String? notes,
  }) {
    return DatabaseExceptionMapper.runSafe(() async {
      if (expectedYield <= 0) {
        throw const ValidationFailure(
          'Expected yield must be greater than zero.',
        );
      }
      if (expectedUnitPriceMinor < 0) {
        throw const ValidationFailure('Selling price cannot be negative.');
      }
      final trimmedUnit = yieldUnit.trim();
      if (trimmedUnit.isEmpty) {
        throw const ValidationFailure(
          'Measurement unit for yield is required.',
        );
      }

      // Verify parent project exists
      final project =
          await (_db.select(_db.projectsTable)..where(
                (tbl) => tbl.id.equals(projectId) & tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      if (project == null) {
        throw const ValidationFailure('Target farm project not found.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      // Mathematical formulas:
      // 1. Projected Gross Revenue = Yield * Unit Price
      final projectedRevenueMinor = (expectedYield * expectedUnitPriceMinor)
          .round();

      // 2. Projected Net Profit = Projected Revenue - Projected Cost
      final projectedProfitMinor = projectedRevenueMinor - projectedCostMinor;

      // 3. Projected ROI % = (Projected Profit / Projected Cost) * 100
      final projectedRoiPercent = projectedCostMinor > 0
          ? ((projectedProfitMinor / projectedCostMinor) * 100.0)
          : 0.0;

      // Check if an existing scenario of this type already exists for this project
      final existing =
          await (_db.select(_db.scenariosTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.scenarioType.equals(scenarioType) &
                    tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();

      if (existing != null) {
        // Update existing scenario
        await (_db.update(
          _db.scenariosTable,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          ScenariosTableCompanion(
            expectedYield: Value(expectedYield),
            yieldUnit: Value(trimmedUnit),
            expectedUnitPriceMinor: Value(expectedUnitPriceMinor),
            projectedRevenueMinor: Value(projectedRevenueMinor),
            projectedCostMinor: Value(projectedCostMinor),
            projectedProfitMinor: Value(projectedProfitMinor),
            projectedRoiPercent: Value(projectedRoiPercent),
            notes: notes != null
                ? Value(notes.trim().isNotEmpty ? notes.trim() : null)
                : const Value.absent(),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );

        return (await (_db.select(
          _db.scenariosTable,
        )..where((tbl) => tbl.id.equals(existing.id))).getSingle());
      } else {
        // Insert new scenario
        final id = _uuid.v4();
        await _db
            .into(_db.scenariosTable)
            .insert(
              ScenariosTableCompanion.insert(
                id: id,
                projectId: projectId,
                scenarioType: scenarioType,
                expectedYield: expectedYield,
                yieldUnit: trimmedUnit,
                expectedUnitPriceMinor: expectedUnitPriceMinor,
                projectedRevenueMinor: projectedRevenueMinor,
                projectedCostMinor: projectedCostMinor,
                projectedProfitMinor: projectedProfitMinor,
                projectedRoiPercent: projectedRoiPercent,
                notes: Value(
                  notes?.trim().isNotEmpty == true ? notes!.trim() : null,
                ),
                createdAt: now,
                updatedAt: now,
                isSynced: const Value(false),
                isDeleted: const Value(false),
              ),
            );

        return (await (_db.select(
          _db.scenariosTable,
        )..where((tbl) => tbl.id.equals(id))).getSingle());
      }
    }, operationName: 'save forecast scenario');
  }

  @override
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
  }) {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Save Expected scenario
      final expected = await saveForecast(
        projectId: projectId,
        scenarioType: 'EXPECTED',
        expectedYield: expectedYield,
        yieldUnit: yieldUnit,
        expectedUnitPriceMinor: expectedUnitPriceMinor,
        projectedCostMinor: projectedCostMinor,
        notes: notes,
      );

      // 2. Save Conservative scenario (-20% yield, -15% price)
      final consYield =
          (expectedYield * conservativeYieldMultiplier * 10000).round() / 10000;
      final consPriceMinor =
          (expectedUnitPriceMinor * conservativePriceMultiplier).round();
      final conservative = await saveForecast(
        projectId: projectId,
        scenarioType: 'CONSERVATIVE',
        expectedYield: consYield,
        yieldUnit: yieldUnit,
        expectedUnitPriceMinor: consPriceMinor,
        projectedCostMinor: projectedCostMinor,
        notes:
            'Auto-generated conservative downside scenario (-20% Yield, -15% Price)',
      );

      // 3. Save Optimistic scenario (+15% yield, +10% price)
      final optYield =
          (expectedYield * optimisticYieldMultiplier * 10000).round() / 10000;
      final optPriceMinor = (expectedUnitPriceMinor * optimisticPriceMultiplier)
          .round();
      final optimistic = await saveForecast(
        projectId: projectId,
        scenarioType: 'OPTIMISTIC',
        expectedYield: optYield,
        yieldUnit: yieldUnit,
        expectedUnitPriceMinor: optPriceMinor,
        projectedCostMinor: projectedCostMinor,
        notes:
            'Auto-generated optimistic upside scenario (+15% Yield, +10% Price)',
      );

      return [conservative, expected, optimistic];
    }, operationName: 'save scenario matrix');
  }

  @override
  Future<void> deleteScenario(String id) {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(
        _db.scenariosTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        ScenariosTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    }, operationName: 'delete forecast scenario');
  }
}
