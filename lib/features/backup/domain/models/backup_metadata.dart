import 'dart:convert';

/// Metadata header describing the format, checksum, and table statistics of a
/// Farmivo encrypted backup archive (Milestone 9.2).
class BackupMetadata {
  /// Format identifier tag.
  final String format;

  /// Schema version number.
  final int version;

  /// ISO 8601 creation timestamp.
  final DateTime createdAt;

  /// SHA-256 integrity checksum computed over the uncompressed payload.
  final String checksum;

  /// Total number of database tables captured in this archive.
  final int totalTables;

  /// Total number of individual row records captured across all tables.
  final int totalRecords;

  /// Farmivo application version.
  final String appVersion;

  /// Breakdown of row counts mapped by table name.
  final Map<String, int> tableRecordCounts;

  const BackupMetadata({
    this.format = 'FARMIVO_BACKUP_V1',
    this.version = 1,
    required this.createdAt,
    required this.checksum,
    required this.totalTables,
    required this.totalRecords,
    this.appVersion = '1.0.0',
    this.tableRecordCounts = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'checksum': checksum,
      'totalTables': totalTables,
      'totalRecords': totalRecords,
      'appVersion': appVersion,
      'tableRecordCounts': tableRecordCounts,
    };
  }

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      format: json['format'] as String? ?? 'FARMIVO_BACKUP_V1',
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      checksum: json['checksum'] as String? ?? '',
      totalTables: json['totalTables'] as int? ?? 0,
      totalRecords: json['totalRecords'] as int? ?? 0,
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      tableRecordCounts:
          (json['tableRecordCounts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          const {},
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
