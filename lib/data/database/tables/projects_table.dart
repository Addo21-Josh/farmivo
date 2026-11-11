import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'farms_table.dart';

/// Represents a distinct agricultural venture, crop season, or livestock cycle.
@DataClassName('Project')
class ProjectsTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'projects';

  TextColumn get farmId =>
      text().references(FarmsTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get projectType =>
      text()(); // 'Crop', 'Livestock', 'Aquaculture', 'Custom'
  TextColumn get commodity => text()(); // e.g. 'Pepper', 'Maize', 'Poultry'
  TextColumn get variety => text().nullable()();
  RealColumn get landSize => real()();
  TextColumn get landUnit => text().withDefault(const Constant('Acres'))();
  IntColumn get startDate => integer()();
  IntColumn get expectedCompletionDate => integer().nullable()();
  IntColumn get expectedFirstHarvestDate => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get status => text().withDefault(
    const Constant('PLANNING'),
  )(); // PLANNING, ACTIVE, etc.
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
}
