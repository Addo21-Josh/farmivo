import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../data/database/app_database.dart';
import 'audit_action.dart';

/// Domain representation of an immutable audit trail entry (Milestone 9.3).
class AuditLogEntry {
  final String id;
  final String entityTable;
  final String entityId;
  final AuditAction action;
  final Map<String, dynamic>? previousState;
  final Map<String, dynamic>? newState;
  final String performedBy;
  final String? reason;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.action,
    this.previousState,
    this.newState,
    this.performedBy = 'local_user',
    this.reason,
    required this.timestamp,
  });

  /// Formatted date string (e.g. `15 Mar 2026, 14:32`).
  String get formattedDate =>
      DateFormat('dd MMM yyyy, HH:mm').format(timestamp);

  /// Human-friendly entity table label.
  String get entityDisplayName {
    switch (entityTable.toLowerCase()) {
      case 'expenses':
        return 'Expense Record';
      case 'sales':
        return 'Sale Contract';
      case 'payments':
        return 'Payment Receipt';
      case 'budget_items':
        return 'Budget Allocation';
      case 'harvests':
        return 'Harvest Yield Batch';
      case 'projects':
        return 'Agricultural Project';
      case 'farms':
        return 'Farm Landholding';
      default:
        return entityTable;
    }
  }

  /// Extracts changed fields between [previousState] and [newState].
  Map<String, (dynamic, dynamic)> get changedFields {
    final diff = <String, (dynamic, dynamic)>{};
    if (previousState == null && newState == null) return diff;

    final prev = previousState ?? const {};
    final next = newState ?? const {};

    final allKeys = {...prev.keys, ...next.keys};
    for (final key in allKeys) {
      final oldVal = prev[key];
      final newVal = next[key];
      if (oldVal != newVal) {
        diff[key] = (oldVal, newVal);
      }
    }

    return diff;
  }

  /// Maps Drift database record to domain entity.
  factory AuditLogEntry.fromDrift(AuditLog log) {
    Map<String, dynamic>? parseJson(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    return AuditLogEntry(
      id: log.id,
      entityTable: log.entityTable,
      entityId: log.entityId,
      action: AuditAction.fromCode(log.action),
      previousState: parseJson(log.previousStateJson),
      newState: parseJson(log.newStateJson),
      performedBy: log.performedBy,
      reason: log.reason,
      timestamp: DateTime.fromMillisecondsSinceEpoch(log.timestamp),
    );
  }
}
