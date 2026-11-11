import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';
import 'budget_categories_table.dart';
import 'budget_items_table.dart';

/// Transactional ledger of operational and capital expenditures.
@DataClassName('Expense')
class ExpensesTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'expenses';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get categoryId => text().references(
    BudgetCategoriesTable,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get budgetItemId => text().nullable().references(
    BudgetItemsTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get activityId => text().nullable()();
  IntColumn get transactionDate => integer()();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().nullable()();
  IntColumn get unitCostMinor => integer().nullable()();

  /// Minor units (Pesewas for GHS).
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get paymentMethod =>
      text()(); // 'CASH', 'MOMO', 'BANK', 'CREDIT', 'OTHER'
  TextColumn get vendorName => text().nullable()();
  TextColumn get receiptPhotoPath => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Soft voiding flags preserving auditability.
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
  IntColumn get voidedAt => integer().nullable()();
  TextColumn get voidReason => text().nullable()();
}
