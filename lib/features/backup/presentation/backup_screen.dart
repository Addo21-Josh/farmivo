import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmivo/app/theme/app_theme_extension.dart';
import 'package:farmivo/features/backup/domain/models/backup_snapshot.dart';
import 'package:farmivo/features/backup/presentation/providers/backup_providers.dart';

/// Screen allowing the farmer to create one-tap encrypted backups, restore from
/// local snapshots with safety checkpoints, and share archives offline (Milestone 9.2).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isCreatingBackup = false;
  String? _restoringFilePath;

  Future<void> _onCreateBackup() async {
    setState(() => _isCreatingBackup = true);

    try {
      final notifier = ref.read(localBackupsProvider.notifier);
      final result = await notifier.createBackup();

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: const Color(0xFF1B6B2F),
            action: result.snapshot != null
                ? SnackBarAction(
                    label: 'Share',
                    textColor: Colors.white,
                    onPressed: () => notifier.shareBackup(result.snapshot!),
                  )
                : null,
          ),
        );
        ref.invalidate(isWeeklyBackupDueProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingBackup = false);
    }
  }

  Future<void> _confirmAndRestore(BackupSnapshot snapshot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Database Snapshot?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to restore "${snapshot.fileName}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: Colors.amber.shade900,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A safety checkpoint will be saved before restore. If an error occurs, the database automatically rolls back.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _restoringFilePath = snapshot.filePath);

    try {
      final notifier = ref.read(localBackupsProvider.notifier);
      final result = await notifier.restoreBackup(snapshot);

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: const Color(0xFF1B6B2F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _restoringFilePath = null);
    }
  }

  Future<void> _confirmAndDelete(BackupSnapshot snapshot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Backup Archive?'),
        content: Text(
          'Are you sure you want to permanently delete "${snapshot.fileName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(localBackupsProvider.notifier).deleteBackup(snapshot);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup archive removed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isWeeklyDueAsync = ref.watch(isWeeklyBackupDueProvider);
    final backupsAsync = ref.watch(localBackupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Local Database Backup')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Weekly Reminder Banner
          isWeeklyDueAsync.when(
            data: (isDue) {
              if (!isDue) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade900,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Backup Recommended',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Over 7 days have passed since your last backup. Keep farm finances protected.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                      onPressed: _isCreatingBackup ? null : _onCreateBackup,
                      child: const Text(
                        'Backup Now',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Primary One-Tap Backup Hero Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.healthGreenBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.healthGreen.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.healthGreen.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: colors.healthGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One-Tap Encrypted Backup',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.healthGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Export all 16 database tables into a single compressed .farmivo archive.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.healthGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isCreatingBackup
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.archive_outlined),
                    label: Text(
                      _isCreatingBackup
                          ? 'Compiling Snapshot...'
                          : 'Create Backup Archive Now',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isCreatingBackup ? null : _onCreateBackup,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Local Backups Header
          Text(
            'Local Backups on This Device',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 10),

          // Local Backups List
          backupsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Text('Error loading backups: $err'),
            data: (snapshots) {
              if (snapshots.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 20,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      40,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withAlpha(60)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No local backups created yet.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the button above to create your first encrypted backup.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: snapshots.map((s) {
                  final isRestoringThis = _restoringFilePath == s.filePath;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.dividerColor.withAlpha(60)),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_zip_outlined,
                                color: colors.healthGreen,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  s.fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.share_outlined,
                                  size: 20,
                                ),
                                tooltip: 'Share',
                                onPressed: () => ref
                                    .read(localBackupsProvider.notifier)
                                    .shareBackup(s),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.red.shade400,
                                ),
                                tooltip: 'Delete',
                                onPressed: () => _confirmAndDelete(s),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${s.formattedDate}  •  ${s.formattedSize}  •  ${s.metadata.totalRecords} records across ${s.metadata.totalTables} tables',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.healthGreen,
                                  side: BorderSide(
                                    color: colors.healthGreen.withAlpha(120),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                icon: isRestoringThis
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.restore, size: 16),
                                label: Text(
                                  isRestoringThis
                                      ? 'Restoring...'
                                      : 'Restore This Snapshot',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: isRestoringThis
                                    ? null
                                    : () => _confirmAndRestore(s),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
