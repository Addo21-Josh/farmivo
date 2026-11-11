import 'dart:io';
import 'package:intl/intl.dart';
import 'backup_metadata.dart';

/// Represents a local `.farmivo` encrypted backup archive stored on device (Milestone 9.2).
class BackupSnapshot {
  /// Absolute file path on local storage.
  final String filePath;

  /// Clean filename (e.g. `farmivo_backup_2026-03-15_143000.farmivo`).
  final String fileName;

  /// File size on disk in bytes.
  final int fileSizeBytes;

  /// Creation date and time.
  final DateTime createdAt;

  /// Parsed metadata header.
  final BackupMetadata metadata;

  const BackupSnapshot({
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.metadata,
  });

  /// The underlying physical file.
  File get file => File(filePath);

  /// Human-readable file size (e.g. `48.5 KB` or `2.1 MB`).
  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Formatted date string (e.g. `15 Mar 2026, 14:30`).
  String get formattedDate {
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  }
}
