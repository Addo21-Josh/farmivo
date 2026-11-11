import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/backup/domain/services/backup_archive_encoder.dart';

void main() {
  group('BackupArchiveEncoder Unit Tests', () {
    final sampleTablesData = {
      'farms': [
        {
          'id': 'farm-1',
          'name': 'Northern Ridge Estates',
          'location': 'Ejura',
          'total_area': 50.0,
          'is_deleted': 0,
        },
      ],
      'projects': [
        {
          'id': 'proj-1',
          'farm_id': 'farm-1',
          'name': 'Maize Commercial 2026',
          'commodity': 'Maize',
          'currency': 'GHS',
        },
      ],
      'expenses': [
        {
          'id': 'exp-1',
          'project_id': 'proj-1',
          'description': 'Hybrid Seeds',
          'amount_minor': 250000,
        },
        {
          'id': 'exp-2',
          'project_id': 'proj-1',
          'description': 'Fertilizer NPK',
          'amount_minor': 450000,
        },
      ],
    };

    test('encodeArchive prepends 8-byte magic header FARMIVO1', () {
      final bytes = BackupArchiveEncoder.encodeArchive(
        tablesData: sampleTablesData,
      );

      expect(
        bytes.length,
        greaterThan(BackupArchiveEncoder.magicHeader.length),
      );
      final header = bytes.sublist(0, BackupArchiveEncoder.magicHeader.length);
      expect(header, equals(BackupArchiveEncoder.magicHeader));
    });

    test(
      'decodeArchive correctly recovers metadata and table records in round-trip',
      () {
        final now = DateTime(2026, 3, 15, 12, 0);
        final bytes = BackupArchiveEncoder.encodeArchive(
          tablesData: sampleTablesData,
          createdAt: now,
        );

        final (metadata, recoveredData) = BackupArchiveEncoder.decodeArchive(
          bytes,
        );

        // Verify Metadata
        expect(metadata.format, 'FARMIVO_BACKUP_V1');
        expect(metadata.version, 1);
        expect(metadata.createdAt, now);
        expect(metadata.totalTables, 3);
        expect(metadata.totalRecords, 4);
        expect(metadata.checksum, isNotEmpty);
        expect(metadata.tableRecordCounts['farms'], 1);
        expect(metadata.tableRecordCounts['projects'], 1);
        expect(metadata.tableRecordCounts['expenses'], 2);

        // Verify Recovered Data
        expect(recoveredData.length, 3);
        expect(recoveredData['farms']!.first['name'], 'Northern Ridge Estates');
        expect(recoveredData['projects']!.first['commodity'], 'Maize');
        expect(recoveredData['expenses']!.length, 2);
        expect(recoveredData['expenses']![0]['amount_minor'], 250000);
        expect(recoveredData['expenses']![1]['amount_minor'], 450000);
      },
    );

    test(
      'decodeArchive throws FormatException when integrity checksum does not match',
      () {
        final bytes = BackupArchiveEncoder.encodeArchive(
          tablesData: sampleTablesData,
        );

        // Tamper with byte stream inside payload
        final tamperedBytes = List<int>.from(bytes);
        tamperedBytes[tamperedBytes.length - 10] ^= 0xFF; // Flip bits

        expect(
          () => BackupArchiveEncoder.decodeArchive(tamperedBytes),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('extractMetadata reads metadata header without failure', () {
      final now = DateTime(2026, 3, 15, 16, 45);
      final bytes = BackupArchiveEncoder.encodeArchive(
        tablesData: sampleTablesData,
        createdAt: now,
      );

      final metadata = BackupArchiveEncoder.extractMetadata(bytes);

      expect(metadata.totalRecords, 4);
      expect(metadata.totalTables, 3);
      expect(metadata.createdAt, now);
    });
  });
}
