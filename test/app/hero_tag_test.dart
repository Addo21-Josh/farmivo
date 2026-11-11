import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/dashboard/domain/models/dashboard_financial_summary.dart';
import 'package:farmivo/features/dashboard/presentation/dashboard_screen.dart';
import 'package:farmivo/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_category_providers.dart';
import 'package:farmivo/features/expenses/presentation/providers/expense_providers.dart';
import 'package:farmivo/features/expenses/presentation/transactions_screen.dart';
import 'package:farmivo/features/farms/presentation/providers/farm_providers.dart';
import 'package:farmivo/features/projects/presentation/projects_screen.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';

void main() {
  testWidgets(
    'Guarantees zero duplicate Hero tags when navigating from multi-tab IndexedStack',
    (tester) async {
      final emptySummary = DashboardFinancialSummary(
        grossSalesValue: Money.zero(),
        collectedRevenue: Money.zero(),
        accountsReceivable: Money.zero(),
        totalInvested: Money.zero(),
        activeProjectsCount: 0,
        debtorsCount: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardFinancialSummaryProvider.overrideWith(
              (ref) => Stream.value(emptySummary),
            ),
            projectsWithFarmStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            projectsStreamProvider.overrideWith((ref) => Stream.value([])),
            farmsStreamProvider.overrideWith((ref) => Stream.value([])),
            filteredExpensesProvider.overrideWith((ref) => Stream.value([])),
            budgetCategoriesStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: IndexedStack(
                    index: 0,
                    children: const [
                      DashboardScreen(),
                      ProjectsScreen(),
                      TransactionsScreen(),
                    ],
                  ),
                  bottomNavigationBar: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(
                            body: Text('Project Details Hub (Planning)'),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Planning'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap navigate to trigger route transition and scheduler hero animation
      await tester.tap(find.text('Open Planning'));
      await tester.pump(); // Start transition
      await tester.pumpAndSettle(); // Complete transition

      final dynamic exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason:
            'No scheduler hero tag exception should be thrown during navigation.',
      );
      expect(find.text('Project Details Hub (Planning)'), findsOneWidget);
    },
  );
}
