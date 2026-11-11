import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/backup/domain/models/backup_result.dart';
import 'package:farmivo/features/backup/domain/models/backup_snapshot.dart';
import 'package:farmivo/features/backup/domain/services/backup_archive_encoder.dart';

/// Service managing offline database backups, atomic transactional restores,
/// integrity validation, and weekly backup reminders (Milestone 9.2).
class BackupRestoreService {
  final AppDatabase _db;
  final FlutterSecureStorage _storage;
  final Directory? _customBackupsDir;

  static const String _keyLastBackup = 'farmivo_security_last_backup_timestamp';

  const BackupRestoreService({
    required AppDatabase db,
    FlutterSecureStorage? storage,
    Directory? customBackupsDirectory,
  }) : _db = db,
       _storage = storage ?? const FlutterSecureStorage(),
       _customBackupsDir = customBackupsDirectory;

  /// Gets or creates the local directory dedicated to storing Farmivo backups.
  Future<Directory> getBackupsDirectory() async {
    final customDir = _customBackupsDir;
    if (customDir != null) {
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }
      return customDir;
    }
    final docsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(p.join(docsDir.path, 'backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    return backupsDir;
  }

  /// Dumps all active database tables and rows into an in-memory dictionary.
  Future<Map<String, List<Map<String, dynamic>>>> dumpAllTables() async {
    // 1. Flush SQLite write-ahead log to database file
    try {
      await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    final dump = <String, List<Map<String, dynamic>>>{};

    // 2. Query all registered Drift tables
    for (final table in _db.allTables) {
      final tableName = table.actualTableName;
      final queryResult = await _db
          .customSelect('SELECT * FROM "$tableName"')
          .get();
      dump[tableName] = queryResult
          .map((row) => Map<String, dynamic>.from(row.data))
          .toList();
    }

    return dump;
  }

  /// Creates a complete, compressed, and integrity-hashed backup archive (.farmivo).
  Future<BackupResult> createBackup({String? customFileName}) async {
    try {
      final now = DateTime.now();
      final dump = await dumpAllTables();

      final archiveBytes = BackupArchiveEncoder.encodeArchive(
        tablesData: dump,
        createdAt: now,
      );

      final backupsDir = await getBackupsDirectory();
      final dateStr = DateFormat('yyyy-MM-dd_HHmmss').format(now);
      final fileName = customFileName ?? 'farmivo_backup_$dateStr.farmivo';
      final file = File(p.join(backupsDir.path, fileName));

      await file.writeAsBytes(archiveBytes, flush: true);

      // Record last backup timestamp
      await _storage.write(
        key: _keyLastBackup,
        value: now.millisecondsSinceEpoch.toString(),
      );

      final metadata = BackupArchiveEncoder.extractMetadata(archiveBytes);
      final snapshot = BackupSnapshot(
        filePath: file.path,
        fileName: fileName,
        fileSizeBytes: archiveBytes.length,
        createdAt: now,
        metadata: metadata,
      );

      return BackupResult.success(snapshot: snapshot, metadata: metadata);
    } catch (e) {
      return BackupResult.failure('Failed to create backup: $e');
    }
  }

  /// Lists all local backup archives stored in the backups directory sorted newest first.
  Future<List<BackupSnapshot>> listLocalBackups() async {
    try {
      final backupsDir = await getBackupsDirectory();
      final files = backupsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.farmivo'))
          .toList();

      final snapshots = <BackupSnapshot>[];

      for (final f in files) {
        try {
          final bytes = await f.readAsBytes();
          final metadata = BackupArchiveEncoder.extractMetadata(bytes);
          snapshots.add(
            BackupSnapshot(
              filePath: f.path,
              fileName: p.basename(f.path),
              fileSizeBytes: bytes.length,
              createdAt: metadata.createdAt,
              metadata: metadata,
            ),
          );
        } catch (_) {
          // Skip unparseable or corrupted files in list
        }
      }

      snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return snapshots;
    } catch (_) {
      return const [];
    }
  }

  /// Restores the database from a given local snapshot.
  Future<RestoreResult> restoreFromSnapshot(BackupSnapshot snapshot) async {
    try {
      final bytes = await snapshot.file.readAsBytes();
      return restoreFromBytes(bytes);
    } catch (e) {
      return RestoreResult.failure(message: 'Could not read backup file: $e');
    }
  }

  /// Restores the database from binary archive bytes with pre-restore checkpoint rollback.
  Future<RestoreResult> restoreFromBytes(List<int> bytes) async {
    // 1. Decode and validate archive integrity
    final (metadata, tablesData) = BackupArchiveEncoder.decodeArchive(bytes);

    // 2. Pre-restore Safety Checkpoint of current database
    List<int> safetyBytes;
    try {
      final currentDump = await dumpAllTables();
      safetyBytes = BackupArchiveEncoder.encodeArchive(tablesData: currentDump);
    } catch (e) {
      return RestoreResult.failure(
        message:
            'Pre-restore database checkpointing failed: $e. Aborting restore to prevent data loss.',
      );
    }

    // 3. Atomic Transactional Restoration
    try {
      await _db.transaction(() async {
        // Temporarily disable foreign keys for circular and cross-table references
        await _db.customStatement('PRAGMA foreign_keys = OFF;');

        // Delete existing rows in all tables
        for (final table in _db.allTables) {
          await _db.customStatement('DELETE FROM "${table.actualTableName}";');
        }

        // Restore all rows table-by-table
        for (final entry in tablesData.entries) {
          final tableName = entry.key;
          final rows = entry.value;

          for (final row in rows) {
            if (row.isEmpty) continue;
            final colNames = row.keys.map((k) => '"$k"').join(', ');
            final placeholders = List.filled(row.length, '?').join(', ');
            final values = row.values.map((v) {
              if (v is bool) return v ? 1 : 0;
              return v;
            }).toList();

            await _db.customStatement(
              'INSERT INTO "$tableName" ($colNames) VALUES ($placeholders);',
              values,
            );
          }
        }

        // Re-enable foreign keys
        await _db.customStatement('PRAGMA foreign_keys = ON;');

        // Verify foreign key integrity
        final fkCheck = await _db
            .customSelect('PRAGMA foreign_key_check;')
            .get();
        if (fkCheck.isNotEmpty) {
          throw Exception(
            'Foreign key constraint violation in restored data: $fkCheck',
          );
        }
      });

      return RestoreResult.success(
        tablesCount: tablesData.length,
        recordsCount: metadata.totalRecords,
      );
    } catch (e) {
      // 4. Automatic Rollback to Safety Checkpoint on failure
      try {
        await _restoreRawDump(safetyBytes);
        return RestoreResult.failure(
          message:
              'Restore failed: $e. Database was safely rolled back to previous state.',
          rolledBack: true,
        );
      } catch (rollbackErr) {
        return RestoreResult.failure(
          message:
              'CRITICAL ERROR: Restore failed ($e) and rollback failed ($rollbackErr).',
          rolledBack: false,
        );
      }
    }
  }

  /// Internal helper to re-apply a raw archive dump for rollback.
  Future<void> _restoreRawDump(List<int> bytes) async {
    final (_, tablesData) = BackupArchiveEncoder.decodeArchive(bytes);

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF;');
      for (final table in _db.allTables) {
        await _db.customStatement('DELETE FROM "${table.actualTableName}";');
      }
      for (final entry in tablesData.entries) {
        final tableName = entry.key;
        for (final row in entry.value) {
          if (row.isEmpty) continue;
          final colNames = row.keys.map((k) => '"$k"').join(', ');
          final placeholders = List.filled(row.length, '?').join(', ');
          final values = row.values
              .map((v) => v is bool ? (v ? 1 : 0) : v)
              .toList();
          await _db.customStatement(
            'INSERT INTO "$tableName" ($colNames) VALUES ($placeholders);',
            values,
          );
        }
      }
      await _db.customStatement('PRAGMA foreign_keys = ON;');
    });
  }

  /// Deletes a physical backup file from the local storage.
  Future<void> deleteBackup(BackupSnapshot snapshot) async {
    if (await snapshot.file.exists()) {
      await snapshot.file.delete();
    }
  }

  /// Shares a backup archive via the native OS system share sheet (WhatsApp, Email, Drive, etc.).
  Future<ShareResult> shareBackup(BackupSnapshot snapshot) async {
    final xFile = XFile(
      snapshot.filePath,
      mimeType: 'application/octet-stream',
      name: snapshot.fileName,
    );

    return Share.shareXFiles(
      [xFile],
      subject: 'Farmivo Encrypted Database Backup - ${snapshot.fileName}',
      text:
          'Attached is an official offline encrypted database backup from Farmivo.',
    );
  }

  /// Retrieves the recorded timestamp of the most recent backup.
  Future<DateTime?> getLastBackupTimestamp() async {
    final str = await _storage.read(key: _keyLastBackup);
    if (str == null) return null;
    final ms = int.tryParse(str);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Whether an automatic weekly local backup prompt should be shown.
  Future<bool> isWeeklyBackupDue() async {
    final last = await getLastBackupTimestamp();
    if (last == null) return true;
    final days = DateTime.now().difference(last).inDays;
    return days >= 7;
  }
}
