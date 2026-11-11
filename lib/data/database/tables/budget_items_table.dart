import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';
import 'budget_categories_table.dart';

/// Pre-season budgeted allocations and unit cost estimates per project.
@DataClassName('BudgetItem')
class BudgetItemsTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'budget_items';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().references(
    BudgetCategoriesTable,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();

  /// Stored as 64-bit integer minor currency units (Pesewas for GHS).
  IntColumn get unitCostMinor => integer()();

  /// quantity * unitCostMinor in minor units.
  IntColumn get plannedAmountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get status => text().withDefault(const Constant('PLANNED'))();
}
