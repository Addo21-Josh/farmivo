import 'package:drift/drift.dart';
import 'base_entity_table.dart';
import 'projects_table.dart';

/// General liquidity movements (Capital injections, loans, owner drawings).
@DataClassName('CashTransaction')
class CashTransactionsTable extends Table with BaseEntityTable {
  @override
  String get tableName => 'cash_transactions';

  TextColumn get projectId => text().nullable().references(
    ProjectsTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get transactionType => text()(); // 'CASH_IN', 'CASH_OUT'
  TextColumn get category => text()();
  IntColumn get transactionDate => integer()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get referenceId => text().nullable()();
  TextColumn get notes => text().nullable()();
}
