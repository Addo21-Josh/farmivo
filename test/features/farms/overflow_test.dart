import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/farms/presentation/providers/farm_providers.dart';
import 'package:farmivo/features/farms/presentation/screens/farm_form_screen.dart';
import 'package:farmivo/features/projects/presentation/create_project_screen.dart';

void main() {
  late AppDatabase db;

  final sampleFarm = Farm(
    id: 'farm-test-1',
    name: 'Test Ashanti Farm',
    location: 'Ejura',
    district: 'Ejura-Sekyedumase',
    region: 'Ashanti',
    country: 'Ghana',
    latitude: 7.38,
    longitude: -1.36,
    totalArea: 10.0,
    areaUnit: 'Acres',
    ownershipType: 'Owned',
    notes: null,
    photoPath: null,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    updatedAt: DateTime.now().millisecondsSinceEpoch,
    isSynced: false,
    isDeleted: false,
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'FarmFormScreen renders without overflow across narrow and standard devices',
    (tester) async {
      final widths = [320.0, 360.0, 375.0, 390.0, 412.0];

      for (final w in widths) {
        tester.view.physicalSize = Size(w, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const FarmFormScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }
    },
  );

  testWidgets(
    'CreateProjectScreen renders without overflow across narrow and standard devices',
    (tester) async {
      final widths = [320.0, 360.0, 375.0, 390.0, 412.0];

      for (final w in widths) {
        tester.view.physicalSize = Size(w, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              farmsStreamProvider.overrideWith(
                (ref) => Stream.value([sampleFarm]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CreateProjectScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }
    },
  );
}
