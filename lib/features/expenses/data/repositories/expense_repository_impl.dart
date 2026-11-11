import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../data/database/app_database.dart';
import '../../../audit/data/repositories/audit_log_repository_impl.dart';
import '../../../audit/domain/models/audit_action.dart';
import '../../../audit/domain/repositories/audit_log_repository.dart';
import '../../domain/models/expense_filter.dart';
import '../../domain/models/expense_with_details.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/repositories/expense_repository.dart';

/// SQLite implementation of [ExpenseRepository] backed by Drift.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase _db;
  final Uuid _uuid;
  final AuditLogRepository _auditRepository;

  ExpenseRepositoryImpl({
    required AppDatabase db,
    Uuid? uuid,
    AuditLogRepository? auditRepository,
  }) : _db = db,
       _uuid = uuid ?? const Uuid(),
       _auditRepository =
           auditRepository ?? AuditLogRepositoryImpl(db: db, uuid: uuid);

  @override
  Future<String> recordExpense({
    required String projectId,
    required String categoryId,
    String? budgetItemId,
    String? activityId,
    required DateTime transactionDate,
    required String description,
    double quantity = 1.0,
    String? unit,
    int? unitCostMinor,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? vendorName,
    String? receiptPhotoPath,
    String? notes,
  }) async {
    if (amountMinor <= 0) {
      throw const ValidationFailure(
        'Expense amount must be greater than zero.',
      );
    }
    final trimmedDesc = description.trim();
    if (trimmedDesc.isEmpty) {
      throw const ValidationFailure('Expense description cannot be empty.');
    }
    if (projectId.trim().isEmpty) {
      throw const ValidationFailure('Project is required.');
    }
    if (categoryId.trim().isEmpty) {
      throw const ValidationFailure('Category is required.');
    }

    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final expenseId = _uuid.v4();

      final companion = ExpensesTableCompanion.insert(
        id: expenseId,
        createdAt: now,
        updatedAt: now,
        isSynced: const Value(false),
        isDeleted: const Value(false),
        projectId: projectId,
        categoryId: categoryId,
        budgetItemId: Value(
          budgetItemId?.trim().isNotEmpty == true ? budgetItemId!.trim() : null,
        ),
        activityId: Value(
          activityId?.trim().isNotEmpty == true ? activityId!.trim() : null,
        ),
        transactionDate: transactionDate.millisecondsSinceEpoch,
        description: trimmedDesc,
        quantity: Value(quantity > 0 ? quantity : 1.0),
        unit: Value(unit?.trim().isNotEmpty == true ? unit!.trim() : null),
        unitCostMinor: Value(unitCostMinor),
        amountMinor: amountMinor,
        currency: Value(currency.trim().toUpperCase()),
        paymentMethod: paymentMethod.code,
        vendorName: Value(
          vendorName?.trim().isNotEmpty == true ? vendorName!.trim() : null,
        ),
        receiptPhotoPath: Value(
          receiptPhotoPath?.trim().isNotEmpty == true
              ? receiptPhotoPath!.trim()
              : null,
        ),
        notes: Value(notes?.trim().isNotEmpty == true ? notes!.trim() : null),
        isVoided: const Value(false),
      );

      await _db.into(_db.expensesTable).insert(companion);
      return expenseId;
    }, operationName: 'recordExpense');
  }

  @override
  Future<void> voidExpense({required String id, required String reason}) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw const ValidationFailure('A voiding reason must be provided.');
    }

    return DatabaseExceptionMapper.runSafe(() async {
      final existing =
          await (_db.select(_db.expensesTable)..where(
                (tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false),
              ))
              .getSingleOrNull();

      if (existing == null) {
        throw const ValidationFailure('Expense not found.');
      }
      if (existing.isVoided) {
        throw const ValidationFailure('This expense has already been voided.');
      }

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.expensesTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        ExpensesTableCompanion(
          isVoided: const Value(true),
          voidedAt: Value(now),
          voidReason: Value(trimmedReason),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // Record immutable audit log entry
      await _auditRepository.logAction(
        entityTable: 'expenses',
        entityId: id,
        action: AuditAction.voidRecord,
        previousState: {
          'id': existing.id,
          'projectId': existing.projectId,
          'amountMinor': existing.amountMinor,
          'currency': existing.currency,
          'isVoided': false,
          'description': existing.description,
        },
        newState: {
          'id': existing.id,
          'projectId': existing.projectId,
          'amountMinor': existing.amountMinor,
          'currency': existing.currency,
          'isVoided': true,
          'voidReason': trimmedReason,
          'voidedAt': now,
          'description': existing.description,
        },
        reason: trimmedReason,
      );
    }, operationName: 'voidExpense');
  }

  @override
  Future<ExpenseWithDetails?> getExpenseById(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final query =
          _db.select(_db.expensesTable).join([
            innerJoin(
              _db.budgetCategoriesTable,
              _db.budgetCategoriesTable.id.equalsExp(
                _db.expensesTable.categoryId,
              ),
            ),
            innerJoin(
              _db.projectsTable,
              _db.projectsTable.id.equalsExp(_db.expensesTable.projectId),
            ),
            leftOuterJoin(
              _db.budgetItemsTable,
              _db.budgetItemsTable.id.equalsExp(_db.expensesTable.budgetItemId),
            ),
          ])..where(
            _db.expensesTable.id.equals(id) &
                _db.expensesTable.isDeleted.equals(false),
          );

      final row = await query.getSingleOrNull();
      if (row == null) return null;

      return ExpenseWithDetails(
        expense: row.readTable(_db.expensesTable),
        category: row.readTable(_db.budgetCategoriesTable),
        project: row.readTableOrNull(_db.projectsTable),
        budgetItem: row.readTableOrNull(_db.budgetItemsTable),
      );
    }, operationName: 'getExpenseById');
  }

  @override
  Stream<List<ExpenseWithDetails>> watchExpensesByProject(String projectId) {
    final query =
        _db.select(_db.expensesTable).join([
            innerJoin(
              _db.budgetCategoriesTable,
              _db.budgetCategoriesTable.id.equalsExp(
                _db.expensesTable.categoryId,
              ),
            ),
            innerJoin(
              _db.projectsTable,
              _db.projectsTable.id.equalsExp(_db.expensesTable.projectId),
            ),
            leftOuterJoin(
              _db.budgetItemsTable,
              _db.budgetItemsTable.id.equalsExp(_db.expensesTable.budgetItemId),
            ),
          ])
          ..where(
            _db.expensesTable.projectId.equals(projectId) &
                _db.expensesTable.isDeleted.equals(false),
          )
          ..orderBy([
            OrderingTerm.desc(_db.expensesTable.transactionDate),
            OrderingTerm.desc(_db.expensesTable.createdAt),
          ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExpenseWithDetails(
          expense: row.readTable(_db.expensesTable),
          category: row.readTable(_db.budgetCategoriesTable),
          project: row.readTableOrNull(_db.projectsTable),
          budgetItem: row.readTableOrNull(_db.budgetItemsTable),
        );
      }).toList();
    });
  }

  @override
  Stream<List<ExpenseWithDetails>> watchAllExpenses() {
    final query =
        _db.select(_db.expensesTable).join([
            innerJoin(
              _db.budgetCategoriesTable,
              _db.budgetCategoriesTable.id.equalsExp(
                _db.expensesTable.categoryId,
              ),
            ),
            innerJoin(
              _db.projectsTable,
              _db.projectsTable.id.equalsExp(_db.expensesTable.projectId),
            ),
            leftOuterJoin(
              _db.budgetItemsTable,
              _db.budgetItemsTable.id.equalsExp(_db.expensesTable.budgetItemId),
            ),
          ])
          ..where(_db.expensesTable.isDeleted.equals(false))
          ..orderBy([
            OrderingTerm.desc(_db.expensesTable.transactionDate),
            OrderingTerm.desc(_db.expensesTable.createdAt),
          ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExpenseWithDetails(
          expense: row.readTable(_db.expensesTable),
          category: row.readTable(_db.budgetCategoriesTable),
          project: row.readTableOrNull(_db.projectsTable),
          budgetItem: row.readTableOrNull(_db.budgetItemsTable),
        );
      }).toList();
    });
  }

  @override
  Stream<List<ExpenseWithDetails>> watchExpensesWithFilter(
    ExpenseFilter filter,
  ) {
    var query = _db.select(_db.expensesTable).join([
      innerJoin(
        _db.budgetCategoriesTable,
        _db.budgetCategoriesTable.id.equalsExp(_db.expensesTable.categoryId),
      ),
      innerJoin(
        _db.projectsTable,
        _db.projectsTable.id.equalsExp(_db.expensesTable.projectId),
      ),
      leftOuterJoin(
        _db.budgetItemsTable,
        _db.budgetItemsTable.id.equalsExp(_db.expensesTable.budgetItemId),
      ),
    ]);

    Expression<bool> predicate = _db.expensesTable.isDeleted.equals(false);

    if (filter.status == ExpenseStatusFilter.activeOnly) {
      predicate = predicate & _db.expensesTable.isVoided.equals(false);
    } else if (filter.status == ExpenseStatusFilter.voidedOnly) {
      predicate = predicate & _db.expensesTable.isVoided.equals(true);
    }

    if (filter.projectId != null) {
      predicate =
          predicate & _db.expensesTable.projectId.equals(filter.projectId!);
    }

    if (filter.categoryId != null) {
      predicate =
          predicate & _db.expensesTable.categoryId.equals(filter.categoryId!);
    }

    if (filter.paymentMethod != null) {
      predicate =
          predicate &
          _db.expensesTable.paymentMethod.equals(filter.paymentMethod!.code);
    }

    if (filter.startDate != null) {
      final startEpoch = DateTime(
        filter.startDate!.year,
        filter.startDate!.month,
        filter.startDate!.day,
      ).millisecondsSinceEpoch;
      predicate =
          predicate &
          _db.expensesTable.transactionDate.isBiggerOrEqualValue(startEpoch);
    }

    if (filter.endDate != null) {
      final endEpoch = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
        999,
      ).millisecondsSinceEpoch;
      predicate =
          predicate &
          _db.expensesTable.transactionDate.isSmallerOrEqualValue(endEpoch);
    }

    if (filter.minAmountMinor != null) {
      predicate =
          predicate &
          _db.expensesTable.amountMinor.isBiggerOrEqualValue(
            filter.minAmountMinor!,
          );
    }

    if (filter.maxAmountMinor != null) {
      predicate =
          predicate &
          _db.expensesTable.amountMinor.isSmallerOrEqualValue(
            filter.maxAmountMinor!,
          );
    }

    if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
      final q = '%${filter.searchQuery!.trim().toLowerCase()}%';
      predicate =
          predicate &
          (_db.expensesTable.description.lower().like(q) |
              _db.expensesTable.vendorName.lower().like(q));
    }

    query = query
      ..where(predicate)
      ..orderBy([
        OrderingTerm.desc(_db.expensesTable.transactionDate),
        OrderingTerm.desc(_db.expensesTable.createdAt),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExpenseWithDetails(
          expense: row.readTable(_db.expensesTable),
          category: row.readTable(_db.budgetCategoriesTable),
          project: row.readTableOrNull(_db.projectsTable),
          budgetItem: row.readTableOrNull(_db.budgetItemsTable),
        );
      }).toList();
    });
  }

  @override
  Future<List<String>> getFrequentVendors({int limit = 10}) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final query = _db.selectOnly(_db.expensesTable, distinct: true)
        ..addColumns([_db.expensesTable.vendorName])
        ..where(
          _db.expensesTable.isDeleted.equals(false) &
              _db.expensesTable.vendorName.isNotNull(),
        )
        ..limit(limit);

      final rows = await query.get();
      return rows
          .map((r) => r.read(_db.expensesTable.vendorName))
          .whereType<String>()
          .where((v) => v.trim().isNotEmpty)
          .toList();
    }, operationName: 'getFrequentVendors');
  }

  @override
  Future<void> deleteExpense(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.expensesTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        ExpensesTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );
    }, operationName: 'deleteExpense');
  }
}
