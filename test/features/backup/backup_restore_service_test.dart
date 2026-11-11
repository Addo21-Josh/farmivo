import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/backup/domain/services/backup_restore_service.dart';
import '../authentication/security_repository_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('BackupRestoreService Unit Tests', () {
    late AppDatabase db;
    late FakeFlutterSecureStorage fakeStorage;
    late Directory tempDir;
    late BackupRestoreService service;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      fakeStorage = FakeFlutterSecureStorage();
      tempDir = Directory.systemTemp.createTempSync('farmivo_backup_test_');
      service = BackupRestoreService(
        db: db,
        storage: fakeStorage,
        customBackupsDirectory: tempDir,
      );

      // Seed sample data in database
      await db
          .into(db.budgetCategoriesTable)
          .insert(
            BudgetCategoriesTableCompanion.insert(
              id: 'cat-seeds',
              name: 'Seeds & Seedlings',
              createdAt: 1773187200000,
              updatedAt: 1773187200000,
            ),
          );

      await db
          .into(db.farmsTable)
          .insert(
            FarmsTableCompanion.insert(
              id: 'farm-1',
              name: 'Volta Green Farms',
              location: 'Ho',
              country: const Value('Ghana'),
              region: 'Volta',
              totalArea: 25.0,
              areaUnit: const Value('Acres'),
              ownershipType: 'OWNED',
              createdAt: 1773187200000,
              updatedAt: 1773187200000,
            ),
          );

      await db
          .into(db.projectsTable)
          .insert(
            ProjectsTableCompanion.insert(
              id: 'proj-1',
              farmId: 'farm-1',
              name: 'Cashew Plantation 2026',
              projectType: 'TREE_CROP',
              commodity: 'Cashew',
              landSize: 20.0,
              landUnit: const Value('Acres'),
              startDate: 1773187200000,
              currency: const Value('GHS'),
              status: const Value('ACTIVE'),
              createdAt: 1773187200000,
              updatedAt: 1773187200000,
            ),
          );

      await db
          .into(db.expensesTable)
          .insert(
            ExpensesTableCompanion.insert(
              id: 'exp-1',
              projectId: 'proj-1',
              categoryId: 'cat-seeds',
              transactionDate: 1773187200000,
              description: 'Cashew Seedlings Grafted',
              quantity: const Value(200.0),
              unit: const Value('Seedlings'),
              amountMinor: 500000,
              currency: const Value('GHS'),
              paymentMethod: 'CASH',
              createdAt: 1773187200000,
              updatedAt: 1773187200000,
            ),
          );
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'isWeeklyBackupDue reports true initially and false after backup creation',
      () async {
        expect(await service.isWeeklyBackupDue(), isTrue);

        final result = await service.createBackup();
        expect(result.success, isTrue);

        expect(await service.isWeeklyBackupDue(), isFalse);
      },
    );

    test(
      'createBackup compiles .farmivo file on disk with correct statistics',
      () async {
        final result = await service.createBackup(
          customFileName: 'test_snapshot.farmivo',
        );

        expect(result.success, isTrue);
        expect(result.snapshot, isNotNull);
        expect(result.snapshot!.fileName, 'test_snapshot.farmivo');
        expect(result.snapshot!.file.existsSync(), isTrue);
        expect(result.metadata, isNotNull);
        expect(result.metadata!.totalTables, greaterThanOrEqualTo(16));
        expect(result.metadata!.totalRecords, greaterThanOrEqualTo(3));
      },
    );

    test(
      'listLocalBackups discovers and parses backup archives on disk',
      () async {
        await service.createBackup(customFileName: 'snap_1.farmivo');
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await service.createBackup(customFileName: 'snap_2.farmivo');

        final backups = await service.listLocalBackups();

        expect(backups.length, 2);
        expect(backups[0].fileName, 'snap_2.farmivo'); // Sorted newest first
        expect(backups[1].fileName, 'snap_1.farmivo');
        expect(backups[0].formattedSize, contains('KB'));
        expect(backups[0].formattedDate, isNotEmpty);
      },
    );

    test(
      'restoreFromSnapshot reconstructs 100% of data after complete database wipe',
      () async {
        // 1. Create backup of current state
        final backupResult = await service.createBackup();
        expect(backupResult.success, isTrue);
        final snapshot = backupResult.snapshot!;

        // 2. Wipe database
        await db.delete(db.expensesTable).go();
        await db.delete(db.projectsTable).go();
        await db.delete(db.farmsTable).go();

        expect(await (db.select(db.farmsTable).get()), isEmpty);
        expect(await (db.select(db.projectsTable).get()), isEmpty);
        expect(await (db.select(db.expensesTable).get()), isEmpty);

        // 3. Restore from backup
        final restoreResult = await service.restoreFromSnapshot(snapshot);

        expect(restoreResult.success, isTrue);
        expect(restoreResult.rolledBackToSafetyCheckpoint, isFalse);

        // 4. Verify 100% of records are fully reconstructed
        final restoredFarms = await (db.select(db.farmsTable).get());
        expect(restoredFarms.length, 1);
        expect(restoredFarms.first.name, 'Volta Green Farms');

        final restoredProjects = await (db.select(db.projectsTable).get());
        expect(restoredProjects.length, 1);
        expect(restoredProjects.first.name, 'Cashew Plantation 2026');

        final restoredExpenses = await (db.select(db.expensesTable).get());
        expect(restoredExpenses.length, 1);
        expect(restoredExpenses.first.amountMinor, 500000);
        expect(restoredExpenses.first.description, 'Cashew Seedlings Grafted');
      },
    );

    test('deleteBackup removes file from storage', () async {
      final backupResult = await service.createBackup(
        customFileName: 'to_delete.farmivo',
      );
      final snapshot = backupResult.snapshot!;

      expect(snapshot.file.existsSync(), isTrue);

      await service.deleteBackup(snapshot);

      expect(snapshot.file.existsSync(), isFalse);
    });
  });
}
