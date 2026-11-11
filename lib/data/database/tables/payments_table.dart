import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'sales_table.dart';

/// Cash or mobile money payments received against sales agreements.
@DataClassName('Payment')
class PaymentsTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'payments';

  TextColumn get saleId =>
      text().references(SalesTable, #id, onDelete: KeyAction.restrict)();
  IntColumn get paymentDate => integer()();

  /// Minor units (Pesewas for GHS).
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get paymentMethod => text()(); // CASH, MOMO, BANK, OTHER
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Soft voiding flags.
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
  IntColumn get voidedAt => integer().nullable()();
  TextColumn get voidReason => text().nullable()();
}
