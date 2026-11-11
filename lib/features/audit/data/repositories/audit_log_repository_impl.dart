import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/audit_action.dart';
import '../../domain/models/audit_log_entry.dart';
import '../../domain/repositories/audit_log_repository.dart';

/// Concrete Drift implementation of the immutable audit repository (Milestone 9.3).
class AuditLogRepositoryImpl implements AuditLogRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  AuditLogRepositoryImpl({required AppDatabase db, Uuid? uuid})
    : _db = db,
      _uuid = uuid ?? const Uuid();

  @override
  Future<void> logAction({
    required String entityTable,
    required String entityId,
    required AuditAction action,
    Map<String, dynamic>? previousState,
    Map<String, dynamic>? newState,
    String? reason,
    String performedBy = 'local_user',
    DateTime? timestamp,
  }) async {
    final now =
        timestamp?.millisecondsSinceEpoch ??
        DateTime.now().toUtc().millisecondsSinceEpoch;
    final logId = _uuid.v4();

    String? serialize(Map<String, dynamic>? data) {
      if (data == null || data.isEmpty) return null;
      try {
        return jsonEncode(data);
      } catch (_) {
        return null;
      }
    }

    final companion = AuditLogsTableCompanion.insert(
      id: logId,
      entityTable: entityTable.trim().toLowerCase(),
      entityId: entityId.trim(),
      action: action.code,
      previousStateJson: Value(serialize(previousState)),
      newStateJson: Value(serialize(newState)),
      performedBy: Value(
        performedBy.trim().isNotEmpty ? performedBy.trim() : 'local_user',
      ),
      reason: Value(reason?.trim().isNotEmpty == true ? reason!.trim() : null),
      timestamp: now,
    );

    await _db.into(_db.auditLogsTable).insert(companion);
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogs({
    String? entityTable,
    String? entityId,
    AuditAction? action,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = _db.select(_db.auditLogsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);

    if (entityTable != null && entityTable.trim().isNotEmpty) {
      query.where(
        (t) => t.entityTable.equals(entityTable.trim().toLowerCase()),
      );
    }
    if (entityId != null && entityId.trim().isNotEmpty) {
      query.where((t) => t.entityId.equals(entityId.trim()));
    }
    if (action != null) {
      query.where((t) => t.action.equals(action.code));
    }

    final rows = await query.get();
    return rows.map(AuditLogEntry.fromDrift).toList();
  }

  @override
  Stream<List<AuditLogEntry>> watchAuditLogs({
    String? entityTable,
    String? entityId,
    AuditAction? action,
    int limit = 100,
  }) {
    final query = _db.select(_db.auditLogsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (entityTable != null && entityTable.trim().isNotEmpty) {
      query.where(
        (t) => t.entityTable.equals(entityTable.trim().toLowerCase()),
      );
    }
    if (entityId != null && entityId.trim().isNotEmpty) {
      query.where((t) => t.entityId.equals(entityId.trim()));
    }
    if (action != null) {
      query.where((t) => t.action.equals(action.code));
    }

    return query.watch().map(
      (rows) => rows.map(AuditLogEntry.fromDrift).toList(),
    );
  }

  @override
  Future<List<AuditLogEntry>> getAuditTrailForEntity({
    required String entityTable,
    required String entityId,
  }) async {
    return getAuditLogs(
      entityTable: entityTable,
      entityId: entityId,
      limit: 200,
    );
  }

  @override
  Future<int> countAuditLogs({String? entityTable, AuditAction? action}) async {
    final countExp = _db.auditLogsTable.id.count();
    final query = _db.selectOnly(_db.auditLogsTable)..addColumns([countExp]);

    if (entityTable != null && entityTable.trim().isNotEmpty) {
      query.where(
        _db.auditLogsTable.entityTable.equals(entityTable.trim().toLowerCase()),
      );
    }
    if (action != null) {
      query.where(_db.auditLogsTable.action.equals(action.code));
    }

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }
}
