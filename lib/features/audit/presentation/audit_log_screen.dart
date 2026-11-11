import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/audit_action.dart';
import 'providers/audit_providers.dart';
import 'widgets/audit_log_tile.dart';

/// Full-screen forensic audit log explorer with action and table filters (Milestone 9.3).
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedAction = ref.watch(selectedAuditActionFilterProvider);
    final selectedTable = ref.watch(selectedAuditTableFilterProvider);
    final logsAsync = ref.watch(auditLogsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Trail & Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Forensic Audit Info',
            onPressed: () => _showAuditInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Informational Notice Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Immutable Forensic Trail',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Append-only record of all modifications and voided transactions.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildActionChip(
                  context,
                  ref,
                  label: 'All Actions',
                  action: null,
                  isSelected: selectedAction == null,
                  keyString: 'audit_action_all',
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  context,
                  ref,
                  label: 'VOID',
                  action: AuditAction.voidRecord,
                  isSelected: selectedAction == AuditAction.voidRecord,
                  keyString: 'audit_action_void',
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  context,
                  ref,
                  label: 'UPDATE',
                  action: AuditAction.update,
                  isSelected: selectedAction == AuditAction.update,
                  keyString: 'audit_action_update',
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  context,
                  ref,
                  label: 'CREATE',
                  action: AuditAction.create,
                  isSelected: selectedAction == AuditAction.create,
                  keyString: 'audit_action_create',
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  context,
                  ref,
                  label: 'DELETE',
                  action: AuditAction.delete,
                  isSelected: selectedAction == AuditAction.delete,
                  keyString: 'audit_action_delete',
                ),
              ],
            ),
          ),

          // Table / Entity Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildTableChip(
                  ref,
                  label: 'All Entities',
                  table: null,
                  isSelected: selectedTable == null,
                  keyString: 'audit_table_all',
                ),
                const SizedBox(width: 8),
                _buildTableChip(
                  ref,
                  label: 'Expenses',
                  table: 'expenses',
                  isSelected: selectedTable == 'expenses',
                  keyString: 'audit_table_expenses',
                ),
                const SizedBox(width: 8),
                _buildTableChip(
                  ref,
                  label: 'Sales',
                  table: 'sales',
                  isSelected: selectedTable == 'sales',
                  keyString: 'audit_table_sales',
                ),
                const SizedBox(width: 8),
                _buildTableChip(
                  ref,
                  label: 'Payments',
                  table: 'payments',
                  isSelected: selectedTable == 'payments',
                  keyString: 'audit_table_payments',
                ),
              ],
            ),
          ),

          const Divider(height: 16),

          // Log Entries Stream List
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load audit logs: $err',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 54,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Audit Logs Found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No financial transactions have been modified or voided matching the selected filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return AuditLogTile(entry: entries[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required AuditAction? action,
    required bool isSelected,
    required String keyString,
  }) {
    return FilterChip(
      key: Key(keyString),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(selectedAuditActionFilterProvider.notifier).state = action;
      },
    );
  }

  Widget _buildTableChip(
    WidgetRef ref, {
    required String label,
    required String? table,
    required bool isSelected,
    required String keyString,
  }) {
    return FilterChip(
      key: Key(keyString),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(selectedAuditTableFilterProvider.notifier).state = table;
      },
    );
  }

  void _showAuditInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFF1B6B2F)),
            SizedBox(width: 8),
            Text('About Audit Trail'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Audit Trail is an append-only, tamper-evident forensic ledger built into Farmivo.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              '• Every void, modification, or cancellation of expenses, sales, and payments is immutably captured.\n'
              '• Previous state and new state diffs are preserved with timestamps.\n'
              '• Audit records can never be edited or deleted by the user, ensuring forensic compliance and financial accountability.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
