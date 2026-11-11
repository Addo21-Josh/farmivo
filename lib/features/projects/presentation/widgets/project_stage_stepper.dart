import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/state_machine/project_state_machine.dart';

/// Outdoor high-contrast visual stage tracker for agricultural project lifecycles.
class ProjectStageStepper extends StatelessWidget {
  final ProjectLifecycleState currentState;
  final ValueChanged<ProjectLifecycleState>? onStepTapped;

  const ProjectStageStepper({
    super.key,
    required this.currentState,
    this.onStepTapped,
  });

  static const List<ProjectLifecycleState> _progressiveStages = [
    ProjectLifecycleState.planning,
    ProjectLifecycleState.active,
    ProjectLifecycleState.production,
    ProjectLifecycleState.harvesting,
    ProjectLifecycleState.selling,
    ProjectLifecycleState.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArchived = currentState == ProjectLifecycleState.archived;
    final currentIdx = _progressiveStages.indexOf(currentState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isArchived)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF9CA3AF)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.archive_outlined,
                  size: 18,
                  color: Color(0xFF4B5563),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This project is currently ARCHIVED. Financial ledgers are sealed.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: List.generate(_progressiveStages.length, (index) {
              final stage = _progressiveStages[index];
              final isPassed = !isArchived && currentIdx > index;
              final isCurrent = !isArchived && currentIdx == index;
              final isAllowed = ProjectStateMachine.canTransition(
                currentState,
                stage,
              );

              return Row(
                children: [
                  GestureDetector(
                    onTap: isAllowed ? () => onStepTapped?.call(stage) : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPassed
                                ? const Color(0xFF15803D)
                                : (isCurrent
                                      ? theme.colorScheme.primary
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest),
                            border: Border.all(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : (isPassed
                                        ? const Color(0xFF15803D)
                                        : (isAllowed
                                              ? theme.colorScheme.primary
                                                    .withAlpha(120)
                                              : theme.dividerColor)),
                              width: isCurrent ? 2.5 : 1.5,
                            ),
                          ),
                          child: Icon(
                            isPassed ? Icons.check : stage.stageIcon,
                            size: 18,
                            color: isPassed || isCurrent
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color?.withAlpha(
                                    150,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : (isPassed
                                      ? const Color(0xFF15803D)
                                      : theme.textTheme.bodySmall?.color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < _progressiveStages.length - 1)
                    Container(
                      width: 24,
                      height: 2.5,
                      margin: const EdgeInsets.only(
                        bottom: 16,
                        left: 4,
                        right: 4,
                      ),
                      color: isPassed
                          ? const Color(0xFF15803D)
                          : theme.dividerColor.withAlpha(120),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
