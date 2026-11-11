import 'package:flutter/material.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../domain/models/project_with_farm.dart';
import '../../domain/state_machine/project_state_machine.dart';
import 'project_status_transition_dialog.dart';

/// Outdoor high-contrast card representing an active or completed agricultural venture.
class ProjectCard extends StatelessWidget {
  final ProjectWithFarm projectWithFarm;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.projectWithFarm,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Project get project => projectWithFarm.project;
  Farm? get farm => projectWithFarm.farm;

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'crop':
        return Icons.eco;
      case 'livestock':
        return Icons.pets;
      case 'aquaculture':
        return Icons.water;
      default:
        return Icons.agriculture;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'crop':
        return const Color(0xFF15803D);
      case 'livestock':
        return const Color(0xFFB45309);
      case 'aquaculture':
        return const Color(0xFF0369A1);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'crop':
        return const Color(0xFFDCFCE7);
      case 'livestock':
        return const Color(0xFFFEF3C7);
      case 'aquaculture':
        return const Color(0xFFE0F2FE);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commodityInfo = project.variety != null && project.variety!.isNotEmpty
        ? '${project.commodity} (${project.variety})'
        : project.commodity;
    final farmSubtitle = farm != null
        ? '$commodityInfo • ${farm!.name}'
        : '$commodityInfo • Unassigned Farm';

    final startDate = DateTime.fromMillisecondsSinceEpoch(project.startDate);
    final harvestDate = project.expectedFirstHarvestDate != null
        ? DateTime.fromMillisecondsSinceEpoch(project.expectedFirstHarvestDate!)
        : null;

    final formattedSize =
        project.landSize.truncateToDouble() == project.landSize
        ? project.landSize.toStringAsFixed(0)
        : project.landSize.toStringAsFixed(1);

    return AppCard(
      title: project.name,
      subtitle: farmSubtitle,
      leadingIcon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _getTypeBgColor(project.projectType),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getTypeIcon(project.projectType),
          color: _getTypeColor(project.projectType),
          size: 24,
        ),
      ),
      onTap: onTap,
      trailingAction: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Project actions',
        onSelected: (value) {
          if (value == 'edit') {
            onEdit?.call();
          } else if (value == 'delete') {
            onDelete?.call();
          } else if (value == 'stage') {
            ProjectStatusTransitionDialog.show(context, project: project);
          }
        },
        itemBuilder: (ctx) => [
          const PopupMenuItem(
            value: 'stage',
            child: Row(
              children: [
                Icon(Icons.alt_route, size: 20),
                SizedBox(width: 8),
                Text('Change Stage'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(width: 8),
                Text('Edit Project'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Project', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Project Lifecycle Status Badge
              AppStatusBadge.fromStatusString(context, project.status),

              // Land / Flock Size Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    120,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.straighten, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedSize ${project.landUnit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Lifecycle Stage Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ProjectLifecycleStateStateMachineX.parse(
                project.status,
              ).progressFraction,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _getTypeColor(project.projectType),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Timeline Information Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Started: ${startDate.toDisplayDate()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(200),
                    ),
                  ),
                ],
              ),
              if (harvestDate != null)
                Row(
                  children: [
                    const Icon(
                      Icons.event_available_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Harvest: ${harvestDate.toDisplayDate()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(200),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
