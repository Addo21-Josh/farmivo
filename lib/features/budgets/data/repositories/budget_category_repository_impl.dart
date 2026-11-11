import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/repositories/budget_category_repository.dart';

/// Drift SQLite implementation of [BudgetCategoryRepository].
class BudgetCategoryRepositoryImpl implements BudgetCategoryRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  BudgetCategoryRepositoryImpl(this._db, {Uuid uuid = const Uuid()})
    : _uuid = uuid;

  @override
  Future<List<BudgetCategory>> getAll() {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.budgetCategoriesTable)
            ..where((tbl) => tbl.isDeleted.equals(false))
            ..orderBy([
              (tbl) => OrderingTerm.asc(tbl.displayOrder),
              (tbl) => OrderingTerm.asc(tbl.name),
            ]))
          .get();
    }, operationName: 'fetch all budget categories');
  }

  @override
  Stream<List<BudgetCategory>> watchAll() {
    return (_db.select(_db.budgetCategoriesTable)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.displayOrder),
            (tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .watch();
  }

  @override
  Future<BudgetCategory?> getById(String id) {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.budgetCategoriesTable)
            ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
          .getSingleOrNull();
    }, operationName: 'fetch budget category by ID');
  }

  @override
  Stream<BudgetCategory?> watchById(String id) {
    return (_db.select(_db.budgetCategoriesTable)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  @override
  Future<bool> nameExists(String name, {String? excludeId}) async {
    final sanitized = name.trim().toLowerCase();
    final categories = await getAll();
    return categories.any(
      (c) =>
          c.name.trim().toLowerCase() == sanitized &&
          (excludeId == null || c.id != excludeId),
    );
  }

  @override
  Future<bool> isCategoryInUse(String categoryId) async {
    final budgetItemCount =
        await (_db.select(_db.budgetItemsTable)..where(
              (tbl) =>
                  tbl.categoryId.equals(categoryId) &
                  tbl.isDeleted.equals(false),
            ))
            .get();
    if (budgetItemCount.isNotEmpty) return true;

    final expenseCount =
        await (_db.select(_db.expensesTable)..where(
              (tbl) =>
                  tbl.categoryId.equals(categoryId) &
                  tbl.isDeleted.equals(false),
            ))
            .get();
    return expenseCount.isNotEmpty;
  }

  @override
  Future<BudgetCategory> createCustomCategory({
    required String name,
    String? description,
    String? iconName,
  }) {
    return DatabaseExceptionMapper.runSafe(() async {
      final sanitizedName = name.trim();
      if (sanitizedName.isEmpty) {
        throw const ValidationFailure('Category name cannot be empty.');
      }

      if (await nameExists(sanitizedName)) {
        throw ValidationFailure(
          'A budget category named "$sanitizedName" already exists.',
        );
      }

      final existing = await getAll();
      final nextOrder = existing.isEmpty
          ? 1
          : existing
                    .map((c) => c.displayOrder)
                    .reduce((a, b) => a > b ? a : b) +
                1;

      final now = DateTime.now().millisecondsSinceEpoch;
      final category = BudgetCategory(
        id: _uuid.v4(),
        name: sanitizedName,
        description: description?.trim().isNotEmpty == true
            ? description!.trim()
            : null,
        iconName: iconName?.trim().isNotEmpty == true
            ? iconName!.trim()
            : 'category',
        isSystemDefault: false,
        displayOrder: nextOrder,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      await _db.into(_db.budgetCategoriesTable).insert(category);
      return category;
    }, operationName: 'create custom budget category');
  }

  @override
  Future<void> create(BudgetCategory entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      await _db.into(_db.budgetCategoriesTable).insert(entity);
    }, operationName: 'insert budget category');
  }

  @override
  Future<void> update(BudgetCategory entity) {
    return DatabaseExceptionMapper.runSafe(() async {
      final existing = await getById(entity.id);
      if (existing == null) {
        throw const ValidationFailure('Budget category not found.');
      }

      if (await nameExists(entity.name, excludeId: entity.id)) {
        throw ValidationFailure(
          'A budget category named "${entity.name}" already exists.',
        );
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      // Preserve system default state
      final updated = entity.copyWith(
        isSystemDefault: existing.isSystemDefault,
        updatedAt: now,
      );

      await _db.update(_db.budgetCategoriesTable).replace(updated);
    }, operationName: 'update budget category');
  }

  @override
  Future<void> delete(String id) {
    return DatabaseExceptionMapper.runSafe(() async {
      final category = await getById(id);
      if (category == null) return;

      if (category.isSystemDefault) {
        throw const FinancialRuleFailure(
          'Standard agricultural categories cannot be deleted.',
        );
      }

      if (await isCategoryInUse(id)) {
        throw FinancialRuleFailure(
          'Cannot delete "${category.name}" because it is currently linked to budgeted items or operational expenses.',
        );
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(
        _db.budgetCategoriesTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        BudgetCategoriesTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'delete budget category');
  }
}
