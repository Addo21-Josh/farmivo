import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';

/// Agronomic field operations and casual labour logs.
@DataClassName('Activity')
class ActivitiesTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'activities';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get activityType =>
      text()(); // 'Ploughing', 'Planting', 'Weeding', 'Spraying', etc.
  TextColumn get title => text()();
  IntColumn get activityDate => integer()();
  TextColumn get description => text().nullable()();
  IntColumn get labourCount => integer().withDefault(const Constant(0))();
  RealColumn get durationHours => real().nullable()();
  IntColumn get costMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();
  TextColumn get notes => text().nullable()();
}
