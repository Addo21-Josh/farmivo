import 'dart:math';

import '../constants/app_constants.dart';
import '../money/money.dart';

/// Breakdown of the 5 weighted health criteria scores (0 to 100 each):
/// 1. Budget Discipline (30% weight)
/// 2. Revenue Performance (25% weight)
/// 3. Cash Liquidity (20% weight)
/// 4. Operational Schedule Drift (15% weight)
/// 5. Credit Risk (10% weight)
class ProjectHealthBreakdown {
  final double budgetDisciplineScore;
  final double revenuePerformanceScore;
  final double cashLiquidityScore;
  final double scheduleDriftScore;
  final double creditRiskScore;

  const ProjectHealthBreakdown({
    required this.budgetDisciplineScore,
    required this.revenuePerformanceScore,
    required this.cashLiquidityScore,
    required this.scheduleDriftScore,
    required this.creditRiskScore,
  });

  /// Factory creating default perfect scores.
  factory ProjectHealthBreakdown.perfect() {
    return const ProjectHealthBreakdown(
      budgetDisciplineScore: 100.0,
      revenuePerformanceScore: 100.0,
      cashLiquidityScore: 100.0,
      scheduleDriftScore: 100.0,
      creditRiskScore: 100.0,
    );
  }

  /// Weighted composite score calculated according to PRD & Roadmap weightings:
  /// (0.30 * Budget) + (0.25 * Revenue) + (0.20 * Liquidity) + (0.15 * Schedule) + (0.10 * Credit Risk)
  int get compositeScore {
    final raw =
        (0.30 * budgetDisciplineScore) +
        (0.25 * revenuePerformanceScore) +
        (0.20 * cashLiquidityScore) +
        (0.15 * scheduleDriftScore) +
        (0.10 * creditRiskScore);
    return raw.round().clamp(0, 100);
  }
}

/// Comprehensive project health evaluation resulting from algorithmic evaluation.
class ProjectHealthEvaluation {
  /// Composite health score on an integer scale from 0 to 100.
  final int score;

  /// Categorical health rating: healthy (>=80), watch (60-79), atRisk (<60).
  final ProjectHealthStatus status;

  /// Human-readable explanation synthesizing financial, schedule, and credit reasons.
  final String summary;

  /// Detailed score breakdown across the 5 weighted criteria.
  final ProjectHealthBreakdown breakdown;

  /// List of specific diagnostic factors triggering score penalties or confirming stability.
  final List<String> diagnosticReasons;

  const ProjectHealthEvaluation({
    required this.score,
    required this.status,
    required this.summary,
    required this.breakdown,
    required this.diagnosticReasons,
  });

  /// True if project has high financial and agronomic health (score >= 80).
  bool get isHealthy => status == ProjectHealthStatus.healthy;

  /// True if project is on watch (60 <= score <= 79).
  bool get isWatch => status == ProjectHealthStatus.watch;

  /// True if project is at risk (score < 60).
  bool get isAtRisk => status == ProjectHealthStatus.atRisk;

  /// Formatted badge label with score (e.g. "HEALTHY (88/100)").
  String get badgeLabel => '${status.label.toUpperCase()} ($score/100)';

  /// Factory computing the full 5-criteria algorithmic health score.
  factory ProjectHealthEvaluation.compute({
    required Money plannedBudget,
    required Money actualSpent,
    required Money expectedRevenue,
    required Money actualSales,
    required Money cashCollected,
    ProjectLifecycleState stage = ProjectLifecycleState.production,
    int totalActivities = 0,
    int completedActivities = 0,
    int overdueActivities = 0,
    double? scheduleProgressRatio,
  }) {
    final reasons = <String>[];

    // =========================================================================
    // 1. Budget Discipline (Weight: 30%)
    // =========================================================================
    double budgetScore = 100.0;
    if (plannedBudget.isPositive) {
      final spentRatio = actualSpent.toMajor() / plannedBudget.toMajor();
      if (spentRatio > 1.0) {
        final overrunPct = (spentRatio - 1.0) * 100.0;
        // Severe penalty for budget breaches
        budgetScore = max(0.0, 50.0 - (overrunPct * 2.0));
        reasons.add(
          'Budget overrun by ${overrunPct.toStringAsFixed(1)}% (expenditures are above budget)',
        );
      } else if (spentRatio >= 0.80) {
        // High capital utilization caution (>= 80% triggers watch score)
        budgetScore = max(40.0, 68.0 - ((spentRatio - 0.80) * 100.0));
        reasons.add(
          'Capital utilization at ${(spentRatio * 100).toStringAsFixed(1)}% of planned budget',
        );
      } else {
        budgetScore = 100.0;
      }
    } else {
      if (actualSpent.isPositive) {
        if (actualSales >= actualSpent) {
          budgetScore = 90.0;
        } else {
          budgetScore = 40.0;
          reasons.add(
            'unbudgeted operational spending incurred without an active pre-season budget',
          );
        }
      } else if (stage == ProjectLifecycleState.planning) {
        budgetScore = 80.0; // Budgeting pending
      }
    }

    // =========================================================================
    // 2. Revenue Performance (Weight: 25%)
    // =========================================================================
    double revenueScore = 100.0;
    final isHarvestOrLater =
        stage == ProjectLifecycleState.harvesting ||
        stage == ProjectLifecycleState.selling ||
        stage == ProjectLifecycleState.completed ||
        stage == ProjectLifecycleState.archived;

    if (!isHarvestOrLater) {
      // Early agronomic stages: sales not yet expected
      revenueScore = 100.0;
    } else {
      if (expectedRevenue.isPositive) {
        final revRatio = actualSales.toMajor() / expectedRevenue.toMajor();
        if (revRatio >= 1.0) {
          revenueScore = 100.0;
        } else {
          if (stage == ProjectLifecycleState.completed ||
              stage == ProjectLifecycleState.archived) {
            revenueScore = max(0.0, revRatio * 100.0);
            final shortfallPct = ((1.0 - revRatio) * 100.0).toStringAsFixed(1);
            reasons.add(
              'final sales revenue fell short of forecast by $shortfallPct%',
            );
          } else {
            // In-season harvesting/selling: partial progress
            revenueScore = max(50.0, revRatio * 100.0);
            if (revRatio < 0.40) {
              reasons.add(
                'commercial sales tracking behind seasonal revenue projection',
              );
            }
          }
        }
      } else {
        // No forecast set
        revenueScore = actualSales.isPositive ? 100.0 : 80.0;
      }
    }

    // =========================================================================
    // 3. Cash Liquidity (Weight: 20%)
    // =========================================================================
    double liquidityScore = 100.0;
    if (actualSpent.isPositive) {
      if (cashCollected >= actualSpent) {
        // Liquid cash break-even achieved: 100%
        liquidityScore = 100.0;
      } else {
        if (!isHarvestOrLater) {
          // Pre-harvest: evaluate whether spending is within budget cushion
          if (plannedBudget.isPositive && actualSpent <= plannedBudget) {
            final spentRatio = actualSpent.toMajor() / plannedBudget.toMajor();
            liquidityScore = max(50.0, 85.0 - (spentRatio * 40.0));
          } else {
            final overrunPct = plannedBudget.isPositive
                ? ((actualSpent.toMajor() / plannedBudget.toMajor()) - 1.0) *
                      100.0
                : 20.0;
            liquidityScore = max(10.0, 40.0 - (overrunPct * 1.5));
            reasons.add(
              'capital buffer breached before harvest without sales collection',
            );
          }
        } else {
          final recoveryRatio = cashCollected.toMajor() / actualSpent.toMajor();
          liquidityScore = min(100.0, max(20.0, recoveryRatio * 100.0));
          if (liquidityScore < 50.0) {
            final recPct = (recoveryRatio * 100.0).toStringAsFixed(0);
            reasons.add(
              'liquid cash covers only $recPct% of incurred expenditures',
            );
          }
        }
      }
    } else {
      liquidityScore = 100.0;
    }

    // =========================================================================
    // 4. Operational Schedule Drift (Weight: 15%)
    // =========================================================================
    double scheduleScore = 100.0;
    if (scheduleProgressRatio != null) {
      scheduleScore = min(100.0, max(0.0, scheduleProgressRatio * 100.0));
    } else if (totalActivities > 0) {
      if (overdueActivities > 0) {
        scheduleScore = max(10.0, 100.0 - (overdueActivities * 25.0));
        reasons.add(
          overdueActivities == 1
              ? '1 field agronomic activity is overdue'
              : '$overdueActivities field agronomic activities are overdue',
        );
      } else {
        scheduleScore = 100.0;
      }
    } else {
      scheduleScore = stage == ProjectLifecycleState.planning ? 90.0 : 85.0;
    }

    // =========================================================================
    // 5. Credit Risk (Weight: 10%)
    // =========================================================================
    double creditRiskScore = 100.0;
    if (actualSales.isPositive) {
      final receivables = actualSales > cashCollected
          ? actualSales - cashCollected
          : Money.zero();
      final receivablesRatio = receivables.toMajor() / actualSales.toMajor();

      if (receivablesRatio <= 0.10) {
        creditRiskScore = 100.0;
      } else {
        creditRiskScore = max(0.0, 100.0 - ((receivablesRatio - 0.10) * 115.0));
        if (receivablesRatio >= 0.25) {
          final uncollectedPct = (receivablesRatio * 100.0).toStringAsFixed(1);
          reasons.add(
            '$uncollectedPct% of sales remain uncollected in buyer credit',
          );
        }
      }
    } else {
      creditRiskScore = 100.0;
    }

    final breakdown = ProjectHealthBreakdown(
      budgetDisciplineScore: budgetScore,
      revenuePerformanceScore: revenueScore,
      cashLiquidityScore: liquidityScore,
      scheduleDriftScore: scheduleScore,
      creditRiskScore: creditRiskScore,
    );

    final compositeScore = breakdown.compositeScore;

    // Status assignment
    final ProjectHealthStatus status;
    if (compositeScore >= 80) {
      status = ProjectHealthStatus.healthy;
    } else if (compositeScore >= 60) {
      status = ProjectHealthStatus.watch;
    } else {
      status = ProjectHealthStatus.atRisk;
    }

    // Explicit explanation synthesis
    final String summary;
    if (reasons.isNotEmpty) {
      summary =
          'Project is ${status.label} (Score: $compositeScore/100) because ${reasons.join(' and ')}.';
    } else {
      if (status == ProjectHealthStatus.healthy) {
        summary = actualSales.isPositive && actualSales >= actualSpent
            ? 'Project is Healthy (Score: $compositeScore/100): Venture is fully profitable with strong budget and revenue discipline.'
            : 'Project is Healthy (Score: $compositeScore/100): Operations and expenditures are proceeding within planned targets.';
      } else if (status == ProjectHealthStatus.watch) {
        summary =
            'Project is on Watch (Score: $compositeScore/100): Moderate deviations detected across operational or financial benchmarks.';
      } else {
        summary =
            'Project is At Risk (Score: $compositeScore/100): Multiple financial deviations require immediate intervention.';
      }
    }

    return ProjectHealthEvaluation(
      score: compositeScore,
      status: status,
      summary: summary,
      breakdown: breakdown,
      diagnosticReasons: reasons,
    );
  }
}
