import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';

/// Agronomic and financial risks tracking.
@DataClassName('Risk')
class RisksTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'risks';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get riskTitle => text()();
  TextColumn get category =>
      text()(); // 'Weather', 'Pest/Disease', 'Market/Price', 'Labour', etc.
  IntColumn get probability => integer()(); // 1 to 5
  IntColumn get impact => integer()(); // 1 to 5
  IntColumn get riskScore => integer()(); // probability * impact (1 to 25)
  TextColumn get mitigationStrategy => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('IDENTIFIED'))();
  TextColumn get notes => text().nullable()();
}
