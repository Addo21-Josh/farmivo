import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/backup/domain/models/backup_metadata.dart';
import 'package:farmivo/features/backup/domain/models/backup_result.dart';
import 'package:farmivo/features/backup/domain/models/backup_snapshot.dart';
import 'package:farmivo/features/backup/domain/services/backup_restore_service.dart';
import 'package:farmivo/features/backup/presentation/backup_screen.dart';
import 'package:farmivo/features/backup/presentation/providers/backup_providers.dart';

class FakeBackupRestoreService extends BackupRestoreService {
  static final _sharedDb = AppDatabase.forTesting(NativeDatabase.memory());

  List<BackupSnapshot> snapshots;
  bool weeklyDue;
  bool createBackupCalled = false;
  bool restoreCalled = false;
  bool deleteCalled = false;

  FakeBackupRestoreService({this.snapshots = const [], this.weeklyDue = true})
    : super(db: _sharedDb);

  @override
  Future<bool> isWeeklyBackupDue() async => weeklyDue;

  @override
  Future<List<BackupSnapshot>> listLocalBackups() async => snapshots;

  @override
  Future<BackupResult> createBackup({String? customFileName}) async {
    createBackupCalled = true;
    final now = DateTime.now();
    final metadata = BackupMetadata(
      createdAt: now,
      checksum: 'test_checksum',
      totalTables: 16,
      totalRecords: 42,
    );
    final snapshot = BackupSnapshot(
      filePath: '/tmp/test_backup.farmivo',
      fileName: customFileName ?? 'farmivo_backup_test.farmivo',
      fileSizeBytes: 2048,
      createdAt: now,
      metadata: metadata,
    );
    snapshots = [snapshot, ...snapshots];
    return BackupResult.success(snapshot: snapshot, metadata: metadata);
  }

  @override
  Future<RestoreResult> restoreFromSnapshot(BackupSnapshot snapshot) async {
    restoreCalled = true;
    return RestoreResult.success(tablesCount: 16, recordsCount: 42);
  }

  @override
  Future<void> deleteBackup(BackupSnapshot snapshot) async {
    deleteCalled = true;
    snapshots = snapshots
        .where((s) => s.filePath != snapshot.filePath)
        .toList();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final sampleMetadata = BackupMetadata(
    createdAt: DateTime(2026, 3, 15, 14, 30),
    checksum: 'mock_checksum',
    totalTables: 16,
    totalRecords: 120,
  );

  final sampleSnapshot = BackupSnapshot(
    filePath: '/tmp/farmivo_backup_2026-03-15_143000.farmivo',
    fileName: 'farmivo_backup_2026-03-15_143000.farmivo',
    fileSizeBytes: 45056, // 44 KB
    createdAt: DateTime(2026, 3, 15, 14, 30),
    metadata: sampleMetadata,
  );

  group('BackupScreen Widget Tests', () {
    testWidgets(
      'renders BackupScreen with hero card, weekly reminder banner, and empty state',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeService = FakeBackupRestoreService(
          snapshots: [],
          weeklyDue: true,
        );

        final container = ProviderContainer(
          overrides: [
            backupRestoreServiceProvider.overrideWithValue(fakeService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const BackupScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Local Database Backup'), findsOneWidget);
        expect(find.text('Weekly Backup Recommended'), findsOneWidget);
        expect(find.text('One-Tap Encrypted Backup'), findsOneWidget);
        expect(find.text('Create Backup Archive Now'), findsOneWidget);
        expect(find.text('No local backups created yet.'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Create Backup compiles archive and displays it in list',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeService = FakeBackupRestoreService(
          snapshots: [],
          weeklyDue: true,
        );

        final container = ProviderContainer(
          overrides: [
            backupRestoreServiceProvider.overrideWithValue(fakeService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const BackupScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap 'Create Backup Archive Now'
        await tester.tap(find.text('Create Backup Archive Now'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(fakeService.createBackupCalled, isTrue);

        // Verify SnackBar message appears
        expect(
          find.textContaining('Backup created successfully'),
          findsOneWidget,
        );

        // Verify Snapshot Card in list
        expect(find.text('farmivo_backup_test.farmivo'), findsOneWidget);
        expect(find.text('Restore This Snapshot'), findsOneWidget);
        expect(find.byIcon(Icons.share_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Restore opens confirmation dialog with checkpoint rollback notice',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeService = FakeBackupRestoreService(
          snapshots: [sampleSnapshot],
          weeklyDue: false,
        );

        final container = ProviderContainer(
          overrides: [
            backupRestoreServiceProvider.overrideWithValue(fakeService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const BackupScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Weekly reminder is not shown when weeklyDue is false
        expect(find.text('Weekly Backup Recommended'), findsNothing);

        // Snapshot card is displayed
        expect(
          find.text('farmivo_backup_2026-03-15_143000.farmivo'),
          findsOneWidget,
        );

        // Tap 'Restore This Snapshot'
        await tester.tap(find.text('Restore This Snapshot'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify Confirmation Dialog
        expect(find.text('Restore Database Snapshot?'), findsOneWidget);
        expect(
          find.textContaining('safety checkpoint will be saved before restore'),
          findsOneWidget,
        );

        // Tap 'Confirm Restore'
        await tester.tap(find.text('Confirm Restore'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(fakeService.restoreCalled, isTrue);
        expect(
          find.textContaining('Database restored successfully'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping Delete shows confirmation dialog and removes snapshot from list',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeService = FakeBackupRestoreService(
          snapshots: [sampleSnapshot],
          weeklyDue: false,
        );

        final container = ProviderContainer(
          overrides: [
            backupRestoreServiceProvider.overrideWithValue(fakeService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const BackupScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('farmivo_backup_2026-03-15_143000.farmivo'),
          findsOneWidget,
        );

        // Tap delete icon
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Confirmation dialog
        expect(find.text('Delete Backup Archive?'), findsOneWidget);

        // Confirm delete
        await tester.tap(find.text('Delete'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(fakeService.deleteCalled, isTrue);
        expect(find.text('Backup archive removed.'), findsOneWidget);
      },
    );
  });
}
