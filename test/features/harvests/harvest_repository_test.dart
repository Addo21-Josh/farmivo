import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/data/repositories/harvest_repository_impl.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';

void main() {
  late AppDatabase db;
  late HarvestRepositoryImpl repository;
  const testFarmId = 'farm-uuid-harv';
  const testProjectId = 'project-uuid-harv';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = HarvestRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Akomadan Irrigation Project',
            location: 'Akomadan, Ashanti',
            region: 'Ashanti',
            totalArea: 50.0,
            areaUnit: const Value('Acres'),
            ownershipType: 'Owned',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Seed Project
    await db
        .into(db.projectsTable)
        .insert(
          ProjectsTableCompanion.insert(
            id: testProjectId,
            farmId: testFarmId,
            name: 'Tomato Dry Season 2026',
            projectType: 'CROP',
            commodity: 'Tomato',
            landSize: 5.0,
            landUnit: const Value('Acres'),
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('HarvestRepository Validation Tests', () {
    test('throws ValidationFailure if productName is empty', () async {
      expect(
        () => repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime.now(),
          productName: '   ',
          quantity: 50.0,
          unit: 'Crate',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure if quantity is zero or negative', () async {
      expect(
        () => repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 0.0,
          unit: 'Crate',
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(
        () => repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime.now(),
          productName: 'Tomato',
          quantity: -10.0,
          unit: 'Crate',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure if unit is empty', () async {
      expect(
        () => repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 50.0,
          unit: '  ',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure if project does not exist', () async {
      expect(
        () => repository.recordHarvest(
          projectId: 'non-existent-project',
          harvestDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 50.0,
          unit: 'Crate',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('Batch Number Generation Tests', () {
    test(
      'generates batch number using commodity code, YYMM, and sequence',
      () async {
        final harvestDate = DateTime(2026, 11, 8);
        final batch1 = await repository.generateNextBatchNumber(
          testProjectId,
          commodity: 'Tomato',
          date: harvestDate,
        );

        expect(batch1, 'HV-TOM-2611-01');

        // Record first harvest
        await repository.recordHarvest(
          projectId: testProjectId,
          batchNumber: batch1,
          harvestDate: harvestDate,
          productName: 'Tomato',
          quantity: 20.0,
          unit: 'Crate',
        );

        // Generating next batch increments sequence
        final batch2 = await repository.generateNextBatchNumber(
          testProjectId,
          commodity: 'Tomato',
          date: harvestDate,
        );
        expect(batch2, 'HV-TOM-2611-02');
      },
    );

    test('handles short commodity abbreviation by padding with X', () async {
      final harvestDate = DateTime(2026, 11, 8);
      final batch = await repository.generateNextBatchNumber(
        testProjectId,
        commodity: 'Ox',
        date: harvestDate,
      );
      expect(batch, 'HV-OXX-2611-01');
    });
  });

  group('Harvest CRUD Operations', () {
    test('recordHarvest creates harvest and streams with details', () async {
      final harvestDate = DateTime(2026, 11, 8);
      final id = await repository.recordHarvest(
        projectId: testProjectId,
        harvestDate: harvestDate,
        productName: 'Roma Tomato',
        quantity: 120.0,
        unit: 'Crate',
        grade: HarvestGrade.gradeA,
        storageLocation: 'Cold Room 2',
        notes: 'Plump and disease-free',
      );

      expect(id, isNotEmpty);

      final detail = await repository.getHarvestById(id);
      expect(detail, isNotNull);
      expect(detail!.productName, 'Roma Tomato');
      expect(detail.quantity, 120.0);
      expect(detail.unit, 'Crate');
      expect(detail.grade, HarvestGrade.gradeA);
      expect(detail.storageLocation, 'Cold Room 2');
      expect(detail.notes, 'Plump and disease-free');
      expect(detail.projectName, 'Tomato Dry Season 2026');
      expect(detail.formattedQuantity, '120 Crate');
    });

    test('updateHarvest modifies fields successfully', () async {
      final id = await repository.recordHarvest(
        projectId: testProjectId,
        harvestDate: DateTime.now(),
        productName: 'Tomato',
        quantity: 50.0,
        unit: 'Crate',
        grade: HarvestGrade.gradeB,
      );

      await repository.updateHarvest(
        id: id,
        projectId: testProjectId,
        quantity: 75.5,
        grade: HarvestGrade.gradeA,
        storageLocation: 'Main Barn',
      );

      final updated = await repository.getHarvestById(id);
      expect(updated!.quantity, 75.5);
      expect(updated.grade, HarvestGrade.gradeA);
      expect(updated.storageLocation, 'Main Barn');
    });

    test('deleteHarvest soft-deletes the record from watch stream', () async {
      final id = await repository.recordHarvest(
        projectId: testProjectId,
        harvestDate: DateTime.now(),
        productName: 'Tomato',
        quantity: 100.0,
        unit: 'Crate',
      );

      var list = await repository.watchHarvests(projectId: testProjectId).first;
      expect(list.length, 1);

      await repository.deleteHarvest(id);

      list = await repository.watchHarvests(projectId: testProjectId).first;
      expect(list, isEmpty);

      final detail = await repository.getHarvestById(id);
      expect(detail, isNull);
    });
  });

  group('Harvest Yield Aggregation & Summary Tests', () {
    test(
      'computes cumulative quantity, grade breakdown, and yield per acre',
      () async {
        // Seed pre-season forecast scenario for projected yield comparison
        final now = DateTime.now().millisecondsSinceEpoch;
        await db
            .into(db.scenariosTable)
            .insert(
              ScenariosTableCompanion.insert(
                id: 'scenario-test-1',
                projectId: testProjectId,
                scenarioType: 'EXPECTED',
                expectedYield: 500.0,
                yieldUnit: 'Crate',
                expectedUnitPriceMinor: 20000,
                projectedRevenueMinor: 10000000,
                projectedCostMinor: 6000000,
                projectedProfitMinor: 4000000,
                projectedRoiPercent: 66.6,
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Record 3 harvests with different grades:
        // Grade A: 200 Crates
        // Grade B: 100 Crates
        // Rejects: 50 Crates
        // Total: 350 Crates out of 500 Projected (70%)
        await repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime(2026, 11, 1),
          productName: 'Tomato',
          quantity: 200.0,
          unit: 'Crate',
          grade: HarvestGrade.gradeA,
        );

        await repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime(2026, 11, 3),
          productName: 'Tomato',
          quantity: 100.0,
          unit: 'Crate',
          grade: HarvestGrade.gradeB,
        );

        await repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime(2026, 11, 5),
          productName: 'Tomato',
          quantity: 50.0,
          unit: 'Crate',
          grade: HarvestGrade.rejects,
        );

        final summary = await repository.getProjectYieldSummary(testProjectId);

        expect(summary.totalQuantity, 350.0);
        expect(summary.totalBatches, 3);
        expect(summary.unit, 'Crate');
        expect(summary.gradeAQuantity, 200.0);
        expect(summary.gradeBQuantity, 100.0);
        expect(summary.rejectsQuantity, 50.0);
        expect(summary.ungradedQuantity, 0.0);

        // Percentages
        // Grade A: 200 / 350 = 57.14%
        expect(summary.gradeAPercent, closeTo(57.14, 0.1));
        // Grade B: 100 / 350 = 28.57%
        expect(summary.gradeBPercent, closeTo(28.57, 0.1));
        // Rejects: 50 / 350 = 14.28%
        expect(summary.rejectsPercent, closeTo(14.28, 0.1));

        // Target comparison: 350 / 500 = 70.0%
        expect(summary.hasProjectedYield, isTrue);
        expect(summary.projectedYield, 500.0);
        expect(summary.yieldAchievementPercent, closeTo(70.0, 0.1));
        expect(summary.isAboveProjection, isFalse);

        // Yield per acre: 350 / 5.0 acres = 70 Crates / Acre
        expect(summary.yieldPerAcre, 70.0);
        expect(summary.formattedYieldPerAcre, '70 Crate / Acres');
      },
    );

    test(
      'getSuggestedStorageLocations returns database and default suggestions',
      () async {
        await repository.recordHarvest(
          projectId: testProjectId,
          harvestDate: DateTime.now(),
          productName: 'Tomato',
          quantity: 20.0,
          unit: 'Crate',
          storageLocation: 'Packhouse North',
        );

        final suggestions = await repository.getSuggestedStorageLocations();
        expect(suggestions, contains('Packhouse North'));
        expect(suggestions, contains('Main Barn'));
        expect(suggestions, contains('Cold Room'));
      },
    );
  });
}
