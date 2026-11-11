import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/financial_engine/project_comparison.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/domain/models/project_with_farm.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/features/reports/domain/models/cash_flow_point.dart';
import 'package:farmivo/features/reports/domain/models/category_expense_share.dart';
import 'package:farmivo/features/reports/presentation/providers/reports_providers.dart';
import 'package:farmivo/features/reports/presentation/reports_screen.dart';
import 'package:farmivo/features/reports/presentation/widgets/budget_vs_actual_bar_chart.dart';
import 'package:farmivo/features/reports/presentation/widgets/cash_flow_trend_line_chart.dart';
import 'package:farmivo/features/reports/presentation/widgets/expense_category_donut_chart.dart';
import 'package:farmivo/features/reports/presentation/widgets/project_comparison_bar_chart.dart';

void main() {
  const currency = 'GHS';

  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('ExpenseCategoryDonutChart', () {
    testWidgets('renders empty placeholder when shares list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(const ExpenseCategoryDonutChart(shares: [])),
      );
      await tester.pump();

      expect(find.text('No expenses logged yet'), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets(
      'renders PieChart, grand total center label, and legend items when shares exist',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final shares = [
          CategoryExpenseShare(
            categoryId: 'cat-1',
            categoryName: 'Seeds & Seedlings',
            totalSpent: Money.fromMajor(400.0, currency: currency),
            percentage: 40.0,
            color: Colors.green,
          ),
          CategoryExpenseShare(
            categoryId: 'cat-2',
            categoryName: 'Fertilizer & Nutrition',
            totalSpent: Money.fromMajor(600.0, currency: currency),
            percentage: 60.0,
            color: Colors.blue,
          ),
        ];

        await tester.pumpWidget(
          wrapWithTheme(ExpenseCategoryDonutChart(shares: shares)),
        );
        await tester.pump();

        expect(find.text('Expense Breakdown by Category'), findsOneWidget);
        expect(find.byType(PieChart), findsOneWidget);
        expect(find.text('Seeds & Seedlings'), findsOneWidget);
        expect(find.text('Fertilizer & Nutrition'), findsOneWidget);
        expect(find.text('40.0%'), findsOneWidget);
        expect(find.text('60.0%'), findsOneWidget);
        expect(find.text('GH₵ 1,000.00'), findsWidgets);
      },
    );
  });

  group('BudgetVsActualBarChart', () {
    testWidgets('renders empty placeholder when report is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(const BudgetVsActualBarChart(report: null)),
      );
      await tester.pump();

      expect(
        find.text('No budget items or expenses to compare'),
        findsOneWidget,
      );
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets(
      'renders grouped BarChart, legend, and category comparison rows',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const cat1 = BudgetCategory(
          id: 'cat-1',
          name: 'Land Prep',
          description: '',
          iconName: 'landscape',
          isSystemDefault: true,
          displayOrder: 1,
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        const cat2 = BudgetCategory(
          id: 'cat-2',
          name: 'Chemicals',
          description: '',
          iconName: 'science',
          isSystemDefault: true,
          displayOrder: 2,
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final report = ProjectVarianceReport(
          projectId: 'p-1',
          currency: currency,
          totalPlanned: Money.fromMajor(1500.0, currency: currency),
          totalSpent: Money.fromMajor(1800.0, currency: currency),
          totalTransactionsCount: 5,
          categories: [
            CategoryVariance(
              category: cat1,
              itemVariances: const [],
              plannedAmount: Money.fromMajor(1000.0, currency: currency),
              actualSpent: Money.fromMajor(800.0, currency: currency),
              transactionCount: 2,
              percentageOfTotalBudget: 66.7,
            ),
            CategoryVariance(
              category: cat2,
              itemVariances: const [],
              plannedAmount: Money.fromMajor(500.0, currency: currency),
              actualSpent: Money.fromMajor(1000.0, currency: currency),
              transactionCount: 3,
              percentageOfTotalBudget: 33.3,
            ),
          ],
        );

        await tester.pumpWidget(
          wrapWithTheme(BudgetVsActualBarChart(report: report)),
        );
        await tester.pump();

        expect(find.text('Budget vs. Actual Spending'), findsOneWidget);
        expect(find.byType(BarChart), findsOneWidget);
        expect(find.text('Planned'), findsOneWidget);
        expect(find.text('Actual'), findsOneWidget);
        expect(find.text('Land Prep'), findsOneWidget);
        expect(find.text('Chemicals'), findsOneWidget);
      },
    );
  });

  group('CashFlowTrendLineChart', () {
    testWidgets('renders empty placeholder when timeline is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(const CashFlowTrendLineChart(timeline: [])),
      );
      await tester.pump();

      expect(find.text('No cash transactions recorded yet'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets(
      'renders dual LineChart lines and break-even crossover banner',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final day1 = DateTime(2025, 1, 1).millisecondsSinceEpoch;
        final day2 = DateTime(2025, 2, 1).millisecondsSinceEpoch;

        final timeline = CashFlowPoint.buildTimeline(
          cashInTransactions: [
            (
              timestamp: day2,
              amount: Money.fromMajor(5000.0, currency: currency),
            ),
          ],
          cashOutTransactions: [
            (
              timestamp: day1,
              amount: Money.fromMajor(3000.0, currency: currency),
            ),
          ],
          currency: currency,
        );

        await tester.pumpWidget(
          wrapWithTheme(CashFlowTrendLineChart(timeline: timeline)),
        );
        await tester.pump();

        expect(find.text('Cumulative Cash Flow Trend'), findsOneWidget);
        expect(find.byType(LineChart), findsOneWidget);
        expect(find.text('Cash In'), findsOneWidget);
        expect(find.text('Cash Out'), findsOneWidget);
        expect(find.text('Cash Break-Even Reached'), findsOneWidget);
      },
    );
  });

  group('ProjectComparisonBarChart', () {
    testWidgets('renders empty placeholder when records are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          ProjectComparisonBarChart(
            matrix: ProjectComparisonMatrix.compute([]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No projects available for comparison'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets(
      'renders grouped BarChart with Capital, Revenue, and Profit legend',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final p1 = ProjectComparisonRecord.compute(
          projectId: 'p-1',
          projectName: 'Ejura Maize A',
          commodity: 'Maize',
          variety: 'Pannar 53',
          farmName: 'Ridge Farm',
          stage: ProjectLifecycleState.completed,
          status: 'COMPLETED',
          landSize: 4.0,
          landUnit: 'Acres',
          plannedBudget: Money.fromMajor(6000),
          actualSpent: Money.fromMajor(5000),
          actualSales: Money.fromMajor(10000),
          daysActive: 105,
          healthScore: 92,
          healthStatus: ProjectHealthStatus.healthy,
        );

        final matrix = ProjectComparisonMatrix.compute([p1]);

        await tester.pumpWidget(
          wrapWithTheme(ProjectComparisonBarChart(matrix: matrix)),
        );
        await tester.pump();

        expect(find.text('Cross-Project Financial Comparison'), findsOneWidget);
        expect(find.byType(BarChart), findsOneWidget);
        expect(find.text('Capital'), findsOneWidget);
        expect(find.text('Revenue'), findsOneWidget);
        expect(find.text('Profit'), findsOneWidget);
      },
    );
  });

  group('ReportsScreen', () {
    testWidgets(
      'renders portfolio summary view with all visual analytics charts',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const testProject = Project(
          id: 'proj-1',
          farmId: 'farm-1',
          name: 'Ejura Maize 2026',
          projectType: 'CROP',
          commodity: 'Maize',
          landSize: 5.0,
          landUnit: 'Acres',
          startDate: 0,
          currency: currency,
          status: 'ACTIVE',
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final pRecord = ProjectComparisonRecord.compute(
          projectId: 'proj-1',
          projectName: 'Ejura Maize 2026',
          commodity: 'Maize',
          farmName: 'Farm Ridge',
          stage: ProjectLifecycleState.active,
          status: 'ACTIVE',
          landSize: 5.0,
          landUnit: 'Acres',
          plannedBudget: Money.fromMajor(5000),
          actualSpent: Money.fromMajor(4000),
          actualSales: Money.fromMajor(8000),
          daysActive: 60,
          healthScore: 85,
          healthStatus: ProjectHealthStatus.healthy,
        );

        final matrix = ProjectComparisonMatrix.compute([pRecord]);

        final shares = [
          CategoryExpenseShare(
            categoryId: 'cat-1',
            categoryName: 'Seeds',
            totalSpent: Money.fromMajor(4000.0, currency: currency),
            percentage: 100.0,
            color: Colors.green,
          ),
        ];

        final timeline = CashFlowPoint.buildTimeline(
          cashInTransactions: [
            (
              timestamp: DateTime(2025, 2, 1).millisecondsSinceEpoch,
              amount: Money.fromMajor(8000.0, currency: currency),
            ),
          ],
          cashOutTransactions: [
            (
              timestamp: DateTime(2025, 1, 1).millisecondsSinceEpoch,
              amount: Money.fromMajor(4000.0, currency: currency),
            ),
          ],
          currency: currency,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              projectsWithFarmStreamProvider.overrideWith(
                (ref) =>
                    Stream.value([const ProjectWithFarm(project: testProject)]),
              ),
              reportCategoryExpenseSharesProvider.overrideWith(
                (ref) => AsyncValue.data(shares),
              ),
              reportCashFlowTimelineProvider.overrideWith(
                (ref) => AsyncValue.data(timeline),
              ),
              reportComparisonMatrixProvider.overrideWith(
                (ref) => AsyncValue.data(matrix),
              ),
              reportVarianceProvider.overrideWith(
                (ref) => const AsyncValue.data(null),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ReportsScreen(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Reports & Analytics'), findsOneWidget);
        expect(find.text('Scope Selection'), findsOneWidget);
        expect(find.text('Executive Portfolio Summary'), findsOneWidget);
        expect(find.byType(ExpenseCategoryDonutChart), findsOneWidget);
        expect(find.byType(CashFlowTrendLineChart), findsOneWidget);
        expect(find.byType(ProjectComparisonBarChart), findsOneWidget);
        expect(find.text('Bank-Ready Financial Statement'), findsOneWidget);
      },
    );

    testWidgets(
      'renders individual project summary and budget variance chart when project is selected',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const testProject = Project(
          id: 'proj-1',
          farmId: 'farm-1',
          name: 'Ejura Maize 2026',
          projectType: 'CROP',
          commodity: 'Maize',
          landSize: 5.0,
          landUnit: 'Acres',
          startDate: 0,
          currency: currency,
          status: 'ACTIVE',
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final metrics = ProjectMetrics.compute(
          project: testProject,
          budgetItems: const [],
          expenses: const [],
          activities: const [],
          harvests: const [],
          sales: const [],
        );

        const cat1 = BudgetCategory(
          id: 'cat-1',
          name: 'Land Prep',
          description: '',
          iconName: 'landscape',
          isSystemDefault: true,
          displayOrder: 1,
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final report = ProjectVarianceReport(
          projectId: 'proj-1',
          currency: currency,
          totalPlanned: Money.fromMajor(1500.0, currency: currency),
          totalSpent: Money.fromMajor(1200.0, currency: currency),
          totalTransactionsCount: 2,
          categories: [
            CategoryVariance(
              category: cat1,
              itemVariances: const [],
              plannedAmount: Money.fromMajor(1500.0, currency: currency),
              actualSpent: Money.fromMajor(1200.0, currency: currency),
              transactionCount: 2,
              percentageOfTotalBudget: 100.0,
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              selectedReportProjectIdProvider.overrideWith((ref) => 'proj-1'),
              projectsWithFarmStreamProvider.overrideWith(
                (ref) =>
                    Stream.value([const ProjectWithFarm(project: testProject)]),
              ),
              projectMetricsProvider(
                'proj-1',
              ).overrideWith((ref) => Stream.value(metrics)),
              reportCategoryExpenseSharesProvider.overrideWith(
                (ref) => const AsyncValue.data([]),
              ),
              reportCashFlowTimelineProvider.overrideWith(
                (ref) => const AsyncValue.data([]),
              ),
              reportVarianceProvider.overrideWith(
                (ref) => AsyncValue.data(report),
              ),
              reportComparisonMatrixProvider.overrideWith(
                (ref) => AsyncValue.data(ProjectComparisonMatrix.compute([])),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ReportsScreen(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Reports & Analytics'), findsOneWidget);
        expect(find.text('Executive Financial Summary'), findsOneWidget);
        expect(find.byType(BudgetVsActualBarChart), findsOneWidget);
        expect(find.text('Land Prep'), findsOneWidget);
      },
    );
  });
}
