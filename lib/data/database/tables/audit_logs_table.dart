import 'package:drift/drift.dart';

/// Immutable forensic audit trail tracking modifications to financial and operational records.
@DataClassName('AuditLog')
class AuditLogsTable extends Table {
  @override
  String get tableName => 'audit_logs';

  TextColumn get id => text()();
  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()(); // 'CREATE', 'UPDATE', 'VOID', 'DELETE'
  TextColumn get previousStateJson => text().nullable()();
  TextColumn get newStateJson => text().nullable()();
  TextColumn get performedBy =>
      text().withDefault(const Constant('local_user'))();
  TextColumn get reason => text().nullable()();
  IntColumn get timestamp => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
