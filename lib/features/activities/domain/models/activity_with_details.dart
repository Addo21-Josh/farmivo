import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';

/// Comprehensive projection of an agronomic [Activity] joined with its parent [Project]
/// and any auto-generated financial [Expense] record.
class ActivityWithDetails {
  final Activity activity;
  final Project? project;
  final Expense? linkedExpense;

  const ActivityWithDetails({
    required this.activity,
    this.project,
    this.linkedExpense,
  });

  String get id => activity.id;
  String get projectId => activity.projectId;
  String get title => activity.title;
  String? get description => activity.description;
  String? get notes => activity.notes;
  int get labourCount => activity.labourCount;
  double? get durationHours => activity.durationHours;
  int get costMinor => activity.costMinor;
  String get currency => activity.currency;
  bool get isDeleted => activity.isDeleted;

  DateTime get activityDate =>
      DateTime.fromMillisecondsSinceEpoch(activity.activityDate);

  ActivityType get type => ActivityType.fromCode(activity.activityType);
  ActivityStatus get status => ActivityStatus.fromCode(activity.status);

  /// Formatted monetary cost of casual labour / operations.
  Money get cost => Money(BigInt.from(costMinor), currency: currency);

  /// Whether casual labour personnel were assigned.
  bool get hasLabour => labourCount > 0;

  /// Whether this activity is linked to a financial ledger expense.
  bool get hasLinkedExpense => linkedExpense != null;

  /// User-friendly duration string (e.g., '4.5 hrs').
  String? get formattedDuration {
    if (durationHours == null || durationHours! <= 0) return null;
    if (durationHours! % 1 == 0) {
      return '${durationHours!.toInt()} hrs';
    }
    return '${durationHours!.toStringAsFixed(1)} hrs';
  }
}
