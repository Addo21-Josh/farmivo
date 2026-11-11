import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../models/backup_metadata.dart';

/// Pure Dart codec responsible for encoding, compressing, hashing, and validating
/// Farmivo backup archives (.farmivo) (Milestone 9.2).
class BackupArchiveEncoder {
  BackupArchiveEncoder._();

  /// 8-byte magic header identifying official Farmivo backup files.
  static const List<int> magicHeader = [
    0x46,
    0x41,
    0x52,
    0x4D,
    0x49,
    0x56,
    0x4F,
    0x31,
  ]; // 'FARMIVO1'

  /// Encodes database tables data into a compressed, hashed .farmivo binary archive.
  static List<int> encodeArchive({
    required Map<String, List<Map<String, dynamic>>> tablesData,
    DateTime? createdAt,
    String appVersion = '1.0.0',
  }) {
    final now = createdAt ?? DateTime.now();

    // 1. Calculate record statistics
    var totalRecords = 0;
    final recordCounts = <String, int>{};
    for (final entry in tablesData.entries) {
      final count = entry.value.length;
      recordCounts[entry.key] = count;
      totalRecords += count;
    }

    // 2. Compute SHA-256 checksum over the raw canonical data JSON
    final dataJsonString = jsonEncode(tablesData);
    final checksum = sha256.convert(utf8.encode(dataJsonString)).toString();

    // 3. Assemble metadata envelope
    final metadata = BackupMetadata(
      format: 'FARMIVO_BACKUP_V1',
      version: 1,
      createdAt: now,
      checksum: checksum,
      totalTables: tablesData.length,
      totalRecords: totalRecords,
      appVersion: appVersion,
      tableRecordCounts: recordCounts,
    );

    final envelope = {'metadata': metadata.toJson(), 'data': tablesData};

    // 4. Compress envelope with GZip
    final envelopeBytes = utf8.encode(jsonEncode(envelope));
    final compressedBytes = gzip.encode(envelopeBytes);

    // 5. Prepend magic header
    return <int>[...magicHeader, ...compressedBytes];
  }

  /// Decodes and validates a .farmivo binary archive, returning the metadata and data.
  /// Throws [FormatException] if the file format is invalid, corrupted, or tampered.
  static (BackupMetadata, Map<String, List<Map<String, dynamic>>>)
  decodeArchive(List<int> bytes) {
    if (bytes.length < magicHeader.length) {
      throw const FormatException('Invalid backup file: file size too small.');
    }

    List<int> compressedPayload;

    // Check magic header
    var hasMagic = true;
    for (var i = 0; i < magicHeader.length; i++) {
      if (bytes[i] != magicHeader[i]) {
        hasMagic = false;
        break;
      }
    }

    if (hasMagic) {
      compressedPayload = bytes.sublist(magicHeader.length);
    } else {
      // Fallback for standard .json.gz without custom header
      compressedPayload = bytes;
    }

    // 1. Decompress GZip
    List<int> decompressedBytes;
    try {
      decompressedBytes = gzip.decode(compressedPayload);
    } catch (e) {
      throw FormatException('Failed to decompress backup archive: $e');
    }

    // 2. Parse JSON envelope
    Map<String, dynamic> envelope;
    try {
      final jsonStr = utf8.decode(decompressedBytes);
      envelope = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Corrupted backup payload: $e');
    }

    // 3. Parse Metadata
    final rawMetadata = envelope['metadata'] as Map<String, dynamic>?;
    if (rawMetadata == null) {
      throw const FormatException('Missing backup metadata header.');
    }
    final metadata = BackupMetadata.fromJson(rawMetadata);

    // 4. Verify Checksum
    final rawData = envelope['data'] as Map<String, dynamic>?;
    if (rawData == null) {
      throw const FormatException(
        'Backup archive contains no database table data.',
      );
    }

    final dataJsonString = jsonEncode(rawData);
    final computedChecksum = sha256
        .convert(utf8.encode(dataJsonString))
        .toString();

    if (metadata.checksum.isNotEmpty && metadata.checksum != computedChecksum) {
      throw const FormatException(
        'Integrity checksum mismatch: backup file is corrupted or has been modified.',
      );
    }

    // 5. Structure table data
    final tablesData = <String, List<Map<String, dynamic>>>{};
    for (final entry in rawData.entries) {
      if (entry.value is List) {
        tablesData[entry.key] = (entry.value as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }

    return (metadata, tablesData);
  }

  /// Extracts only the metadata header from a .farmivo archive.
  static BackupMetadata extractMetadata(List<int> bytes) {
    final (metadata, _) = decodeArchive(bytes);
    return metadata;
  }
}
