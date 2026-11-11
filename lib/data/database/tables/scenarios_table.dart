import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';

/// Sensitivity scenarios (Conservative, Expected, Optimistic).
@DataClassName('Scenario')
class ScenariosTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'scenarios';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get scenarioType =>
      text()(); // 'CONSERVATIVE', 'EXPECTED', 'OPTIMISTIC'
  RealColumn get expectedYield => real()();
  TextColumn get yieldUnit => text()();
  IntColumn get expectedUnitPriceMinor => integer()();
  IntColumn get projectedRevenueMinor => integer()();
  IntColumn get projectedCostMinor => integer()();
  IntColumn get projectedProfitMinor => integer()();
  RealColumn get projectedRoiPercent => real()();
  TextColumn get notes => text().nullable()();
}
