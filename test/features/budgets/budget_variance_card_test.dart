import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_variance_providers.dart';
import 'package:farmivo/features/budgets/presentation/widgets/budget_variance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const currency = 'GHS';
  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Maize 2026',
    projectType: 'CROP',
    commodity: 'Maize',
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

  const testCategory = BudgetCategory(
    id: 'cat-chem',
    name: 'Agro-Chemicals & Spraying',
    description: 'Weedicides and pest control',
    iconName: 'pest_control',
    isSystemDefault: true,
    displayOrder: 4,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  testWidgets(
    'BudgetVarianceCard renders planned vs actual metrics and healthy badge',
    (tester) async {
      final report = ProjectVarianceReport(
        projectId: 'proj-1',
        currency: currency,
        totalPlanned: Money(
          BigInt.from(500000),
          currency: currency,
        ), // GH₵ 5,000.00
        totalSpent: Money(
          BigInt.from(250000),
          currency: currency,
        ), // GH₵ 2,500.00 (50%)
        totalTransactionsCount: 3,
        categories: [
          CategoryVariance(
            category: testCategory,
            itemVariances: const [],
            plannedAmount: Money(BigInt.from(500000), currency: currency),
            actualSpent: Money(BigInt.from(250000), currency: currency),
            transactionCount: 3,
            percentageOfTotalBudget: 100.0,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectVarianceReportProvider(
              'proj-1',
            ).overrideWithValue(AsyncValue.data(report)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BudgetVarianceCard(project: testProject)),
          ),
        ),
      );

      expect(find.text('Planned vs. Actual Variance'), findsOneWidget);
      expect(find.text('PLANNED BUDGET'), findsOneWidget);
      expect(find.text('ACTUAL SPENT'), findsOneWidget);
      expect(find.text('NET VARIANCE'), findsOneWidget);
      expect(find.text('GH₵ 5,000.00'), findsOneWidget);
      expect(find.text('GH₵ 2,500.00'), findsOneWidget);
      expect(find.text('-GH₵ 2,500.00'), findsOneWidget);
      expect(find.text('-50.0%'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.textContaining('ACTIVE THRESHOLD ALERTS'), findsNothing);
    },
  );

  testWidgets(
    'BudgetVarianceCard displays automated threshold alerts on category overrun',
    (tester) async {
      final report = ProjectVarianceReport(
        projectId: 'proj-1',
        currency: currency,
        totalPlanned: Money(
          BigInt.from(200000),
          currency: currency,
        ), // GH₵ 2,000.00
        totalSpent: Money(
          BigInt.from(260000),
          currency: currency,
        ), // GH₵ 2,600.00 (130% overrun)
        totalTransactionsCount: 5,
        categories: [
          CategoryVariance(
            category: testCategory,
            itemVariances: const [],
            plannedAmount: Money(BigInt.from(200000), currency: currency),
            actualSpent: Money(BigInt.from(260000), currency: currency),
            transactionCount: 5,
            percentageOfTotalBudget: 100.0,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectVarianceReportProvider(
              'proj-1',
            ).overrideWithValue(AsyncValue.data(report)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BudgetVarianceCard(project: testProject)),
          ),
        ),
      );

      expect(find.text('Planned vs. Actual Variance'), findsOneWidget);
      expect(find.text('Overrun (>100%)'), findsOneWidget);
      expect(find.text('+GH₵ 600.00'), findsOneWidget);
      expect(find.text('+30.0%'), findsOneWidget);
      expect(find.text('ACTIVE THRESHOLD ALERTS (1)'), findsOneWidget);
      expect(find.text('Agro-Chemicals & Spraying'), findsOneWidget);
      expect(
        find.textContaining('Category overrun by GH₵ 600.00 (+30.0%)'),
        findsOneWidget,
      );
      expect(find.text('130%'), findsOneWidget);
    },
  );

  testWidgets(
    'BudgetVarianceCard returns empty widget when totalPlanned and totalSpent are both zero',
    (tester) async {
      final report = ProjectVarianceReport(
        projectId: 'proj-1',
        currency: currency,
        totalPlanned: Money.zero(currency: currency),
        totalSpent: Money.zero(currency: currency),
        totalTransactionsCount: 0,
        categories: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectVarianceReportProvider(
              'proj-1',
            ).overrideWithValue(AsyncValue.data(report)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BudgetVarianceCard(project: testProject)),
          ),
        ),
      );

      expect(find.text('Planned vs. Actual Variance'), findsNothing);
    },
  );
}
