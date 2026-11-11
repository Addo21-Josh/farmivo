import 'package:drift/drift.dart';
import 'base_entity_table.dart';

/// Taxonomy categories for grouping planned and actual farm expenditures.
@DataClassName('BudgetCategory')
class BudgetCategoriesTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'budget_categories';

  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get iconName => text().nullable()();
  BoolColumn get isSystemDefault =>
      boolean().withDefault(const Constant(false))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
}
