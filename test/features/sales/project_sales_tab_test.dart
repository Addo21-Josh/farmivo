import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/tabs/project_sales_tab.dart';
import 'package:farmivo/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';
import 'package:farmivo/features/sales/presentation/providers/sale_providers.dart';
import 'package:farmivo/features/sales/presentation/widgets/sale_tile.dart';

void main() {
  late AppDatabase db;
  late SaleRepositoryImpl saleRepo;
  const testFarmId = 'farm-tab-1';
  const testProjectId = 'proj-tab-1';
  late Project testProject;
  late ProjectMetrics testMetrics;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    saleRepo = SaleRepositoryImpl(db: db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed Farm
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'Dawhenya Irrigation Farm',
            location: 'Dawhenya, Greater Accra',
            region: 'Greater Accra',
            totalArea: 50.0,
            areaUnit: const Value('Acres'),
            ownershipType: 'Leased',
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
            name: 'Dry Season Commercial Tomato 2026',
            projectType: 'CROP',
            commodity: 'Tomato',
            landSize: 5.0,
            currency: const Value('GHS'),
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    testProject = await (db.select(
      db.projectsTable,
    )..where((p) => p.id.equals(testProjectId))).getSingle();

    testMetrics = ProjectMetrics.compute(
      project: testProject,
      budgetItems: const [],
      expenses: const [],
      activities: const [],
      harvests: const [],
      sales: const [],
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        saleRepositoryProvider.overrideWithValue(saleRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProjectSalesTab(project: testProject, metrics: testMetrics),
        ),
      ),
    );
  }

  group('ProjectSalesTab Tests', () {
    testWidgets('renders empty state when no sales are recorded', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Commercial Revenue'), findsOneWidget);
      expect(find.text('No Commercial Sales Recorded'), findsOneWidget);
      expect(find.text('Record Harvest Sale'), findsOneWidget);
      expect(find.text('Buyers'), findsOneWidget);
      expect(find.text('Record Sale'), findsOneWidget);
    });

    testWidgets(
      'renders populated list with SaleTiles and dynamic revenue summary',
      (tester) async {
        // 1. Record Paid sale
        await saleRepo.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Roma Tomato',
          quantity: 20.0,
          unit: 'Crates',
          unitPriceMinor: 15000, // GH₵ 3,000.00
          paymentStatus: SalePaymentStatus.paid,
        );

        // 2. Record Partial sale
        await saleRepo.recordSale(
          projectId: testProjectId,
          saleDate: DateTime.now(),
          productName: 'Yellow Corn',
          quantity: 10.0,
          unit: 'Bags',
          unitPriceMinor: 10000, // GH₵ 1,000.00 total
          paymentStatus: SalePaymentStatus.partial,
          initialPaymentAmountMinor: 40000, // GH₵ 400.00 paid, GH₵ 600.00 due
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify SaleTiles rendered
        expect(find.byType(SaleTile), findsNWidgets(2));
        expect(find.text('Roma Tomato'), findsOneWidget);
        expect(find.text('Yellow Corn'), findsOneWidget);

        // Verify dynamic summary header
        // Total Gross: 3,000 + 1,000 = GH₵ 4,000.00
        expect(find.text('GH₵ 4,000.00'), findsOneWidget);
        // Receivables: GH₵ 600.00 Due
        expect(find.text('GH₵ 600.00 Due'), findsOneWidget);
      },
    );
  });
}
