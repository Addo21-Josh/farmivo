import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../domain/services/pdf_report_generator.dart';
import '../providers/report_pdf_providers.dart';
import '../widgets/export_options_sheet.dart';

/// Full-screen bank-ready PDF report preview, sharing, and printing screen (Milestone 8.2).
class PdfReportPreviewScreen extends ConsumerWidget {
  final String projectId;

  const PdfReportPreviewScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final reportDataAsync = ref.watch(projectReportDataProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank-Ready Statement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Report Options & Signatories',
            onPressed: () {
              ExportOptionsSheet.show(context, projectId: projectId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share PDF',
            onPressed: () async {
              final reportData = reportDataAsync.value;
              if (reportData != null) {
                final bytes = await PdfReportGenerator.generate(reportData);
                await Printing.sharePdf(
                  bytes: bytes,
                  filename:
                      'Farmivo_${reportData.project.name.replaceAll(' ', '_')}_Statement.pdf',
                );
              }
            },
          ),
        ],
      ),
      body: reportDataAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colors.healthGreen),
              const SizedBox(height: 16),
              const Text(
                'Compiling offline financial ledgers...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Auditing variance, yields, and break-even calculations',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colors.healthRed),
                const SizedBox(height: 12),
                Text(
                  'Failed to Compile Financial Statement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () =>
                      ref.invalidate(projectReportDataProvider(projectId)),
                ),
              ],
            ),
          ),
        ),
        data: (reportData) {
          final fileName =
              'Farmivo_${reportData.project.name.replaceAll(' ', '_')}_Financial_Statement.pdf';

          return PdfPreview(
            build: (format) => PdfReportGenerator.generate(reportData),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: fileName,
            previewPageMargin: const EdgeInsets.all(12),
            loadingWidget: Center(
              child: CircularProgressIndicator(color: colors.healthGreen),
            ),
          );
        },
      ),
    );
  }
}
