import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/authentication/domain/services/security_repository.dart';
import 'package:farmivo/features/settings/domain/services/data_wipe_service.dart';
import '../authentication/security_repository_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('DataWipeService Unit Tests (Milestone 9.4)', () {
    late AppDatabase db;
    late FakeFlutterSecureStorage fakeStorage;
    late SecurityRepository securityRepo;
    late Directory tempDir;
    late DataWipeService wipeService;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      fakeStorage = FakeFlutterSecureStorage();
      securityRepo = SecurityRepository(storage: fakeStorage);
      tempDir = Directory.systemTemp.createTempSync('farmivo_wipe_test_');

      wipeService = DataWipeService(
        db: db,
        securityRepository: securityRepo,
        storage: fakeStorage,
        customBackupsDirectory: tempDir,
      );
    });

    tearDown(() async {
      await db.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'verifyWipeAuthorization allows wipe without PIN when app lock is disabled',
      () async {
        expect(await wipeService.isPinVerificationRequired(), isFalse);
        expect(await wipeService.verifyWipeAuthorization(''), isTrue);
        expect(await wipeService.verifyWipeAuthorization('1234'), isTrue);
      },
    );

    test(
      'verifyWipeAuthorization enforces correct PIN when app lock is enabled',
      () async {
        await securityRepo.savePin('4321');
        await securityRepo.setAppLockEnabled(true);

        expect(await wipeService.isPinVerificationRequired(), isTrue);
        expect(await wipeService.getRequiredPinLength(), equals(4));

        // Wrong PIN
        expect(await wipeService.verifyWipeAuthorization('1111'), isFalse);
        expect(await wipeService.verifyWipeAuthorization(''), isFalse);

        // Correct PIN
        expect(await wipeService.verifyWipeAuthorization('4321'), isTrue);
      },
    );

    test(
      'executeFactoryReset truncates all data, reseeds categories, and wipes secure storage',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        // 1. Seed sample data into Drift database
        await db
            .into(db.farmsTable)
            .insert(
              FarmsTableCompanion.insert(
                id: 'farm-1',
                name: 'Abokobi Farm',
                location: 'Accra',
                region: 'Greater Accra',
                totalArea: 15.0,
                areaUnit: const Value('Acres'),
                ownershipType: 'OWNED',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: 'proj-1',
                farmId: 'farm-1',
                name: 'Pepper Project',
                projectType: 'CROP',
                commodity: 'Pepper',
                landSize: 5.0,
                startDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.auditLogsTable)
            .insert(
              AuditLogsTableCompanion.insert(
                id: 'audit-1',
                entityTable: 'projects',
                entityId: 'proj-1',
                action: 'CREATE',
                performedBy: const Value('tester'),
                timestamp: now,
              ),
            );

        // 2. Populate secure storage
        await fakeStorage.write(
          key: 'farmivo_onboarding_completed',
          value: 'true',
        );
        await securityRepo.savePin('9876');

        // 3. Create a backup file in temp directory
        final backupFile = File('${tempDir.path}/test_backup.farmivo');
        await backupFile.writeAsString('backup content');
        expect(await backupFile.exists(), isTrue);

        // Verify pre-reset counts
        final farmsBefore = await db.select(db.farmsTable).get();
        final projectsBefore = await db.select(db.projectsTable).get();
        final auditBefore = await db.select(db.auditLogsTable).get();
        expect(farmsBefore.length, equals(1));
        expect(projectsBefore.length, equals(1));
        expect(auditBefore.length, equals(1));

        // 4. Execute Factory Reset keeping backups
        final result = await wipeService.executeFactoryReset(
          deleteBackups: false,
        );

        expect(result.success, isTrue);
        expect(result.tablesCleared, greaterThanOrEqualTo(16));
        expect(result.backupsDeleted, equals(0));

        // 5. Verify database truncation
        final farmsAfter = await db.select(db.farmsTable).get();
        final projectsAfter = await db.select(db.projectsTable).get();
        final auditAfter = await db.select(db.auditLogsTable).get();
        expect(farmsAfter, isEmpty);
        expect(projectsAfter, isEmpty);
        expect(auditAfter, isEmpty);

        // 6. Verify default budget categories are reseeded
        final categoriesAfter = await db.select(db.budgetCategoriesTable).get();
        expect(categoriesAfter, isNotEmpty);

        // 7. Verify secure storage is wiped
        expect(
          await fakeStorage.read(key: 'farmivo_onboarding_completed'),
          isNull,
        );
        expect(await securityRepo.hasPin(), isFalse);

        // 8. Verify backup file was preserved
        expect(await backupFile.exists(), isTrue);
      },
    );

    test(
      'executeFactoryReset with deleteBackups: true purges all local backup archives',
      () async {
        // Create multiple backup files
        final backup1 = File('${tempDir.path}/backup_1.farmivo');
        final backup2 = File('${tempDir.path}/backup_2.farmivo');
        await backup1.writeAsString('backup 1');
        await backup2.writeAsString('backup 2');

        expect(await backup1.exists(), isTrue);
        expect(await backup2.exists(), isTrue);

        // Execute factory reset with deleteBackups: true
        final result = await wipeService.executeFactoryReset(
          deleteBackups: true,
        );

        expect(result.success, isTrue);
        expect(result.backupsDeleted, equals(2));
        expect(await backup1.exists(), isFalse);
        expect(await backup2.exists(), isFalse);
      },
    );
  });
}
