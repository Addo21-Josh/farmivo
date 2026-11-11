import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';
import 'buyers_table.dart';
import 'harvests_table.dart';

/// Commercial harvest sales transactions.
@DataClassName('Sale')
class SalesTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'sales';

  TextColumn get projectId =>
      text().references(ProjectsTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get buyerId => text().nullable().references(
    BuyersTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get harvestId => text().nullable().references(
    HarvestsTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get saleDate => integer()();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();

  /// Minor units (Pesewas for GHS).
  IntColumn get unitPriceMinor => integer()();

  /// Minor units (quantity * unitPriceMinor).
  IntColumn get totalAmountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get paymentStatus =>
      text().withDefault(const Constant('UNPAID'))(); // PAID, PARTIAL, UNPAID
  TextColumn get notes => text().nullable()();

  /// Soft voiding flags.
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
  IntColumn get voidedAt => integer().nullable()();
  TextColumn get voidReason => text().nullable()();
}
