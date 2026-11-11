import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:uuid/uuid.dart';

import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../audit/data/repositories/audit_log_repository_impl.dart';
import '../../../audit/domain/models/audit_action.dart';
import '../../../audit/domain/repositories/audit_log_repository.dart';
import '../../domain/models/sale_payment_status.dart';
import '../../domain/models/sale_with_details.dart';
import '../../domain/models/sales_summary.dart';
import '../../domain/repositories/sale_repository.dart';

/// Concrete SQLite Drift implementation of [SaleRepository].
class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase _db;
  final Uuid _uuid;
  final AuditLogRepository _auditRepository;

  SaleRepositoryImpl({
    required AppDatabase db,
    Uuid uuid = const Uuid(),
    AuditLogRepository? auditRepository,
  }) : _db = db,
       _uuid = uuid,
       _auditRepository =
           auditRepository ?? AuditLogRepositoryImpl(db: db, uuid: uuid);

  @override
  Stream<List<SaleWithDetails>> watchSales({
    String? projectId,
    String? buyerId,
    String? harvestId,
    bool includeVoided = false,
  }) async* {
    yield await getSales(
      projectId: projectId,
      buyerId: buyerId,
      harvestId: harvestId,
      includeVoided: includeVoided,
    );
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.salesTable,
            _db.paymentsTable,
            _db.buyersTable,
            _db.harvestsTable,
            _db.projectsTable,
          ]),
        )
        .asyncMap(
          (_) => getSales(
            projectId: projectId,
            buyerId: buyerId,
            harvestId: harvestId,
            includeVoided: includeVoided,
          ),
        );
  }

  @override
  Future<List<SaleWithDetails>> getSales({
    String? projectId,
    String? buyerId,
    String? harvestId,
    bool includeVoided = false,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Fetch sales matching criteria
      final query = _db.select(_db.salesTable)
        ..where((s) => s.isDeleted.equals(false));

      if (!includeVoided) {
        query.where((s) => s.isVoided.equals(false));
      }
      if (projectId != null) {
        query.where((s) => s.projectId.equals(projectId));
      }
      if (buyerId != null) {
        query.where((s) => s.buyerId.equals(buyerId));
      }
      if (harvestId != null) {
        query.where((s) => s.harvestId.equals(harvestId));
      }

      query.orderBy([
        (s) => OrderingTerm.desc(s.saleDate),
        (s) => OrderingTerm.desc(s.createdAt),
      ]);

      final sales = await query.get();
      if (sales.isEmpty) return const [];

      // 2. Fetch all non-voided, non-deleted payments for these sales
      final saleIds = sales.map((s) => s.id).toSet();
      final payments =
          await (_db.select(_db.paymentsTable)..where(
                (p) =>
                    p.isDeleted.equals(false) &
                    p.isVoided.equals(false) &
                    p.saleId.isIn(saleIds),
              ))
              .get();

      final paidBySaleId = <String, int>{};
      for (final p in payments) {
        paidBySaleId[p.saleId] = (paidBySaleId[p.saleId] ?? 0) + p.amountMinor;
      }

      // 3. Fetch linked Projects, Buyers, and Harvests in batches
      final projectIds = sales.map((s) => s.projectId).toSet();
      final projects = await (_db.select(
        _db.projectsTable,
      )..where((p) => p.id.isIn(projectIds))).get();
      final projectMap = {for (final p in projects) p.id: p};

      final bIds = sales.map((s) => s.buyerId).whereType<String>().toSet();
      final buyerMap = <String, Buyer>{};
      if (bIds.isNotEmpty) {
        final buyers = await (_db.select(
          _db.buyersTable,
        )..where((b) => b.id.isIn(bIds))).get();
        for (final b in buyers) {
          buyerMap[b.id] = b;
        }
      }

      final hIds = sales.map((s) => s.harvestId).whereType<String>().toSet();
      final harvestMap = <String, Harvest>{};
      if (hIds.isNotEmpty) {
        final harvests = await (_db.select(
          _db.harvestsTable,
        )..where((h) => h.id.isIn(hIds))).get();
        for (final h in harvests) {
          harvestMap[h.id] = h;
        }
      }

      // 4. Map into SaleWithDetails
      return sales.map((sale) {
        final paidMinor = paidBySaleId[sale.id] ?? 0;
        return SaleWithDetails(
          sale: sale,
          project: projectMap[sale.projectId],
          buyer: sale.buyerId != null ? buyerMap[sale.buyerId!] : null,
          harvest: sale.harvestId != null ? harvestMap[sale.harvestId!] : null,
          totalPaidMinor: paidMinor,
        );
      }).toList();
    }, operationName: 'getSales');
  }

  @override
  Future<SaleWithDetails?> getSaleById(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final sale =
          await (_db.select(_db.salesTable)
                ..where((s) => s.id.equals(id) & s.isDeleted.equals(false)))
              .getSingleOrNull();

      if (sale == null) return null;

      final project = await (_db.select(
        _db.projectsTable,
      )..where((p) => p.id.equals(sale.projectId))).getSingleOrNull();

      Buyer? buyer;
      if (sale.buyerId != null) {
        buyer = await (_db.select(
          _db.buyersTable,
        )..where((b) => b.id.equals(sale.buyerId!))).getSingleOrNull();
      }

      Harvest? harvest;
      if (sale.harvestId != null) {
        harvest = await (_db.select(
          _db.harvestsTable,
        )..where((h) => h.id.equals(sale.harvestId!))).getSingleOrNull();
      }

      final payments =
          await (_db.select(_db.paymentsTable)..where(
                (p) =>
                    p.saleId.equals(id) &
                    p.isDeleted.equals(false) &
                    p.isVoided.equals(false),
              ))
              .get();

      final totalPaid = payments.fold<int>(0, (sum, p) => sum + p.amountMinor);

      return SaleWithDetails(
        sale: sale,
        project: project,
        buyer: buyer,
        harvest: harvest,
        totalPaidMinor: totalPaid,
      );
    }, operationName: 'getSaleById');
  }

  @override
  Future<String> recordSale({
    required String projectId,
    String? buyerId,
    String? harvestId,
    required DateTime saleDate,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    String currency = 'GHS',
    required SalePaymentStatus paymentStatus,
    int? initialPaymentAmountMinor,
    String? paymentMethod,
    String? notes,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Validation
      if (productName.trim().isEmpty) {
        throw const ValidationFailure('Product name cannot be empty.');
      }
      if (quantity <= 0) {
        throw const ValidationFailure('Quantity must be greater than zero.');
      }
      if (unit.trim().isEmpty) {
        throw const ValidationFailure('Unit of measure cannot be empty.');
      }
      if (unitPriceMinor < 0) {
        throw const ValidationFailure('Unit price cannot be negative.');
      }

      // 2. Validate project
      final project =
          await (_db.select(_db.projectsTable)..where(
                (p) => p.id.equals(projectId) & p.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      if (project == null) {
        throw const ValidationFailure('Project not found or deleted.');
      }

      // 3. Validate buyer if provided
      if (buyerId != null) {
        final buyer =
            await (_db.select(_db.buyersTable)..where(
                  (b) => b.id.equals(buyerId) & b.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (buyer == null) {
          throw const ValidationFailure('Buyer not found or deleted.');
        }
      }

      // 4. Validate harvest if provided
      if (harvestId != null) {
        final harvest =
            await (_db.select(_db.harvestsTable)..where(
                  (h) => h.id.equals(harvestId) & h.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (harvest == null) {
          throw const ValidationFailure('Harvest batch not found or deleted.');
        }
      }

      // 5. Compute total amount
      final totalAmountMinor = (quantity * unitPriceMinor).round();

      // Validate initial payment amount if partial
      if (paymentStatus == SalePaymentStatus.partial) {
        if (initialPaymentAmountMinor == null ||
            initialPaymentAmountMinor <= 0) {
          throw const ValidationFailure(
            'Partial payments require an initial payment amount greater than zero.',
          );
        }
        if (initialPaymentAmountMinor >= totalAmountMinor) {
          throw const ValidationFailure(
            'Initial deposit cannot meet or exceed the total sale amount. Use Paid status instead.',
          );
        }
      }

      final saleId = _uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      // 6. Insert Sale and any initial payment in a transaction
      await _db.transaction(() async {
        await _db
            .into(_db.salesTable)
            .insert(
              SalesTableCompanion.insert(
                id: saleId,
                projectId: projectId,
                buyerId: Value(buyerId),
                harvestId: Value(harvestId),
                saleDate: saleDate.millisecondsSinceEpoch,
                productName: productName.trim(),
                quantity: quantity,
                unit: unit.trim(),
                unitPriceMinor: unitPriceMinor,
                totalAmountMinor: totalAmountMinor,
                currency: Value(currency),
                paymentStatus: Value(paymentStatus.code),
                notes: Value(
                  notes?.trim().isEmpty == true ? null : notes?.trim(),
                ),
                isVoided: const Value(false),
                createdAt: now,
                updatedAt: now,
                isSynced: const Value(false),
                isDeleted: const Value(false),
              ),
            );

        // Record initial payment if Paid or Partial
        if (paymentStatus == SalePaymentStatus.paid) {
          await _db
              .into(_db.paymentsTable)
              .insert(
                PaymentsTableCompanion.insert(
                  id: _uuid.v4(),
                  saleId: saleId,
                  paymentDate: saleDate.millisecondsSinceEpoch,
                  amountMinor: totalAmountMinor,
                  currency: Value(currency),
                  paymentMethod: paymentMethod?.trim() ?? 'CASH',
                  referenceNumber: const Value('FULL_SETTLEMENT'),
                  notes: const Value('Initial payment upon sale'),
                  createdAt: now,
                  updatedAt: now,
                  isSynced: const Value(false),
                  isDeleted: const Value(false),
                ),
              );
        } else if (paymentStatus == SalePaymentStatus.partial &&
            initialPaymentAmountMinor != null &&
            initialPaymentAmountMinor > 0) {
          await _db
              .into(_db.paymentsTable)
              .insert(
                PaymentsTableCompanion.insert(
                  id: _uuid.v4(),
                  saleId: saleId,
                  paymentDate: saleDate.millisecondsSinceEpoch,
                  amountMinor: initialPaymentAmountMinor,
                  currency: Value(currency),
                  paymentMethod: paymentMethod?.trim() ?? 'CASH',
                  referenceNumber: const Value('INITIAL_DEPOSIT'),
                  notes: const Value('Initial partial payment upon sale'),
                  createdAt: now,
                  updatedAt: now,
                  isSynced: const Value(false),
                  isDeleted: const Value(false),
                ),
              );
        }
      });

      return saleId;
    }, operationName: 'recordSale');
  }

  @override
  Future<void> updateSale({
    required String id,
    String? buyerId,
    String? harvestId,
    required DateTime saleDate,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    String? notes,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      if (productName.trim().isEmpty) {
        throw const ValidationFailure('Product name cannot be empty.');
      }
      if (quantity <= 0) {
        throw const ValidationFailure('Quantity must be greater than zero.');
      }
      if (unit.trim().isEmpty) {
        throw const ValidationFailure('Unit of measure cannot be empty.');
      }
      if (unitPriceMinor < 0) {
        throw const ValidationFailure('Unit price cannot be negative.');
      }

      final existing = await getSaleById(id);
      if (existing == null) {
        throw const ValidationFailure('Sale transaction not found or deleted.');
      }
      if (existing.sale.isVoided) {
        throw const ValidationFailure('Voided sales cannot be edited.');
      }

      if (buyerId != null) {
        final buyer =
            await (_db.select(_db.buyersTable)..where(
                  (b) => b.id.equals(buyerId) & b.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (buyer == null) {
          throw const ValidationFailure('Buyer not found or deleted.');
        }
      }

      if (harvestId != null) {
        final harvest =
            await (_db.select(_db.harvestsTable)..where(
                  (h) => h.id.equals(harvestId) & h.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (harvest == null) {
          throw const ValidationFailure('Harvest batch not found or deleted.');
        }
      }

      final totalAmountMinor = (quantity * unitPriceMinor).round();
      final now = DateTime.now().millisecondsSinceEpoch;

      await (_db.update(_db.salesTable)..where((s) => s.id.equals(id))).write(
        SalesTableCompanion(
          buyerId: Value(buyerId),
          harvestId: Value(harvestId),
          saleDate: Value(saleDate.millisecondsSinceEpoch),
          productName: Value(productName.trim()),
          quantity: Value(quantity),
          unit: Value(unit.trim()),
          unitPriceMinor: Value(unitPriceMinor),
          totalAmountMinor: Value(totalAmountMinor),
          notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
          updatedAt: Value(now),
        ),
      );
    }, operationName: 'updateSale');
  }

  @override
  Future<void> voidSale(String id, {required String reason}) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedReason = reason.trim();
      if (trimmedReason.isEmpty) {
        throw const ValidationFailure('A reason is required to void a sale.');
      }

      final existing = await getSaleById(id);
      if (existing == null) {
        throw const ValidationFailure('Sale transaction not found or deleted.');
      }
      if (existing.sale.isVoided) {
        throw const ValidationFailure('Sale is already voided.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      await _db.transaction(() async {
        // Soft void the sale
        await (_db.update(_db.salesTable)..where((s) => s.id.equals(id))).write(
          SalesTableCompanion(
            isVoided: const Value(true),
            voidedAt: Value(now),
            voidReason: Value(trimmedReason),
            updatedAt: Value(now),
          ),
        );

        // Soft void any existing payments linked to this sale
        await (_db.update(
          _db.paymentsTable,
        )..where((p) => p.saleId.equals(id) & p.isVoided.equals(false))).write(
          PaymentsTableCompanion(
            isVoided: const Value(true),
            voidedAt: Value(now),
            voidReason: Value('Sale voided: $trimmedReason'),
            updatedAt: Value(now),
          ),
        );

        // Record immutable audit log entry
        await _auditRepository.logAction(
          entityTable: 'sales',
          entityId: id,
          action: AuditAction.voidRecord,
          previousState: {
            'id': existing.sale.id,
            'projectId': existing.sale.projectId,
            'totalAmountMinor': existing.sale.totalAmountMinor,
            'currency': existing.sale.currency,
            'isVoided': false,
            'productName': existing.sale.productName,
          },
          newState: {
            'id': existing.sale.id,
            'projectId': existing.sale.projectId,
            'totalAmountMinor': existing.sale.totalAmountMinor,
            'currency': existing.sale.currency,
            'isVoided': true,
            'voidReason': trimmedReason,
            'voidedAt': now,
            'productName': existing.sale.productName,
          },
          reason: trimmedReason,
        );
      });
    }, operationName: 'voidSale');
  }

  @override
  Stream<SalesSummary> watchSalesSummary({
    String? projectId,
    String? buyerId,
  }) async* {
    yield await getSalesSummary(projectId: projectId, buyerId: buyerId);
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([_db.salesTable, _db.paymentsTable]),
        )
        .asyncMap(
          (_) => getSalesSummary(projectId: projectId, buyerId: buyerId),
        );
  }

  @override
  Future<SalesSummary> getSalesSummary({
    String? projectId,
    String? buyerId,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final allSales = await getSales(
        projectId: projectId,
        buyerId: buyerId,
        includeVoided: true,
      );

      if (allSales.isEmpty) {
        return SalesSummary.zero();
      }

      int totalCount = 0;
      int voidedCount = 0;
      int paidCount = 0;
      int partialCount = 0;
      int unpaidCount = 0;

      BigInt grossMinor = BigInt.zero;
      BigInt collectedMinor = BigInt.zero;
      BigInt receivablesMinor = BigInt.zero;
      String currency = allSales.first.sale.currency;

      for (final s in allSales) {
        if (s.sale.isVoided) {
          voidedCount++;
          continue;
        }

        totalCount++;
        grossMinor += s.totalAmount.minorUnits;
        collectedMinor += s.paidAmount.minorUnits;
        receivablesMinor += s.remainingBalance.minorUnits;

        if (s.isFullyPaid) {
          paidCount++;
        } else if (s.isPartiallyPaid) {
          partialCount++;
        } else {
          unpaidCount++;
        }
      }

      return SalesSummary(
        totalSalesCount: totalCount,
        totalGrossSales: Money(grossMinor, currency: currency),
        totalCashCollected: Money(collectedMinor, currency: currency),
        totalAccountsReceivable: Money(receivablesMinor, currency: currency),
        paidSalesCount: paidCount,
        partialSalesCount: partialCount,
        unpaidSalesCount: unpaidCount,
        voidedSalesCount: voidedCount,
        currency: currency,
      );
    }, operationName: 'getSalesSummary');
  }
}
