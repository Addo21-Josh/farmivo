import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';
import 'package:farmivo/features/activities/domain/models/activity_with_details.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';

/// Contract for agronomic field activity records and optional expense linking.
abstract class ActivityRepository {
  /// Reactive stream of field operations, optionally filtered by [projectId].
  Stream<List<ActivityWithDetails>> watchActivities({String? projectId});

  /// Retrieves a single activity with project and expense details.
  Future<ActivityWithDetails?> getActivityById(String id);

  /// Records a new agronomic field operation.
  ///
  /// If [createLinkedExpense] is true and [costMinor] > 0, an associated
  /// expense record is automatically posted to the financial ledger under
  /// the project's Labour category.
  Future<String> recordActivity({
    required String projectId,
    required ActivityType activityType,
    required String title,
    required DateTime activityDate,
    String? description,
    int labourCount = 0,
    double? durationHours,
    int costMinor = 0,
    String currency = 'GHS',
    ActivityStatus status = ActivityStatus.completed,
    String? notes,
    bool createLinkedExpense = false,
    PaymentMethod expensePaymentMethod = PaymentMethod.cash,
    String? expenseCategoryId,
  });

  /// Updates an existing field operation and syncs linked expense cost if applicable.
  Future<void> updateActivity({
    required String id,
    required String projectId,
    required ActivityType activityType,
    required String title,
    required DateTime activityDate,
    String? description,
    int labourCount = 0,
    double? durationHours,
    int costMinor = 0,
    String currency = 'GHS',
    ActivityStatus status = ActivityStatus.completed,
    String? notes,
  });

  /// Soft deletes an activity from local storage.
  /// If [deleteLinkedExpense] is true, also soft deletes the linked expense record.
  Future<void> deleteActivity(String id, {bool deleteLinkedExpense = false});

  /// Returns commonly used titles for rapid form input based on [activityType].
  Future<List<String>> getSuggestedTitles(
    ActivityType activityType, {
    int limit = 10,
  });
}
