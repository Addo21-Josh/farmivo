import 'package:drift/drift.dart';

/// Idempotent queue for offline-first transactional replication.
@DataClassName('SyncQueueEntry')
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  TextColumn get id => text()();
  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'INSERT', 'UPDATE', 'DELETE'
  TextColumn get payloadJson => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get queuedAt => integer()();
  TextColumn get status => text().withDefault(
    const Constant('PENDING'),
  )(); // PENDING, PROCESSING, FAILED, COMPLETED

  @override
  Set<Column> get primaryKey => {id};
}
