import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/backup/domain/models/backup_result.dart';
import 'package:farmivo/features/backup/domain/models/backup_snapshot.dart';
import 'package:farmivo/features/backup/domain/services/backup_restore_service.dart';

/// Provider exposing the [BackupRestoreService] singleton.
final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupRestoreService(db: db);
});

/// Future provider checking if an automatic weekly backup prompt should be presented.
final isWeeklyBackupDueProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(backupRestoreServiceProvider);
  return service.isWeeklyBackupDue();
});

/// State notifier managing local backup snapshots and operations.
class LocalBackupsNotifier
    extends StateNotifier<AsyncValue<List<BackupSnapshot>>> {
  final BackupRestoreService _service;

  LocalBackupsNotifier(this._service) : super(const AsyncValue.loading()) {
    refresh();
  }

  /// Refreshes the list of local backup snapshots.
  Future<void> refresh() async {
    try {
      final snapshots = await _service.listLocalBackups();
      state = AsyncValue.data(snapshots);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a new backup and refreshes list.
  Future<BackupResult> createBackup({String? customFileName}) async {
    final result = await _service.createBackup(customFileName: customFileName);
    if (result.success) {
      await refresh();
    }
    return result;
  }

  /// Restores the database from a given snapshot.
  Future<RestoreResult> restoreBackup(BackupSnapshot snapshot) async {
    final result = await _service.restoreFromSnapshot(snapshot);
    if (result.success) {
      await refresh();
    }
    return result;
  }

  /// Deletes a local backup snapshot.
  Future<void> deleteBackup(BackupSnapshot snapshot) async {
    await _service.deleteBackup(snapshot);
    await refresh();
  }

  /// Shares a local backup snapshot via system share sheet.
  Future<ShareResult> shareBackup(BackupSnapshot snapshot) async {
    return _service.shareBackup(snapshot);
  }
}

/// Provider managing the list of local backup snapshots.
final localBackupsProvider =
    StateNotifierProvider<
      LocalBackupsNotifier,
      AsyncValue<List<BackupSnapshot>>
    >((ref) {
      final service = ref.watch(backupRestoreServiceProvider);
      return LocalBackupsNotifier(service);
    });
