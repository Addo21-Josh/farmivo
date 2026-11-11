import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/financial_engine/financial_calculator.dart';
import 'package:farmivo/core/money/money.dart';

void main() {
  group('Milestone 7.4: Algorithmic Project Health Scoring Engine (0–100)', () {
    test(
      'Computes perfect 100 composite health score for a stellar project',
      () {
        final evaluation = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.harvesting,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(7000),
          expectedRevenue: Money.fromMajor(10000),
          actualSales: Money.fromMajor(12000),
          cashCollected: Money.fromMajor(12000),
          totalActivities: 10,
          overdueActivities: 0,
        );

        expect(evaluation.score, 100);
        expect(evaluation.status, ProjectHealthStatus.healthy);
        expect(evaluation.badgeLabel, 'HEALTHY (100/100)');
        expect(evaluation.breakdown.budgetDisciplineScore, 100.0);
        expect(evaluation.breakdown.revenuePerformanceScore, 100.0);
        expect(evaluation.breakdown.cashLiquidityScore, 100.0);
        expect(evaluation.breakdown.scheduleDriftScore, 100.0);
        expect(evaluation.breakdown.creditRiskScore, 100.0);

        expect(evaluation.summary, contains('100/100'));
        expect(
          evaluation.summary,
          contains(
            'fully profitable with strong budget and revenue discipline',
          ),
        );
      },
    );

    test(
      'Identifies At Risk project (< 60) with clear, color-independent textual explanations',
      () {
        // Incurred costs exceed budget by 28.5% (12,850 spent vs 10,000 budget)
        // 40% of sales remain uncollected in buyer credit (6,000 collected / 10,000 sales)
        // 3 of 5 activities overdue
        final evaluation = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.harvesting,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(12850),
          expectedRevenue: Money.fromMajor(12000),
          actualSales: Money.fromMajor(10000),
          cashCollected: Money.fromMajor(6000),
          totalActivities: 5,
          overdueActivities: 3,
        );

        expect(evaluation.score, lessThan(60));
        expect(evaluation.status, ProjectHealthStatus.atRisk);
        expect(evaluation.badgeLabel, startsWith('AT RISK'));

        // Explanations must be specific and color-independent
        final reasonsJoined = evaluation.diagnosticReasons.join(' ');
        expect(reasonsJoined, contains('Budget overrun by 28.5%'));
        expect(
          reasonsJoined,
          contains('40.0% of sales remain uncollected in buyer credit'),
        );
        expect(
          reasonsJoined,
          contains('3 field agronomic activities are overdue'),
        );

        // Check summary synthesis
        expect(evaluation.summary, contains('Project is At Risk'));
        expect(evaluation.summary, contains('Budget overrun by 28.5%'));
      },
    );

    test(
      'Identifies Watch project (60–79) with moderate schedule drift and receivables',
      () {
        final evaluation = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.harvesting,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(9200), // 92% spent
          expectedRevenue: Money.fromMajor(8000),
          actualSales: Money.fromMajor(5000),
          cashCollected: Money.fromMajor(3750), // 25% receivables
          totalActivities: 6,
          overdueActivities: 1, // 1 overdue activity
        );

        expect(evaluation.score, greaterThanOrEqualTo(60));
        expect(evaluation.score, lessThan(80));
        expect(evaluation.status, ProjectHealthStatus.watch);
        expect(evaluation.badgeLabel, startsWith('WATCH'));
        expect(
          evaluation.diagnosticReasons.any(
            (r) => r.contains('1 field agronomic activity is overdue'),
          ),
          isTrue,
        );
      },
    );

    test(
      'Early-stage pre-harvest resilience: avoids penalizing planning or active stage for zero revenue',
      () {
        // In active/production stage before harvest, spending 30% of budget with 0 sales and negative cash flow is normal
        final evaluation = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.active,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(3000),
          expectedRevenue: Money.fromMajor(15000),
          actualSales: Money.zero(),
          cashCollected: Money.zero(),
          totalActivities: 4,
          overdueActivities: 0,
        );

        // Early-stage allowance ensures score is healthy
        expect(evaluation.score, greaterThanOrEqualTo(80));
        expect(evaluation.status, ProjectHealthStatus.healthy);
        expect(evaluation.breakdown.revenuePerformanceScore, 100.0);
        expect(evaluation.breakdown.creditRiskScore, 100.0);
        expect(evaluation.breakdown.budgetDisciplineScore, 100.0);
      },
    );

    test(
      'Post-harvest completed stage heavily penalizes unrecovered capital & severe revenue shortfall',
      () {
        final evaluation = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.completed,
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(10000),
          expectedRevenue: Money.fromMajor(10000),
          actualSales: Money.fromMajor(
            2000,
          ), // Only 20% of projected 10,000 realized
          cashCollected: Money.fromMajor(2000),
          totalActivities: 8,
          overdueActivities: 0,
        );

        expect(evaluation.score, lessThan(60));
        expect(evaluation.status, ProjectHealthStatus.atRisk);
        expect(
          evaluation.diagnosticReasons.any(
            (r) => r.contains(
              'final sales revenue fell short of forecast by 80.0%',
            ),
          ),
          isTrue,
        );
      },
    );

    test(
      'Boundary test: Clamps scores between 0 and 100 even in catastrophic conditions',
      () {
        final catastrophic = ProjectHealthEvaluation.compute(
          stage: ProjectLifecycleState.harvesting,
          plannedBudget: Money.fromMajor(1000),
          actualSpent: Money.fromMajor(5000), // 500% budget spent
          expectedRevenue: Money.fromMajor(5000),
          actualSales: Money.fromMajor(500),
          cashCollected: Money.zero(), // 100% receivables
          totalActivities: 10,
          overdueActivities: 10, // 100% overdue
        );

        expect(catastrophic.score, greaterThanOrEqualTo(0));
        expect(catastrophic.score, lessThanOrEqualTo(100));
        expect(catastrophic.breakdown.budgetDisciplineScore, 0.0);
        expect(catastrophic.breakdown.scheduleDriftScore, 10.0); // max(10, ...)
        expect(catastrophic.breakdown.creditRiskScore, 0.0);
        expect(catastrophic.status, ProjectHealthStatus.atRisk);
      },
    );

    test(
      'Delegation through FinancialCalculator.calculateProjectHealth works identically',
      () {
        final eval = FinancialCalculator.calculateProjectHealth(
          stage: ProjectLifecycleState.active,
          plannedBudget: Money.fromMajor(5000),
          actualSpent: Money.fromMajor(4000),
          expectedRevenue: Money.fromMajor(6000),
          actualSales: Money.fromMajor(4500),
          cashCollected: Money.fromMajor(4000),
          totalActivities: 4,
          overdueActivities: 0,
        );

        expect(eval.score, inInclusiveRange(0, 100));
        expect(eval.breakdown.compositeScore, eval.score);
      },
    );

    test(
      'Legacy FinancialCalculator.evaluateProjectHealth remains backward compatible',
      () {
        final legacy = FinancialCalculator.evaluateProjectHealth(
          plannedBudget: Money.fromMajor(10000),
          actualSpent: Money.fromMajor(3000),
          expectedRevenue: Money.fromMajor(10000),
          actualSales: Money.fromMajor(5000),
          collectedRevenue: Money.fromMajor(5000),
          scheduleProgressRatio: 1.0,
        );

        expect(legacy.status, ProjectHealthStatus.healthy);
        expect(legacy.score, greaterThanOrEqualTo(80));
      },
    );
  });
}
