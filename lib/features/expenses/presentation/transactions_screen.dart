import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/routes.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/money/money.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/money_display.dart';
import '../../budgets/presentation/providers/budget_category_providers.dart';
import '../../projects/presentation/providers/project_providers.dart';
import '../domain/models/expense_filter.dart';
import '../domain/models/expense_with_details.dart';
import 'providers/expense_providers.dart';
import 'widgets/expense_filter_sheet.dart';
import 'widgets/expense_tile.dart';

/// Main transactional ledger screen supporting multi-dimensional filtering
/// (Project, Category, Payment Method, Date Range, Amount Range, Status) and full-text search.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = ref.read(expenseFilterProvider);
    if (filter.searchQuery != null) {
      _searchController.text = filter.searchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(expenseFilterProvider.notifier).state = ref
        .read(expenseFilterProvider)
        .copyWith(searchQuery: query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(expenseFilterProvider.notifier).state = ref
        .read(expenseFilterProvider)
        .copyWith(clearSearch: true);
  }

  void _resetAllFilters() {
    _searchController.clear();
    ref.read(expenseFilterProvider.notifier).state = const ExpenseFilter();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(expenseFilterProvider);
    final expensesAsync = ref.watch(filteredExpensesProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Ledger'),
        actions: [
          // Filter Button with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter Ledger',
                onPressed: () => ExpenseFilterSheet.show(context),
              ),
              if (filter.activeFilterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${filter.activeFilterCount}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Customer Directory',
            onPressed: () => context.push(AppRoutes.buyers),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Record Expense',
            onPressed: () => context.push(AppRoutes.addExpense),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.addExpense),
        icon: const Icon(Icons.add),
        label: const Text('Record Expense'),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search description, vendor, or notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),

          // 2. Active Filter Chips Row (if any filter is active)
          if (filter.hasActiveFilters)
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Status filter chip
                  if (filter.status != ExpenseStatusFilter.all)
                    _buildActiveChip(
                      label: 'Status: ${filter.status.displayName}',
                      onDeleted: () {
                        ref.read(expenseFilterProvider.notifier).state = filter
                            .copyWith(status: ExpenseStatusFilter.all);
                      },
                    ),

                  // Project filter chip
                  if (filter.projectId != null)
                    _buildActiveChip(
                      label:
                          'Project: ${_resolveProjectName(projectsAsync, filter.projectId!)}',
                      onDeleted: () {
                        ref.read(expenseFilterProvider.notifier).state = filter
                            .copyWith(clearProject: true);
                      },
                    ),

                  // Category filter chip
                  if (filter.categoryId != null)
                    _buildActiveChip(
                      label:
                          'Category: ${_resolveCategoryName(categoriesAsync, filter.categoryId!)}',
                      onDeleted: () {
                        ref.read(expenseFilterProvider.notifier).state = filter
                            .copyWith(clearCategory: true);
                      },
                    ),

                  // Payment method filter chip
                  if (filter.paymentMethod != null)
                    _buildActiveChip(
                      label: filter.paymentMethod!.displayName,
                      onDeleted: () {
                        ref.read(expenseFilterProvider.notifier).state = filter
                            .copyWith(clearPaymentMethod: true);
                      },
                    ),

                  // Date range filter chip
                  if (filter.startDate != null || filter.endDate != null)
                    _buildActiveChip(
                      label: filter.startDate != null && filter.endDate != null
                          ? '${filter.startDate!.toDisplayDate()} – ${filter.endDate!.toDisplayDate()}'
                          : (filter.startDate != null
                                ? 'From ${filter.startDate!.toDisplayDate()}'
                                : 'Until ${filter.endDate!.toDisplayDate()}'),
                      onDeleted: () {
                        ref.read(expenseFilterProvider.notifier).state = filter
                            .copyWith(clearDates: true);
                      },
                    ),

                  // Amount range filter chip
                  if (filter.minAmountMinor != null ||
                      filter.maxAmountMinor != null)
                    _buildActiveChip(
                      label:
                          'Amount: ${filter.minAmountMinor != null ? "≥ GH₵ ${(filter.minAmountMinor! / 100).toStringAsFixed(0)}" : ""} ${filter.maxAmountMinor != null ? "≤ GH₵ ${(filter.maxAmountMinor! / 100).toStringAsFixed(0)}" : ""}',
                      onDeleted: () {
                        ref.read(expenseFilterProvider.notifier).state = filter
                            .copyWith(clearAmountRange: true);
                      },
                    ),

                  // Reset All Button
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ActionChip(
                      avatar: const Icon(Icons.refresh, size: 14),
                      label: const Text('Clear All'),
                      onPressed: _resetAllFilters,
                    ),
                  ),
                ],
              ),
            ),

          // 3. Transactions List & Summaries
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading transactions: $err'),
                ),
              ),
              data: (List<ExpenseWithDetails> expenses) {
                if (expenses.isEmpty) {
                  if (filter.hasActiveFilters) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 56,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No transactions match your filters',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting or resetting your search and filter criteria.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _resetAllFilters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset All Filters'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: theme.colorScheme.primary.withAlpha(140),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions recorded yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log your field expenses, inputs, labour, and transport.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 48),
                            ),
                            onPressed: () => context.push(AppRoutes.addExpense),
                            icon: const Icon(Icons.add),
                            label: const Text('Record First Expense'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Calculate matching summary totals
                final activeExpenses = expenses
                    .where((e) => !e.isVoided)
                    .toList();
                BigInt totalSpentPesewas = BigInt.zero;
                for (final exp in activeExpenses) {
                  totalSpentPesewas += exp.amount.minorUnits;
                }
                final totalSpent = Money(totalSpentPesewas, currency: 'GHS');

                return ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 90),
                  children: [
                    // Summary Header Card
                    AppCard(
                      title: filter.hasActiveFilters
                          ? 'Filtered Transactions (${expenses.length})'
                          : 'Total Active Expenditure',
                      subtitle:
                          '${activeExpenses.length} active • ${expenses.length - activeExpenses.length} voided',
                      leadingIcon: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MoneyDisplay(
                            money: totalSpent,
                            sentiment: MoneyDisplaySentiment.negative,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter.hasActiveFilters
                                ? 'Sum of active transactions matching selected filters'
                                : 'Across all farm projects and field operations',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Transaction Items
                    ...expenses.map((exp) => ExpenseTile(expense: exp)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        backgroundColor: theme.colorScheme.primaryContainer.withAlpha(140),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _resolveProjectName(
    AsyncValue<List<Project>> asyncProjects,
    String projectId,
  ) {
    return asyncProjects.maybeWhen(
      data: (projects) {
        final match = projects.where((p) => p.id == projectId);
        return match.isNotEmpty ? match.first.name : 'Selected';
      },
      orElse: () => 'Selected',
    );
  }

  String _resolveCategoryName(
    AsyncValue<List<BudgetCategory>> asyncCategories,
    String categoryId,
  ) {
    return asyncCategories.maybeWhen(
      data: (categories) {
        final match = categories.where((c) => c.id == categoryId);
        return match.isNotEmpty ? match.first.name : 'Selected';
      },
      orElse: () => 'Selected',
    );
  }
}
