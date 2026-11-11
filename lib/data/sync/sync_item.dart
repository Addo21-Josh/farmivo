/// Synchronization operation types for replication queue.
enum SyncOperation { insert, update, delete }

/// Synchronization processing statuses.
enum SyncStatus { pending, inProgress, failed, completed }

/// In-memory contract for sync payloads queued while offline.
class SyncItem {
  final String id;
  final String entityTable;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final int queuedAt;
  final int retryCount;
  final SyncStatus status;
  final String? lastError;

  const SyncItem({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.queuedAt,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.lastError,
  });
}
