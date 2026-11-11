import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/database/app_database.dart';

/// Extension adding state-machine capabilities, codes, and metadata to [ProjectLifecycleState].
extension ProjectLifecycleStateStateMachineX on ProjectLifecycleState {
  /// Standardized database string code.
  String get code {
    switch (this) {
      case ProjectLifecycleState.planning:
        return 'PLANNING';
      case ProjectLifecycleState.active:
        return 'ACTIVE';
      case ProjectLifecycleState.production:
        return 'PRODUCTION';
      case ProjectLifecycleState.harvesting:
        return 'HARVESTING';
      case ProjectLifecycleState.selling:
        return 'SELLING';
      case ProjectLifecycleState.completed:
        return 'COMPLETED';
      case ProjectLifecycleState.archived:
        return 'ARCHIVED';
    }
  }

  /// Parses a string code into a typed [ProjectLifecycleState] with safe fallback.
  static ProjectLifecycleState parse(String? raw) {
    if (raw == null) return ProjectLifecycleState.planning;
    final normalized = raw.trim().toUpperCase();
    switch (normalized) {
      case 'PLANNING':
        return ProjectLifecycleState.planning;
      case 'ACTIVE':
        return ProjectLifecycleState.active;
      case 'PRODUCTION':
        return ProjectLifecycleState.production;
      case 'HARVESTING':
        return ProjectLifecycleState.harvesting;
      case 'SELLING':
        return ProjectLifecycleState.selling;
      case 'COMPLETED':
        return ProjectLifecycleState.completed;
      case 'ARCHIVED':
        return ProjectLifecycleState.archived;
      default:
        return ProjectLifecycleState.planning;
    }
  }

  /// Visual progress completion fraction from 0.0 to 1.0.
  double get progressFraction {
    switch (this) {
      case ProjectLifecycleState.planning:
        return 0.15;
      case ProjectLifecycleState.active:
        return 0.30;
      case ProjectLifecycleState.production:
        return 0.50;
      case ProjectLifecycleState.harvesting:
        return 0.70;
      case ProjectLifecycleState.selling:
        return 0.85;
      case ProjectLifecycleState.completed:
      case ProjectLifecycleState.archived:
        return 1.0;
    }
  }

  /// Descriptive operational meaning of this stage.
  String get stageDescription {
    switch (this) {
      case ProjectLifecycleState.planning:
        return 'Designing pre-season budget, input selection, and break-even targets.';
      case ProjectLifecycleState.active:
        return 'Budget approved, capital deployed, and preliminary land work underway.';
      case ProjectLifecycleState.production:
        return 'Agronomic maintenance: planting, fertilizing, spraying, or livestock feeding.';
      case ProjectLifecycleState.harvesting:
        return 'Crop maturity reached or livestock ready for collection and harvesting.';
      case ProjectLifecycleState.selling:
        return 'Distributing harvest batches to buyers, invoicing, and collecting receivables.';
      case ProjectLifecycleState.completed:
        return 'All yields sold, financial accounts settled, and net profit reconciled.';
      case ProjectLifecycleState.archived:
        return 'Historical record audited and sealed against retroactive changes.';
    }
  }

  /// Recognizable Material icon for this stage.
  IconData get stageIcon {
    switch (this) {
      case ProjectLifecycleState.planning:
        return Icons.edit_note;
      case ProjectLifecycleState.active:
        return Icons.play_arrow;
      case ProjectLifecycleState.production:
        return Icons.grass;
      case ProjectLifecycleState.harvesting:
        return Icons.agriculture;
      case ProjectLifecycleState.selling:
        return Icons.storefront;
      case ProjectLifecycleState.completed:
        return Icons.task_alt;
      case ProjectLifecycleState.archived:
        return Icons.archive_outlined;
    }
  }
}

/// Result of evaluating a potential lifecycle transition.
class TransitionValidation {
  final bool isPermitted;
  final bool hasWarning;
  final String? warningMessage;
  final bool requiresReason;

  const TransitionValidation({
    required this.isPermitted,
    this.hasWarning = false,
    this.warningMessage,
    this.requiresReason = false,
  });

  const TransitionValidation.permitted()
    : isPermitted = true,
      hasWarning = false,
      warningMessage = null,
      requiresReason = false;

  const TransitionValidation.warning(
    String message, {
    this.requiresReason = false,
  }) : isPermitted = true,
       hasWarning = true,
       warningMessage = message;

  const TransitionValidation.blocked(String reason)
    : isPermitted = false,
      hasWarning = true,
      warningMessage = reason,
      requiresReason = false;
}

/// Automated system suggestion recommending that the farmer advance the project stage.
class ProjectStatusSuggestion {
  final ProjectLifecycleState suggestedState;
  final String reasonTitle;
  final String reasonDescription;

  const ProjectStatusSuggestion({
    required this.suggestedState,
    required this.reasonTitle,
    required this.reasonDescription,
  });
}

/// Deterministic Finite State Machine governing project lifecycles.
class ProjectStateMachine {
  ProjectStateMachine._();

  /// Returns the valid forward, rollback, and archival states allowed from [current].
  static List<ProjectLifecycleState> getAllowedNextStates(
    ProjectLifecycleState current,
  ) {
    switch (current) {
      case ProjectLifecycleState.planning:
        return [ProjectLifecycleState.active, ProjectLifecycleState.archived];
      case ProjectLifecycleState.active:
        return [
          ProjectLifecycleState.production,
          ProjectLifecycleState.planning,
          ProjectLifecycleState.archived,
        ];
      case ProjectLifecycleState.production:
        return [
          ProjectLifecycleState.harvesting,
          ProjectLifecycleState.active,
          ProjectLifecycleState.archived,
        ];
      case ProjectLifecycleState.harvesting:
        return [
          ProjectLifecycleState.selling,
          ProjectLifecycleState.production,
          ProjectLifecycleState.archived,
        ];
      case ProjectLifecycleState.selling:
        return [
          ProjectLifecycleState.completed,
          ProjectLifecycleState.harvesting,
          ProjectLifecycleState.archived,
        ];
      case ProjectLifecycleState.completed:
        return [ProjectLifecycleState.archived, ProjectLifecycleState.selling];
      case ProjectLifecycleState.archived:
        // Allows unarchiving/re-opening if archived inadvertently
        return [ProjectLifecycleState.active, ProjectLifecycleState.planning];
    }
  }

  /// Whether a direct transition from [from] to [to] is structurally allowed.
  static bool canTransition(
    ProjectLifecycleState from,
    ProjectLifecycleState to,
  ) {
    if (from == to) return false;
    return getAllowedNextStates(from).contains(to);
  }

  /// Validates a prospective status change against domain rules and operational data.
  static TransitionValidation validateTransition({
    required Project project,
    required ProjectLifecycleState targetState,
    int budgetItemCount = 0,
    int harvestCount = 0,
    int salesCount = 0,
    double unpaidReceivablesMinor = 0.0,
  }) {
    final currentState = ProjectLifecycleStateStateMachineX.parse(
      project.status,
    );

    if (currentState == targetState) {
      return const TransitionValidation.blocked(
        'The project is already in this stage.',
      );
    }

    if (!canTransition(currentState, targetState)) {
      return TransitionValidation.blocked(
        'Cannot directly transition from ${currentState.displayName} to ${targetState.displayName}.',
      );
    }

    // 1. Moving from PLANNING to ACTIVE without budget items
    if (currentState == ProjectLifecycleState.planning &&
        targetState == ProjectLifecycleState.active &&
        budgetItemCount == 0) {
      return const TransitionValidation.warning(
        'No pre-season budget items have been created yet. You can still activate the project and add budget items later.',
      );
    }

    // 2. Rolling backwards (e.g. SELLING -> HARVESTING or ACTIVE -> PLANNING)
    if (_isRollback(currentState, targetState)) {
      return TransitionValidation.warning(
        'Moving backwards from ${currentState.displayName} to ${targetState.displayName} will adjust the active tracking stage. Existing records will remain intact.',
        requiresReason: true,
      );
    }

    // 3. Moving from SELLING to COMPLETED with outstanding receivables
    if (currentState == ProjectLifecycleState.selling &&
        targetState == ProjectLifecycleState.completed &&
        unpaidReceivablesMinor > 0) {
      return const TransitionValidation.warning(
        'There are outstanding debtor balances / credit sales recorded. Completing the project will close the production cycle while receivables remain pending collection.',
        requiresReason: false,
      );
    }

    // 4. Moving to ARCHIVED
    if (targetState == ProjectLifecycleState.archived) {
      return const TransitionValidation.warning(
        'Archiving this project will seal historical ledgers and remove it from active operational views.',
        requiresReason: true,
      );
    }

    return const TransitionValidation.permitted();
  }

  /// Analyzes operational activity logs and detects if the system should suggest an advance.
  static ProjectStatusSuggestion? detectSuggestion({
    required Project project,
    int harvestCount = 0,
    int salesCount = 0,
    bool allHarvestSold = false,
  }) {
    final currentState = ProjectLifecycleStateStateMachineX.parse(
      project.status,
    );

    // Suggest HARVESTING when first harvest is recorded during PRODUCTION or ACTIVE
    if ((currentState == ProjectLifecycleState.production ||
            currentState == ProjectLifecycleState.active) &&
        harvestCount > 0) {
      return const ProjectStatusSuggestion(
        suggestedState: ProjectLifecycleState.harvesting,
        reasonTitle: 'Harvest Logged',
        reasonDescription:
            'You recorded farm harvests. Advance this project to the Harvesting stage to track yields and storage.',
      );
    }

    // Suggest SELLING when sales are recorded during HARVESTING
    if (currentState == ProjectLifecycleState.harvesting && salesCount > 0) {
      return const ProjectStatusSuggestion(
        suggestedState: ProjectLifecycleState.selling,
        reasonTitle: 'Produce Sales Recorded',
        reasonDescription:
            'You started recording sales transactions. Advance to Selling to monitor receivables and buyer payments.',
      );
    }

    // Suggest COMPLETED when all harvests are sold during SELLING
    if (currentState == ProjectLifecycleState.selling &&
        allHarvestSold &&
        salesCount > 0) {
      return const ProjectStatusSuggestion(
        suggestedState: ProjectLifecycleState.completed,
        reasonTitle: 'All Yields Distributed',
        reasonDescription:
            'All logged harvest quantities have been accounted for in sales. Ready to reconcile and mark as Completed?',
      );
    }

    return null;
  }

  static bool _isRollback(
    ProjectLifecycleState from,
    ProjectLifecycleState to,
  ) {
    final order = [
      ProjectLifecycleState.planning,
      ProjectLifecycleState.active,
      ProjectLifecycleState.production,
      ProjectLifecycleState.harvesting,
      ProjectLifecycleState.selling,
      ProjectLifecycleState.completed,
      ProjectLifecycleState.archived,
    ];
    final fromIdx = order.indexOf(from);
    final toIdx = order.indexOf(to);
    return toIdx < fromIdx;
  }
}
