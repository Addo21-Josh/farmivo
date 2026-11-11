import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/data/repositories/forecast_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ForecastRepositoryImpl repository;
  const testFarmId = 'farm-uuid-1';
  const testProjectId = 'project-uuid-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ForecastRepositoryImpl(db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Asante Agribusiness Farm',
            location: 'Ejura, Ashanti Region',
            region: 'Ashanti',
            totalArea: 25.0,
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
            name: 'Major Maize Season 2026',
            projectType: 'CROP',
            commodity: 'Maize',
            landSize: 10.0,
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('ForecastRepository Integration Tests', () {
    test(
      'Saves new forecast scenario and computes revenue, profit, and ROI in minor units',
      () async {
        // 200 bags of maize @ GH₵ 180.00 each (18000 pesewas)
        // Cost: GH₵ 15,000.00 (1500000 pesewas)
        // Gross Revenue = 200 * 18000 = 3,600,000 pesewas (GH₵ 36,000.00)
        // Profit = 3,600,000 - 1,500,000 = 2,100,000 pesewas (GH₵ 21,000.00)
        // ROI = (2,100,000 / 1,500,000) * 100 = 140.0%
        final scenario = await repository.saveForecast(
          projectId: testProjectId,
          scenarioType: 'EXPECTED',
          expectedYield: 200.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 18000,
          projectedCostMinor: 1500000,
          notes: 'Target based on 20 bags/acre on 10 acres',
        );

        expect(scenario.id, isNotEmpty);
        expect(scenario.projectId, testProjectId);
        expect(scenario.scenarioType, 'EXPECTED');
        expect(scenario.expectedYield, 200.0);
        expect(scenario.yieldUnit, 'Bags');
        expect(scenario.expectedUnitPriceMinor, 18000);
        expect(scenario.projectedRevenueMinor, 3600000);
        expect(scenario.projectedCostMinor, 1500000);
        expect(scenario.projectedProfitMinor, 2100000);
        expect(scenario.projectedRoiPercent, 140.0);
        expect(scenario.notes, 'Target based on 20 bags/acre on 10 acres');
      },
    );

    test('Upserts existing scenario without creating duplicates', () async {
      // 1. Initial save
      await repository.saveForecast(
        projectId: testProjectId,
        scenarioType: 'EXPECTED',
        expectedYield: 150.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 16000,
        projectedCostMinor: 1200000,
      );

      final initialList = await repository.getAllScenarios(testProjectId);
      expect(initialList.length, 1);
      final initialId = initialList.first.id;

      // 2. Updated save with revised yield & price
      final updated = await repository.saveForecast(
        projectId: testProjectId,
        scenarioType: 'EXPECTED',
        expectedYield: 180.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 17500,
        projectedCostMinor: 1200000,
      );

      expect(updated.id, initialId); // Same record ID preserved
      expect(updated.expectedYield, 180.0);
      expect(updated.expectedUnitPriceMinor, 17500);
      expect(updated.projectedRevenueMinor, 3150000); // 180 * 17500

      final updatedList = await repository.getAllScenarios(testProjectId);
      expect(updatedList.length, 1); // No duplicates created
    });

    test(
      'Supports multiple sensitivity scenarios (Conservative, Expected, Optimistic)',
      () async {
        await repository.saveForecast(
          projectId: testProjectId,
          scenarioType: 'CONSERVATIVE',
          expectedYield: 120.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 14000,
          projectedCostMinor: 1200000,
        );

        await repository.saveForecast(
          projectId: testProjectId,
          scenarioType: 'EXPECTED',
          expectedYield: 180.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 18000,
          projectedCostMinor: 1200000,
        );

        await repository.saveForecast(
          projectId: testProjectId,
          scenarioType: 'OPTIMISTIC',
          expectedYield: 240.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 20000,
          projectedCostMinor: 1200000,
        );

        final scenarios = await repository.getAllScenarios(testProjectId);
        expect(scenarios.length, 3);

        final types = scenarios.map((s) => s.scenarioType).toList();
        expect(types, contains('CONSERVATIVE'));
        expect(types, contains('EXPECTED'));
        expect(types, contains('OPTIMISTIC'));
      },
    );

    test('Throws ValidationFailure when expected yield <= 0', () async {
      await expectLater(
        repository.saveForecast(
          projectId: testProjectId,
          expectedYield: 0.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 15000,
          projectedCostMinor: 1000000,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      await expectLater(
        repository.saveForecast(
          projectId: testProjectId,
          expectedYield: -10.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 15000,
          projectedCostMinor: 1000000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when unit price is negative', () async {
      await expectLater(
        repository.saveForecast(
          projectId: testProjectId,
          expectedYield: 100.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: -500,
          projectedCostMinor: 1000000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Throws ValidationFailure when yield unit is empty', () async {
      await expectLater(
        repository.saveForecast(
          projectId: testProjectId,
          expectedYield: 100.0,
          yieldUnit: '   ',
          expectedUnitPriceMinor: 15000,
          projectedCostMinor: 1000000,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Soft-deletes scenario cleanly', () async {
      final scenario = await repository.saveForecast(
        projectId: testProjectId,
        expectedYield: 100.0,
        yieldUnit: 'Bags',
        expectedUnitPriceMinor: 15000,
        projectedCostMinor: 1000000,
      );

      await repository.deleteScenario(scenario.id);

      final fetched = await repository.getForecast(testProjectId);
      expect(fetched, isNull);

      final all = await repository.getAllScenarios(testProjectId);
      expect(all, isEmpty);
    });

    test(
      'saveScenarioMatrix creates and persists all 3 scenarios atomically',
      () async {
        final scenarios = await repository.saveScenarioMatrix(
          projectId: testProjectId,
          expectedYield: 100.0,
          yieldUnit: 'Bags',
          expectedUnitPriceMinor: 20000, // 200.00 GHS
          projectedCostMinor: 1000000, // 10,000.00 GHS
        );

        expect(scenarios.length, 3);
        final all = await repository.getAllScenarios(testProjectId);
        expect(all.length, 3);

        final cons = all.firstWhere((s) => s.scenarioType == 'CONSERVATIVE');
        final exp = all.firstWhere((s) => s.scenarioType == 'EXPECTED');
        final opt = all.firstWhere((s) => s.scenarioType == 'OPTIMISTIC');

        // Conservative: 80 bags @ 170.00 = 13,600.00 GHS revenue, 3,600.00 profit
        expect(cons.expectedYield, 80.0);
        expect(cons.expectedUnitPriceMinor, 17000);
        expect(cons.projectedRevenueMinor, 1360000);
        expect(cons.projectedProfitMinor, 360000);

        // Expected: 100 bags @ 200.00 = 20,000.00 GHS revenue, 10,000.00 profit
        expect(exp.expectedYield, 100.0);
        expect(exp.expectedUnitPriceMinor, 20000);
        expect(exp.projectedRevenueMinor, 2000000);
        expect(exp.projectedProfitMinor, 1000000);

        // Optimistic: 115 bags @ 220.00 = 25,300.00 GHS revenue, 15,300.00 profit
        expect(opt.expectedYield, 115.0);
        expect(opt.expectedUnitPriceMinor, 22000);
        expect(opt.projectedRevenueMinor, 2530000);
        expect(opt.projectedProfitMinor, 1530000);
      },
    );
  });
}
