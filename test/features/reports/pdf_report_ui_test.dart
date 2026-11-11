import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farmivo/app/router/routes.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/domain/models/project_with_farm.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/features/reports/domain/models/project_report_data.dart';
import 'package:farmivo/features/reports/presentation/providers/report_pdf_providers.dart';
import 'package:farmivo/features/reports/presentation/screens/pdf_report_preview_screen.dart';
import 'package:farmivo/features/reports/presentation/widgets/export_options_sheet.dart';

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
    preparedBy: 'Kwame Mensah',
    verifiedBy: 'ADB Officer',
    includeSignatureBlocks: true,
  );

  group('PdfReportPreviewScreen Widget Tests', () {
    testWidgets('renders loading state when report data is compiling', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectReportDataProvider(
              'proj-1',
            ).overrideWith((ref) => const AsyncValue.loading()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PdfReportPreviewScreen(projectId: 'proj-1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Bank-Ready Statement'), findsOneWidget);
      expect(
        find.text('Compiling offline financial ledgers...'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'renders error message and retry button when data loading fails',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              projectReportDataProvider('proj-1').overrideWith(
                (ref) => AsyncValue.error(
                  'Database connection failed',
                  StackTrace.empty,
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const PdfReportPreviewScreen(projectId: 'proj-1'),
            ),
          ),
        );
        await tester.pump();

        expect(
          find.text('Failed to Compile Financial Statement'),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'renders preview screen with title and actions when reportData is loaded',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              projectReportDataProvider(
                'proj-1',
              ).overrideWith((ref) => AsyncValue.data(reportData)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const PdfReportPreviewScreen(projectId: 'proj-1'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Bank-Ready Statement'), findsOneWidget);
        expect(find.byIcon(Icons.tune_outlined), findsOneWidget);
        expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      },
    );
  });

  group('ExportOptionsSheet Widget Tests', () {
    testWidgets(
      'renders export configuration controls and updates providers on submit',
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
            GoRoute(
              path: AppRoutes.pdfReportPreview,
              builder: (context, state) =>
                  const Scaffold(body: Text('PDF Preview Screen')),
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

        expect(find.text('Bank-Ready Financial Report'), findsOneWidget);
        expect(
          find.text('Include Official Signature & Stamp Blocks'),
          findsOneWidget,
        );
        expect(find.text('View & Export Bank-Ready PDF'), findsOneWidget);

        // Verify form fields can be typed into
        final preparedByField = find.widgetWithText(
          TextField,
          'Prepared By (Farmer / Manager Name)',
        );
        expect(preparedByField, findsOneWidget);
        await tester.enterText(preparedByField, 'John Farmer');

        final verifiedByField = find.widgetWithText(
          TextField,
          'Auditor / Credit Review Officer (Optional)',
        );
        expect(verifiedByField, findsOneWidget);
        await tester.enterText(verifiedByField, 'Mary Auditor');

        await tester.pump();

        // Submit export
        await tester.tap(find.text('View & Export Bank-Ready PDF'));
        await tester.pump();

        expect(container.read(reportPreparedByNameProvider), 'John Farmer');
        expect(container.read(reportVerifiedByNameProvider), 'Mary Auditor');
        expect(container.read(reportIncludeSignaturesProvider), isTrue);
      },
    );
  });
}
