import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:uuid/uuid.dart';

import 'package:farmivo/core/errors/database_exception_mapper.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/domain/models/buyers_directory_summary.dart';
import 'package:farmivo/features/buyers/domain/repositories/buyer_repository.dart';

/// Concrete SQLite Drift implementation of [BuyerRepository].
class BuyerRepositoryImpl implements BuyerRepository {
  final AppDatabase _db;
  final Uuid _uuid;

  BuyerRepositoryImpl({required AppDatabase db, Uuid uuid = const Uuid()})
    : _db = db,
      _uuid = uuid;

  @override
  Stream<List<BuyerSummary>> watchBuyers({
    String? searchQuery,
    bool onlyDebtors = false,
  }) async* {
    yield await getBuyers(searchQuery: searchQuery, onlyDebtors: onlyDebtors);
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.buyersTable,
            _db.salesTable,
            _db.paymentsTable,
          ]),
        )
        .asyncMap(
          (_) => getBuyers(searchQuery: searchQuery, onlyDebtors: onlyDebtors),
        );
  }

  @override
  Future<List<BuyerSummary>> getBuyers({
    String? searchQuery,
    bool onlyDebtors = false,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Fetch all active buyers
      final buyers =
          await (_db.select(_db.buyersTable)
                ..where((b) => b.isDeleted.equals(false))
                ..orderBy([(b) => OrderingTerm.asc(b.name)]))
              .get();

      if (buyers.isEmpty) return const [];

      // 2. Fetch all active, non-voided sales
      final activeSales =
          await (_db.select(_db.salesTable)..where(
                (s) =>
                    s.isDeleted.equals(false) &
                    s.isVoided.equals(false) &
                    s.buyerId.isNotNull(),
              ))
              .get();

      // 3. Fetch all active, non-voided payments
      final activePayments =
          await (_db.select(_db.paymentsTable)..where(
                (p) => p.isDeleted.equals(false) & p.isVoided.equals(false),
              ))
              .get();

      // Index payments by sale ID
      final paymentsBySaleId = <String, int>{};
      for (final p in activePayments) {
        paymentsBySaleId[p.saleId] =
            (paymentsBySaleId[p.saleId] ?? 0) + p.amountMinor;
      }

      // Group sales by buyer ID
      final salesByBuyerId = <String, List<Sale>>{};
      for (final s in activeSales) {
        if (s.buyerId != null) {
          salesByBuyerId.putIfAbsent(s.buyerId!, () => []).add(s);
        }
      }

      // 4. Compute summaries
      var summaries = buyers.map((buyer) {
        final buyerSales = salesByBuyerId[buyer.id] ?? const [];
        BigInt totalPurchasedMinor = BigInt.zero;
        BigInt totalPaidMinor = BigInt.zero;
        DateTime? lastTx;

        for (final sale in buyerSales) {
          totalPurchasedMinor += BigInt.from(sale.totalAmountMinor);
          final paidForSale = paymentsBySaleId[sale.id] ?? 0;
          totalPaidMinor += BigInt.from(paidForSale);

          final saleDate = DateTime.fromMillisecondsSinceEpoch(sale.saleDate);
          if (lastTx == null || saleDate.isAfter(lastTx)) {
            lastTx = saleDate;
          }
        }

        final outstandingMinor = totalPurchasedMinor > totalPaidMinor
            ? totalPurchasedMinor - totalPaidMinor
            : BigInt.zero;

        return BuyerSummary(
          buyer: buyer,
          totalPurchased: Money(totalPurchasedMinor),
          totalPaid: Money(totalPaidMinor),
          outstandingBalance: Money(outstandingMinor),
          salesCount: buyerSales.length,
          lastTransactionDate: lastTx,
        );
      }).toList();

      // 5. Apply filtering
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        summaries = summaries.where((b) {
          final nameMatch = b.name.toLowerCase().contains(q);
          final phoneMatch = b.phone?.toLowerCase().contains(q) ?? false;
          final bizMatch = b.businessName?.toLowerCase().contains(q) ?? false;
          final locMatch = b.location?.toLowerCase().contains(q) ?? false;
          return nameMatch || phoneMatch || bizMatch || locMatch;
        }).toList();
      }

      if (onlyDebtors) {
        summaries = summaries.where((b) => b.hasDebt).toList();
      }

      // 6. Sort: Debtors with highest outstanding balance first, then alphabetical
      summaries.sort((a, b) {
        final aDebt = a.outstandingBalance.minorUnits;
        final bDebt = b.outstandingBalance.minorUnits;
        if (aDebt > BigInt.zero || bDebt > BigInt.zero) {
          final cmp = bDebt.compareTo(aDebt);
          if (cmp != 0) return cmp;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return summaries;
    }, operationName: 'getBuyers');
  }

  @override
  Stream<BuyerSummary?> watchBuyerSummaryById(String id) async* {
    yield await getBuyerSummaryById(id);
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.buyersTable,
            _db.salesTable,
            _db.paymentsTable,
          ]),
        )
        .asyncMap((_) => getBuyerSummaryById(id));
  }

  @override
  Future<BuyerSummary?> getBuyerSummaryById(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final buyer =
          await (_db.select(_db.buyersTable)
                ..where((b) => b.id.equals(id) & b.isDeleted.equals(false)))
              .getSingleOrNull();

      if (buyer == null) return null;

      final sales =
          await (_db.select(_db.salesTable)..where(
                (s) =>
                    s.buyerId.equals(id) &
                    s.isDeleted.equals(false) &
                    s.isVoided.equals(false),
              ))
              .get();

      BigInt totalPurchasedMinor = BigInt.zero;
      BigInt totalPaidMinor = BigInt.zero;
      DateTime? lastTx;

      if (sales.isNotEmpty) {
        final saleIds = sales.map((s) => s.id).toList();
        final payments =
            await (_db.select(_db.paymentsTable)..where(
                  (p) =>
                      p.saleId.isIn(saleIds) &
                      p.isDeleted.equals(false) &
                      p.isVoided.equals(false),
                ))
                .get();

        final paymentsBySaleId = <String, int>{};
        for (final p in payments) {
          paymentsBySaleId[p.saleId] =
              (paymentsBySaleId[p.saleId] ?? 0) + p.amountMinor;
        }

        for (final sale in sales) {
          totalPurchasedMinor += BigInt.from(sale.totalAmountMinor);
          final paidForSale = paymentsBySaleId[sale.id] ?? 0;
          totalPaidMinor += BigInt.from(paidForSale);

          final saleDate = DateTime.fromMillisecondsSinceEpoch(sale.saleDate);
          if (lastTx == null || saleDate.isAfter(lastTx)) {
            lastTx = saleDate;
          }
        }
      }

      final outstandingMinor = totalPurchasedMinor > totalPaidMinor
          ? totalPurchasedMinor - totalPaidMinor
          : BigInt.zero;

      return BuyerSummary(
        buyer: buyer,
        totalPurchased: Money(totalPurchasedMinor),
        totalPaid: Money(totalPaidMinor),
        outstandingBalance: Money(outstandingMinor),
        salesCount: sales.length,
        lastTransactionDate: lastTx,
      );
    }, operationName: 'getBuyerSummaryById');
  }

  @override
  Future<Buyer?> getBuyerById(String id) async {
    return DatabaseExceptionMapper.runSafe(() {
      return (_db.select(_db.buyersTable)
            ..where((b) => b.id.equals(id) & b.isDeleted.equals(false)))
          .getSingleOrNull();
    }, operationName: 'getBuyerById');
  }

  @override
  Future<String> createBuyer({
    required String name,
    String? phone,
    String? businessName,
    String? location,
    String? notes,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw const ValidationFailure('Buyer name cannot be empty.');
      }

      final id = _uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      await _db
          .into(_db.buyersTable)
          .insert(
            BuyersTableCompanion.insert(
              id: id,
              name: trimmedName,
              phone: Value(
                phone?.trim().isEmpty == true ? null : phone?.trim(),
              ),
              businessName: Value(
                businessName?.trim().isEmpty == true
                    ? null
                    : businessName?.trim(),
              ),
              location: Value(
                location?.trim().isEmpty == true ? null : location?.trim(),
              ),
              notes: Value(
                notes?.trim().isEmpty == true ? null : notes?.trim(),
              ),
              createdAt: now,
              updatedAt: now,
              isSynced: const Value(false),
              isDeleted: const Value(false),
            ),
          );

      return id;
    }, operationName: 'createBuyer');
  }

  @override
  Future<void> updateBuyer({
    required String id,
    required String name,
    String? phone,
    String? businessName,
    String? location,
    String? notes,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw const ValidationFailure('Buyer name cannot be empty.');
      }

      final existing = await getBuyerById(id);
      if (existing == null) {
        throw const ValidationFailure('Buyer not found or already deleted.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      await (_db.update(_db.buyersTable)..where((b) => b.id.equals(id))).write(
        BuyersTableCompanion(
          name: Value(trimmedName),
          phone: Value(phone?.trim().isEmpty == true ? null : phone?.trim()),
          businessName: Value(
            businessName?.trim().isEmpty == true ? null : businessName?.trim(),
          ),
          location: Value(
            location?.trim().isEmpty == true ? null : location?.trim(),
          ),
          notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'updateBuyer');
  }

  @override
  Future<void> deleteBuyer(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await (_db.update(_db.buyersTable)..where((b) => b.id.equals(id))).write(
        BuyersTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'deleteBuyer');
  }

  @override
  Stream<BuyersDirectorySummary> watchDirectorySummary() async* {
    yield await getDirectorySummary();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.buyersTable,
            _db.salesTable,
            _db.paymentsTable,
          ]),
        )
        .asyncMap((_) => getDirectorySummary());
  }

  @override
  Future<BuyersDirectorySummary> getDirectorySummary() async {
    return DatabaseExceptionMapper.runSafe(() async {
      final allBuyers = await getBuyers();
      int total = allBuyers.length;
      int debtors = 0;
      BigInt totalRec = BigInt.zero;
      BigInt totalSales = BigInt.zero;
      BigInt totalPaid = BigInt.zero;

      for (final b in allBuyers) {
        if (b.hasDebt) debtors++;
        totalRec += b.outstandingBalance.minorUnits;
        totalSales += b.totalPurchased.minorUnits;
        totalPaid += b.totalPaid.minorUnits;
      }

      return BuyersDirectorySummary(
        totalBuyers: total,
        activeDebtorsCount: debtors,
        totalReceivables: Money(totalRec),
        totalSalesVolume: Money(totalSales),
        totalCashCollected: Money(totalPaid),
      );
    }, operationName: 'getDirectorySummary');
  }
}
