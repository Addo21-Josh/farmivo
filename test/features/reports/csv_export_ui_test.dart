import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/domain/models/project_with_farm.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/features/reports/domain/models/project_report_data.dart';
import 'package:farmivo/features/reports/domain/services/csv_export_service.dart';
import 'package:farmivo/features/reports/presentation/providers/report_export_providers.dart';
import 'package:farmivo/features/reports/presentation/providers/report_pdf_providers.dart';
import 'package:farmivo/features/reports/presentation/widgets/export_options_sheet.dart';

class FakeCsvExportService extends CsvExportService {
  String? lastSharedSingleFilename;
  String? lastSharedSingleContent;
  Map<String, String>? lastSharedMultipleFiles;

  @override
  Future<ShareResult> shareSingleLedger({
    required String filename,
    required String content,
    String? subject,
    String? text,
  }) async {
    lastSharedSingleFilename = filename;
    lastSharedSingleContent = content;
    return const ShareResult('success', ShareResultStatus.success);
  }

  @override
  Future<ShareResult> shareMultipleLedgers({
    required Map<String, String> files,
    String? subject,
    String? text,
  }) async {
    lastSharedMultipleFiles = files;
    return const ShareResult('success', ShareResultStatus.success);
  }
}

void main() {
  const currency = 'GHS';

  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Ejura Maize Commercial Venture',
    projectType: 'CROP',
    commodity: 'Maize',
    variety: 'Pannar 53',
    landSize: 10.0,
    landUnit: 'Acres',
    startDate: 0,
    currency: currency,
    status: 'ACTIVE',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testFarm = Farm(
    id: 'farm-1',
    name: 'Northern Ridge Estates',
    location: 'Ejura',
    region: 'Ashanti',
    country: 'Ghana',
    totalArea: 50.0,
    areaUnit: 'Acres',
    ownershipType: 'OWNED',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final varianceReport = ProjectVarianceReport(
    projectId: 'proj-1',
    currency: currency,
    totalPlanned: Money.fromMajor(10000.0, currency: currency),
    totalSpent: Money.fromMajor(8500.0, currency: currency),
    totalTransactionsCount: 2,
    categories: const [],
  );

  final metrics = ProjectMetrics.compute(
    project: testProject,
    budgetItems: const [],
    expenses: const [],
    activities: const [],
    harvests: const [],
    sales: const [],
  );

  final reportData = ProjectReportData(
    project: testProject,
    farm: testFarm,
    metrics: metrics,
    varianceReport: varianceReport,
    harvests: const [],
    sales: const [],
    expenses: const [],
    generatedAt: DateTime.now(),
  );

  group('ExportOptionsSheet CSV Export Widget Tests', () {
    testWidgets('renders CSV export tab and exports all ledgers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeService = FakeCsvExportService();

      final container = ProviderContainer(
        overrides: [
          projectsWithFarmStreamProvider.overrideWith(
            (ref) => Stream.value([
              const ProjectWithFarm(project: testProject, farm: testFarm),
            ]),
          ),
          projectReportDataProvider(
            'proj-1',
          ).overrideWith((ref) => AsyncValue.data(reportData)),
          csvExportServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: ExportOptionsSheet(
                initialProjectId: 'proj-1',
                initialTabIndex: 1,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      // Verify Header
      expect(find.text('Excel & CSV Data Export'), findsOneWidget);

      // Verify Excel/CSV Compatibility Banner
      expect(
        find.textContaining('Exports as RFC 4180 CSV with UTF-8 BOM encoding'),
        findsOneWidget,
      );

      // Verify Ledger dropdown is displayed with All Ledgers selected
      expect(find.text('All Ledgers (Complete Audit Pack)'), findsOneWidget);

      // Verify Export button
      expect(find.text('Export & Share CSV'), findsOneWidget);

      // Tap Export button
      await tester.tap(find.text('Export & Share CSV'));
      await tester.pump();

      expect(fakeService.lastSharedMultipleFiles, isNotNull);
      expect(fakeService.lastSharedMultipleFiles!.length, 4);
      expect(
        fakeService.lastSharedMultipleFiles!.containsKey(
          'Ejura_Maize_Commercial_Venture_Expenses_Ledger.csv',
        ),
        isTrue,
      );
      expect(
        fakeService.lastSharedMultipleFiles!.containsKey(
          'Ejura_Maize_Commercial_Venture_Sales_Ledger.csv',
        ),
        isTrue,
      );
    });

    testWidgets(
      'allows selecting individual ledger type from dropdown and triggers single export',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeService = FakeCsvExportService();

        final container = ProviderContainer(
          overrides: [
            projectsWithFarmStreamProvider.overrideWith(
              (ref) => Stream.value([
                const ProjectWithFarm(project: testProject, farm: testFarm),
              ]),
            ),
            projectReportDataProvider(
              'proj-1',
            ).overrideWith((ref) => AsyncValue.data(reportData)),
            csvExportServiceProvider.overrideWithValue(fakeService),
          ],
        );
        addTearDown(container.dispose);

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                body: ExportOptionsSheet(
                  initialProjectId: 'proj-1',
                  initialTabIndex: 1,
                ),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        );
        await tester.pump();

        // Open the dropdown
        await tester.tap(find.text('All Ledgers (Complete Audit Pack)'));
        await tester.pumpAndSettle();

        // Select "Expenses Ledger" from dropdown options
        await tester.tap(find.text('Expenses Ledger').last);
        await tester.pumpAndSettle();

        // Tap the export button
        await tester.tap(find.text('Export & Share CSV'));
        await tester.pump();

        expect(
          fakeService.lastSharedSingleFilename,
          'Ejura_Maize_Commercial_Venture_Expenses_Ledger.csv',
        );
        expect(fakeService.lastSharedSingleContent, isNotNull);
        expect(
          fakeService.lastSharedSingleContent!.startsWith('\uFEFF'),
          isTrue,
        );
      },
    );

    testWidgets(
      'switches seamlessly between Bank-Ready PDF and Excel / CSV Ledgers tabs',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            projectsWithFarmStreamProvider.overrideWith(
              (ref) => Stream.value([
                const ProjectWithFarm(project: testProject, farm: testFarm),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                body: ExportOptionsSheet(initialProjectId: 'proj-1'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        );
        await tester.pump();

        // Initially on PDF tab
        expect(find.text('Bank-Ready Financial Report'), findsOneWidget);
        expect(
          find.text('Include Official Signature & Stamp Blocks'),
          findsOneWidget,
        );
        expect(find.text('View & Export Bank-Ready PDF'), findsOneWidget);

        // Tap on CSV tab
        await tester.tap(find.text('Excel / CSV Ledgers'));
        await tester.pump();

        // Now on CSV tab
        expect(find.text('Excel & CSV Data Export'), findsOneWidget);
        expect(find.text('Export & Share CSV'), findsOneWidget);

        // Tap back on PDF tab
        await tester.tap(find.text('Bank-Ready PDF'));
        await tester.pump();

        // Back to PDF tab
        expect(find.text('Bank-Ready Financial Report'), findsOneWidget);
        expect(
          find.text('Include Official Signature & Stamp Blocks'),
          findsOneWidget,
        );
        expect(find.text('View & Export Bank-Ready PDF'), findsOneWidget);
      },
    );
  });
}
