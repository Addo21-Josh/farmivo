import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/financial_engine/project_comparison.dart';
import '../../../../core/money/money.dart';
import '../../../budgets/domain/models/budget_variance.dart';
import '../../../budgets/presentation/providers/budget_variance_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../projects/presentation/providers/project_comparison_providers.dart';
import '../../../sales/presentation/providers/sale_providers.dart';
import '../../domain/models/cash_flow_point.dart';
import '../../domain/models/category_expense_share.dart';

/// Currently selected project ID for reporting analytics.
/// `null` represents the aggregate portfolio view (all projects).
final selectedReportProjectIdProvider = StateProvider<String?>((ref) => null);

/// Provider computing expense distribution across categories for the selected project (or all projects).
final reportCategoryExpenseSharesProvider =
    Provider.autoDispose<AsyncValue<List<CategoryExpenseShare>>>((ref) {
      final selectedProjectId = ref.watch(selectedReportProjectIdProvider);

      final expensesAsync = selectedProjectId == null
          ? ref.watch(allExpensesWithDetailsProvider)
          : ref.watch(projectExpensesWithDetailsProvider(selectedProjectId));

      return expensesAsync.whenData((expensesWithDetails) {
        final active = expensesWithDetails
            .where((e) => !e.expense.isVoided)
            .toList();
        if (active.isEmpty) {
          return const [];
        }

        // Accumulate minor units per category
        final categoryTotals =
            <String, ({String name, BigInt totalMinor, String currency})>{};
        BigInt grandTotalMinor = BigInt.zero;
        String currency = 'GHS';

        for (final item in active) {
          final catId = item.category.id;
          final catName = item.category.name;
          final amountMinor = BigInt.from(item.expense.amountMinor);
          currency = item.expense.currency;

          grandTotalMinor += amountMinor;

          final existing = categoryTotals[catId];
          if (existing == null) {
            categoryTotals[catId] = (
              name: catName,
              totalMinor: amountMinor,
              currency: currency,
            );
          } else {
            categoryTotals[catId] = (
              name: catName,
              totalMinor: existing.totalMinor + amountMinor,
              currency: currency,
            );
          }
        }

        final grandTotalDouble = grandTotalMinor.toDouble();
        final result = <CategoryExpenseShare>[];

        var index = 0;
        // Sort descending by amount
        final sortedEntries = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.totalMinor.compareTo(a.value.totalMinor));

        for (final entry in sortedEntries) {
          final total = entry.value.totalMinor;
          final pct = grandTotalDouble > 0
              ? (total.toDouble() / grandTotalDouble) * 100.0
              : 0.0;

          result.add(
            CategoryExpenseShare(
              categoryId: entry.key,
              categoryName: entry.value.name,
              totalSpent: Money(total, currency: entry.value.currency),
              percentage: (pct * 10).round() / 10.0,
              color: CategoryExpenseShare.resolveColor(index),
            ),
          );
          index++;
        }

        return result;
      });
    });

/// Provider computing chronological cumulative cash flow timeline (cash in vs. cash out).
final reportCashFlowTimelineProvider =
    Provider.autoDispose<AsyncValue<List<CashFlowPoint>>>((ref) {
      final selectedProjectId = ref.watch(selectedReportProjectIdProvider);

      final expensesAsync = selectedProjectId == null
          ? ref.watch(allExpensesWithDetailsProvider)
          : ref.watch(projectExpensesWithDetailsProvider(selectedProjectId));

      final salesAsync = selectedProjectId == null
          ? ref.watch(allSalesProvider)
          : ref.watch(projectSalesWithDetailsProvider(selectedProjectId));

      if (expensesAsync.isLoading || salesAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (expensesAsync.hasError) {
        return AsyncValue.error(
          expensesAsync.error!,
          expensesAsync.stackTrace!,
        );
      }
      if (salesAsync.hasError) {
        return AsyncValue.error(salesAsync.error!, salesAsync.stackTrace!);
      }

      final expenses = (expensesAsync.value ?? [])
          .where((e) => !e.expense.isVoided)
          .map((e) => (timestamp: e.expense.transactionDate, amount: e.amount))
          .toList();

      final sales = (salesAsync.value ?? [])
          .where((s) => !s.sale.isVoided && s.paidAmount.isPositive)
          .map((s) => (timestamp: s.sale.saleDate, amount: s.paidAmount))
          .toList();

      final timeline = CashFlowPoint.buildTimeline(
        cashInTransactions: sales,
        cashOutTransactions: expenses,
      );

      return AsyncValue.data(timeline);
    });

/// Provider delivering budget variance report for the selected project (or null if portfolio view).
final reportVarianceProvider =
    Provider.autoDispose<AsyncValue<ProjectVarianceReport?>>((ref) {
      final selectedProjectId = ref.watch(selectedReportProjectIdProvider);
      if (selectedProjectId == null) {
        return const AsyncValue.data(null);
      }

      final reportAsync = ref.watch(
        projectVarianceReportProvider(selectedProjectId),
      );
      return reportAsync.whenData((report) => report);
    });

/// Provider delivering the project comparison matrix across all active and completed projects.
final reportComparisonMatrixProvider =
    Provider.autoDispose<AsyncValue<ProjectComparisonMatrix>>((ref) {
      final allRecordsAsync = ref.watch(allProjectsComparisonProvider);

      return allRecordsAsync.whenData((records) {
        return ProjectComparisonMatrix.compute(records);
      });
    });
