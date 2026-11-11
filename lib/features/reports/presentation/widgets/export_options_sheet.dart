import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/services/csv_report_generator.dart';
import '../providers/report_export_providers.dart';
import '../providers/report_pdf_providers.dart';
import '../providers/reports_providers.dart';

/// Modal bottom sheet for configuring and generating official bank-ready PDF
/// reports and CSV exports (Milestone 8.2 & 8.3).
class ExportOptionsSheet extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final int initialTabIndex;

  const ExportOptionsSheet({
    super.key,
    this.initialProjectId,
    this.initialTabIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    String? projectId,
    int initialTabIndex = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportOptionsSheet(
        initialProjectId: projectId,
        initialTabIndex: initialTabIndex,
      ),
    );
  }

  @override
  ConsumerState<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends ConsumerState<ExportOptionsSheet> {
  late int _selectedTabIndex;
  late String? _selectedProjectId;
  late TextEditingController _preparedByController;
  late TextEditingController _verifiedByController;
  late TextEditingController _notesController;
  bool _includeSignatures = true;
  CsvLedgerType _selectedLedgerType = CsvLedgerType.all;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _selectedProjectId =
        widget.initialProjectId ?? ref.read(selectedReportProjectIdProvider);
    _preparedByController = TextEditingController(
      text: ref.read(reportPreparedByNameProvider) ?? '',
    );
    _verifiedByController = TextEditingController(
      text: ref.read(reportVerifiedByNameProvider) ?? '',
    );
    _notesController = TextEditingController(
      text: ref.read(reportNotesProvider) ?? '',
    );
    _includeSignatures = ref.read(reportIncludeSignaturesProvider);
    _selectedLedgerType = ref.read(selectedCsvLedgerTypeProvider);
  }

  @override
  void dispose() {
    _preparedByController.dispose();
    _verifiedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onGeneratePdf() {
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project for the financial statement.'),
        ),
      );
      return;
    }

    // Save configuration into providers
    ref
        .read(reportPreparedByNameProvider.notifier)
        .state = _preparedByController.text.trim().isNotEmpty
        ? _preparedByController.text.trim()
        : null;
    ref
        .read(reportVerifiedByNameProvider.notifier)
        .state = _verifiedByController.text.trim().isNotEmpty
        ? _verifiedByController.text.trim()
        : null;
    ref
        .read(reportNotesProvider.notifier)
        .state = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;
    ref.read(reportIncludeSignaturesProvider.notifier).state =
        _includeSignatures;

    Navigator.of(context).maybePop();

    try {
      context.push(
        AppRoutes.pdfReportPreview.replaceFirst(
          ':projectId',
          _selectedProjectId!,
        ),
      );
    } catch (_) {
      // Fallback if rendered outside GoRouter context
    }
  }

  Future<void> _onExportCsv() async {
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project for the CSV export.'),
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final reportDataAsync = ref.read(
        projectReportDataProvider(_selectedProjectId!),
      );
      final data = reportDataAsync.value;
      if (data == null) {
        throw Exception('Financial records are compiling. Please try again.');
      }

      final csvService = ref.read(csvExportServiceProvider);
      final safeName = data.project.name.replaceAll(
        RegExp(r'[^a-zA-Z0-9_\-]'),
        '_',
      );

      switch (_selectedLedgerType) {
        case CsvLedgerType.all:
          final files = CsvReportGenerator.generateAllProjectCsvs(data);
          await csvService.shareMultipleLedgers(
            files: files,
            subject: '${data.project.name} - Complete Audit Pack (CSV)',
          );
          break;
        case CsvLedgerType.expenses:
          final csv = CsvReportGenerator.generateExpensesCsv(
            data.expenses,
            projectName: data.project.name,
          );
          await csvService.shareSingleLedger(
            filename: '${safeName}_Expenses_Ledger.csv',
            content: csv,
            subject: '${data.project.name} - Expenses Ledger',
          );
          break;
        case CsvLedgerType.sales:
          final csv = CsvReportGenerator.generateSalesCsv(
            data.sales,
            projectName: data.project.name,
          );
          await csvService.shareSingleLedger(
            filename: '${safeName}_Sales_Ledger.csv',
            content: csv,
            subject: '${data.project.name} - Sales & Debtors Ledger',
          );
          break;
        case CsvLedgerType.harvests:
          final csv = CsvReportGenerator.generateHarvestsCsv(
            data.harvests,
            projectName: data.project.name,
          );
          await csvService.shareSingleLedger(
            filename: '${safeName}_Harvest_Yield_Log.csv',
            content: csv,
            subject: '${data.project.name} - Harvest Yield Log',
          );
          break;
        case CsvLedgerType.budgetVariance:
          final csv = CsvReportGenerator.generateBudgetVarianceCsv(
            data.varianceReport,
            projectName: data.project.name,
          );
          await csvService.shareSingleLedger(
            filename: '${safeName}_Budget_Variance_Ledger.csv',
            content: csv,
            subject: '${data.project.name} - Budget & Variance Ledger',
          );
          break;
      }

      if (mounted) {
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final projectsAsync = ref.watch(projectsWithFarmStreamProvider);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.healthGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedTabIndex == 0
                          ? Icons.picture_as_pdf_rounded
                          : Icons.table_view_rounded,
                      color: colors.healthGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTabIndex == 0
                              ? 'Bank-Ready Financial Report'
                              : 'Excel & CSV Data Export',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedTabIndex == 0
                              ? 'Configure official PDF statement for banks & credit audits'
                              : 'Export raw tabular ledgers for Excel, Sheets, & accounting',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Segmented Tab Switcher (PDF vs CSV)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    80,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0
                                ? theme.colorScheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 16,
                                color: _selectedTabIndex == 0
                                    ? colors.healthGreen
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Bank-Ready PDF',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _selectedTabIndex == 0
                                      ? colors.healthGreen
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1
                                ? theme.colorScheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.table_chart_outlined,
                                size: 16,
                                color: _selectedTabIndex == 1
                                    ? colors.healthGreen
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Excel / CSV Ledgers',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: _selectedTabIndex == 1
                                      ? colors.healthGreen
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Target Project Selector
              projectsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading projects: $e'),
                data: (projects) {
                  if (projects.isEmpty) {
                    return const Text('No projects available.');
                  }
                  return DropdownButtonFormField<String>(
                    key: ValueKey(_selectedProjectId),
                    initialValue:
                        _selectedProjectId ?? projects.first.project.id,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Target Agricultural Venture',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: projects.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.project.id,
                        child: Text(
                          '${p.displayName} (${p.project.commodity})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedProjectId = val);
                    },
                  );
                },
              ),
              const SizedBox(height: 14),

              // Tab 0: Bank-Ready PDF Options
              if (_selectedTabIndex == 0) ...[
                // Prepared By (Farmer / Manager)
                TextField(
                  controller: _preparedByController,
                  decoration: InputDecoration(
                    labelText: 'Prepared By (Farmer / Manager Name)',
                    hintText: 'e.g. Kwame Mensah',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Verified By (Lender / Auditor)
                TextField(
                  controller: _verifiedByController,
                  decoration: InputDecoration(
                    labelText: 'Auditor / Credit Review Officer (Optional)',
                    hintText: 'e.g. ADB Loan Officer / Extension Agent',
                    prefixIcon: const Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Notes / Remarks
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Audit Remarks / Loan Purpose (Optional)',
                    hintText:
                        'e.g. Submitted for 2026 Input Financing Facility',
                    prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Include Signature Blocks Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Include Official Signature & Stamp Blocks',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Provides formal sign-off sections for operator and loan officer',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _includeSignatures,
                  activeThumbColor: colors.healthGreen,
                  onChanged: (val) {
                    setState(() => _includeSignatures = val);
                  },
                ),
                const SizedBox(height: 16),

                // PDF Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.healthGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text(
                      'View & Export Bank-Ready PDF',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _onGeneratePdf,
                  ),
                ),
              ]
              // Tab 1: Excel / CSV Ledgers Export Options
              else ...[
                // Ledger Selector
                DropdownButtonFormField<CsvLedgerType>(
                  initialValue: _selectedLedgerType,
                  isExpanded: true,
                  itemHeight: 56.0,
                  selectedItemBuilder: (context) {
                    return CsvLedgerType.values.map((type) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          type.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Ledger to Export',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: CsvLedgerType.values.map((type) {
                    return DropdownMenuItem<CsvLedgerType>(
                      value: type,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            type.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            type.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLedgerType = val);
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Info card regarding Excel and Google Sheets compatibility
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.healthGreenBg.withAlpha(70),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.healthGreen.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: colors.healthGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Exports as RFC 4180 CSV with UTF-8 BOM encoding for direct opening in Microsoft Excel and Google Sheets without font or column errors.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // CSV Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.healthGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.share_outlined),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Export & Share CSV',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isExporting ? null : _onExportCsv,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
