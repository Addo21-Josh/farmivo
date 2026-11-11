import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/state_machine/project_state_machine.dart';
import '../providers/project_providers.dart';

/// Interactive modal allowing farmers to transition project stages with domain validations and audit logging.
class ProjectStatusTransitionDialog extends ConsumerStatefulWidget {
  final Project project;
  final ProjectLifecycleState? preselectedTarget;

  const ProjectStatusTransitionDialog({
    super.key,
    required this.project,
    this.preselectedTarget,
  });

  /// Static helper to display the transition dialog easily.
  static Future<bool?> show(
    BuildContext context, {
    required Project project,
    ProjectLifecycleState? preselectedTarget,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ProjectStatusTransitionDialog(
        project: project,
        preselectedTarget: preselectedTarget,
      ),
    );
  }

  @override
  ConsumerState<ProjectStatusTransitionDialog> createState() =>
      _ProjectStatusTransitionDialogState();
}

class _ProjectStatusTransitionDialogState
    extends ConsumerState<ProjectStatusTransitionDialog> {
  late ProjectLifecycleState _currentState;
  late List<ProjectLifecycleState> _allowedNextStates;
  ProjectLifecycleState? _selectedTarget;
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentState = ProjectLifecycleStateStateMachineX.parse(
      widget.project.status,
    );
    _allowedNextStates = ProjectStateMachine.getAllowedNextStates(
      _currentState,
    );

    if (widget.preselectedTarget != null &&
        _allowedNextStates.contains(widget.preselectedTarget)) {
      _selectedTarget = widget.preselectedTarget;
    } else if (_allowedNextStates.isNotEmpty) {
      _selectedTarget = _allowedNextStates.first;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitTransition() async {
    if (_selectedTarget == null) return;
    if (!_formKey.currentState!.validate()) return;

    final reason = _reasonController.text.trim();
    final controller = ref.read(projectControllerProvider.notifier);

    final success = await controller.updateStatus(
      widget.project.id,
      _selectedTarget!.code,
      reason: reason.isNotEmpty ? reason : null,
    );

    if (mounted) {
      Navigator.of(context).pop(success);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Project stage updated to ${_selectedTarget!.displayName}.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update project stage.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOperating = ref.watch(projectControllerProvider).isLoading;

    final validation = _selectedTarget != null
        ? ProjectStateMachine.validateTransition(
            project: widget.project,
            targetState: _selectedTarget!,
          )
        : const TransitionValidation.permitted();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.alt_route, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Change Project Stage'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current stage pill
              Text(
                'Current Stage:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _currentState.stageIcon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentState.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _currentState.stageDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Target stage selection
              Text(
                'Select Next Stage:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),

              if (_allowedNextStates.isEmpty)
                const Text(
                  'No further stage transitions available for this project.',
                )
              else
                RadioGroup<ProjectLifecycleState>(
                  groupValue: _selectedTarget,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedTarget = val);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _allowedNextStates.map((state) {
                      final isSelected = _selectedTarget == state;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withAlpha(50)
                              : theme.colorScheme.surfaceContainerHighest
                                    .withAlpha(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: RadioListTile<ProjectLifecycleState>(
                            value: state,
                            secondary: Icon(
                              state.stageIcon,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(
                              state.displayName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              state.stageDescription,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Warning alert box if applicable
              if (validation.hasWarning &&
                  validation.warningMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD97706)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          validation.warningMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Audit reason input if rollback or archive
              if (validation.requiresReason) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Stage Change *',
                    hintText:
                        'e.g. Field inspection required replanning / pest damage',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (val) {
                    if (validation.requiresReason &&
                        (val == null || val.trim().isEmpty)) {
                      return 'Please provide a reason for this transition.';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isOperating
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
          onPressed:
              isOperating || _selectedTarget == null || !validation.isPermitted
              ? null
              : _submitTransition,
          child: isOperating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm Stage'),
        ),
      ],
    );
  }
}
