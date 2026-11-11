import 'package:drift/drift.dart';
import 'base_entity_table.dart';

/// Stores agricultural landholdings and farm properties.
@DataClassName('Farm')
class FarmsTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'farms';

  TextColumn get name => text()();
  TextColumn get location => text()();
  TextColumn get district => text().nullable()();
  TextColumn get region => text()();
  TextColumn get country => text().withDefault(const Constant('Ghana'))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get totalArea => real()();
  TextColumn get areaUnit => text().withDefault(const Constant('Acres'))();
  TextColumn get ownershipType =>
      text()(); // 'Owned', 'Family', 'Rented', 'Leased', 'Abunu', 'Abusa', etc.
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
}
