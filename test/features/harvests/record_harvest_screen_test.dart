import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/harvests/domain/repositories/harvest_repository.dart';
import 'package:farmivo/features/harvests/presentation/providers/harvest_providers.dart';
import 'package:farmivo/features/harvests/presentation/record_harvest_screen.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';

class MockHarvestRepository implements HarvestRepository {
  @override
  Future<String> generateNextBatchNumber(
    String projectId, {
    String? commodity,
    DateTime? date,
  }) async {
    return 'HV-MAI-2611-01';
  }

  @override
  Future<String> recordHarvest({
    required String projectId,
    String? batchNumber,
    required DateTime harvestDate,
    required String productName,
    required double quantity,
    required String unit,
    HarvestGrade grade = HarvestGrade.ungraded,
    String? storageLocation,
    String? notes,
    String? photoPath,
  }) async {
    return 'harvest-id-mock';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testProject = Project(
    id: 'proj-harv-1',
    farmId: 'farm-1',
    name: 'Maize Block Alpha',
    projectType: 'CROP',
    commodity: 'Maize',
    landSize: 10.0,
    landUnit: 'Acres',
    startDate: 0,
    currency: 'GHS',
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  Widget createWidget({
    String? initialProjectId = 'proj-harv-1',
    List<Project> projects = const [testProject],
    HarvestRepository? repository,
  }) {
    final repo = repository ?? MockHarvestRepository();
    return ProviderScope(
      overrides: [
        projectsStreamProvider.overrideWith((ref) => Stream.value(projects)),
        harvestRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: RecordHarvestScreen(initialProjectId: initialProjectId),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RecordHarvestScreen Widget Tests', () {
    testWidgets('Renders all input fields and standard controls', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Record Harvest Batch'), findsOneWidget);
      expect(find.text('Farm Project *'), findsOneWidget);
      expect(find.text('Produce / Commodity Name *'), findsOneWidget);
      expect(find.text('Batch / Lot Number *'), findsOneWidget);
      expect(find.text('Harvest Date *'), findsOneWidget);
      expect(find.text('Harvest Quantity & Unit *'), findsOneWidget);
      expect(find.text('Quality Grade *'), findsOneWidget);
      expect(find.text('Storage Facility / Location'), findsOneWidget);
      expect(find.text('Save Harvest Batch'), findsOneWidget);
    });

    testWidgets('Auto-generates intelligent batch number on project load', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('HV-MAI-2611-01'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Tapping unit quick-chips updates unit field', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Default unit is 50kg Bag
      expect(find.text('50kg Bag'), findsWidgets);

      // Tap on 'Crate' unit chip
      final crateChip = find.widgetWithText(ChoiceChip, 'Crate');
      expect(crateChip, findsOneWidget);
      await tester.tap(crateChip);
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Crate'), findsOneWidget);
    });

    testWidgets('Tapping storage suggestion chip sets storage location', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on 'Silo 1' suggestion chip
      final siloChip = find.widgetWithText(ActionChip, 'Silo 1');
      expect(siloChip, findsOneWidget);
      await tester.tap(siloChip);
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Silo 1'), findsOneWidget);
    });

    testWidgets('Validates quantity input when empty or invalid', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Save Harvest Batch without quantity
      await tester.tap(find.text('Save Harvest Batch'));
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });
  });
}
