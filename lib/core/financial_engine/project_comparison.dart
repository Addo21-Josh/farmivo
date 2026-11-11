import '../constants/app_constants.dart';
import '../money/money.dart';

/// Single project's comparative performance record across standard agronomic & financial metrics.
class ProjectComparisonRecord {
  final String projectId;
  final String projectName;
  final String commodity;
  final String? variety;
  final String? farmName;
  final ProjectLifecycleState stage;
  final String status;
  final double landSize;
  final String landUnit;
  final Money plannedBudget;
  final Money capitalInvested;
  final Money totalRevenue;
  final Money netProfit;
  final double roiPercentage;
  final int cycleDurationDays;
  final Money profitPerLandUnit;
  final Money capitalPerLandUnit;
  final int healthScore;
  final ProjectHealthStatus healthStatus;

  const ProjectComparisonRecord({
    required this.projectId,
    required this.projectName,
    required this.commodity,
    this.variety,
    this.farmName,
    required this.stage,
    required this.status,
    required this.landSize,
    required this.landUnit,
    required this.plannedBudget,
    required this.capitalInvested,
    required this.totalRevenue,
    required this.netProfit,
    required this.roiPercentage,
    required this.cycleDurationDays,
    required this.profitPerLandUnit,
    required this.capitalPerLandUnit,
    required this.healthScore,
    required this.healthStatus,
  });

  String get formattedLand =>
      '${landSize % 1 == 0 ? landSize.toInt() : landSize.toStringAsFixed(1)} $landUnit';

  String get stageLabel => stage.displayName;

  String get healthBadge =>
      '${healthStatus.label.toUpperCase()} ($healthScore/100)';

  /// Creates a comparison record from project attributes and metrics.
  factory ProjectComparisonRecord.compute({
    required String projectId,
    required String projectName,
    required String commodity,
    String? variety,
    String? farmName,
    required ProjectLifecycleState stage,
    required String status,
    required double landSize,
    String landUnit = 'Acres',
    required Money plannedBudget,
    required Money actualSpent,
    required Money actualSales,
    required int daysActive,
    int? healthScore,
    ProjectHealthStatus? healthStatus,
    String currency = 'GHS',
  }) {
    final netProfit = actualSales - actualSpent;

    double roi = 0.0;
    if (actualSpent.isPositive) {
      roi = (netProfit.toMajor() / actualSpent.toMajor()) * 100.0;
    }

    // Profit and capital per land unit calculations with zero-division guard
    Money profitPerUnit;
    Money capitalPerUnit;
    if (landSize > 0.001) {
      final profitMinor = (netProfit.minorUnits.toDouble() / landSize).round();
      profitPerUnit = Money(BigInt.from(profitMinor), currency: currency);

      final capitalMinor = (actualSpent.minorUnits.toDouble() / landSize)
          .round();
      capitalPerUnit = Money(BigInt.from(capitalMinor), currency: currency);
    } else {
      profitPerUnit = Money.zero(currency: currency);
      capitalPerUnit = Money.zero(currency: currency);
    }

    final resolvedScore = healthScore ?? 80;
    final resolvedStatus =
        healthStatus ??
        (resolvedScore >= 80
            ? ProjectHealthStatus.healthy
            : (resolvedScore >= 60
                  ? ProjectHealthStatus.watch
                  : ProjectHealthStatus.atRisk));

    return ProjectComparisonRecord(
      projectId: projectId,
      projectName: projectName,
      commodity: commodity,
      variety: variety,
      farmName: farmName,
      stage: stage,
      status: status,
      landSize: landSize,
      landUnit: landUnit,
      plannedBudget: plannedBudget,
      capitalInvested: actualSpent,
      totalRevenue: actualSales,
      netProfit: netProfit,
      roiPercentage: (roi * 10).round() / 10.0,
      cycleDurationDays: daysActive,
      profitPerLandUnit: profitPerUnit,
      capitalPerLandUnit: capitalPerUnit,
      healthScore: resolvedScore,
      healthStatus: resolvedStatus,
    );
  }
}

/// Side-by-side comparative matrix benchmarking multiple agricultural ventures (Milestone 7.5).
class ProjectComparisonMatrix {
  final List<ProjectComparisonRecord> records;
  final Money totalCapitalInvested;
  final Money totalRevenue;
  final Money totalNetProfit;
  final double averageRoiPercentage;
  final ProjectComparisonRecord? bestRoiProject;
  final ProjectComparisonRecord? mostProfitableProject;
  final ProjectComparisonRecord? highestRevenueProject;
  final ProjectComparisonRecord? mostCapitalEfficientProject;
  final String summaryDiagnosis;

  const ProjectComparisonMatrix({
    required this.records,
    required this.totalCapitalInvested,
    required this.totalRevenue,
    required this.totalNetProfit,
    required this.averageRoiPercentage,
    this.bestRoiProject,
    this.mostProfitableProject,
    this.highestRevenueProject,
    this.mostCapitalEfficientProject,
    required this.summaryDiagnosis,
  });

  /// Factory computing comparative benchmarks across provided project records.
  factory ProjectComparisonMatrix.compute(
    List<ProjectComparisonRecord> records, {
    String currency = 'GHS',
  }) {
    if (records.isEmpty) {
      return ProjectComparisonMatrix(
        records: const [],
        totalCapitalInvested: Money.zero(currency: currency),
        totalRevenue: Money.zero(currency: currency),
        totalNetProfit: Money.zero(currency: currency),
        averageRoiPercentage: 0.0,
        summaryDiagnosis: 'No projects selected for comparison.',
      );
    }

    Money totalCapital = Money.zero(currency: currency);
    Money totalRev = Money.zero(currency: currency);
    Money totalProfit = Money.zero(currency: currency);
    double roiSum = 0.0;

    ProjectComparisonRecord? bestRoi;
    ProjectComparisonRecord? mostProfitable;
    ProjectComparisonRecord? highestRevenue;
    ProjectComparisonRecord? mostCapitalEfficient;

    for (final r in records) {
      totalCapital = totalCapital + r.capitalInvested;
      totalRev = totalRev + r.totalRevenue;
      totalProfit = totalProfit + r.netProfit;
      roiSum += r.roiPercentage;

      if (bestRoi == null || r.roiPercentage > bestRoi.roiPercentage) {
        bestRoi = r;
      }

      if (mostProfitable == null || r.netProfit > mostProfitable.netProfit) {
        mostProfitable = r;
      }

      if (highestRevenue == null ||
          r.totalRevenue > highestRevenue.totalRevenue) {
        highestRevenue = r;
      }

      if (r.landSize > 0) {
        if (mostCapitalEfficient == null ||
            r.profitPerLandUnit > mostCapitalEfficient.profitPerLandUnit) {
          mostCapitalEfficient = r;
        }
      }
    }

    final avgRoi = records.isNotEmpty
        ? ((roiSum / records.length) * 10).round() / 10.0
        : 0.0;

    // Synthesize clear, actionable comparative narrative
    final String summary;
    if (records.length == 1) {
      final p = records.first;
      summary =
          '${p.projectName} (${p.commodity}): ${p.formattedLand}, '
          'Invested ${p.capitalInvested.format()}, Generated ${p.totalRevenue.format()} '
          '(${p.roiPercentage >= 0 ? "+" : ""}${p.roiPercentage.toStringAsFixed(1)}% ROI).';
    } else {
      final buffer = StringBuffer();
      buffer.write('Across the ${records.length} compared ventures, ');

      if (bestRoi != null && bestRoi.roiPercentage > 0) {
        buffer.write(
          '${bestRoi.projectName} generated the highest ROI (+${bestRoi.roiPercentage.toStringAsFixed(1)}%) ',
        );
        if (mostProfitable != null &&
            mostProfitable.projectId != bestRoi.projectId) {
          buffer.write(
            'while ${mostProfitable.projectName} delivered the largest nominal profit (${mostProfitable.netProfit.format()}). ',
          );
        } else {
          buffer.write('with net profit of ${bestRoi.netProfit.format()}. ');
        }
      } else if (mostProfitable != null) {
        buffer.write(
          '${mostProfitable.projectName} performed best with net profit of ${mostProfitable.netProfit.format()}. ',
        );
      }

      if (mostCapitalEfficient != null &&
          mostCapitalEfficient.profitPerLandUnit.isPositive &&
          (mostCapitalEfficient.projectId != bestRoi?.projectId &&
              mostCapitalEfficient.projectId != mostProfitable?.projectId)) {
        buffer.write(
          '${mostCapitalEfficient.projectName} was the most land-efficient at ${mostCapitalEfficient.profitPerLandUnit.format()}/${mostCapitalEfficient.landUnit}.',
        );
      }

      summary = buffer.toString().trim();
    }

    return ProjectComparisonMatrix(
      records: records,
      totalCapitalInvested: totalCapital,
      totalRevenue: totalRev,
      totalNetProfit: totalProfit,
      averageRoiPercentage: avgRoi,
      bestRoiProject: bestRoi,
      mostProfitableProject: mostProfitable,
      highestRevenueProject: highestRevenue,
      mostCapitalEfficientProject: mostCapitalEfficient,
      summaryDiagnosis: summary,
    );
  }
}
