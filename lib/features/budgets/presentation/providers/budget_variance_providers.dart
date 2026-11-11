import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/budget_variance.dart';
import 'budget_tracking_providers.dart';

/// Reactive provider delivering real-time planned vs. actual variance analysis
/// for an entire project, including line items and categories.
final projectVarianceReportProvider =
    Provider.family<AsyncValue<ProjectVarianceReport>, String>((
      ref,
      projectId,
    ) {
      final trackingAsync = ref.watch(projectBudgetTrackingProvider(projectId));

      return trackingAsync.whenData((tracking) {
        return ProjectVarianceReport.fromTracking(tracking);
      });
    });

/// Reactive provider filtering only high-priority budget threshold alerts
/// (Warning ≥80%, Critical 100%, Overrun >100%) for prominent field warnings.
final projectBudgetAlertsProvider =
    Provider.family<AsyncValue<List<CategoryVariance>>, String>((
      ref,
      projectId,
    ) {
      final reportAsync = ref.watch(projectVarianceReportProvider(projectId));

      return reportAsync.whenData((report) {
        return report.categoriesAtRisk;
      });
    });
