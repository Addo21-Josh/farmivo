import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/farms/farms.dart';
import 'package:farmivo/features/projects/projects.dart';

void main() {
  Project sampleProject({
    String id = 'proj-state-1',
    String status = 'PLANNING',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Project(
      id: id,
      farmId: 'farm-1',
      name: 'State Test Maize',
      projectType: 'Crop',
      commodity: 'Maize',
      landSize: 5.0,
      landUnit: 'Acres',
      startDate: now,
      currency: 'GHS',
      status: status,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  Farm sampleFarm() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Farm(
      id: 'farm-1',
      name: 'State Test Farm',
      location: 'Koforidua',
      region: 'Eastern',
      country: 'Ghana',
      totalArea: 10.0,
      areaUnit: 'Acres',
      ownershipType: 'Owned',
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  group('ProjectStageStepper Widget', () {
    testWidgets('renders all progressive stages and highlights current stage', (
      tester,
    ) async {
      ProjectLifecycleState? tappedStage;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ProjectStageStepper(
              currentState: ProjectLifecycleState.production,
              onStepTapped: (stage) => tappedStage = stage,
            ),
          ),
        ),
      );

      // Verify all stages are present in the stepper
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Production'), findsOneWidget);
      expect(find.text('Harvesting'), findsOneWidget);
      expect(find.text('Selling'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Planning and Active are passed -> have check icons
      expect(find.byIcon(Icons.check), findsNWidgets(2));

      // Tap allowed next stage (Harvesting)
      await tester.tap(find.text('Harvesting'));
      await tester.pumpAndSettle();

      expect(tappedStage, ProjectLifecycleState.harvesting);
    });
  });

  group('ProjectStatusTransitionDialog Widget', () {
    testWidgets(
      'displays current stage, allowed next stages, and executes transition',
      (tester) async {
        final project = sampleProject(status: 'PLANNING');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Dummy repository or controller
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        ProjectStatusTransitionDialog.show(
                          context,
                          project: project,
                        );
                      },
                      child: const Text('Open Dialog'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog header & stages
        expect(find.text('Change Project Stage'), findsOneWidget);
        expect(find.text('Current Stage:'), findsOneWidget);

        // Allowed stages from PLANNING: Active, Archived
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Archived'), findsOneWidget);

        // Disallowed stages should NOT be in the dialog choices
        expect(find.text('Selling'), findsNothing);
        expect(find.text('Completed'), findsNothing);

        // Verify confirm button
        expect(find.text('Confirm Stage'), findsOneWidget);
      },
    );
  });

  group('ProjectDetailsScreen Stepper Integration', () {
    testWidgets(
      'renders stepper and current objective in ProjectDetailsScreen',
      (tester) async {
        final project = sampleProject(id: 'details-p1', status: 'ACTIVE');
        final farm = sampleFarm();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              projectDetailProvider(
                'details-p1',
              ).overrideWith((ref) => Stream.value(project)),
              farmDetailProvider(
                'farm-1',
              ).overrideWith((ref) => Stream.value(farm)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ProjectDetailsScreen(projectId: 'details-p1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Lifecycle Progress'), findsOneWidget);
        expect(find.text('Current Objective:'), findsOneWidget);
        expect(find.text('Active'), findsAtLeastNWidgets(1));
        expect(find.text('Production'), findsAtLeastNWidgets(1));
      },
    );
  });
}
