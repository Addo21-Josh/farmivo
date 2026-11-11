import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/dashboard_financial_summary.dart';

/// Reactive stream of aggregated financial metrics for the entire farm enterprise,
/// enforcing strict separation of Gross Sales Value, Collected Revenue, and Accounts Receivable.
final dashboardFinancialSummaryProvider =
    StreamProvider<DashboardFinancialSummary>((ref) {
      final db = ref.watch(databaseProvider);

      Future<DashboardFinancialSummary> compute() async {
        // 1. Projects
        final projects = await (db.select(
          db.projectsTable,
        )..where((p) => p.isDeleted.equals(false))).get();

        final activeProjects = projects.where((p) {
          final status = p.status.toUpperCase();
          return status != 'ARCHIVED' && status != 'COMPLETED';
        }).toList();

        // 2. Expenses (invested)
        final expenses =
            await (db.select(db.expensesTable)..where(
                  (e) => e.isDeleted.equals(false) & e.isVoided.equals(false),
                ))
                .get();
        final totalSpentMinor = expenses.fold<BigInt>(
          BigInt.zero,
          (acc, e) => acc + BigInt.from(e.amountMinor),
        );

        // 3. Sales (gross sales)
        final sales =
            await (db.select(db.salesTable)..where(
                  (s) => s.isDeleted.equals(false) & s.isVoided.equals(false),
                ))
                .get();
        final grossMinor = sales.fold<BigInt>(
          BigInt.zero,
          (acc, s) => acc + BigInt.from(s.totalAmountMinor),
        );

        // 4. Payments (collected cash on active sales)
        final activeSaleIds = sales.map((s) => s.id).toSet();
        final payments = activeSaleIds.isEmpty
            ? <Payment>[]
            : await (db.select(db.paymentsTable)..where(
                    (p) =>
                        p.saleId.isIn(activeSaleIds) & p.isVoided.equals(false),
                  ))
                  .get();

        final collectedMinor = payments.fold<BigInt>(
          BigInt.zero,
          (acc, p) => acc + BigInt.from(p.amountMinor),
        );

        // Outstanding debt (Accounts Receivable)
        final receivablesMinor = grossMinor > collectedMinor
            ? grossMinor - collectedMinor
            : BigInt.zero;

        // Debtors count (buyers with outstanding debt)
        final buyerDebts = <String, int>{};
        for (final s in sales) {
          if (s.buyerId != null) {
            buyerDebts[s.buyerId!] =
                (buyerDebts[s.buyerId!] ?? 0) + s.totalAmountMinor;
          }
        }
        for (final p in payments) {
          final sale = sales.firstWhere(
            (s) => s.id == p.saleId,
            orElse: () => sales.first,
          );
          if (sale.buyerId != null && buyerDebts.containsKey(sale.buyerId)) {
            buyerDebts[sale.buyerId!] =
                buyerDebts[sale.buyerId!]! - p.amountMinor;
          }
        }
        final debtorsCount = buyerDebts.values.where((d) => d > 0).length;

        final currency = projects.isNotEmpty ? projects.first.currency : 'GHS';

        return DashboardFinancialSummary(
          totalInvested: Money(totalSpentMinor, currency: currency),
          grossSalesValue: Money(grossMinor, currency: currency),
          collectedRevenue: Money(collectedMinor, currency: currency),
          accountsReceivable: Money(receivablesMinor, currency: currency),
          activeProjectsCount: activeProjects.length,
          debtorsCount: debtorsCount,
          currency: currency,
        );
      }

      Stream<DashboardFinancialSummary> stream() async* {
        yield await compute();
        yield* db
            .tableUpdates(
              TableUpdateQuery.onAllTables([
                db.projectsTable,
                db.expensesTable,
                db.salesTable,
                db.paymentsTable,
                db.buyersTable,
              ]),
            )
            .asyncMap((_) => compute());
      }

      return stream();
    });
