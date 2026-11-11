import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../data/repositories/audit_log_repository_impl.dart';
import '../../domain/models/audit_action.dart';
import '../../domain/models/audit_log_entry.dart';
import '../../domain/repositories/audit_log_repository.dart';

/// Provider exposing the [AuditLogRepository] singleton.
final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AuditLogRepositoryImpl(db: db);
});

/// Currently selected action filter (e.g. VOID, UPDATE, CREATE, or null for ALL).
final selectedAuditActionFilterProvider = StateProvider<AuditAction?>(
  (ref) => null,
);

/// Currently selected entity table filter (e.g. 'expenses', 'sales', or null for ALL).
final selectedAuditTableFilterProvider = StateProvider<String?>((ref) => null);

/// Stream provider watching audit logs matching the current filter state.
final auditLogsStreamProvider = StreamProvider<List<AuditLogEntry>>((ref) {
  final repository = ref.watch(auditLogRepositoryProvider);
  final action = ref.watch(selectedAuditActionFilterProvider);
  final table = ref.watch(selectedAuditTableFilterProvider);

  return repository.watchAuditLogs(
    action: action,
    entityTable: table,
    limit: 150,
  );
});

/// Family provider loading the specific audit history of a single entity record.
final entityAuditTrailProvider =
    FutureProvider.family<List<AuditLogEntry>, ({String table, String id})>((
      ref,
      arg,
    ) async {
      final repository = ref.watch(auditLogRepositoryProvider);
      return repository.getAuditTrailForEntity(
        entityTable: arg.table,
        entityId: arg.id,
      );
    });
