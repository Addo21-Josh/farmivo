import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';

/// Harvest yields and inventory batches decoupled from sales.
@DataClassName('Harvest')
class HarvestsTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'harvests';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get batchNumber => text()();
  IntColumn get harvestDate => integer()();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()(); // 'kg', '50kg Bag', 'Crate', 'Tonne'
  TextColumn get grade =>
      text().nullable()(); // 'Grade A', 'Grade B', 'Rejects'
  TextColumn get storageLocation => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
}
