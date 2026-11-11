import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/money/money.dart';
import '../../../budgets/domain/models/budget_variance.dart';
import '../../../sales/domain/models/sale_payment_status.dart';
import '../models/project_report_data.dart';

/// Pure Dart offline Bank-Ready PDF Financial Report Generator (Milestone 8.2).
///
/// Compiles a comprehensive 3+ page executive financial statement adhering to
/// commercial banking, cooperative audit, and agricultural loan standards.
class PdfReportGenerator {
  PdfReportGenerator._();

  // Primary Theme Tokens (Offline vector-calibrated)
  static final PdfColor primaryGreen = PdfColor.fromHex('#2E7D32');
  static final PdfColor darkGreen = PdfColor.fromHex('#1B5E20');
  static final PdfColor lightGreenBg = PdfColor.fromHex('#E8F5E9');
  static final PdfColor textDark = PdfColor.fromHex('#1E293B');
  static final PdfColor textMuted = PdfColor.fromHex('#475569');
  static final PdfColor borderSlate = PdfColor.fromHex('#CBD5E1');
  static final PdfColor headerBg = PdfColor.fromHex('#F1F5F9');
  static final PdfColor alertRed = PdfColor.fromHex('#DC2626');
  static final PdfColor alertRedBg = PdfColor.fromHex('#FEE2E2');
  static final PdfColor alertAmber = PdfColor.fromHex('#D97706');
  static final PdfColor alertAmberBg = PdfColor.fromHex('#FEF3C7');
  static final PdfColor healthGreen = PdfColor.fromHex('#16A34A');
  static final PdfColor cardFill = PdfColor.fromHex('#F8FAFC');

  /// Generates the complete binary PDF bytes for the provided [ProjectReportData].
  static Future<Uint8List> generate(ProjectReportData data) async {
    final pdf = pw.Document(
      title: '${data.project.name} - Bank-Ready Financial Statement',
      author: 'Farmivo Agricultural Financial Planning System',
      creator: 'Farmivo Mobile System (Offline Engine)',
      subject: 'Agricultural Credit Audit & Financial Statement',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          italic: pw.Font.helveticaOblique(),
          boldItalic: pw.Font.helveticaBoldOblique(),
        ),
        header: (context) => _buildPageHeader(context, data),
        footer: (context) => _buildPageFooter(context, data),
        build: (context) => [
          // Document Header Title Banner
          _buildDocumentTitleBanner(data),
          pw.SizedBox(height: 12),

          // 1. Farm & Project Executive Profile
          _buildSectionHeader('1. FARM & VENTURE EXECUTIVE PROFILE'),
          pw.SizedBox(height: 6),
          _buildExecutiveProfile(data),
          pw.SizedBox(height: 8),
          _buildExecutiveKpiSummary(data),
          pw.SizedBox(height: 14),

          // 2. Budget vs. Actual Expenditure Variance Ledger
          _buildSectionHeader(
            '2. BUDGET VS. ACTUAL EXPENDITURE VARIANCE LEDGER',
          ),
          pw.SizedBox(height: 4),
          _buildVarianceSectionSubtitle(),
          pw.SizedBox(height: 6),
          _buildBudgetVarianceTable(data),
          pw.SizedBox(height: 14),

          // 3. Production & Harvest Yield Log
          _buildSectionHeader('3. PRODUCTION & HARVEST YIELD LOG'),
          pw.SizedBox(height: 6),
          _buildHarvestYieldSection(data),
          pw.SizedBox(height: 14),

          // 4. Commercial Sales, Cash Collections & Debtors Ledger
          _buildSectionHeader(
            '4. COMMERCIAL SALES, CASH COLLECTIONS & OUTSTANDING DEBTORS',
          ),
          pw.SizedBox(height: 6),
          _buildSalesAndReceivablesSection(data),
          pw.SizedBox(height: 14),

          // 5. Profitability & Financial Return Statement
          _buildSectionHeader('5. PROFITABILITY & FINANCIAL RETURN STATEMENT'),
          pw.SizedBox(height: 6),
          _buildProfitabilityStatement(data),
          pw.SizedBox(height: 14),

          // 6. Dynamic Break-Even & Risk Sensitivity Analysis
          _buildSectionHeader('6. BREAK-EVEN & RISK SENSITIVITY ANALYSIS'),
          pw.SizedBox(height: 6),
          _buildBreakEvenAndRiskSection(data),
          pw.SizedBox(height: 14),

          // 7. Audit Verification & Formal Sign-Off
          if (data.includeSignatureBlocks) ...[
            _buildSectionHeader('7. AUDIT VERIFICATION & FORMAL SIGN-OFF'),
            pw.SizedBox(height: 6),
            _buildSignatureAndAuditSection(data),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // HEADER & FOOTER
  // ==========================================

  static pw.Widget _buildPageHeader(
    pw.Context context,
    ProjectReportData data,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: borderSlate, width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FARMIVO AGRIBUSINESS INTELLIGENCE SYSTEM',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryGreen,
                  letterSpacing: 0.5,
                ),
              ),
              pw.Text(
                'OFFICIAL BANK-READY FINANCIAL STATEMENT & OPERATIONAL AUDIT',
                style: pw.TextStyle(fontSize: 6.5, color: textMuted),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                data.projectTitle.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: textDark,
                ),
              ),
              pw.Text(
                'Generated: ${formatPdfDate(data.generatedAt)}',
                style: pw.TextStyle(fontSize: 6.5, color: textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageFooter(
    pw.Context context,
    ProjectReportData data,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderSlate, width: 0.6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'CONFIDENTIAL | PREPARED FOR AGRICULTURAL CREDIT COMMITTEES, COOPERATIVE AUDITS & TAX FILING',
            style: pw.TextStyle(fontSize: 6, color: textMuted),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TITLE BANNER & SECTION HEADERS
  // ==========================================

  static pw.Widget _buildDocumentTitleBanner(ProjectReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: lightGreenBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: primaryGreen, width: 1.2),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.reportTitle,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: darkGreen,
                  letterSpacing: 0.4,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Comprehensive Financial Ledger, Yield Analysis, and Credit Risk Assessment',
                style: pw.TextStyle(fontSize: 8, color: textMuted),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: primaryGreen,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'AUDIT GRADE',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: headerBg,
        border: pw.Border(left: pw.BorderSide(color: primaryGreen, width: 3.5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: textDark,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static pw.Widget _buildVarianceSectionSubtitle() {
    return pw.Text(
      'Detailed variance audit tracking pre-season planned allocations against incurred actual expenditures.',
      style: pw.TextStyle(
        fontSize: 7,
        color: textMuted,
        fontStyle: pw.FontStyle.italic,
      ),
    );
  }

  // ==========================================
  // SECTION 1: EXECUTIVE PROFILE & KPIS
  // ==========================================

  static pw.Widget _buildExecutiveProfile(ProjectReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: cardFill,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: borderSlate, width: 0.6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left Column: Farm Information
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildProfileRow('Farm Enterprise:', data.farmDisplayName),
                _buildProfileRow(
                  'Location / Region:',
                  data.farmLocationSummary,
                ),
                _buildProfileRow(
                  'Farmer / Manager:',
                  data.preparedBy ?? 'Farm Manager',
                ),
                _buildProfileRow(
                  'Land Area Allocated:',
                  data.formattedLandSize,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          // Right Column: Project Information
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildProfileRow('Venture Project:', data.projectTitle),
                _buildProfileRow('Crop / Commodity:', data.commoditySummary),
                _buildProfileRow(
                  'Lifecycle Stage:',
                  data.project.status.toUpperCase(),
                ),
                _buildProfileRow(
                  'Cycle Duration:',
                  '${data.metrics.daysActive} Days Active',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProfileRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 82,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: textMuted,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 7.5,
                color: textDark,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExecutiveKpiSummary(ProjectReportData data) {
    final netProfit = data.netProfit;
    final isProfitPositive = netProfit.isPositive;

    return pw.Row(
      children: [
        _buildKpiCard(
          title: 'Total Capital Deployed',
          value: formatPdfMoney(data.totalExpenses),
          subtitle:
              'Budget: ${formatPdfMoney(data.totalBudgetPlanned)} (${data.budgetSpentPercentage.toStringAsFixed(0)}% spent)',
          color: alertRed,
        ),
        pw.SizedBox(width: 6),
        _buildKpiCard(
          title: 'Gross Sales Revenue',
          value: formatPdfMoney(data.totalSalesValue),
          subtitle:
              'Cash In: ${formatPdfMoney(data.collectedRevenue)} (${data.collectionRatePercentage.toStringAsFixed(0)}% collected)',
          color: primaryGreen,
        ),
        pw.SizedBox(width: 6),
        _buildKpiCard(
          title: 'Net Accrual Profit',
          value: formatPdfMoney(netProfit),
          subtitle:
              'Margin: ${data.netProfitMargin.toStringAsFixed(1)}% | ROI: ${data.roiPercentage.toStringAsFixed(1)}%',
          color: isProfitPositive ? healthGreen : alertRed,
        ),
        pw.SizedBox(width: 6),
        _buildKpiCard(
          title: 'Project Health Rating',
          value: '${data.healthScore} / 100',
          subtitle:
              '${data.healthStatusLabel.toUpperCase()} | ${data.metrics.cashProfit.isPositive ? "Positive Cashflow" : "Cash Deficit"}',
          color: data.healthScore >= 80
              ? healthGreen
              : (data.healthScore >= 60 ? alertAmber : alertRed),
        ),
      ],
    );
  }

  static pw.Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: pw.BoxDecoration(
          color: cardFill,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: borderSlate, width: 0.6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 6.5,
                color: textMuted,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              subtitle,
              style: pw.TextStyle(fontSize: 6, color: textMuted),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 2: BUDGET VS ACTUAL TABLE
  // ==========================================

  static pw.Widget _buildBudgetVarianceTable(ProjectReportData data) {
    final categories = data.varianceReport.categories;

    if (categories.isEmpty) {
      return _buildEmptyBox(
        'No pre-season budget items or expenditures recorded.',
      );
    }

    final tableRows = <pw.TableRow>[
      // Table Header Row
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerBg),
        children: [
          _tableCell('Category / Line Item', isHeader: true, flex: 3),
          _tableCell('Planned', isHeader: true, alignRight: true, flex: 2),
          _tableCell('Actual Spent', isHeader: true, alignRight: true, flex: 2),
          _tableCell(
            'Variance (Diff)',
            isHeader: true,
            alignRight: true,
            flex: 2,
          ),
          _tableCell('% Spent', isHeader: true, alignRight: true, flex: 1),
          _tableCell('Status', isHeader: true, alignCenter: true, flex: 1),
        ],
      ),
    ];

    for (final cat in categories) {
      final isOverrun = cat.threshold == BudgetVarianceThreshold.overrun;

      // Category Group Subtotal Row
      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: lightGreenBg.withAlpha(0.6)),
          children: [
            _tableCell(
              '${cat.category.name.toUpperCase()} (Total)',
              isBold: true,
              color: darkGreen,
              flex: 3,
            ),
            _tableCell(
              formatPdfMoney(cat.plannedAmount),
              isBold: true,
              alignRight: true,
              flex: 2,
            ),
            _tableCell(
              formatPdfMoney(cat.actualSpent),
              isBold: true,
              alignRight: true,
              flex: 2,
            ),
            _tableCell(
              '${isOverrun ? "+" : ""}${formatPdfMoney(cat.variance)}',
              isBold: true,
              alignRight: true,
              color: isOverrun ? alertRed : textDark,
              flex: 2,
            ),
            _tableCell(
              '${cat.spentPercentage.toStringAsFixed(0)}%',
              isBold: true,
              alignRight: true,
              flex: 1,
            ),
            _tableCell(
              cat.threshold.displayName,
              isBold: true,
              alignCenter: true,
              color: isOverrun
                  ? alertRed
                  : (cat.threshold.isAlert ? alertAmber : healthGreen),
              flex: 1,
            ),
          ],
        ),
      );

      // Line item rows
      for (final it in cat.itemVariances) {
        final itemOverrun = it.threshold == BudgetVarianceThreshold.overrun;
        tableRows.add(
          pw.TableRow(
            children: [
              _tableCell('  - ${it.item.name}', flex: 3),
              _tableCell(
                formatPdfMoney(it.plannedAmount),
                alignRight: true,
                flex: 2,
              ),
              _tableCell(
                formatPdfMoney(it.actualSpent),
                alignRight: true,
                flex: 2,
              ),
              _tableCell(
                '${itemOverrun ? "+" : ""}${formatPdfMoney(it.variance)}',
                alignRight: true,
                color: itemOverrun ? alertRed : textMuted,
                flex: 2,
              ),
              _tableCell(
                '${it.spentPercentage.toStringAsFixed(0)}%',
                alignRight: true,
                flex: 1,
              ),
              _tableCell(
                it.threshold.displayName,
                alignCenter: true,
                color: itemOverrun
                    ? alertRed
                    : (it.threshold.isAlert ? alertAmber : healthGreen),
                flex: 1,
              ),
            ],
          ),
        );
      }
    }

    // Grand Total Row
    final totalPlanned = data.varianceReport.totalPlanned;
    final totalSpent = data.varianceReport.totalSpent;
    final totalVariance = data.varianceReport.variance;
    final grandOverrun = totalVariance.isPositive;

    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerBg),
        children: [
          _tableCell(
            'GRAND TOTAL ALLOCATIONS',
            isHeader: true,
            isBold: true,
            flex: 3,
          ),
          _tableCell(
            formatPdfMoney(totalPlanned),
            isHeader: true,
            isBold: true,
            alignRight: true,
            flex: 2,
          ),
          _tableCell(
            formatPdfMoney(totalSpent),
            isHeader: true,
            isBold: true,
            alignRight: true,
            flex: 2,
          ),
          _tableCell(
            '${grandOverrun ? "+" : ""}${formatPdfMoney(totalVariance)}',
            isHeader: true,
            isBold: true,
            alignRight: true,
            color: grandOverrun ? alertRed : healthGreen,
            flex: 2,
          ),
          _tableCell(
            '${data.varianceReport.spentPercentage.toStringAsFixed(0)}%',
            isHeader: true,
            isBold: true,
            alignRight: true,
            flex: 1,
          ),
          _tableCell(
            data.varianceReport.overallThreshold.displayName,
            isHeader: true,
            isBold: true,
            alignCenter: true,
            color: grandOverrun ? alertRed : healthGreen,
            flex: 1,
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: borderSlate, width: 0.5),
      children: tableRows,
    );
  }

  // ==========================================
  // SECTION 3: HARVEST YIELD LOG
  // ==========================================

  static pw.Widget _buildHarvestYieldSection(ProjectReportData data) {
    final harvests = data.harvests;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // KPI summary bar
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: cardFill,
            border: pw.Border.all(color: borderSlate, width: 0.6),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Target Yield: ${data.metrics.projectedYieldDisplay}',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: textMuted,
                ),
              ),
              pw.Text(
                'Actual Harvested: ${data.totalHarvestYieldFormatted}',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              pw.Text(
                'Batches Logged: ${data.harvestBatchesCount}',
                style: pw.TextStyle(fontSize: 7.5, color: textDark),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 6),

        // Harvest Table
        if (harvests.isEmpty)
          _buildEmptyBox(
            'No harvest batches recorded for this agricultural cycle.',
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: borderSlate, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerBg),
                children: [
                  _tableCell('Date', isHeader: true, flex: 2),
                  _tableCell('Batch #', isHeader: true, flex: 2),
                  _tableCell(
                    'Quantity',
                    isHeader: true,
                    alignRight: true,
                    flex: 2,
                  ),
                  _tableCell(
                    'Grade',
                    isHeader: true,
                    alignCenter: true,
                    flex: 1,
                  ),
                  _tableCell('Storage / Location', isHeader: true, flex: 2),
                  _tableCell('Remarks / Notes', isHeader: true, flex: 3),
                ],
              ),
              ...harvests.map((h) {
                return pw.TableRow(
                  children: [
                    _tableCell(formatPdfDate(h.harvestDate), flex: 2),
                    _tableCell(h.batchNumber, flex: 2),
                    _tableCell(
                      h.formattedQuantity,
                      isBold: true,
                      alignRight: true,
                      flex: 2,
                    ),
                    _tableCell(h.grade.shortLabel, alignCenter: true, flex: 1),
                    _tableCell(
                      h.storageLocation ?? 'On-Farm Facility',
                      flex: 2,
                    ),
                    _tableCell(h.notes ?? '-', flex: 3),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: SALES & RECEIVABLES TABLE
  // ==========================================

  static pw.Widget _buildSalesAndReceivablesSection(ProjectReportData data) {
    final sales = data.sales;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Debtors & Collections Summary Banner
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: cardFill,
            border: pw.Border.all(color: borderSlate, width: 0.6),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Agreed Sales: ${formatPdfMoney(data.totalSalesValue)}',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: textDark,
                ),
              ),
              pw.Text(
                'Collected: ${formatPdfMoney(data.collectedRevenue)}',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: healthGreen,
                ),
              ),
              pw.Text(
                'Debtors / Receivables: ${formatPdfMoney(data.accountsReceivable)}',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: data.accountsReceivable.isPositive
                      ? alertAmber
                      : healthGreen,
                ),
              ),
              pw.Text(
                'Collection Rate: ${data.collectionRatePercentage.toStringAsFixed(0)}%',
                style: pw.TextStyle(fontSize: 7.5, color: textMuted),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 6),

        if (sales.isEmpty)
          _buildEmptyBox(
            'No commercial sales recorded for this agricultural cycle.',
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: borderSlate, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerBg),
                children: [
                  _tableCell('Date', isHeader: true, flex: 2),
                  _tableCell('Buyer / Off-Taker', isHeader: true, flex: 3),
                  _tableCell(
                    'Quantity Sold',
                    isHeader: true,
                    alignRight: true,
                    flex: 2,
                  ),
                  _tableCell(
                    'Total Agreed',
                    isHeader: true,
                    alignRight: true,
                    flex: 2,
                  ),
                  _tableCell(
                    'Cash Paid',
                    isHeader: true,
                    alignRight: true,
                    flex: 2,
                  ),
                  _tableCell(
                    'Balance Due',
                    isHeader: true,
                    alignRight: true,
                    flex: 2,
                  ),
                  _tableCell(
                    'Status',
                    isHeader: true,
                    alignCenter: true,
                    flex: 1,
                  ),
                ],
              ),
              ...sales.map((s) {
                final isCredit = s.remainingBalance.isPositive;
                return pw.TableRow(
                  children: [
                    _tableCell(formatPdfDate(s.saleDate), flex: 2),
                    _tableCell(s.buyerDisplayName, flex: 3),
                    _tableCell(s.formattedQuantity, alignRight: true, flex: 2),
                    _tableCell(
                      formatPdfMoney(s.totalAmount),
                      isBold: true,
                      alignRight: true,
                      flex: 2,
                    ),
                    _tableCell(
                      formatPdfMoney(s.paidAmount),
                      alignRight: true,
                      color: healthGreen,
                      flex: 2,
                    ),
                    _tableCell(
                      formatPdfMoney(s.remainingBalance),
                      alignRight: true,
                      color: isCredit ? alertRed : textMuted,
                      flex: 2,
                    ),
                    _tableCell(
                      s.effectiveStatus == SalePaymentStatus.paid
                          ? 'PAID'
                          : (s.effectiveStatus == SalePaymentStatus.partial
                                ? 'PARTIAL'
                                : 'UNPAID'),
                      alignCenter: true,
                      color: isCredit ? alertAmber : healthGreen,
                      flex: 1,
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  // ==========================================
  // SECTION 5: PROFITABILITY STATEMENT (P&L)
  // ==========================================

  static pw.Widget _buildProfitabilityStatement(ProjectReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: cardFill,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: borderSlate, width: 0.6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Structured P&L Table
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              children: [
                _plRow(
                  'Gross Operating Revenue (Sales Turnover)',
                  formatPdfMoney(data.totalSalesValue),
                  isHeader: true,
                ),
                _plRow(
                  'Less: Direct Operational Expenditure (COGS)',
                  '(${formatPdfMoney(data.totalExpenses)})',
                  isNegative: true,
                ),
                pw.Divider(color: borderSlate, thickness: 0.5),
                _plRow(
                  'NET ACCRUAL PROFIT / (DEFICIT)',
                  formatPdfMoney(data.netProfit),
                  isBold: true,
                  highlight: true,
                  color: data.netProfit.isPositive ? healthGreen : alertRed,
                ),
                pw.SizedBox(height: 4),
                _plRow(
                  'Liquid Cash Receipts Incurred',
                  formatPdfMoney(data.collectedRevenue),
                ),
                _plRow(
                  'Less: Total Capital Outflows Disbursed',
                  '(${formatPdfMoney(data.totalExpenses)})',
                  isNegative: true,
                ),
                pw.Divider(color: borderSlate, thickness: 0.5),
                _plRow(
                  'NET CASH-BASIS LIQUID PROFIT',
                  formatPdfMoney(data.cashProfit),
                  isBold: true,
                  color: data.cashProfit.isPositive ? healthGreen : alertRed,
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 14),

          // Right: Key Return Ratios
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: lightGreenBg.withAlpha(0.5),
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(
                  color: primaryGreen.withAlpha(0.4),
                  width: 0.6,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FINANCIAL PERFORMANCE RATIOS',
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  _ratioRow(
                    'Net Profit Margin:',
                    '${data.netProfitMargin.toStringAsFixed(1)}%',
                  ),
                  _ratioRow(
                    'Return on Capital (ROI):',
                    '${data.roiPercentage.toStringAsFixed(1)}%',
                  ),
                  _ratioRow(
                    'Cash-Basis ROI:',
                    '${data.cashRoiPercentage.toStringAsFixed(1)}%',
                  ),
                  _ratioRow(
                    'Net Return / Land Unit:',
                    '${formatPdfMoney(data.profitPerLandUnit)} / ${data.project.landUnit}',
                  ),
                  _ratioRow(
                    'Operating Expense Ratio:',
                    '${(data.operatingExpenseRatio * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _plRow(
    String label,
    String value, {
    bool isHeader = false,
    bool isBold = false,
    bool isNegative = false,
    bool highlight = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isHeader || isBold ? 8 : 7.5,
              fontWeight: isHeader || isBold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              color: textDark,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isHeader || isBold ? 8 : 7.5,
              fontWeight: isHeader || isBold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              color: color ?? (isNegative ? alertRed : textDark),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _ratioRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 7, color: textMuted)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: BREAK-EVEN & RISK ANALYSIS
  // ==========================================

  static pw.Widget _buildBreakEvenAndRiskSection(ProjectReportData data) {
    final healthEvaluation = data.metrics.healthEvaluation;

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: cardFill,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: borderSlate, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: Break Even Indicators
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BREAK-EVEN RECOVERY METRICS',
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    _buildProfileRow(
                      'Break-Even Production Volume:',
                      data.breakEvenYieldDisplay,
                    ),
                    _buildProfileRow(
                      'Unit Cost of Production:',
                      data.unitCostOfProductionDisplay,
                    ),
                    _buildProfileRow(
                      'Volume Safety Margin:',
                      '${data.safetyMarginPercentage.toStringAsFixed(1)}%',
                    ),
                    _buildProfileRow(
                      'Break-Even Status:',
                      data.isBreakEvenAchieved
                          ? 'ACHIEVED (Profitable)'
                          : 'PENDING HARVEST/SALES',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 14),

              // Right: Health Evaluation Summary
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CREDIT RISK & HEALTH SCORE EVALUATION',
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    _buildProfileRow(
                      'Composite Health Rating:',
                      '${data.healthScore}/100 (${data.healthStatusLabel.toUpperCase()})',
                    ),
                    _buildProfileRow(
                      'Budget Discipline (30%):',
                      '${healthEvaluation.breakdown.budgetDisciplineScore.toStringAsFixed(0)}/100',
                    ),
                    _buildProfileRow(
                      'Revenue Realization (25%):',
                      '${healthEvaluation.breakdown.revenuePerformanceScore.toStringAsFixed(0)}/100',
                    ),
                    _buildProfileRow(
                      'Cash Liquidity (20%):',
                      '${healthEvaluation.breakdown.cashLiquidityScore.toStringAsFixed(0)}/100',
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          // Diagnostic Explanation Note
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: pw.BoxDecoration(
              color: lightGreenBg.withAlpha(0.6),
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Audit Diagnosis: ',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    data.healthExplanation,
                    style: pw.TextStyle(fontSize: 7, color: textDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 7: AUDIT & SIGN-OFF BLOCKS
  // ==========================================

  static pw.Widget _buildSignatureAndAuditSection(ProjectReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'I/We hereby certify that the financial accounts, expenditure receipts, production records, and commercial sales recorded herein represent an accurate and auditable statement of the agricultural venture.',
          style: pw.TextStyle(
            fontSize: 6.8,
            color: textMuted,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.SizedBox(height: 8),

        pw.Row(
          children: [
            // Signatory 1: Farmer / Operator
            pw.Expanded(
              child: _buildSignatureBox(
                title: 'OPERATOR / FARM MANAGER',
                name: data.preparedBy ?? 'Authorized Farm Manager',
                organization: data.farmDisplayName,
              ),
            ),
            pw.SizedBox(width: 10),

            // Signatory 2: Lending Officer / Extension Agent
            pw.Expanded(
              child: _buildSignatureBox(
                title: 'AUDITOR / AGRICULTURAL LENDING OFFICER',
                name: data.verifiedBy ?? 'Credit Review Officer',
                organization:
                    'Financing Institution / Agribusiness Cooperative',
              ),
            ),
            pw.SizedBox(width: 10),

            // Signatory 3: Official Stamp & Seal Area
            pw.Container(
              width: 90,
              height: 75,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderSlate, width: 0.8),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              alignment: pw.Alignment.center,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'OFFICIAL STAMP',
                    style: pw.TextStyle(
                      fontSize: 6.5,
                      fontWeight: pw.FontWeight.bold,
                      color: borderSlate,
                    ),
                  ),
                  pw.Text(
                    '& SEAL',
                    style: pw.TextStyle(fontSize: 6, color: borderSlate),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (data.notes != null && data.notes!.trim().isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: cardFill,
              borderRadius: pw.BorderRadius.circular(3),
              border: pw.Border.all(color: borderSlate, width: 0.5),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Auditor Remarks: ',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: textDark,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    data.notes!,
                    style: pw.TextStyle(fontSize: 7, color: textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildSignatureBox({
    required String title,
    required String name,
    required String organization,
  }) {
    return pw.Container(
      height: 75,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: cardFill,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: borderSlate, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 6,
                  fontWeight: pw.FontWeight.bold,
                  color: textMuted,
                ),
              ),
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: textDark,
                ),
              ),
              pw.Text(
                organization,
                style: pw.TextStyle(fontSize: 6, color: textMuted),
                maxLines: 1,
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 0.6,
                color: textMuted,
                margin: const pw.EdgeInsets.only(bottom: 2),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Signature',
                    style: pw.TextStyle(fontSize: 5.5, color: textMuted),
                  ),
                  pw.Text(
                    'Date',
                    style: pw.TextStyle(fontSize: 5.5, color: textMuted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED UTILITIES
  // ==========================================

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool alignRight = false,
    bool alignCenter = false,
    PdfColor? color,
    int flex = 1,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
        child: pw.Align(
          alignment: alignRight
              ? pw.Alignment.centerRight
              : (alignCenter ? pw.Alignment.center : pw.Alignment.centerLeft),
          child: pw.Text(
            _sanitizeText(text),
            style: pw.TextStyle(
              fontSize: isHeader ? 7 : 6.8,
              fontWeight: isHeader || isBold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              color: color ?? (isHeader ? textDark : textMuted),
            ),
          ),
        ),
      ),
    );
  }

  static String _sanitizeText(String text) {
    return text
        .replaceAll('•', '|')
        .replaceAll('≥', '>=')
        .replaceAll('≤', '<=')
        .replaceAll('—', '-')
        .replaceAll('–', '-');
  }

  static pw.Widget _buildEmptyBox(String message) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderSlate, width: 0.5),
        color: cardFill,
      ),
      child: pw.Text(
        message,
        style: pw.TextStyle(
          fontSize: 7,
          color: textMuted,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  /// Formats monetary figures safely using standard ASCII characters (e.g. GHS 1,200.00).
  static String formatPdfMoney(Money money) {
    final major = money.toMajor();
    final isNeg = major < 0;
    final absVal = major.abs();
    final fixed = absVal.toStringAsFixed(2);
    final parts = fixed.split('.');
    final wholePart = parts[0];
    final fracPart = parts[1];

    final buffer = StringBuffer();
    final chars = wholePart.split('').reversed.toList();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    final formattedWhole = buffer.toString().split('').reversed.join('');
    final sign = isNeg ? '-' : '';
    return '$sign${money.currency} $formattedWhole.$fracPart';
  }

  /// Formats dates cleanly (e.g. 15 Mar 2026).
  static String formatPdfDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${m[(d.month - 1).clamp(0, 11)]} ${d.year}';
  }
}
