import '../models/audit_action.dart';
import '../models/audit_log_entry.dart';

/// Contract for immutable audit log persistence and querying (Milestone 9.3).
abstract class AuditLogRepository {
  /// Appends an immutable audit entry to the audit log.
  Future<void> logAction({
    required String entityTable,
    required String entityId,
    required AuditAction action,
    Map<String, dynamic>? previousState,
    Map<String, dynamic>? newState,
    String? reason,
    String performedBy = 'local_user',
    DateTime? timestamp,
  });

  /// Queries audit logs with optional filters, sorted descending by timestamp.
  Future<List<AuditLogEntry>> getAuditLogs({
    String? entityTable,
    String? entityId,
    AuditAction? action,
    int limit = 100,
    int offset = 0,
  });

  /// Watches an active stream of audit logs for real-time UI updates.
  Stream<List<AuditLogEntry>> watchAuditLogs({
    String? entityTable,
    String? entityId,
    AuditAction? action,
    int limit = 100,
  });

  /// Retrieves the complete forensic history of a specific entity record.
  Future<List<AuditLogEntry>> getAuditTrailForEntity({
    required String entityTable,
    required String entityId,
  });

  /// Total count of audit records currently stored.
  Future<int> countAuditLogs({String? entityTable, AuditAction? action});
}
