import 'package:drift/drift.dart';
import 'base_entity_table.dart';

/// Customers, off-takers, and market buyers.
@DataClassName('Buyer')
class BuyersTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'buyers';

  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get businessName => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
}
