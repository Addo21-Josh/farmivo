import 'package:flutter/material.dart';
import '../../domain/models/audit_action.dart';
import '../../domain/models/audit_log_entry.dart';

/// Card widget rendering an individual immutable audit log entry (Milestone 9.3).
class AuditLogTile extends StatefulWidget {
  final AuditLogEntry entry;

  const AuditLogTile({super.key, required this.entry});

  @override
  State<AuditLogTile> createState() => _AuditLogTileState();
}

class _AuditLogTileState extends State<AuditLogTile> {
  bool _isExpanded = false;

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.voidRecord:
      case AuditAction.delete:
        return Colors.red.shade700;
      case AuditAction.update:
        return Colors.amber.shade800;
      case AuditAction.create:
        return const Color(0xFF1B6B2F); // Forest Green
    }
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.voidRecord:
        return Icons.block_outlined;
      case AuditAction.delete:
        return Icons.delete_outline;
      case AuditAction.update:
        return Icons.edit_note_outlined;
      case AuditAction.create:
        return Icons.add_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = widget.entry;
    final actionColor = _getActionColor(e.action);
    final diff = e.changedFields;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withAlpha(60)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Action Badge + Timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: actionColor.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getActionIcon(e.action),
                        size: 14,
                        color: actionColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        e.action.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  e.entityDisplayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  e.formattedDate,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Entity Identifier
            Text(
              'ID: ${e.entityId}',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.grey.shade600,
              ),
            ),

            // Reason / Audit Remarks (if any)
            if (e.reason != null && e.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: e.action == AuditAction.voidRecord
                      ? Colors.red.shade50
                      : theme.colorScheme.surfaceContainerHighest.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: e.action == AuditAction.voidRecord
                        ? Colors.red.shade200
                        : theme.dividerColor.withAlpha(50),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: e.action == AuditAction.voidRecord
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${e.reason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: e.action == AuditAction.voidRecord
                              ? Colors.red.shade900
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: e.action == AuditAction.voidRecord
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Performed By & Expand Toggle
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  e.performedBy,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (diff.isNotEmpty)
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded
                                ? 'Hide Changes'
                                : 'View Changes (${diff.length})',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Expandable Diff Table
            if (_isExpanded && diff.isNotEmpty) ...[
              const Divider(height: 16),
              ...diff.entries.map((entry) {
                final field = entry.key;
                final (oldVal, newVal) = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          field,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$oldVal',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_right_alt,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$newVal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B6B2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
