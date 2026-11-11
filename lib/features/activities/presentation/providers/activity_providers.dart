import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';
import 'package:farmivo/features/activities/domain/models/activity_with_details.dart';
import 'package:farmivo/features/activities/domain/repositories/activity_repository.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';

/// Provider for [ActivityRepository].
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ActivityRepositoryImpl(db: db);
});

/// Reactive stream of all activities across all projects.
final allActivitiesProvider = StreamProvider<List<ActivityWithDetails>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActivities();
});

/// Reactive stream of activities for a specific project.
final projectActivitiesWithDetailsProvider =
    StreamProvider.family<List<ActivityWithDetails>, String>((ref, projectId) {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.watchActivities(projectId: projectId);
    });

/// Single activity detail provider.
final activityDetailProvider =
    FutureProvider.family<ActivityWithDetails?, String>((ref, activityId) {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.getActivityById(activityId);
    });

/// Suggested titles for an activity type.
final activityTitleSuggestionsProvider =
    FutureProvider.family<List<String>, ActivityType>((ref, type) {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.getSuggestedTitles(type);
    });

/// Controller handling stateful operations (record, update, delete) for field activities.
class ActivityController extends StateNotifier<AsyncValue<void>> {
  final ActivityRepository _repository;

  ActivityController(this._repository) : super(const AsyncValue.data(null));

  Future<String?> recordActivity({
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
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.recordActivity(
        projectId: projectId,
        activityType: activityType,
        title: title,
        activityDate: activityDate,
        description: description,
        labourCount: labourCount,
        durationHours: durationHours,
        costMinor: costMinor,
        currency: currency,
        status: status,
        notes: notes,
        createLinkedExpense: createLinkedExpense,
        expensePaymentMethod: expensePaymentMethod,
        expenseCategoryId: expenseCategoryId,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateActivity({
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
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateActivity(
        id: id,
        projectId: projectId,
        activityType: activityType,
        title: title,
        activityDate: activityDate,
        description: description,
        labourCount: labourCount,
        durationHours: durationHours,
        costMinor: costMinor,
        currency: currency,
        status: status,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteActivity(
    String id, {
    bool deleteLinkedExpense = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteActivity(
        id,
        deleteLinkedExpense: deleteLinkedExpense,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for [ActivityController].
final activityControllerProvider =
    StateNotifierProvider<ActivityController, AsyncValue<void>>((ref) {
      final repository = ref.watch(activityRepositoryProvider);
      return ActivityController(repository);
    });
