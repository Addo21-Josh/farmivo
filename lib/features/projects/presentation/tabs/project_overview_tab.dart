import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../farms/presentation/providers/farm_providers.dart';
import '../../domain/models/project_metrics.dart';
import '../../domain/state_machine/project_state_machine.dart';
import '../widgets/project_stage_stepper.dart';
import '../widgets/project_status_transition_dialog.dart';

/// Primary overview dashboard displaying lifecycle progress, landholding details,
/// and quick operational actions.
class ProjectOverviewTab extends ConsumerWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectOverviewTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final farmAsync = ref.watch(farmDetailProvider(project.farmId));
    final farm = farmAsync.valueOrNull;

    final currentState = metrics.stage;
    final allowedNextStates = ProjectStateMachine.getAllowedNextStates(
      currentState,
    );
    final nextState = allowedNextStates.isNotEmpty
        ? allowedNextStates.first
        : null;

    final startDate = DateTime.fromMillisecondsSinceEpoch(project.startDate);
    final harvestDate = project.expectedFirstHarvestDate != null
        ? DateTime.fromMillisecondsSinceEpoch(project.expectedFirstHarvestDate!)
        : null;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      children: [
        // 1. Lifecycle Progress & Objective Card
        AppCard(
          title: 'Lifecycle Progress',
          subtitle:
              'Stage ${currentState.index + 1} of 7 • ${metrics.daysActive} days active',
          leadingIcon: Icon(
            currentState.stageIcon,
            color: theme.colorScheme.primary,
          ),
          trailingAction: AppStatusBadge.fromStatusString(
            context,
            project.status,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProjectStageStepper(
                currentState: currentState,
                onStepTapped: (target) {
                  ProjectStatusTransitionDialog.show(
                    context,
                    project: project,
                    preselectedTarget: target,
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    60,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Objective:',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentState.stageDescription,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (nextState != null &&
                        currentState != ProjectLifecycleState.archived) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(110, 48),
                        ),
                        onPressed: () {
                          ProjectStatusTransitionDialog.show(
                            context,
                            project: project,
                            preselectedTarget: nextState,
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: Text(nextState.displayName),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Venture Identity & Landholding Card
        AppCard(
          title: 'Venture & Landholding',
          subtitle: farm != null
              ? '${farm.name} • ${farm.region}'
              : 'Assigned Landholding',
          leadingIcon: const Icon(Icons.location_on_outlined),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DetailStat(
                      label: 'Commodity',
                      value: project.commodity,
                      subtitle: project.variety ?? 'Standard variety',
                    ),
                  ),
                  Expanded(
                    child: _DetailStat(
                      label: 'Production Size',
                      value: '${project.landSize} ${project.landUnit}',
                      subtitle: '${project.projectType} Venture',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailStat(
                      label: 'Start Date',
                      value: startDate.toDisplayDate(),
                      subtitle: '${metrics.daysActive} days active',
                    ),
                  ),
                  Expanded(
                    child: _DetailStat(
                      label: 'Target Harvest',
                      value: harvestDate != null
                          ? harvestDate.toDisplayDate()
                          : 'Not scheduled',
                      subtitle: harvestDate != null
                          ? '${harvestDate.difference(DateTime.now()).inDays} days remaining'
                          : 'TBD',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Financial Snapshot Summary Card
        AppCard(
          title: 'Financial Snapshot',
          subtitle: 'Capital allocation & revenue position',
          leadingIcon: const Icon(Icons.account_balance_outlined),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DetailStat(
                      label: 'Budget Allocated',
                      value: metrics.totalBudgeted.format(),
                      subtitle:
                          '${metrics.budgetSpentPercentage.toStringAsFixed(0)}% spent',
                    ),
                  ),
                  Expanded(
                    child: _DetailStat(
                      label: 'Actual Revenue',
                      value: metrics.totalRevenue.format(),
                      subtitle: metrics.unpaidReceivables.isPositive
                          ? '${metrics.unpaidReceivables.format()} pending'
                          : 'Fully collected',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Budget utilization linear progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: metrics.totalBudgeted.isPositive
                      ? (metrics.budgetSpentPercentage / 100.0).clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 8,
                  backgroundColor: theme.dividerColor.withAlpha(50),
                  color: metrics.budgetSpentPercentage > 100.0
                      ? colors.healthRed
                      : (metrics.budgetSpentPercentage >= 80.0
                            ? colors.healthYellow
                            : colors.healthGreen),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Position: ${metrics.netProfit.format()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: metrics.netProfit.isPositive
                          ? colors.cashIn
                          : (metrics.netProfit.isNegative
                                ? colors.cashOut
                                : null),
                    ),
                  ),
                  Text(
                    'ROI: ${metrics.roiPercentage >= 0 ? "+" : ""}${metrics.roiPercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 4. Notes & Observations Card if present
        if (project.description != null && project.description!.isNotEmpty ||
            project.notes != null && project.notes!.isNotEmpty)
          AppCard(
            title: 'Season Notes & Observations',
            leadingIcon: const Icon(Icons.notes_outlined),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.description != null &&
                    project.description!.isNotEmpty) ...[
                  Text(project.description!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                ],
                if (project.notes != null && project.notes!.isNotEmpty)
                  Text(
                    project.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                    ),
                  ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // 5. Quick Field Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUICK ACTIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      onPressed: () {
                        ProjectStatusTransitionDialog.show(
                          context,
                          project: project,
                        );
                      },
                      icon: const Icon(Icons.alt_route, size: 18),
                      label: const Text('Change Stage'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () =>
                          context.push('/projects/${project.id}/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Project'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
