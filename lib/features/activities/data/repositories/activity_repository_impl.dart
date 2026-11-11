import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:farmivo/core/errors/database_exception_mapper.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';
import 'package:farmivo/features/activities/domain/models/activity_with_details.dart';
import 'package:farmivo/features/activities/domain/repositories/activity_repository.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';

/// Concrete SQLite Drift implementation of [ActivityRepository].
class ActivityRepositoryImpl implements ActivityRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  ActivityRepositoryImpl({required AppDatabase db, Uuid uuid = const Uuid()})
    : _db = db,
      _uuid = uuid;

  @override
  Stream<List<ActivityWithDetails>> watchActivities({String? projectId}) {
    var query = _db.select(_db.activitiesTable).join([
      leftOuterJoin(
        _db.projectsTable,
        _db.projectsTable.id.equalsExp(_db.activitiesTable.projectId),
      ),
      leftOuterJoin(
        _db.expensesTable,
        _db.expensesTable.activityId.equalsExp(_db.activitiesTable.id) &
            _db.expensesTable.isDeleted.equals(false) &
            _db.expensesTable.isVoided.equals(false),
      ),
    ]);

    Expression<bool> predicate = _db.activitiesTable.isDeleted.equals(false);
    if (projectId != null) {
      predicate = predicate & _db.activitiesTable.projectId.equals(projectId);
    }

    query = query
      ..where(predicate)
      ..orderBy([
        OrderingTerm.desc(_db.activitiesTable.activityDate),
        OrderingTerm.desc(_db.activitiesTable.createdAt),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ActivityWithDetails(
          activity: row.readTable(_db.activitiesTable),
          project: row.readTableOrNull(_db.projectsTable),
          linkedExpense: row.readTableOrNull(_db.expensesTable),
        );
      }).toList();
    });
  }

  @override
  Future<ActivityWithDetails?> getActivityById(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final query =
          _db.select(_db.activitiesTable).join([
            leftOuterJoin(
              _db.projectsTable,
              _db.projectsTable.id.equalsExp(_db.activitiesTable.projectId),
            ),
            leftOuterJoin(
              _db.expensesTable,
              _db.expensesTable.activityId.equalsExp(_db.activitiesTable.id) &
                  _db.expensesTable.isDeleted.equals(false) &
                  _db.expensesTable.isVoided.equals(false),
            ),
          ])..where(
            _db.activitiesTable.id.equals(id) &
                _db.activitiesTable.isDeleted.equals(false),
          );

      final row = await query.getSingleOrNull();
      if (row == null) return null;

      return ActivityWithDetails(
        activity: row.readTable(_db.activitiesTable),
        project: row.readTableOrNull(_db.projectsTable),
        linkedExpense: row.readTableOrNull(_db.expensesTable),
      );
    }, operationName: 'getActivityById');
  }

  @override
  Future<String> recordActivity({
    required String projectId,
    required ActivityType activityType,
    required String title,
    required DateTime activityDate,
    String? description,
    int labourCount = 0,
    double? durationHours,
    int costMinor = 0,
    String currency = 'GHS',
    ActivityStatus status = ActivityStatus.completed,
    String? notes,
    bool createLinkedExpense = false,
    PaymentMethod expensePaymentMethod = PaymentMethod.cash,
    String? expenseCategoryId,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Validations
      final trimmedTitle = title.trim();
      if (trimmedTitle.isEmpty) {
        throw const ValidationFailure('Activity title cannot be empty.');
      }
      if (costMinor < 0) {
        throw const ValidationFailure('Activity cost cannot be negative.');
      }
      if (labourCount < 0) {
        throw const ValidationFailure('Labour headcount cannot be negative.');
      }
      if (durationHours != null && durationHours <= 0) {
        throw const ValidationFailure(
          'Duration hours must be greater than zero.',
        );
      }

      // 2. Validate project exists
      final project =
          await (_db.select(_db.projectsTable)..where(
                (p) => p.id.equals(projectId) & p.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      if (project == null) {
        throw const ValidationFailure('Selected project does not exist.');
      }

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final activityId = _uuid.v4();

      return await _db.transaction(() async {
        // 3. Insert Activity record
        await _db
            .into(_db.activitiesTable)
            .insert(
              ActivitiesTableCompanion.insert(
                id: activityId,
                projectId: projectId,
                activityType: activityType.code,
                title: trimmedTitle,
                activityDate: activityDate.millisecondsSinceEpoch,
                description: Value(
                  description?.trim().isNotEmpty == true
                      ? description!.trim()
                      : null,
                ),
                labourCount: Value(labourCount),
                durationHours: Value(durationHours),
                costMinor: Value(costMinor),
                currency: Value(currency),
                status: Value(status.code),
                notes: Value(
                  notes?.trim().isNotEmpty == true ? notes!.trim() : null,
                ),
                createdAt: now,
                updatedAt: now,
                isSynced: const Value(false),
              ),
            );

        // 4. Optionally generate corresponding linked financial expense
        if (createLinkedExpense && costMinor > 0) {
          String targetCategoryId = expenseCategoryId ?? '';

          if (targetCategoryId.isEmpty) {
            // Find Labour category or system default
            final categories = await _db
                .select(_db.budgetCategoriesTable)
                .get();
            final labourCat = categories.cast<BudgetCategory?>().firstWhere(
              (c) => c != null && c.name.toLowerCase().contains('labour'),
              orElse: () => null,
            );

            if (labourCat != null) {
              targetCategoryId = labourCat.id;
            } else if (categories.isNotEmpty) {
              targetCategoryId = categories.first.id;
            } else {
              // Create default Labour category if table is empty
              targetCategoryId = _uuid.v4();
              await _db
                  .into(_db.budgetCategoriesTable)
                  .insert(
                    BudgetCategoriesTableCompanion.insert(
                      id: targetCategoryId,
                      name: 'Labour (Field Operations)',
                      description: const Value(
                        'Casual wages for planting, weeding, and maintenance.',
                      ),
                      iconName: const Value('people'),
                      isSystemDefault: const Value(true),
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
            }
          }

          final expenseId = _uuid.v4();
          await _db
              .into(_db.expensesTable)
              .insert(
                ExpensesTableCompanion.insert(
                  id: expenseId,
                  projectId: projectId,
                  categoryId: targetCategoryId,
                  activityId: Value(activityId),
                  transactionDate: activityDate.millisecondsSinceEpoch,
                  description: 'Labour: $trimmedTitle',
                  quantity: const Value(1.0),
                  currency: Value(currency),
                  amountMinor: costMinor,
                  paymentMethod: expensePaymentMethod.code,
                  notes: Value(
                    notes?.trim().isNotEmpty == true ? notes!.trim() : null,
                  ),
                  createdAt: now,
                  updatedAt: now,
                  isSynced: const Value(false),
                ),
              );
        }

        return activityId;
      });
    }, operationName: 'recordActivity');
  }

  @override
  Future<void> updateActivity({
    required String id,
    required String projectId,
    required ActivityType activityType,
    required String title,
    required DateTime activityDate,
    String? description,
    int labourCount = 0,
    double? durationHours,
    int costMinor = 0,
    String currency = 'GHS',
    ActivityStatus status = ActivityStatus.completed,
    String? notes,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedTitle = title.trim();
      if (trimmedTitle.isEmpty) {
        throw const ValidationFailure('Activity title cannot be empty.');
      }
      if (costMinor < 0) {
        throw const ValidationFailure('Activity cost cannot be negative.');
      }
      if (labourCount < 0) {
        throw const ValidationFailure('Labour headcount cannot be negative.');
      }
      if (durationHours != null && durationHours <= 0) {
        throw const ValidationFailure(
          'Duration hours must be greater than zero.',
        );
      }

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await _db.transaction(() async {
        // Update Activity
        await (_db.update(
          _db.activitiesTable,
        )..where((tbl) => tbl.id.equals(id))).write(
          ActivitiesTableCompanion(
            projectId: Value(projectId),
            activityType: Value(activityType.code),
            title: Value(trimmedTitle),
            activityDate: Value(activityDate.millisecondsSinceEpoch),
            description: Value(
              description?.trim().isNotEmpty == true
                  ? description!.trim()
                  : null,
            ),
            labourCount: Value(labourCount),
            durationHours: Value(durationHours),
            costMinor: Value(costMinor),
            currency: Value(currency),
            status: Value(status.code),
            notes: Value(
              notes?.trim().isNotEmpty == true ? notes!.trim() : null,
            ),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );

        // Update any linked Expense
        final linkedExpense =
            await (_db.select(_db.expensesTable)..where(
                  (e) => e.activityId.equals(id) & e.isDeleted.equals(false),
                ))
                .getSingleOrNull();

        if (linkedExpense != null) {
          await (_db.update(
            _db.expensesTable,
          )..where((tbl) => tbl.id.equals(linkedExpense.id))).write(
            ExpensesTableCompanion(
              projectId: Value(projectId),
              transactionDate: Value(activityDate.millisecondsSinceEpoch),
              amountMinor: Value(costMinor),
              description: Value('Labour: $trimmedTitle'),
              updatedAt: Value(now),
              isSynced: const Value(false),
            ),
          );
        }
      });
    }, operationName: 'updateActivity');
  }

  @override
  Future<void> deleteActivity(
    String id, {
    bool deleteLinkedExpense = false,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      await _db.transaction(() async {
        // Soft delete activity
        await (_db.update(
          _db.activitiesTable,
        )..where((tbl) => tbl.id.equals(id))).write(
          ActivitiesTableCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
            isSynced: const Value(false),
          ),
        );

        // Optionally soft delete linked expense
        if (deleteLinkedExpense) {
          await (_db.update(
            _db.expensesTable,
          )..where((tbl) => tbl.activityId.equals(id))).write(
            ExpensesTableCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(now),
              isSynced: const Value(false),
            ),
          );
        }
      });
    }, operationName: 'deleteActivity');
  }

  @override
  Future<List<String>> getSuggestedTitles(
    ActivityType activityType, {
    int limit = 10,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final query = _db.selectOnly(_db.activitiesTable, distinct: true)
        ..addColumns([_db.activitiesTable.title])
        ..where(
          _db.activitiesTable.activityType.equals(activityType.code) &
              _db.activitiesTable.isDeleted.equals(false),
        )
        ..limit(limit);

      final rows = await query.get();
      final historicTitles = rows
          .map((r) => r.read(_db.activitiesTable.title))
          .whereType<String>()
          .toList();

      final combined = <String>{
        ...historicTitles,
        ...activityType.suggestedTitles,
      };
      return combined.take(limit).toList();
    }, operationName: 'getSuggestedTitles');
  }
}
