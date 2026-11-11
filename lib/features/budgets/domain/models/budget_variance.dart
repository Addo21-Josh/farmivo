import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import 'budget_item_with_category.dart';
import 'budget_tracking.dart';

/// Automated budget variance alert levels based on capital utilization thresholds.
enum BudgetVarianceThreshold {
  /// Category / item expenditure is within safe limits (<80%).
  healthy,

  /// 🟡 Warning: Expenditure reaches or exceeds 80% of allocation.
  warning,

  /// 🟠 Critical: Expenditure has completely exhausted 100% of allocation.
  critical,

  /// 🔴 Overrun: Expenditure exceeds planned budget (>100%).
  overrun;

  /// User-friendly label for display.
  String get displayName {
    switch (this) {
      case BudgetVarianceThreshold.healthy:
        return 'Healthy';
      case BudgetVarianceThreshold.warning:
        return 'Warning (≥80%)';
      case BudgetVarianceThreshold.critical:
        return 'Exhausted (100%)';
      case BudgetVarianceThreshold.overrun:
        return 'Overrun (>100%)';
    }
  }

  /// Whether this threshold represents an actionable alert.
  bool get isAlert => this != BudgetVarianceThreshold.healthy;

  /// Resolves the alert threshold given planned allocation and actual spending.
  static BudgetVarianceThreshold resolve({
    required Money planned,
    required Money actual,
  }) {
    if (!planned.isPositive) {
      return actual.isPositive
          ? BudgetVarianceThreshold.overrun
          : BudgetVarianceThreshold.healthy;
    }

    final ratio = actual.toMajor() / planned.toMajor();

    if (ratio > 1.0) {
      return BudgetVarianceThreshold.overrun;
    } else if (actual == planned || (ratio >= 0.9999 && ratio <= 1.0)) {
      return BudgetVarianceThreshold.critical;
    } else if (ratio >= 0.8) {
      return BudgetVarianceThreshold.warning;
    }

    return BudgetVarianceThreshold.healthy;
  }
}

/// Variance calculation and alert tracking for an individual budget line item.
class ItemVariance {
  final BudgetItemWithCategory itemWithCategory;
  final Money actualSpent;
  final int transactionCount;

  const ItemVariance({
    required this.itemWithCategory,
    required this.actualSpent,
    this.transactionCount = 0,
  });

  /// The underlying budget line item.
  BudgetItem get item => itemWithCategory.item;

  /// The parent budget category.
  BudgetCategory get category => itemWithCategory.category;

  /// Pre-season planned allocation.
  Money get plannedAmount => itemWithCategory.plannedAmount;

  /// Variance = Actual - Planned (positive = over budget, negative = under budget).
  Money get variance => actualSpent - plannedAmount;

  /// Variance % = (Variance / Planned) * 100.
  double get variancePercentage {
    if (!plannedAmount.isPositive) return actualSpent.isPositive ? 100.0 : 0.0;
    return (variance.toMajor() / plannedAmount.toMajor()) * 100.0;
  }

  /// Capital utilization ratio = (Actual / Planned) * 100.
  double get spentPercentage {
    if (!plannedAmount.isPositive) return actualSpent.isPositive ? 100.0 : 0.0;
    return (actualSpent.toMajor() / plannedAmount.toMajor()) * 100.0;
  }

  /// Automated threshold alert status.
  BudgetVarianceThreshold get threshold => BudgetVarianceThreshold.resolve(
    planned: plannedAmount,
    actual: actualSpent,
  );

  /// Explanatory message for farmer guidance.
  String get alertMessage {
    switch (threshold) {
      case BudgetVarianceThreshold.overrun:
        return 'Overrun by ${variance.format()} (+${variancePercentage.toStringAsFixed(1)}%)';
      case BudgetVarianceThreshold.critical:
        return 'Allocation exhausted (100% spent)';
      case BudgetVarianceThreshold.warning:
        return 'Warning: ${spentPercentage.toStringAsFixed(0)}% spent (${(plannedAmount - actualSpent).format()} remaining)';
      case BudgetVarianceThreshold.healthy:
        return '${(plannedAmount - actualSpent).format()} remaining (${spentPercentage.toStringAsFixed(0)}% spent)';
    }
  }
}

/// Category-level variance analysis and automated threshold alert.
class CategoryVariance {
  final BudgetCategory category;
  final List<ItemVariance> itemVariances;
  final Money plannedAmount;
  final Money actualSpent;
  final int transactionCount;
  final double percentageOfTotalBudget;

  const CategoryVariance({
    required this.category,
    required this.itemVariances,
    required this.plannedAmount,
    required this.actualSpent,
    required this.transactionCount,
    required this.percentageOfTotalBudget,
  });

  /// Variance = Actual - Planned.
  Money get variance => actualSpent - plannedAmount;

  /// Variance % = (Variance / Planned) * 100.
  double get variancePercentage {
    if (!plannedAmount.isPositive) return actualSpent.isPositive ? 100.0 : 0.0;
    return (variance.toMajor() / plannedAmount.toMajor()) * 100.0;
  }

  /// Capital spent ratio = (Actual / Planned) * 100.
  double get spentPercentage {
    if (!plannedAmount.isPositive) return actualSpent.isPositive ? 100.0 : 0.0;
    return (actualSpent.toMajor() / plannedAmount.toMajor()) * 100.0;
  }

  /// Automated category threshold alert status.
  BudgetVarianceThreshold get threshold => BudgetVarianceThreshold.resolve(
    planned: plannedAmount,
    actual: actualSpent,
  );

  /// Guidance message for category status.
  String get alertMessage {
    switch (threshold) {
      case BudgetVarianceThreshold.overrun:
        return 'Category overrun by ${variance.format()} (+${variancePercentage.toStringAsFixed(1)}%)';
      case BudgetVarianceThreshold.critical:
        return 'Category budget completely exhausted (100%)';
      case BudgetVarianceThreshold.warning:
        return 'Warning: ${spentPercentage.toStringAsFixed(0)}% spent (${(plannedAmount - actualSpent).format()} remaining)';
      case BudgetVarianceThreshold.healthy:
        return '${(plannedAmount - actualSpent).format()} remaining (${spentPercentage.toStringAsFixed(0)}% spent)';
    }
  }

  /// Unlinked spending within this category.
  Money get unlinkedSpent {
    BigInt itemSpentMinor = BigInt.zero;
    for (final it in itemVariances) {
      itemSpentMinor += it.actualSpent.minorUnits;
    }
    final diff = actualSpent.minorUnits - itemSpentMinor;
    return Money(
      diff > BigInt.zero ? diff : BigInt.zero,
      currency: actualSpent.currency,
    );
  }
}

/// Comprehensive project-level variance report aggregating planned vs actual
/// performance across all categories and line items.
class ProjectVarianceReport {
  final String projectId;
  final String currency;
  final Money totalPlanned;
  final Money totalSpent;
  final List<CategoryVariance> categories;
  final int totalTransactionsCount;

  const ProjectVarianceReport({
    required this.projectId,
    required this.currency,
    required this.totalPlanned,
    required this.totalSpent,
    required this.categories,
    required this.totalTransactionsCount,
  });

  /// Overall Variance = Total Actual - Total Planned.
  Money get variance => totalSpent - totalPlanned;

  /// Variance % = (Variance / Total Planned) * 100.
  double get variancePercentage {
    if (!totalPlanned.isPositive) return totalSpent.isPositive ? 100.0 : 0.0;
    return (variance.toMajor() / totalPlanned.toMajor()) * 100.0;
  }

  /// Overall capital spent ratio = (Total Actual / Total Planned) * 100.
  double get spentPercentage {
    if (!totalPlanned.isPositive) return totalSpent.isPositive ? 100.0 : 0.0;
    return (totalSpent.toMajor() / totalPlanned.toMajor()) * 100.0;
  }

  /// Overall project alert threshold.
  BudgetVarianceThreshold get overallThreshold =>
      BudgetVarianceThreshold.resolve(
        planned: totalPlanned,
        actual: totalSpent,
      );

  /// Categories that have reached warning (≥80%), critical (100%), or overrun (>100%).
  List<CategoryVariance> get categoriesAtRisk =>
      categories.where((c) => c.threshold.isAlert).toList();

  /// Budget line items that have reached warning (≥80%), critical (100%), or overrun (>100%).
  List<ItemVariance> get itemsAtRisk => categories
      .expand((c) => c.itemVariances)
      .where((i) => i.threshold.isAlert)
      .toList();

  /// Count of categories or items currently in overrun.
  int get overrunCount => categories
      .where((c) => c.threshold == BudgetVarianceThreshold.overrun)
      .length;

  /// Count of categories or items currently in warning or critical status.
  int get warningCount => categories
      .where(
        (c) =>
            c.threshold == BudgetVarianceThreshold.warning ||
            c.threshold == BudgetVarianceThreshold.critical,
      )
      .length;

  /// Whether the project has any budget warnings or overruns.
  bool get hasAlerts => categoriesAtRisk.isNotEmpty || itemsAtRisk.isNotEmpty;

  /// Factory computing the variance report directly from a [ProjectBudgetTracking] instance.
  factory ProjectVarianceReport.fromTracking(ProjectBudgetTracking tracking) {
    final catVariances = tracking.categories.map((catTrack) {
      final itemVars = catTrack.items.map((it) {
        return ItemVariance(
          itemWithCategory: it.itemWithCategory,
          actualSpent: it.actualSpent,
          transactionCount: it.transactionCount,
        );
      }).toList();

      return CategoryVariance(
        category: catTrack.category,
        itemVariances: itemVars,
        plannedAmount: catTrack.plannedAmount,
        actualSpent: catTrack.actualSpent,
        transactionCount: catTrack.transactionCount,
        percentageOfTotalBudget: catTrack.percentageOfTotalBudget,
      );
    }).toList();

    return ProjectVarianceReport(
      projectId: tracking.projectId,
      currency: tracking.currency,
      totalPlanned: tracking.totalPlanned,
      totalSpent: tracking.totalSpent,
      categories: catVariances,
      totalTransactionsCount: tracking.totalTransactionsCount,
    );
  }
}
