import 'package:flutter/material.dart';

import 'package:farmivo/app/theme/app_theme_extension.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_yield_summary.dart';
import 'package:farmivo/shared/widgets/app_card.dart';

/// Visual metrics card presenting cumulative production volume,
/// pre-season target achievement progress, density per acre, and quality grade distribution.
class HarvestYieldCard extends StatelessWidget {
  final HarvestYieldSummary summary;

  const HarvestYieldCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final totalDisplay = summary.totalQuantity > 0
        ? '${summary.formattedTotalQuantity} ${summary.unit}'
        : '0 ${summary.unit.isNotEmpty ? summary.unit : "Harvested"}';

    return AppCard(
      title: 'Total Harvest Production',
      subtitle: 'Cumulative physical inventory captured',
      leadingIcon: Icon(Icons.inventory_2_outlined, color: colors.healthGreen),
      trailingAction: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.healthGreenBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${summary.totalBatches} ${summary.totalBatches == 1 ? "Batch" : "Batches"}',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.healthGreen,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Primary Volume & Yield / Acre
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalDisplay,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.healthGreen,
                ),
              ),
              if (summary.formattedYieldPerAcre != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '(${summary.formattedYieldPerAcre})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // 2. Pre-Season Target Comparison (if forecast was established)
          if (summary.hasProjectedYield) ...[
            _buildTargetProgress(context, colors),
            const SizedBox(height: 16),
          ],

          // 3. Quality Grade Distribution
          if (summary.totalQuantity > 0) ...[
            Text(
              'Quality Breakdown',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.hintColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            _buildGradeDistributionBar(context),
            const SizedBox(height: 8),
            _buildGradePills(context),
          ] else ...[
            Text(
              'Record harvest lots as field produce is harvested to track yield totals and grading.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(180),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetProgress(BuildContext context, AppThemeExtension colors) {
    final theme = Theme.of(context);
    final percent = summary.yieldAchievementPercent ?? 0.0;
    final clampedRatio = (percent / 100.0).clamp(0.0, 1.0);
    final isSurpassed = percent >= 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pre-Season Target Achievement',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}% achieved',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSurpassed
                    ? colors.healthGreen
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clampedRatio,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isSurpassed ? colors.healthGreen : theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Target: ${summary.formattedProjectedYield} ${summary.projectedYieldUnit ?? summary.unit}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDistributionBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            if (summary.gradeAPercent > 0)
              Expanded(
                flex: (summary.gradeAPercent * 10).round().clamp(1, 1000),
                child: Container(color: HarvestGrade.gradeA.color),
              ),
            if (summary.gradeBPercent > 0)
              Expanded(
                flex: (summary.gradeBPercent * 10).round().clamp(1, 1000),
                child: Container(color: HarvestGrade.gradeB.color),
              ),
            if (summary.rejectsPercent > 0)
              Expanded(
                flex: (summary.rejectsPercent * 10).round().clamp(1, 1000),
                child: Container(color: HarvestGrade.rejects.color),
              ),
            if (summary.ungradedPercent > 0)
              Expanded(
                flex: (summary.ungradedPercent * 10).round().clamp(1, 1000),
                child: Container(color: HarvestGrade.ungraded.color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradePills(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (summary.gradeAQuantity > 0)
          _buildPill(
            HarvestGrade.gradeA,
            summary.gradeAQuantity,
            summary.gradeAPercent,
          ),
        if (summary.gradeBQuantity > 0)
          _buildPill(
            HarvestGrade.gradeB,
            summary.gradeBQuantity,
            summary.gradeBPercent,
          ),
        if (summary.rejectsQuantity > 0)
          _buildPill(
            HarvestGrade.rejects,
            summary.rejectsQuantity,
            summary.rejectsPercent,
          ),
        if (summary.ungradedQuantity > 0)
          _buildPill(
            HarvestGrade.ungraded,
            summary.ungradedQuantity,
            summary.ungradedPercent,
          ),
      ],
    );
  }

  Widget _buildPill(HarvestGrade grade, double quantity, double percent) {
    final qtyStr = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: grade.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '${grade.shortLabel}: $qtyStr ${summary.unit} (${percent.toStringAsFixed(0)}%)',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
