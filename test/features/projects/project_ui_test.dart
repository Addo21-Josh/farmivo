import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/farms/farms.dart';
import 'package:farmivo/features/projects/projects.dart';
import 'package:farmivo/shared/widgets/widgets.dart';

void main() {
  Farm sampleFarm({
    String id = 'farm-1',
    String name = 'Juaboso Valley Farm',
    String location = 'Juaboso Nkwanta',
    String region = 'Western North',
    double totalArea = 15.0,
    String areaUnit = 'Acres',
    String ownershipType = 'Family Land',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Farm(
      id: id,
      name: name,
      location: location,
      region: region,
      country: 'Ghana',
      totalArea: totalArea,
      areaUnit: areaUnit,
      ownershipType: ownershipType,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  Project sampleProject({
    String id = 'project-1',
    String farmId = 'farm-1',
    String name = '2-Acre Pepper Project',
    String projectType = 'Crop',
    String commodity = 'Pepper',
    String? variety = 'Legon 18',
    double landSize = 2.0,
    String landUnit = 'Acres',
    String status = 'PLANNING',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Project(
      id: id,
      farmId: farmId,
      name: name,
      projectType: projectType,
      commodity: commodity,
      variety: variety,
      landSize: landSize,
      landUnit: landUnit,
      startDate: now,
      expectedFirstHarvestDate: now + (80 * 24 * 60 * 60 * 1000),
      currency: 'GHS',
      status: status,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  group('ProjectCard Component', () {
    testWidgets(
      'renders project details, farm subtitle, size chip, and status badge',
      (tester) async {
        final farm = sampleFarm();
        final project = sampleProject();
        final pwf = ProjectWithFarm(project: project, farm: farm);

        bool editTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ProjectCard(
                projectWithFarm: pwf,
                onEdit: () => editTapped = true,
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('2-Acre Pepper Project'), findsOneWidget);
        expect(
          find.text('Pepper (Legon 18) • Juaboso Valley Farm'),
          findsOneWidget,
        );
        expect(find.text('Planning'), findsOneWidget);
        expect(find.text('2 Acres'), findsOneWidget);

        // Verify popup menu actions
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('Edit Project'), findsOneWidget);
        expect(find.text('Delete Project'), findsOneWidget);

        await tester.tap(find.text('Edit Project'));
        await tester.pumpAndSettle();
        expect(editTapped, isTrue);
      },
    );
  });

  group('ProjectsScreen Views', () {
    testWidgets('shows empty state when no projects exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsWithFarmStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProjectsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Projects Yet'), findsOneWidget);
      expect(find.text('Create First Project'), findsOneWidget);
      expect(find.text('Manage Farms & Land'), findsOneWidget);
    });

    testWidgets('displays summary and project cards when projects exist', (
      tester,
    ) async {
      final farm = sampleFarm();
      final project = sampleProject();
      final pwf = ProjectWithFarm(project: project, farm: farm);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectsWithFarmStreamProvider.overrideWith(
              (ref) => Stream.value([pwf]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProjectsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Projects Summary'), findsOneWidget);
      expect(find.text('1 Project'), findsOneWidget);
      expect(find.text('1 Crops • 0 Livestock'), findsOneWidget);
      expect(find.text('2-Acre Pepper Project'), findsOneWidget);
    });
  });

  group('CreateProjectScreen Farm Guard & Validation', () {
    testWidgets('displays prompt to register farm if no farms exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            farmsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CreateProjectScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A Farm is Required'), findsOneWidget);
      expect(find.text('Register Farm First'), findsOneWidget);
    });

    testWidgets(
      'triggers validation errors for required inputs on empty submit',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final farm = sampleFarm();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              farmsStreamProvider.overrideWith((ref) => Stream.value([farm])),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CreateProjectScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Clear the auto-suggested name to test validation
        final nameFinder = find.widgetWithText(TextFormField, 'Pepper Project');
        if (nameFinder.evaluate().isNotEmpty) {
          await tester.enterText(nameFinder, '');
        }

        // Tap Launch Project button
        await tester.ensureVisible(find.byType(AppButton));
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        expect(find.text('Project name is required.'), findsOneWidget);
        expect(find.text('Size is required.'), findsOneWidget);
      },
    );

    testWidgets(
      'switching venture type dynamically adapts commodity presets and measurement units',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final farm = sampleFarm();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              farmsStreamProvider.overrideWith((ref) => Stream.value([farm])),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CreateProjectScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially Crop
        expect(find.text('Pepper'), findsOneWidget);
        expect(find.text('Acres'), findsOneWidget);

        // Tap Livestock segment
        await tester.tap(find.text('Livestock'));
        await tester.pumpAndSettle();

        // Commodity changes to Poultry (Broilers) and Unit to Birds
        expect(find.text('Poultry (Broilers)'), findsOneWidget);
        expect(find.text('Birds'), findsOneWidget);

        // Tap Aquaculture segment
        await tester.tap(find.text('Aquaculture'));
        await tester.pumpAndSettle();

        // Commodity changes to Tilapia and Unit to Fingerlings
        expect(find.text('Tilapia'), findsOneWidget);
        expect(find.text('Fingerlings'), findsOneWidget);
      },
    );
  });
}
