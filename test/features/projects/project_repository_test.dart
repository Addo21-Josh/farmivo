import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/projects/data/repositories/project_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ProjectRepositoryImpl repository;
  const uuid = Uuid();
  late String testFarmId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProjectRepositoryImpl(db);

    // Seed a test farm
    testFarmId = uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Juaboso Valley Farm',
            location: 'Juaboso Nkwanta',
            region: 'Western North',
            totalArea: 25.0,
            ownershipType: 'Family Land',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Project createSampleProject({
    String? id,
    String? farmId,
    String name = '2-Acre Pepper Project',
    String projectType = 'Crop',
    String commodity = 'Pepper',
    String? variety = 'Legon 18',
    double landSize = 2.0,
    String landUnit = 'Acres',
    String status = 'PLANNING',
    bool isDeleted = false,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Project(
      id: id ?? uuid.v4(),
      farmId: farmId ?? testFarmId,
      name: name,
      projectType: projectType,
      commodity: commodity,
      variety: variety,
      landSize: landSize,
      landUnit: landUnit,
      startDate: now,
      expectedFirstHarvestDate: now + (80 * 24 * 60 * 60 * 1000), // +80 days
      currency: 'GHS',
      status: status,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: isDeleted,
    );
  }

  group('ProjectRepositoryImpl CRUD & Status Transitions', () {
    test('create() persists project and getById() retrieves it', () async {
      final project = createSampleProject(name: 'Maize Season 1');
      await repository.create(project);

      final retrieved = await repository.getById(project.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Maize Season 1');
      expect(retrieved.commodity, 'Pepper');
      expect(retrieved.landSize, 2.0);
      expect(retrieved.status, 'PLANNING');
    });

    test(
      'getAll() returns all active projects excluding soft-deleted ones',
      () async {
        final p1 = createSampleProject(name: 'Project 1');
        final p2 = createSampleProject(name: 'Project 2');
        await repository.create(p1);
        await repository.create(p2);

        await repository.delete(p1.id);

        final active = await repository.getAll();
        expect(active.length, 1);
        expect(active.first.name, 'Project 2');

        final deletedDirect = await repository.getById(p1.id);
        expect(deletedDirect, isNull);
      },
    );

    test('update() modifies project attributes in the database', () async {
      final project = createSampleProject(name: 'Initial Name', landSize: 1.5);
      await repository.create(project);

      final updated = project.copyWith(
        name: 'Expanded Pepper Project',
        landSize: 3.5,
        variety: const Value('Shito Super'),
      );
      await repository.update(updated);

      final retrieved = await repository.getById(project.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Expanded Pepper Project');
      expect(retrieved.landSize, 3.5);
      expect(retrieved.variety, 'Shito Super');
    });

    test('updateStatus() changes lifecycle status', () async {
      final project = createSampleProject(status: 'PLANNING');
      await repository.create(project);

      await repository.updateStatus(project.id, 'ACTIVE');

      final retrieved = await repository.getById(project.id);
      expect(retrieved!.status, 'ACTIVE');
    });

    test(
      'getActiveProjects() filters out COMPLETED and ARCHIVED projects',
      () async {
        final pPlanning = createSampleProject(
          name: 'Planning Project',
          status: 'PLANNING',
        );
        final pActive = createSampleProject(
          name: 'Active Project',
          status: 'ACTIVE',
        );
        final pCompleted = createSampleProject(
          name: 'Completed Project',
          status: 'COMPLETED',
        );
        final pArchived = createSampleProject(
          name: 'Archived Project',
          status: 'ARCHIVED',
        );

        await repository.create(pPlanning);
        await repository.create(pActive);
        await repository.create(pCompleted);
        await repository.create(pArchived);

        final activeProjects = await repository.getActiveProjects();
        expect(activeProjects.length, 2);
        final names = activeProjects.map((p) => p.name).toList();
        expect(names.contains('Planning Project'), isTrue);
        expect(names.contains('Active Project'), isTrue);
        expect(names.contains('Completed Project'), isFalse);
        expect(names.contains('Archived Project'), isFalse);
      },
    );
  });

  group('ProjectRepositoryImpl Relational & Farm Joins', () {
    test(
      'getProjectsByFarm() returns projects only for specific farm',
      () async {
        // Create a second farm
        final secondFarmId = uuid.v4();
        final now = DateTime.now().millisecondsSinceEpoch;
        await db
            .into(db.farmsTable)
            .insert(
              FarmsTableCompanion.insert(
                id: secondFarmId,
                name: 'Central Coast Farm',
                location: 'Cape Coast',
                region: 'Central',
                totalArea: 10.0,
                ownershipType: 'Owned',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final pFarm1 = createSampleProject(
          name: 'Farm 1 Project',
          farmId: testFarmId,
        );
        final pFarm2 = createSampleProject(
          name: 'Farm 2 Project',
          farmId: secondFarmId,
        );

        await repository.create(pFarm1);
        await repository.create(pFarm2);

        final farm1Projects = await repository.getProjectsByFarm(testFarmId);
        expect(farm1Projects.length, 1);
        expect(farm1Projects.first.name, 'Farm 1 Project');

        final farm2Projects = await repository.getProjectsByFarm(secondFarmId);
        expect(farm2Projects.length, 1);
        expect(farm2Projects.first.name, 'Farm 2 Project');
      },
    );

    test('getAllWithFarm() joins Project with parent Farm record', () async {
      final project = createSampleProject(name: 'Juaboso Pepper V1');
      await repository.create(project);

      final joinedList = await repository.getAllWithFarm();
      expect(joinedList.length, 1);
      expect(joinedList.first.project.name, 'Juaboso Pepper V1');
      expect(joinedList.first.farm, isNotNull);
      expect(joinedList.first.farm!.name, 'Juaboso Valley Farm');
      expect(
        joinedList.first.locationSummary,
        'Juaboso Nkwanta • Western North',
      );
    });
  });
}
