import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/budgets/domain/models/budget_item_with_category.dart';
import 'package:farmivo/features/budgets/domain/models/budget_tracking.dart';
import 'package:farmivo/features/budgets/domain/models/budget_variance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const currency = 'GHS';
  const testProjectId = 'project-uuid-1';

  group('BudgetVarianceThreshold.resolve', () {
    test('Resolves healthy when actual is below 80% of planned', () {
      final planned = Money(
        BigInt.from(100000),
        currency: currency,
      ); // GH₵ 1,000.00
      final actual = Money(
        BigInt.from(50000),
        currency: currency,
      ); // GH₵ 500.00 (50%)

      expect(
        BudgetVarianceThreshold.resolve(planned: planned, actual: actual),
        equals(BudgetVarianceThreshold.healthy),
      );
    });

    test('Resolves warning when actual is >= 80% and < 100% of planned', () {
      final planned = Money(
        BigInt.from(100000),
        currency: currency,
      ); // GH₵ 1,000.00
      final actual80 = Money(
        BigInt.from(80000),
        currency: currency,
      ); // GH₵ 800.00 (80%)
      final actual95 = Money(
        BigInt.from(95000),
        currency: currency,
      ); // GH₵ 950.00 (95%)

      expect(
        BudgetVarianceThreshold.resolve(planned: planned, actual: actual80),
        equals(BudgetVarianceThreshold.warning),
      );
      expect(
        BudgetVarianceThreshold.resolve(planned: planned, actual: actual95),
        equals(BudgetVarianceThreshold.warning),
      );
    });

    test('Resolves critical when actual is exactly 100% of planned', () {
      final planned = Money(
        BigInt.from(100000),
        currency: currency,
      ); // GH₵ 1,000.00
      final actual100 = Money(
        BigInt.from(100000),
        currency: currency,
      ); // GH₵ 1,000.00 (100%)

      expect(
        BudgetVarianceThreshold.resolve(planned: planned, actual: actual100),
        equals(BudgetVarianceThreshold.critical),
      );
    });

    test('Resolves overrun when actual exceeds 100% of planned', () {
      final planned = Money(
        BigInt.from(100000),
        currency: currency,
      ); // GH₵ 1,000.00
      final actualOver = Money(
        BigInt.from(115000),
        currency: currency,
      ); // GH₵ 1,150.00 (115%)

      expect(
        BudgetVarianceThreshold.resolve(planned: planned, actual: actualOver),
        equals(BudgetVarianceThreshold.overrun),
      );
    });

    test(
      'Resolves overrun when spending occurs without any planned allocation',
      () {
        final planned = Money.zero(currency: currency);
        final actual = Money(BigInt.from(25000), currency: currency);

        expect(
          BudgetVarianceThreshold.resolve(planned: planned, actual: actual),
          equals(BudgetVarianceThreshold.overrun),
        );
      },
    );
  });

  group('ProjectVarianceReport - Variance Formulas & Threshold Alerts', () {
    const testCategory = BudgetCategory(
      id: 'cat-seeds',
      name: 'Seeds & Seedlings',
      description: 'Crop seeds',
      iconName: 'grass',
      isSystemDefault: true,
      displayOrder: 2,
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
    );

    const testItem = BudgetItem(
      id: 'item-1',
      projectId: testProjectId,
      categoryId: 'cat-seeds',
      name: 'Hybrid Maize Seed',
      quantity: 5.0,
      unit: 'Bags',
      unitCostMinor: 20000, // GH₵ 200.00
      plannedAmountMinor: 100000, // GH₵ 1,000.00
      currency: currency,
      status: 'ACTIVE',
      createdAt: 0,
      updatedAt: 0,
      isSynced: false,
      isDeleted: false,
    );

    const itemWithCat = BudgetItemWithCategory(
      item: testItem,
      category: testCategory,
    );

    test('Computes exact Variance = Actual - Planned and Variance %', () {
      // Planned: GH₵ 1,000.00. Actual: GH₵ 850.00
      // Variance: 850 - 1000 = -GH₵ 150.00 (-15% under budget)
      final itemVar = ItemVariance(
        itemWithCategory: itemWithCat,
        actualSpent: Money(BigInt.from(85000), currency: currency),
        transactionCount: 2,
      );

      expect(itemVar.variance.minorUnits, equals(BigInt.from(-15000)));
      expect(itemVar.variancePercentage, closeTo(-15.0, 0.01));
      expect(itemVar.spentPercentage, closeTo(85.0, 0.01));
      expect(itemVar.threshold, equals(BudgetVarianceThreshold.warning));
      expect(itemVar.alertMessage, contains('Warning: 85% spent'));
    });

    test('Computes positive variance on overrun with exact excess', () {
      // Planned: GH₵ 1,000.00. Actual: GH₵ 1,250.00
      // Variance: 1250 - 1000 = +GH₵ 250.00 (+25% overrun)
      final itemVar = ItemVariance(
        itemWithCategory: itemWithCat,
        actualSpent: Money(BigInt.from(125000), currency: currency),
        transactionCount: 3,
      );

      expect(itemVar.variance.minorUnits, equals(BigInt.from(25000)));
      expect(itemVar.variancePercentage, closeTo(25.0, 0.01));
      expect(itemVar.spentPercentage, closeTo(125.0, 0.01));
      expect(itemVar.threshold, equals(BudgetVarianceThreshold.overrun));
      expect(itemVar.alertMessage, contains('Overrun by GH₵ 250.00 (+25.0%)'));
    });

    test(
      'ProjectVarianceReport filters categories and items at risk correctly',
      () {
        final categoryHealthy = const BudgetCategory(
          id: 'cat-healthy',
          name: 'Land Prep',
          description: '',
          iconName: 'agriculture',
          isSystemDefault: true,
          displayOrder: 1,
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final categoryWarning = const BudgetCategory(
          id: 'cat-warning',
          name: 'Agro-Chemicals',
          description: '',
          iconName: 'pest_control',
          isSystemDefault: true,
          displayOrder: 4,
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final categoryOverrun = const BudgetCategory(
          id: 'cat-overrun',
          name: 'Casual Labour',
          description: '',
          iconName: 'groups',
          isSystemDefault: true,
          displayOrder: 6,
          createdAt: 0,
          updatedAt: 0,
          isSynced: false,
          isDeleted: false,
        );

        final tracking = ProjectBudgetTracking(
          projectId: testProjectId,
          currency: currency,
          totalPlanned: Money(
            BigInt.from(1000000),
            currency: currency,
          ), // GH₵ 10,000.00
          totalSpent: Money(
            BigInt.from(920000),
            currency: currency,
          ), // GH₵ 9,200.00 (92% warning)
          totalTransactionsCount: 8,
          categories: [
            CategoryBudgetTracking(
              category: categoryHealthy,
              items: const [],
              plannedAmount: Money(
                BigInt.from(300000),
                currency: currency,
              ), // GH₵ 3,000.00
              actualSpent: Money(
                BigInt.from(100000),
                currency: currency,
              ), // GH₵ 1,000.00 (33% healthy)
              transactionCount: 1,
              percentageOfTotalBudget: 30.0,
            ),
            CategoryBudgetTracking(
              category: categoryWarning,
              items: const [],
              plannedAmount: Money(
                BigInt.from(400000),
                currency: currency,
              ), // GH₵ 4,000.00
              actualSpent: Money(
                BigInt.from(360000),
                currency: currency,
              ), // GH₵ 3,600.00 (90% warning)
              transactionCount: 3,
              percentageOfTotalBudget: 40.0,
            ),
            CategoryBudgetTracking(
              category: categoryOverrun,
              items: const [],
              plannedAmount: Money(
                BigInt.from(300000),
                currency: currency,
              ), // GH₵ 3,000.00
              actualSpent: Money(
                BigInt.from(460000),
                currency: currency,
              ), // GH₵ 4,600.00 (153% overrun)
              transactionCount: 4,
              percentageOfTotalBudget: 30.0,
            ),
          ],
        );

        final report = ProjectVarianceReport.fromTracking(tracking);

        expect(report.totalPlanned.minorUnits, equals(BigInt.from(1000000)));
        expect(report.totalSpent.minorUnits, equals(BigInt.from(920000)));
        expect(
          report.variance.minorUnits,
          equals(BigInt.from(-80000)),
        ); // -GH₵ 800.00
        expect(report.variancePercentage, closeTo(-8.0, 0.01));
        expect(
          report.overallThreshold,
          equals(BudgetVarianceThreshold.warning),
        );

        // Threshold alerts
        expect(report.categoriesAtRisk.length, equals(2)); // Warning + Overrun
        expect(report.overrunCount, equals(1));
        expect(report.warningCount, equals(1));
        expect(report.hasAlerts, isTrue);

        final overrunCat = report.categoriesAtRisk.firstWhere(
          (c) => c.category.id == 'cat-overrun',
        );
        expect(overrunCat.threshold, equals(BudgetVarianceThreshold.overrun));
        expect(
          overrunCat.variance.minorUnits,
          equals(BigInt.from(160000)),
        ); // +GH₵ 1,600.00 overrun
        expect(overrunCat.variancePercentage, closeTo(53.33, 0.01));
        expect(
          overrunCat.alertMessage,
          contains('Category overrun by GH₵ 1,600.00 (+53.3%)'),
        );
      },
    );
  });
}
