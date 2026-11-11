import 'backup_metadata.dart';
import 'backup_snapshot.dart';

/// Result of a backup creation operation (Milestone 9.2).
class BackupResult {
  final bool success;
  final String message;
  final BackupSnapshot? snapshot;
  final BackupMetadata? metadata;

  const BackupResult({
    required this.success,
    required this.message,
    this.snapshot,
    this.metadata,
  });

  factory BackupResult.success({
    required BackupSnapshot snapshot,
    required BackupMetadata metadata,
  }) {
    return BackupResult(
      success: true,
      message:
          'Backup created successfully (${snapshot.metadata.totalRecords} records).',
      snapshot: snapshot,
      metadata: metadata,
    );
  }

  factory BackupResult.failure(String message) {
    return BackupResult(success: false, message: message);
  }
}

/// Result of an atomic database restoration operation (Milestone 9.2).
class RestoreResult {
  final bool success;
  final String message;
  final int restoredTablesCount;
  final int restoredRecordsCount;
  final bool rolledBackToSafetyCheckpoint;

  const RestoreResult({
    required this.success,
    required this.message,
    this.restoredTablesCount = 0,
    this.restoredRecordsCount = 0,
    this.rolledBackToSafetyCheckpoint = false,
  });

  factory RestoreResult.success({
    required int tablesCount,
    required int recordsCount,
  }) {
    return RestoreResult(
      success: true,
      message:
          'Database restored successfully ($recordsCount records across $tablesCount tables).',
      restoredTablesCount: tablesCount,
      restoredRecordsCount: recordsCount,
      rolledBackToSafetyCheckpoint: false,
    );
  }

  factory RestoreResult.failure({
    required String message,
    bool rolledBack = false,
  }) {
    return RestoreResult(
      success: false,
      message: message,
      rolledBackToSafetyCheckpoint: rolledBack,
    );
  }
}
