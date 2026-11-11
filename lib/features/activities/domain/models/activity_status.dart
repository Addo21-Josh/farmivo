import 'package:flutter/material.dart';

/// Execution status of an agronomic activity.
enum ActivityStatus {
  completed,
  inProgress,
  planned,
  cancelled;

  /// String code stored in SQLite.
  String get code {
    switch (this) {
      case ActivityStatus.completed:
        return 'COMPLETED';
      case ActivityStatus.inProgress:
        return 'IN_PROGRESS';
      case ActivityStatus.planned:
        return 'PLANNED';
      case ActivityStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Human-readable label for UI badges.
  String get displayName {
    switch (this) {
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.inProgress:
        return 'In Progress';
      case ActivityStatus.planned:
        return 'Planned';
      case ActivityStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Theme-consistent semantic indicator color.
  Color get color {
    switch (this) {
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.inProgress:
        return Colors.orange;
      case ActivityStatus.planned:
        return Colors.blue;
      case ActivityStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Associated status icon.
  IconData get icon {
    switch (this) {
      case ActivityStatus.completed:
        return Icons.check_circle_outline;
      case ActivityStatus.inProgress:
        return Icons.pending_outlined;
      case ActivityStatus.planned:
        return Icons.schedule_outlined;
      case ActivityStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  /// Parses stored database string into [ActivityStatus].
  static ActivityStatus fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    return ActivityStatus.values.firstWhere(
      (status) => status.code == normalized,
      orElse: () => ActivityStatus.completed,
    );
  }
}
