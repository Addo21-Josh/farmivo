import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/farms/data/repositories/farm_repository_impl.dart';

void main() {
  late AppDatabase db;
  late FarmRepositoryImpl repository;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FarmRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Farm createSampleFarm({
    String? id,
    String name = 'Juaboso Farm',
    String location = 'Juaboso Nkwanta',
    String? district = 'Juaboso',
    String region = 'Western North',
    double totalArea = 10.0,
    String areaUnit = 'Acres',
    String ownershipType = 'Family Land',
    bool isDeleted = false,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Farm(
      id: id ?? uuid.v4(),
      name: name,
      location: location,
      district: district,
      region: region,
      country: 'Ghana',
      totalArea: totalArea,
      areaUnit: areaUnit,
      ownershipType: ownershipType,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: isDeleted,
    );
  }

  group('FarmRepositoryImpl CRUD Operations', () {
    test('create() persists a farm and getById() retrieves it', () async {
      final farm = createSampleFarm(name: 'Ahafo Cocoa Plot');
      await repository.create(farm);

      final retrieved = await repository.getById(farm.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Ahafo Cocoa Plot');
      expect(retrieved.region, 'Western North');
      expect(retrieved.totalArea, 10.0);
    });

    test(
      'getAll() returns all active farms ordered alphabetically by name',
      () async {
        final farmB = createSampleFarm(name: 'Bono Agro Estate');
        final farmA = createSampleFarm(name: 'Ashanti Goldfields Farm');
        final farmC = createSampleFarm(name: 'Central Cassava Plantation');

        await repository.create(farmB);
        await repository.create(farmA);
        await repository.create(farmC);

        final farms = await repository.getAll();
        expect(farms.length, 3);
        expect(farms[0].name, 'Ashanti Goldfields Farm');
        expect(farms[1].name, 'Bono Agro Estate');
        expect(farms[2].name, 'Central Cassava Plantation');
      },
    );

    test('getAll() excludes soft-deleted farms', () async {
      final farm1 = createSampleFarm(name: 'Active Farm 1');
      final farm2 = createSampleFarm(name: 'Active Farm 2');
      await repository.create(farm1);
      await repository.create(farm2);

      await repository.delete(farm1.id);

      final activeFarms = await repository.getAll();
      expect(activeFarms.length, 1);
      expect(activeFarms.first.name, 'Active Farm 2');

      final deletedDirect = await repository.getById(farm1.id);
      expect(deletedDirect, isNull);
    });

    test('update() modifies farm attributes in the database', () async {
      final farm = createSampleFarm(name: 'Original Name', totalArea: 5.0);
      await repository.create(farm);

      final updated = farm.copyWith(
        name: 'Updated Name',
        totalArea: 15.5,
        ownershipType: 'Shared / Abunu',
      );
      await repository.update(updated);

      final retrieved = await repository.getById(farm.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.totalArea, 15.5);
      expect(retrieved.ownershipType, 'Shared / Abunu');
    });

    test('watchAll() emits updated lists reactively', () async {
      final initial = await repository.watchAll().first;
      expect(initial, isEmpty);

      final farm1 = createSampleFarm(name: 'Stream Farm 1');
      await repository.create(farm1);
      final afterFirst = await repository.watchAll().first;
      expect(afterFirst.length, 1);
      expect(afterFirst.first.name, 'Stream Farm 1');

      final farm2 = createSampleFarm(name: 'Stream Farm 2');
      await repository.create(farm2);
      final afterSecond = await repository.watchAll().first;
      expect(afterSecond.length, 2);
    });
  });

  group('FarmRepositoryImpl Relational Aggregations', () {
    test(
      'getProjectCount() and getTotalAllocatedArea() aggregate correctly',
      () async {
        final farm = createSampleFarm(
          name: 'Multi-Project Farm',
          totalArea: 20.0,
        );
        await repository.create(farm);

        final now = DateTime.now().millisecondsSinceEpoch;

        // Initially 0 projects and 0 area
        expect(await repository.getProjectCount(farm.id), 0);
        expect(await repository.getTotalAllocatedArea(farm.id), 0.0);

        // Insert Project 1 (4.0 acres)
        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: uuid.v4(),
                farmId: farm.id,
                name: 'Pepper Project',
                projectType: 'Crop',
                commodity: 'Pepper',
                landSize: 4.0,
                startDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Insert Project 2 (6.5 acres)
        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: uuid.v4(),
                farmId: farm.id,
                name: 'Maize Project',
                projectType: 'Crop',
                commodity: 'Maize',
                landSize: 6.5,
                startDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Insert Soft-deleted Project (should NOT be counted)
        await db
            .into(db.projectsTable)
            .insert(
              ProjectsTableCompanion.insert(
                id: uuid.v4(),
                farmId: farm.id,
                name: 'Cancelled Project',
                projectType: 'Crop',
                commodity: 'Tomato',
                landSize: 3.0,
                isDeleted: const Value(true),
                startDate: now,
                createdAt: now,
                updatedAt: now,
              ),
            );

        expect(await repository.getProjectCount(farm.id), 2);
        expect(await repository.getTotalAllocatedArea(farm.id), 10.5);
      },
    );
  });
}
