import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';

/// Aggregated yield metrics, quality grade breakdown, and projected yield comparison.
class HarvestYieldSummary {
  final String projectId;
  final double totalQuantity;
  final String unit;
  final int totalBatches;
  final Map<HarvestGrade, double> quantityByGrade;
  final double? projectedYield;
  final String? projectedYieldUnit;
  final double? landSize;
  final String? landUnit;

  const HarvestYieldSummary({
    required this.projectId,
    required this.totalQuantity,
    required this.unit,
    required this.totalBatches,
    required this.quantityByGrade,
    this.projectedYield,
    this.projectedYieldUnit,
    this.landSize,
    this.landUnit,
  });

  /// Factory providing an empty initial state.
  factory HarvestYieldSummary.empty({String projectId = ''}) {
    return HarvestYieldSummary(
      projectId: projectId,
      totalQuantity: 0.0,
      unit: '',
      totalBatches: 0,
      quantityByGrade: {for (final grade in HarvestGrade.values) grade: 0.0},
    );
  }

  double get gradeAQuantity => quantityByGrade[HarvestGrade.gradeA] ?? 0.0;
  double get gradeBQuantity => quantityByGrade[HarvestGrade.gradeB] ?? 0.0;
  double get rejectsQuantity => quantityByGrade[HarvestGrade.rejects] ?? 0.0;
  double get ungradedQuantity => quantityByGrade[HarvestGrade.ungraded] ?? 0.0;

  double get gradeAPercent =>
      totalQuantity > 0 ? (gradeAQuantity / totalQuantity) * 100.0 : 0.0;

  double get gradeBPercent =>
      totalQuantity > 0 ? (gradeBQuantity / totalQuantity) * 100.0 : 0.0;

  double get rejectsPercent =>
      totalQuantity > 0 ? (rejectsQuantity / totalQuantity) * 100.0 : 0.0;

  double get ungradedPercent =>
      totalQuantity > 0 ? (ungradedQuantity / totalQuantity) * 100.0 : 0.0;

  /// Percentage of pre-season target yield achieved so far.
  double? get yieldAchievementPercent {
    if (projectedYield == null || projectedYield! <= 0) return null;
    return (totalQuantity / projectedYield!) * 100.0;
  }

  /// Physical production per unit of land (e.g., Bags/Acre).
  double? get yieldPerAcre {
    if (landSize == null || landSize! <= 0) return null;
    return totalQuantity / landSize!;
  }

  /// Whether a valid pre-season projected yield is available for comparison.
  bool get hasProjectedYield => projectedYield != null && projectedYield! > 0;

  /// Whether actual harvest has met or surpassed projected expectations.
  bool get isAboveProjection =>
      yieldAchievementPercent != null && yieldAchievementPercent! >= 100.0;

  /// Clean string of total harvested quantity.
  String get formattedTotalQuantity => totalQuantity % 1 == 0
      ? totalQuantity.toInt().toString()
      : totalQuantity.toStringAsFixed(1);

  /// Clean string of projected harvest target.
  String? get formattedProjectedYield {
    if (projectedYield == null) return null;
    return projectedYield! % 1 == 0
        ? projectedYield!.toInt().toString()
        : projectedYield!.toStringAsFixed(1);
  }

  /// Formatted yield per unit of land (e.g., '45 Bags / Acre').
  String? get formattedYieldPerAcre {
    if (yieldPerAcre == null) return null;
    final qty = yieldPerAcre! % 1 == 0
        ? yieldPerAcre!.toInt().toString()
        : yieldPerAcre!.toStringAsFixed(1);
    final lUnit = landUnit ?? 'Acre';
    final u = unit.isNotEmpty ? unit : 'Units';
    return '$qty $u / $lUnit';
  }
}
