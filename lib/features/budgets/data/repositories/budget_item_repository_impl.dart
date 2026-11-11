import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/budget_item_with_category.dart';
import '../../domain/repositories/budget_item_repository.dart';

/// Concrete SQLite implementation of [BudgetItemRepository] using Drift.
class BudgetItemRepositoryImpl implements BudgetItemRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  BudgetItemRepositoryImpl(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  Future<List<BudgetItem>> getAll() {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.budgetItemsTable)
            ..where((tbl) => tbl.isDeleted.equals(false))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();
    }, operationName: 'fetch all budget items');
  }

  @override
  Stream<List<BudgetItem>> watchAll() {
    return (_db.select(_db.budgetItemsTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  @override
  Future<BudgetItem?> getById(String id) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.budgetItemsTable)
            ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();
    }, operationName: 'get budget item by id');
  }

  @override
  Stream<List<BudgetItem>> watchByProject(String projectId) {
    return (_db.select(_db.budgetItemsTable)
          ..where(
            (tbl) =>
                tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  @override
  Future<List<BudgetItem>> getByProject(String projectId) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.budgetItemsTable)
            ..where(
              (tbl) =>
                  tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();
    }, operationName: 'get budget items by project');
  }

  @override
  Stream<List<BudgetItemWithCategory>> watchByProjectWithCategory(
    String projectId,
  ) {
    final query =
        _db.select(_db.budgetItemsTable).join([
            innerJoin(
              _db.budgetCategoriesTable,
              _db.budgetCategoriesTable.id.equalsExp(
                _db.budgetItemsTable.categoryId,
              ),
            ),
          ])
          ..where(
            _db.budgetItemsTable.projectId.equals(projectId) &
                _db.budgetItemsTable.isDeleted.equals(false) &
                _db.budgetCategoriesTable.isDeleted.equals(false),
          )
          ..orderBy([
            OrderingTerm.asc(_db.budgetCategoriesTable.displayOrder),
            OrderingTerm.asc(_db.budgetItemsTable.name),
          ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return BudgetItemWithCategory(
          item: row.readTable(_db.budgetItemsTable),
          category: row.readTable(_db.budgetCategoriesTable),
        );
      }).toList();
    });
  }

  @override
  Future<List<BudgetItemWithCategory>> getByProjectWithCategory(
    String projectId,
  ) {
    return DatabaseExceptionMapper.runSafe(() async {
      final query =
          _db.select(_db.budgetItemsTable).join([
              innerJoin(
                _db.budgetCategoriesTable,
                _db.budgetCategoriesTable.id.equalsExp(
                  _db.budgetItemsTable.categoryId,
                ),
              ),
            ])
            ..where(
              _db.budgetItemsTable.projectId.equals(projectId) &
                  _db.budgetItemsTable.isDeleted.equals(false) &
                  _db.budgetCategoriesTable.isDeleted.equals(false),
            )
            ..orderBy([
              OrderingTerm.asc(_db.budgetCategoriesTable.displayOrder),
              OrderingTerm.asc(_db.budgetItemsTable.name),
            ]);

      final rows = await query.get();
      return rows.map((row) {
        return BudgetItemWithCategory(
          item: row.readTable(_db.budgetItemsTable),
          category: row.readTable(_db.budgetCategoriesTable),
        );
      }).toList();
    }, operationName: 'get budget items with category by project');
  }

  @override
  Future<BudgetItem> createBudgetItem({
    required String projectId,
    required String categoryId,
    required String name,
    required double quantity,
    required String unit,
    required int unitCostMinor,
    String currency = 'GHS',
    String? description,
  }) {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw const ValidationFailure('Budget item name cannot be empty.');
      }
      if (quantity <= 0) {
        throw const ValidationFailure('Quantity must be greater than zero.');
      }
      if (unitCostMinor < 0) {
        throw const ValidationFailure('Unit cost cannot be negative.');
      }
      final trimmedUnit = unit.trim();
      if (trimmedUnit.isEmpty) {
        throw const ValidationFailure('Measurement unit is required.');
      }

      // Verify project exists
      final project =
          await (_db.select(_db.projectsTable)..where(
                (tbl) => tbl.id.equals(projectId) & tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      if (project == null) {
        throw const ValidationFailure('Target farm project not found.');
      }

      // Verify category exists
      final category =
          await (_db.select(_db.budgetCategoriesTable)..where(
                (tbl) =>
                    tbl.id.equals(categoryId) & tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      if (category == null) {
        throw const ValidationFailure('Budget category not found.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final id = _uuid.v4();

      // Formula: Planned Amount = Quantity * Unit Cost
      final plannedAmountMinor = (quantity * unitCostMinor).round();

      final companion = BudgetItemsTableCompanion.insert(
        id: id,
        projectId: projectId,
        categoryId: categoryId,
        name: trimmedName,
        description: Value(
          description?.trim().isNotEmpty == true ? description!.trim() : null,
        ),
        quantity: quantity,
        unit: trimmedUnit,
        unitCostMinor: unitCostMinor,
        plannedAmountMinor: plannedAmountMinor,
        currency: Value(currency),
        status: const Value('PLANNED'),
        createdAt: now,
        updatedAt: now,
        isSynced: const Value(false),
        isDeleted: const Value(false),
      );

      await _db.into(_db.budgetItemsTable).insert(companion);

      return (await (_db.select(
        _db.budgetItemsTable,
      )..where((tbl) => tbl.id.equals(id))).getSingle());
    }, operationName: 'create budget item');
  }

  @override
  Future<void> updateBudgetItem({
    required String id,
    String? categoryId,
    String? name,
    double? quantity,
    String? unit,
    int? unitCostMinor,
    String? description,
    String? status,
  }) {
    return DatabaseExceptionMapper.runSafe(() async {
      final existing =
          await (_db.select(_db.budgetItemsTable)..where(
                (tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();

      if (existing == null) {
        throw const ValidationFailure('Budget item not found.');
      }

      final resolvedName = name != null ? name.trim() : existing.name;
      if (resolvedName.isEmpty) {
        throw const ValidationFailure('Budget item name cannot be empty.');
      }

      final resolvedQuantity = quantity ?? existing.quantity;
      if (resolvedQuantity <= 0) {
        throw const ValidationFailure('Quantity must be greater than zero.');
      }

      final resolvedUnitCost = unitCostMinor ?? existing.unitCostMinor;
      if (resolvedUnitCost < 0) {
        throw const ValidationFailure('Unit cost cannot be negative.');
      }

      final resolvedUnit = unit != null ? unit.trim() : existing.unit;
      if (resolvedUnit.isEmpty) {
        throw const ValidationFailure('Measurement unit is required.');
      }

      if (categoryId != null && categoryId != existing.categoryId) {
        final category =
            await (_db.select(_db.budgetCategoriesTable)..where(
                  (tbl) =>
                      tbl.id.equals(categoryId) & tbl.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (category == null) {
          throw const ValidationFailure('Budget category not found.');
        }
      }

      // Recompute Planned Amount = Quantity * Unit Cost
      final resolvedPlannedAmount = (resolvedQuantity * resolvedUnitCost)
          .round();
      final now = DateTime.now().millisecondsSinceEpoch;

      await (_db.update(
        _db.budgetItemsTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        BudgetItemsTableCompanion(
          categoryId: categoryId != null
              ? Value(categoryId)
              : const Value.absent(),
          name: Value(resolvedName),
          quantity: Value(resolvedQuantity),
          unit: Value(resolvedUnit),
          unitCostMinor: Value(resolvedUnitCost),
          plannedAmountMinor: Value(resolvedPlannedAmount),
          description: description != null
              ? Value(description.trim().isNotEmpty ? description.trim() : null)
              : const Value.absent(),
          status: status != null ? Value(status) : const Value.absent(),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    }, operationName: 'update budget item');
  }

  @override
  Future<void> delete(String id) {
    return deleteBudgetItem(id);
  }

  @override
  Future<void> deleteBudgetItem(String id) {
    return DatabaseExceptionMapper.runSafe(() async {
      final existing =
          await (_db.select(_db.budgetItemsTable)..where(
                (tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();

      if (existing == null) {
        throw const ValidationFailure('Budget item not found.');
      }

      // Check referential integrity with recorded expenses
      final linkedExpenses =
          await (_db.select(_db.expensesTable)..where(
                (tbl) =>
                    tbl.budgetItemId.equals(id) &
                    tbl.isDeleted.equals(false) &
                    tbl.isVoided.equals(false),
              ))
              .get();

      if (linkedExpenses.isNotEmpty) {
        throw FinancialRuleFailure(
          'Cannot delete "${existing.name}" because ${linkedExpenses.length} expense record(s) are currently linked to it.',
        );
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(
        _db.budgetItemsTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        BudgetItemsTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    }, operationName: 'delete budget item');
  }

  @override
  Future<void> create(BudgetItem entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.into(_db.budgetItemsTable).insert(entity);
    }, operationName: 'insert raw budget item');
  }

  @override
  Future<void> update(BudgetItem entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.update(_db.budgetItemsTable).replace(entity);
    }, operationName: 'replace raw budget item');
  }

  @override
  Future<int> getTotalPlannedMinor(String projectId) {
    return DatabaseExceptionMapper.runSafe(() async {
      final items =
          await (_db.select(_db.budgetItemsTable)..where(
                (tbl) =>
                    tbl.projectId.equals(projectId) &
                    tbl.isDeleted.equals(false),
              ))
              .get();

      return items.fold<int>(0, (acc, item) => acc + item.plannedAmountMinor);
    }, operationName: 'calculate total planned budget');
  }

  @override
  Stream<int> watchTotalPlannedMinor(String projectId) {
    return (_db.select(_db.budgetItemsTable)..where(
          (tbl) =>
              tbl.projectId.equals(projectId) & tbl.isDeleted.equals(false),
        ))
        .watch()
        .map(
          (items) =>
              items.fold<int>(0, (acc, item) => acc + item.plannedAmountMinor),
        );
  }
}
