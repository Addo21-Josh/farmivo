import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../budgets/presentation/providers/budget_variance_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../farms/presentation/providers/farm_providers.dart';
import '../../../harvests/presentation/providers/harvest_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../sales/presentation/providers/sale_providers.dart';
import '../../domain/models/project_report_data.dart';
import '../../domain/services/pdf_report_generator.dart';

/// Configurable signatory and auditor customization providers for PDF generation.
final reportPreparedByNameProvider = StateProvider<String?>((ref) => null);
final reportVerifiedByNameProvider = StateProvider<String?>((ref) => null);
final reportNotesProvider = StateProvider<String?>((ref) => null);
final reportIncludeSignaturesProvider = StateProvider<bool>((ref) => true);

/// Assembles the complete [ProjectReportData] aggregate for the given project.
final projectReportDataProvider = Provider.autoDispose
    .family<AsyncValue<ProjectReportData>, String>((ref, projectId) {
      final projectAsync = ref.watch(projectDetailProvider(projectId));
      final metricsAsync = ref.watch(projectMetricsProvider(projectId));
      final varianceAsync = ref.watch(projectVarianceReportProvider(projectId));
      final harvestsAsync = ref.watch(
        projectHarvestsWithDetailsProvider(projectId),
      );
      final salesAsync = ref.watch(projectSalesWithDetailsProvider(projectId));
      final expensesAsync = ref.watch(
        projectExpensesWithDetailsProvider(projectId),
      );

      // Check loading states
      if (projectAsync.isLoading ||
          metricsAsync.isLoading ||
          varianceAsync.isLoading ||
          harvestsAsync.isLoading ||
          salesAsync.isLoading ||
          expensesAsync.isLoading) {
        return const AsyncValue.loading();
      }

      // Check error states
      if (projectAsync.hasError) {
        return AsyncValue.error(projectAsync.error!, projectAsync.stackTrace!);
      }
      if (metricsAsync.hasError) {
        return AsyncValue.error(metricsAsync.error!, metricsAsync.stackTrace!);
      }
      if (varianceAsync.hasError) {
        return AsyncValue.error(
          varianceAsync.error!,
          varianceAsync.stackTrace!,
        );
      }
      if (harvestsAsync.hasError) {
        return AsyncValue.error(
          harvestsAsync.error!,
          harvestsAsync.stackTrace!,
        );
      }
      if (salesAsync.hasError) {
        return AsyncValue.error(salesAsync.error!, salesAsync.stackTrace!);
      }
      if (expensesAsync.hasError) {
        return AsyncValue.error(
          expensesAsync.error!,
          expensesAsync.stackTrace!,
        );
      }

      final project = projectAsync.value;
      final metrics = metricsAsync.value;
      final varianceReport = varianceAsync.value;

      if (project == null || metrics == null || varianceReport == null) {
        return AsyncValue.error(
          Exception(
            'Failed to assemble project financial metrics: records missing.',
          ),
          StackTrace.current,
        );
      }

      // Resolve optional parent farm
      Farm? farm;
      if (project.farmId.isNotEmpty) {
        final farmAsync = ref.watch(farmDetailProvider(project.farmId));
        farm = farmAsync.value;
      }

      final preparedBy = ref.watch(reportPreparedByNameProvider);
      final verifiedBy = ref.watch(reportVerifiedByNameProvider);
      final notes = ref.watch(reportNotesProvider);
      final includeSignatures = ref.watch(reportIncludeSignaturesProvider);

      final data = ProjectReportData(
        project: project,
        farm: farm,
        metrics: metrics,
        varianceReport: varianceReport,
        harvests: harvestsAsync.value ?? const [],
        sales: salesAsync.value ?? const [],
        expenses: expensesAsync.value ?? const [],
        generatedAt: DateTime.now(),
        preparedBy: preparedBy,
        verifiedBy: verifiedBy,
        notes: notes,
        includeSignatureBlocks: includeSignatures,
      );

      return AsyncValue.data(data);
    });

/// Reactive provider generating raw PDF bytes for bank auditing.
final projectPdfBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, String>((ref, projectId) async {
      final reportDataAsync = ref.watch(projectReportDataProvider(projectId));

      final reportData = reportDataAsync.when(
        data: (data) => data,
        loading: () => null,
        error: (e, st) => throw e,
      );

      if (reportData == null) {
        throw Exception('Project report data is still loading.');
      }

      return PdfReportGenerator.generate(reportData);
    });
