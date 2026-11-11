import 'package:drift/drift.dart';

/// Common base entity columns for offline-first synchronization and auditability.
mixin BaseEntityTable on Table {
  /// Unique client-generated UUID v4 identifier.
  TextColumn get id => text()();

  /// Creation timestamp in milliseconds since epoch (UTC).
  IntColumn get createdAt => integer()();

  /// Last modification timestamp in milliseconds since epoch (UTC).
  IntColumn get updatedAt => integer()();

  /// Whether this record has been confirmed and synchronized with cloud.
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// Soft deletion tombstone for cloud replication.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
