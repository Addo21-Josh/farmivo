import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/farms/farms.dart';
import 'package:farmivo/shared/widgets/widgets.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: AppTheme.lightTheme, home: child),
    );
  }

  Farm sampleFarm({
    String id = 'farm-1',
    String name = 'Juaboso Valley Farm',
    String location = 'Juaboso Nkwanta',
    String district = 'Juaboso',
    String region = 'Western North',
    double totalArea = 12.5,
    String areaUnit = 'Acres',
    String ownershipType = 'Family Land',
    String? notes = 'Good loamy soil near stream',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Farm(
      id: id,
      name: name,
      location: location,
      district: district,
      region: region,
      country: 'Ghana',
      totalArea: totalArea,
      areaUnit: areaUnit,
      ownershipType: ownershipType,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  group('Customary Land Tenure Badges', () {
    testWidgets(
      'AppStatusBadge.fromTenure renders badges for Ghanaian tenure types',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Builder(
                builder: (ctx) => Column(
                  children: [
                    AppStatusBadge.fromTenure(ctx, 'Owned (Freehold)'),
                    AppStatusBadge.fromTenure(ctx, 'Family Land'),
                    AppStatusBadge.fromTenure(ctx, 'Rented (Short-term)'),
                    AppStatusBadge.fromTenure(ctx, 'Leased (Long-term)'),
                    AppStatusBadge.fromTenure(ctx, 'Shared / Abunu'),
                    AppStatusBadge.fromTenure(ctx, 'Shared / Abusa'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Owned'), findsOneWidget);
        expect(find.text('Family Land'), findsOneWidget);
        expect(find.text('Rented'), findsOneWidget);
        expect(find.text('Leased'), findsOneWidget);
        expect(find.text('Abunu (50/50)'), findsOneWidget);
        expect(find.text('Abusa (1/3)'), findsOneWidget);
      },
    );
  });

  group('FarmCard Component', () {
    testWidgets('FarmCard displays name, location, area, and tenure', (
      tester,
    ) async {
      final farm = sampleFarm();
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: FarmCard(
              farm: farm,
              onEdit: () => editTapped = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Juaboso Valley Farm'), findsOneWidget);
      expect(
        find.text('Juaboso Nkwanta, Juaboso • Western North'),
        findsOneWidget,
      );
      expect(find.text('12.5 Acres'), findsOneWidget);
      expect(find.text('Family Land'), findsOneWidget);
      expect(find.text('Good loamy soil near stream'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Edit Farm'), findsOneWidget);
      expect(find.text('Delete Farm'), findsOneWidget);

      await tester.tap(find.text('Edit Farm'));
      await tester.pumpAndSettle();
      expect(editTapped, isTrue);
    });
  });

  group('FarmsScreen Views', () {
    testWidgets('shows empty state when no farms exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            farmsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FarmsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Farms Registered Yet'), findsOneWidget);
      expect(find.text('Register First Farm'), findsOneWidget);
    });

    testWidgets('displays list and summary metrics when farms exist', (
      tester,
    ) async {
      final farm = sampleFarm();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            farmsStreamProvider.overrideWith((ref) => Stream.value([farm])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FarmsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Landholdings Summary'), findsOneWidget);
      expect(find.text('1 Farm'), findsOneWidget);
      expect(find.text('12.5 Total Acres'), findsOneWidget);
      expect(find.text('Juaboso Valley Farm'), findsOneWidget);
    });
  });

  group('FarmFormScreen Validation', () {
    testWidgets('triggers validation errors for required fields on submit', (
      tester,
    ) async {
      // Set tester surface size to guarantee form fits comfortably
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const FarmFormScreen()));
      await tester.pumpAndSettle();

      // Scroll to AppButton and tap
      await tester.ensureVisible(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text('Farm name is required.'), findsOneWidget);
      expect(find.text('Location is required.'), findsOneWidget);
      expect(find.text('Total land area is required.'), findsOneWidget);
    });
  });

  group('FarmDetailScreen View', () {
    testWidgets('renders landholding details and stats', (tester) async {
      final farm = sampleFarm(id: 'detail-farm-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            farmDetailProvider(
              'detail-farm-1',
            ).overrideWith((ref) => Stream.value(farm)),
            farmProjectsCountProvider(
              'detail-farm-1',
            ).overrideWith((ref) => Future.value(1)),
            farmAllocatedAreaProvider(
              'detail-farm-1',
            ).overrideWith((ref) => Future.value(4.0)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FarmDetailScreen(farmId: 'detail-farm-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Landholding Overview'), findsOneWidget);
      expect(find.text('Family Land'), findsOneWidget);
      expect(find.text('12.5 Acres'), findsOneWidget);
      expect(find.text('Active Projects'), findsOneWidget);
      expect(find.text('Allocated Area'), findsOneWidget);
      expect(find.text('Available Land'), findsOneWidget);
      expect(find.text('Geographic Location'), findsOneWidget);
      expect(find.text('Field Notes & Soil Characteristics'), findsOneWidget);
      expect(find.text('Launch Project on this Farm'), findsOneWidget);
    });
  });
}
