import 'package:flutter/material.dart';

/// Standard agricultural produce quality grades for yield tracking and market sorting.
enum HarvestGrade {
  gradeA,
  gradeB,
  rejects,
  ungraded;

  /// String code stored in SQLite.
  String get code {
    switch (this) {
      case HarvestGrade.gradeA:
        return 'GRADE_A';
      case HarvestGrade.gradeB:
        return 'GRADE_B';
      case HarvestGrade.rejects:
        return 'REJECTS';
      case HarvestGrade.ungraded:
        return 'UNGRADED';
    }
  }

  /// Human-readable label for UI badges.
  String get displayName {
    switch (this) {
      case HarvestGrade.gradeA:
        return 'Grade A (Premium)';
      case HarvestGrade.gradeB:
        return 'Grade B (Standard)';
      case HarvestGrade.rejects:
        return 'Rejects / Damaged';
      case HarvestGrade.ungraded:
        return 'Ungraded / Bulk';
    }
  }

  /// Short code representation.
  String get shortLabel {
    switch (this) {
      case HarvestGrade.gradeA:
        return 'Grade A';
      case HarvestGrade.gradeB:
        return 'Grade B';
      case HarvestGrade.rejects:
        return 'Rejects';
      case HarvestGrade.ungraded:
        return 'Ungraded';
    }
  }

  /// Theme-consistent semantic indicator color.
  Color get color {
    switch (this) {
      case HarvestGrade.gradeA:
        return Colors.green;
      case HarvestGrade.gradeB:
        return Colors.amber.shade700;
      case HarvestGrade.rejects:
        return Colors.red;
      case HarvestGrade.ungraded:
        return Colors.blueGrey;
    }
  }

  /// Grade icon.
  IconData get icon {
    switch (this) {
      case HarvestGrade.gradeA:
        return Icons.verified;
      case HarvestGrade.gradeB:
        return Icons.star_half;
      case HarvestGrade.rejects:
        return Icons.remove_circle_outline;
      case HarvestGrade.ungraded:
        return Icons.grain;
    }
  }

  /// Parses stored database string into [HarvestGrade].
  static HarvestGrade fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return HarvestGrade.ungraded;
    final normalized = code.trim().toUpperCase();

    if (normalized == 'GRADE_A' ||
        normalized == 'GRADE A' ||
        normalized == 'A' ||
        normalized.contains('PREMIUM')) {
      return HarvestGrade.gradeA;
    } else if (normalized == 'GRADE_B' ||
        normalized == 'GRADE B' ||
        normalized == 'B' ||
        normalized.contains('STANDARD')) {
      return HarvestGrade.gradeB;
    } else if (normalized.contains('REJECT') ||
        normalized.contains('DAMAGED')) {
      return HarvestGrade.rejects;
    }
    return HarvestGrade.ungraded;
  }
}
