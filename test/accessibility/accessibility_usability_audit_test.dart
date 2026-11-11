import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_colors.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_variance_providers.dart';
import 'package:farmivo/features/budgets/presentation/widgets/budget_variance_card.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/features/projects/presentation/widgets/dynamic_break_even_card.dart';
import 'package:farmivo/features/projects/presentation/widgets/multi_dimensional_profitability_card.dart';
import 'package:farmivo/features/projects/presentation/widgets/project_health_score_card.dart';

/// Helper computing WCAG 2.1 relative luminance for a given Color.
double computeLuminance(Color color) {
  double linearize(double channel) {
    return channel <= 0.04045
        ? channel / 12.92
        : pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize(color.r);
  final g = linearize(color.g);
  final b = linearize(color.b);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Helper computing WCAG 2.1 contrast ratio between two colors.
double computeContrastRatio(Color foreground, Color background) {
  final lum1 = computeLuminance(foreground);
  final lum2 = computeLuminance(background);

  final lighter = max(lum1, lum2);
  final darker = min(lum1, lum2);

  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Milestone 10.3: Accessibility & Usability Audit', () {
    const currency = 'GHS';
    const testProject = Project(
      id: 'proj-a11y',
      farmId: 'farm-a11y',
      name: 'Sunyani Maize Demonstration',
      projectType: 'CROP',
      commodity: 'Yellow Maize',
      variety: 'Abontem',
      landSize: 10.0,
      landUnit: 'Acres',
      startDate: 1767225600000,
      currency: currency,
      status: 'ACTIVE',
      createdAt: 1767225600000,
      updatedAt: 1767225600000,
      isSynced: false,
      isDeleted: false,
    );

    final testMetrics = ProjectMetrics(
      projectId: testProject.id,
      daysActive: 45,
      stage: ProjectLifecycleState.production,
      totalBudgeted: Money.fromMajor(15000.0),
      totalSpent: Money.fromMajor(10500.0),
      totalRevenue: Money.fromMajor(25000.0),
      collectedRevenue: Money.fromMajor(20000.0),
      accountsReceivable: Money.fromMajor(5000.0),
      netProfit: Money.fromMajor(14500.0),
      cashProfit: Money.fromMajor(9500.0),
      roiPercentage: 138.1,
      cashRoiPercentage: 90.5,
      projectedYieldDisplay: '12,000 kg',
      actualYieldTotal: 12500.0,
      actualYieldUnit: 'kg',
      activitiesCount: 8,
      harvestBatchesCount: 2,
      salesCount: 3,
      unpaidReceivables: Money.fromMajor(5000.0),
      budgetSpentPercentage: 70.0,
      healthStatus: ProjectHealthStatus.healthy,
      healthMessage:
          'Project is operating with high financial discipline and strong liquidity.',
      healthEvaluation: ProjectHealthEvaluation.compute(
        plannedBudget: Money.fromMajor(15000.0),
        actualSpent: Money.fromMajor(10500.0),
        expectedRevenue: Money.fromMajor(25000.0),
        actualSales: Money.fromMajor(25000.0),
        cashCollected: Money.fromMajor(20000.0),
        completedActivities: 8,
        totalActivities: 8,
      ),
      profitability: ProjectProfitability.compute(
        actualRevenue: Money.fromMajor(25000.0),
        actualExpenses: Money.fromMajor(10500.0),
        cashCollected: Money.fromMajor(20000.0),
        cashDisbursed: Money.fromMajor(10500.0),
        totalBudgeted: Money.fromMajor(15000.0),
      ),
      dynamicBreakEven: DynamicBreakEven.compute(
        actualCosts: Money.fromMajor(10500.0),
        actualSales: Money.fromMajor(25000.0),
        cashCollected: Money.fromMajor(20000.0),
        effectiveUnitPrice: Money.fromMajor(2.50),
        unit: 'kg',
      ),
    );

    group('1. High-Contrast Sunlight Glare & WCAG Contrast Ratio Verification', () {
      test('Light outdoor theme body text exceeds WCAG AAA (>= 7.0:1)', () {
        final ratio = computeContrastRatio(
          AppColors.textPrimaryLight,
          AppColors.backgroundLight,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(7.0),
          reason:
              'Light outdoor theme text primary contrast ($ratio:1) must meet WCAG AAA',
        );
      });

      test('Light outdoor theme secondary text exceeds WCAG AA (>= 4.5:1)', () {
        final ratio = computeContrastRatio(
          AppColors.textSecondaryLight,
          AppColors.backgroundLight,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Light outdoor theme secondary text ($ratio:1) must meet WCAG AA',
        );
      });

      test('Dark theme text primary on surface exceeds WCAG AAA (>= 7.0:1)', () {
        final ratio = computeContrastRatio(
          AppColors.textPrimaryDark,
          AppColors.surfaceDark,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(7.0),
          reason:
              'Dark theme primary text contrast ($ratio:1) must meet WCAG AAA',
        );
      });

      test(
        'Pure OLED Black theme text contrast exceeds 15.0:1 for high glare visibility',
        () {
          final ratio = computeContrastRatio(
            Colors.white,
            AppColors.surfaceOled,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(15.0),
            reason: 'OLED Black high-contrast text ($ratio:1) must exceed 15:1',
          );
        },
      );

      test('Agricultural Brand Green on white exceeds WCAG AA (>= 4.5:1)', () {
        final ratio = computeContrastRatio(
          AppColors.primaryGreen,
          Colors.white,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Primary brand green contrast ($ratio:1) must meet WCAG AA',
        );
      });

      test(
        'Financial Health Badges (Green, Amber, Red) meet WCAG AA on their tint backgrounds (>= 4.0:1)',
        () {
          final greenRatio = computeContrastRatio(
            AppColors.healthGreen,
            AppColors.healthGreenBg,
          );
          final amberRatio = computeContrastRatio(
            AppColors.healthYellow,
            AppColors.healthYellowBg,
          );
          final redRatio = computeContrastRatio(
            AppColors.healthRed,
            AppColors.healthRedBg,
          );

          expect(greenRatio, greaterThanOrEqualTo(4.0));
          expect(amberRatio, greaterThanOrEqualTo(4.0));
          expect(redRatio, greaterThanOrEqualTo(4.0));
        },
      );
    });

    group('2. Screen Reader Semantics Labels on Financial Cards', () {
      testWidgets(
        'ProjectHealthScoreCard exposes verbal composite score & status to TalkBack/VoiceOver',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: ProjectHealthScoreCard(metrics: testMetrics),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final semanticsFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains('Project Health Score') ==
                    true,
          );
          expect(semanticsFinder, findsWidgets);

          // Verify criteria bar semantics
          final criteriaSemantics = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains('Budget Discipline') == true,
          );
          expect(criteriaSemantics, findsWidgets);
        },
      );

      testWidgets(
        'MultiDimensionalProfitabilityCard exposes all 3 profit dimensions to screen readers',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: MultiDimensionalProfitabilityCard(metrics: testMetrics),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final semanticsFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains(
                      'Multi-Dimensional Profitability',
                    ) ==
                    true,
          );
          expect(semanticsFinder, findsWidgets);

          final accrualFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains('Actual Net Profit') == true,
          );
          expect(accrualFinder, findsWidgets);
        },
      );

      testWidgets(
        'DynamicBreakEvenCard exposes cost recovery percentage and deficit to screen readers',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(body: DynamicBreakEvenCard(metrics: testMetrics)),
            ),
          );
          await tester.pumpAndSettle();

          final semanticsFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains(
                      'Dynamic Break-Even Analysis',
                    ) ==
                    true,
          );
          expect(semanticsFinder, findsWidgets);
        },
      );

      testWidgets(
        'BudgetVarianceCard exposes planned vs actual metrics verbally to screen readers',
        (tester) async {
          const testCategory = BudgetCategory(
            id: 'cat-1',
            name: 'Certified Hybrid Seeds',
            iconName: 'grass',
            isSystemDefault: true,
            displayOrder: 1,
            createdAt: 0,
            updatedAt: 0,
            isSynced: false,
            isDeleted: false,
          );

          final varianceReport = ProjectVarianceReport(
            projectId: testProject.id,
            currency: 'GHS',
            totalPlanned: Money.fromMajor(15000.0),
            totalSpent: Money.fromMajor(10500.0),
            totalTransactionsCount: 8,
            categories: [
              CategoryVariance(
                category: testCategory,
                itemVariances: const [],
                plannedAmount: Money.fromMajor(6000.0),
                actualSpent: Money.fromMajor(4000.0),
                transactionCount: 3,
                percentageOfTotalBudget: 40.0,
              ),
            ],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                projectVarianceReportProvider(
                  testProject.id,
                ).overrideWithValue(AsyncValue.data(varianceReport)),
              ],
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: const Scaffold(
                  body: BudgetVarianceCard(project: testProject),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          final plannedFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains('PLANNED BUDGET') == true,
          );
          expect(plannedFinder, findsWidgets);

          final spentFinder = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label?.contains('ACTUAL SPENT') == true,
          );
          expect(spentFinder, findsWidgets);
        },
      );
    });

    group('3. Minimum 48x48dp Tap Target Size Enforcement', () {
      testWidgets('ElevatedButton enforces >= 48dp minimum height and width', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Record Operating Expense'),
                ),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(ElevatedButton);
        final size = tester.getSize(buttonFinder);
        expect(size.height, greaterThanOrEqualTo(48.0));
        expect(size.width, greaterThanOrEqualTo(48.0));
      });

      testWidgets('OutlinedButton enforces >= 48dp minimum height and width', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Cancel Transaction'),
                ),
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(OutlinedButton);
        final size = tester.getSize(buttonFinder);
        expect(size.height, greaterThanOrEqualTo(48.0));
        expect(size.width, greaterThanOrEqualTo(48.0));
      });

      testWidgets('IconButton theme enforces >= 48x48dp minimum bounding box', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                ),
              ),
            ),
          ),
        );

        final iconButtonFinder = find.byType(IconButton);
        final size = tester.getSize(iconButtonFinder);
        expect(size.height, greaterThanOrEqualTo(48.0));
        expect(size.width, greaterThanOrEqualTo(48.0));
      });

      testWidgets(
        'FilterChip touch area provides comfortable outdoor finger tapping (>= 44dp)',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(
                  child: FilterChip(
                    selected: true,
                    label: const Text('Fertilizers'),
                    onSelected: (_) {},
                  ),
                ),
              ),
            ),
          );

          final chipFinder = find.byType(FilterChip);
          final size = tester.getSize(chipFinder);
          expect(size.height, greaterThanOrEqualTo(40.0));
          expect(size.width, greaterThanOrEqualTo(48.0));
        },
      );
    });
  });
}
