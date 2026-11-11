import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/dashboard/domain/models/dashboard_financial_summary.dart';
import 'package:farmivo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:farmivo/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:farmivo/features/projects/domain/models/project_with_farm.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';

void main() {
  Widget buildTestableWidget({
    DashboardFinancialSummary? summary,
    List<ProjectWithFarm>? projects,
  }) {
    final testSummary =
        summary ??
        DashboardFinancialSummary(
          totalInvested: Money.fromMajor(5000),
          grossSalesValue: Money.fromMajor(10000),
          collectedRevenue: Money.fromMajor(6000),
          accountsReceivable: Money.fromMajor(4000),
          activeProjectsCount: 1,
          debtorsCount: 1,
        );

    return ProviderScope(
      overrides: [
        dashboardFinancialSummaryProvider.overrideWith(
          (ref) => Stream.value(testSummary),
        ),
        projectsWithFarmStreamProvider.overrideWith(
          (ref) => Stream.value(projects ?? const []),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }

  testWidgets(
    'Dashboard strictly separates Gross Sales, Collected Cash, and Accounts Receivable',
    (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Farm Financial Overview title
      expect(find.text('Farm Financial Overview'), findsOneWidget);

      // 1. Gross Sales Value
      expect(find.text('Gross Sales Value'), findsOneWidget);
      expect(find.text('GH₵ 10,000.00'), findsOneWidget);

      // 2. Collected Revenue
      expect(find.text('Collected Revenue'), findsOneWidget);
      expect(find.text('GH₵ 6,000.00'), findsOneWidget);

      // 3. Accounts Receivable
      expect(find.text('Accounts Receivable'), findsOneWidget);
      expect(find.text('GH₵ 4,000.00'), findsOneWidget); // In metric tile
      expect(
        find.text('GH₵ 4,000.00 Due'),
        findsOneWidget,
      ); // In card header trailing badge

      // 4. Total Invested / Spent
      expect(find.text('Total Invested / Spent'), findsOneWidget);
      expect(find.text('GH₵ 5,000.00'), findsWidgets);

      // 5. Collection rate indicator
      expect(find.text('60% Cash Collected'), findsOneWidget);

      // 6. Cash Profit vs Accrual Net Profit
      expect(find.text('Cash-Basis Profit'), findsOneWidget);
      expect(find.text('Accrual Net Profit'), findsOneWidget);
      expect(
        find.text('+GH₵ 1,000.00'),
        findsOneWidget,
      ); // Cash profit: 6,000 - 5,000
      expect(
        find.text('+GH₵ 5,000.00'),
        findsOneWidget,
      ); // Accrual profit: 10,000 - 5,000
    },
  );

  testWidgets('Renders empty project state and quick actions bottom sheet', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(projects: const []));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No Active Farm Projects'), findsOneWidget);
    expect(find.text('Launch First Project'), findsOneWidget);

    // Tap Quick Action bolt icon in AppBar
    await tester.tap(find.byIcon(Icons.bolt));
    await tester.pumpAndSettle();

    expect(
      find.text('Quick Action'),
      findsNWidgets(2),
    ); // FAB + bottom sheet title
    expect(find.text('Record Expense'), findsOneWidget);
    expect(find.text('Record Harvest Sale'), findsOneWidget);
    expect(find.text('Record Payment Received'), findsOneWidget);
    expect(find.text('Launch New Project'), findsOneWidget);
    expect(find.text('Register New Farm'), findsOneWidget);
  });
}
