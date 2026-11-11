import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_theme_extension.dart';
import '../../../core/money/money.dart';
import '../../../shared/widgets/widgets.dart';
import '../../projects/presentation/providers/project_providers.dart';
import '../../projects/presentation/widgets/project_card.dart';
import 'providers/dashboard_providers.dart';

/// Enterprise executive dashboard for the farm operation.
///
/// Strictly enforces the separation between:
/// 1. Gross Sales Value (Total invoiced commercial produce)
/// 2. Collected Revenue (Liquid cash received into bank / MoMo / cashbox)
/// 3. Accounts Receivable (Unsettled credit owed by market buyers)
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Action',
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(Icons.arrow_upward, color: Color(0xFFDC2626)),
                  ),
                  title: const Text('Record Expense'),
                  subtitle: const Text('Log field costs, fertilizers, labour'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.addExpense);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.arrow_downward, color: Color(0xFF16A34A)),
                  ),
                  title: const Text('Record Harvest Sale'),
                  subtitle: const Text('Log sales agreements and buyer credit'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.addSale);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.payment, color: Color(0xFFD97706)),
                  ),
                  title: const Text('Record Payment Received'),
                  subtitle: const Text(
                    'Collect money on outstanding debtor sales',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.addPayment);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDBEAFE),
                    child: Icon(Icons.add_task, color: Color(0xFF1D4ED8)),
                  ),
                  title: const Text('Launch New Project'),
                  subtitle: const Text(
                    'Start a new crop, livestock, or aquaculture cycle',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.createProject);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(
                      Icons.landscape_outlined,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                  title: const Text('Register New Farm'),
                  subtitle: const Text(
                    'Add a landholding, family plot, or leased farm',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.createFarm);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final summaryAsync = ref.watch(dashboardFinancialSummaryProvider);
    final projectsAsync = ref.watch(projectsWithFarmStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Project Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: 'Quick Actions',
            onPressed: () => _showQuickActions(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        children: [
          // 1. Executive Financial Overview Card (Milestone 6.4)
          summaryAsync.when(
            loading: () => AppCard(
              title: 'Farm Financial Overview',
              subtitle: 'Calculating commercial liquidity & receivables...',
              leadingIcon: const Icon(Icons.account_balance_wallet_outlined),
              child: const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (err, _) => AppCard(
              title: 'Farm Financial Overview',
              subtitle: 'Error loading ledger',
              leadingIcon: const Icon(Icons.account_balance_wallet_outlined),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Unable to load financial summary: $err'),
              ),
            ),
            data: (summary) {
              final isCashProfitable = summary.cashProfit.isPositive;
              final isCashLoss = summary.cashProfit.isNegative;
              final hasReceivables = summary.accountsReceivable.isPositive;

              return AppCard(
                title: 'Farm Financial Overview',
                subtitle: 'Real-time performance across active projects',
                leadingIcon: const Icon(Icons.account_balance_wallet_outlined),
                trailingAction: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasReceivables
                        ? colors.healthYellowBg
                        : colors.healthGreenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasReceivables
                        ? '${summary.accountsReceivable.format()} Due'
                        : 'Credit Settled',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasReceivables
                          ? colors.healthYellow
                          : colors.healthGreen,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Gross Sales vs Total Invested
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MetricTile(
                          label: 'Gross Sales Value',
                          tooltip:
                              'Total value of all produce sold to date (Accrual)',
                          money: summary.grossSalesValue,
                          sentiment: MoneyDisplaySentiment.positive,
                          icon: Icons.storefront_outlined,
                        ),
                        const SizedBox(width: 12),
                        _MetricTile(
                          label: 'Total Invested / Spent',
                          tooltip:
                              'Total cash spent on inputs, equipment, and labour',
                          money: summary.totalInvested,
                          sentiment: MoneyDisplaySentiment.negative,
                          icon: Icons.trending_down,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // Second Row: Collected Revenue vs Accounts Receivable (Milestone 6.4 core)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MetricTile(
                          label: 'Collected Revenue',
                          tooltip:
                              'Liquid cash collected into pocket, MoMo, or bank',
                          money: summary.collectedRevenue,
                          sentiment: MoneyDisplaySentiment.positive,
                          icon: Icons.payments_outlined,
                          iconColor: colors.cashIn,
                        ),
                        const SizedBox(width: 12),
                        _MetricTile(
                          label: 'Accounts Receivable',
                          tooltip:
                              'Money owed by market buyers for credit sales',
                          money: summary.accountsReceivable,
                          sentiment: hasReceivables
                              ? MoneyDisplaySentiment.neutral
                              : MoneyDisplaySentiment.positive,
                          icon: Icons.hourglass_top_outlined,
                          iconColor: hasReceivables
                              ? colors.healthYellow
                              : colors.healthGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Collection Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: summary.grossSalesValue.isPositive
                                  ? (summary.collectionRatePercentage / 100.0)
                                        .clamp(0.0, 1.0)
                                  : 0.0,
                              minHeight: 6,
                              backgroundColor: theme.dividerColor.withAlpha(40),
                              color: colors.cashIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${summary.collectionRatePercentage.toStringAsFixed(0)}% Cash Collected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.cashIn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cash Profit vs Accrual Net Profit Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(120),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash-Basis Profit',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              MoneyDisplay(
                                money: summary.cashProfit,
                                showSign: true,
                                sentiment: isCashProfitable
                                    ? MoneyDisplaySentiment.positive
                                    : (isCashLoss
                                          ? MoneyDisplaySentiment.negative
                                          : MoneyDisplaySentiment.neutral),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Accrual Net Profit',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              MoneyDisplay(
                                money: summary.accrualProfit,
                                showSign: true,
                                sentiment: summary.accrualProfit.isPositive
                                    ? MoneyDisplaySentiment.positive
                                    : (summary.accrualProfit.isNegative
                                          ? MoneyDisplaySentiment.negative
                                          : MoneyDisplaySentiment.neutral),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Active Projects Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Projects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.projects),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),

          // 3. Active Projects List / Cards
          projectsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Error loading projects: $err'),
            ),
            data: (projectsWithFarm) {
              final activeProjects = projectsWithFarm.where((pwf) {
                final status = pwf.project.status.toUpperCase();
                return status != 'ARCHIVED' && status != 'COMPLETED';
              }).toList();

              if (activeProjects.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.agriculture_outlined,
                        size: 48,
                        color: theme.colorScheme.primary.withAlpha(150),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Active Farm Projects',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start a crop, livestock, or aquaculture cycle to track budgets, yields, and commercial sales.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.createProject),
                        icon: const Icon(Icons.add),
                        label: const Text('Launch First Project'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: activeProjects.take(3).map((pwf) {
                  return ProjectCard(
                    projectWithFarm: pwf,
                    onTap: () => context.push('/projects/${pwf.project.id}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showQuickActions(context),
        icon: const Icon(Icons.add),
        label: const Text('Quick Action'),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String? tooltip;
  final Money money;
  final MoneyDisplaySentiment sentiment;
  final IconData? icon;
  final Color? iconColor;

  const _MetricTile({
    required this.label,
    this.tooltip,
    required this.money,
    required this.sentiment,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: iconColor ?? Colors.grey),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          MoneyDisplay(
            money: money,
            sentiment: sentiment,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
