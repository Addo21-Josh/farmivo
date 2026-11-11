import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/project_metrics.dart';
import '../../domain/models/project_with_farm.dart';
import '../../domain/repositories/project_repository.dart';

/// Drift SQLite implementation of [ProjectRepository].
class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _db;

  ProjectRepositoryImpl(this._db);

  @override
  Future<List<Project>> getAll() {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.projectsTable)
            ..where((tbl) => tbl.isDeleted.equals(false))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
          .get();
    }, operationName: 'fetch all active projects');
  }

  @override
  Stream<List<Project>> watchAll() {
    return (_db.select(_db.projectsTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  @override
  Future<Project?> getById(String id) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.projectsTable)
            ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();
    }, operationName: 'fetch project by ID');
  }

  @override
  Stream<Project?> watchById(String id) {
    return (_db.select(_db.projectsTable)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  @override
  Future<void> create(Project entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.into(_db.projectsTable).insert(entity);
    }, operationName: 'create project');
  }

  @override
  Future<void> update(Project entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.update(_db.projectsTable).replace(entity);
    }, operationName: 'update project');
  }

  @override
  Future<void> delete(String id) {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(
        _db.projectsTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        ProjectsTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'soft-delete project');
  }

  @override
  Future<List<Project>> getProjectsByFarm(String farmId) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.projectsTable)
            ..where(
              (tbl) => tbl.farmId.equals(farmId) & tbl.isDeleted.equals(false),
            )
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
          .get();
    }, operationName: 'fetch projects by farm');
  }

  @override
  Stream<List<Project>> watchProjectsByFarm(String farmId) {
    return (_db.select(_db.projectsTable)
          ..where(
            (tbl) => tbl.farmId.equals(farmId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  @override
  Future<List<ProjectWithFarm>> getAllWithFarm() {
    return DatabaseExceptionMapper.runSafe(() async {
      final query =
          _db.select(_db.projectsTable).join([
              leftOuterJoin(
                _db.farmsTable,
                _db.farmsTable.id.equalsExp(_db.projectsTable.farmId),
              ),
            ])
            ..where(_db.projectsTable.isDeleted.equals(false))
            ..orderBy([OrderingTerm.desc(_db.projectsTable.createdAt)]);

      final rows = await query.get();
      return rows.map((row) {
        return ProjectWithFarm(
          project: row.readTable(_db.projectsTable),
          farm: row.readTableOrNull(_db.farmsTable),
        );
      }).toList();
    }, operationName: 'fetch all projects with farms');
  }

  @override
  Stream<List<ProjectWithFarm>> watchAllWithFarm() {
    final query =
        _db.select(_db.projectsTable).join([
            leftOuterJoin(
              _db.farmsTable,
              _db.farmsTable.id.equalsExp(_db.projectsTable.farmId),
            ),
          ])
          ..where(_db.projectsTable.isDeleted.equals(false))
          ..orderBy([OrderingTerm.desc(_db.projectsTable.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ProjectWithFarm(
          project: row.readTable(_db.projectsTable),
          farm: row.readTableOrNull(_db.farmsTable),
        );
      }).toList();
    });
  }

  @override
  Future<void> updateStatus(String id, String newStatus, {String? reason}) {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Fetch current status for audit trail
      final current = await (_db.select(
        _db.projectsTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      final prevStatus = current?.status ?? 'UNKNOWN';

      // 2. Update project status in SQLite
      await (_db.update(
        _db.projectsTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        ProjectsTableCompanion(status: Value(newStatus), updatedAt: Value(now)),
      );

      // 3. Insert immutable forensic audit log
      const uuid = Uuid();
      await _db
          .into(_db.auditLogsTable)
          .insert(
            AuditLogsTableCompanion.insert(
              id: uuid.v4(),
              entityTable: 'projects',
              entityId: id,
              action: 'STATUS_CHANGE',
              previousStateJson: Value('{"status": "$prevStatus"}'),
              newStateJson: Value('{"status": "$newStatus"}'),
              reason: Value(reason),
              timestamp: now,
            ),
          );
    }, operationName: 'update project status');
  }

  @override
  Future<List<Project>> getActiveProjects() {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.projectsTable)
            ..where(
              (tbl) =>
                  tbl.isDeleted.equals(false) &
                  tbl.status.isNotIn(const ['COMPLETED', 'ARCHIVED']),
            )
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
          .get();
    }, operationName: 'fetch active projects');
  }

  @override
  Future<ProjectMetrics?> getProjectMetrics(String projectId) {
    return DatabaseExceptionMapper.runSafe(() async {
      final project = await getById(projectId);
      if (project == null) return null;

      final budgetItems =
          await (_db.select(_db.budgetItemsTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.isDeleted.equals(false),
              ))
              .get();

      final expenses =
          await (_db.select(_db.expensesTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.isDeleted.equals(false),
              ))
              .get();

      final activities =
          await (_db.select(_db.activitiesTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.isDeleted.equals(false),
              ))
              .get();

      final harvests =
          await (_db.select(_db.harvestsTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.isDeleted.equals(false),
              ))
              .get();

      final sales =
          await (_db.select(_db.salesTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.isDeleted.equals(false),
              ))
              .get();

      final saleIds = sales.map((s) => s.id).toSet();
      final payments = saleIds.isEmpty
          ? <Payment>[]
          : await (_db.select(_db.paymentsTable)..where(
                  (tbl) =>
                      tbl.saleId.isIn(saleIds) & tbl.isVoided.equals(false),
                ))
                .get();

      final forecastScenario =
          await (_db.select(_db.scenariosTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.scenarioType.equals('EXPECTED'),
              ))
              .getSingleOrNull();

      return ProjectMetrics.compute(
        project: project,
        budgetItems: budgetItems,
        expenses: expenses,
        activities: activities,
        harvests: harvests,
        sales: sales,
        payments: payments,
        forecastScenario: forecastScenario,
      );
    }, operationName: 'compute project metrics');
  }

  @override
  Stream<ProjectMetrics?> watchProjectMetrics(String projectId) async* {
    yield await getProjectMetrics(projectId);
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.projectsTable,
            _db.budgetItemsTable,
            _db.expensesTable,
            _db.activitiesTable,
            _db.harvestsTable,
            _db.salesTable,
            _db.paymentsTable,
            _db.scenariosTable,
          ]),
        )
        .asyncMap((_) => getProjectMetrics(projectId));
  }

  @override
  Stream<List<BudgetItem>> watchBudgetItems(String projectId) {
    return (_db.select(_db.budgetItemsTable)..where(
          (tbl) =>
              tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
        ))
        .watch();
  }

  @override
  Stream<List<Expense>> watchExpenses(String projectId) {
    return (_db.select(_db.expensesTable)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.transactionDate)]))
        .watch();
  }

  @override
  Stream<List<Activity>> watchActivities(String projectId) {
    return (_db.select(_db.activitiesTable)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.activityDate)]))
        .watch();
  }

  @override
  Stream<List<Harvest>> watchHarvests(String projectId) {
    return (_db.select(_db.harvestsTable)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.harvestDate)]))
        .watch();
  }

  @override
  Stream<List<Sale>> watchSales(String projectId) {
    return (_db.select(_db.salesTable)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.saleDate)]))
        .watch();
  }
}
