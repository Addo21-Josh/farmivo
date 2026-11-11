import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:uuid/uuid.dart';

import '../../../../core/errors/database_exception_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../audit/data/repositories/audit_log_repository_impl.dart';
import '../../../audit/domain/models/audit_action.dart';
import '../../../audit/domain/repositories/audit_log_repository.dart';
import '../../../expenses/domain/models/payment_method.dart';
import '../../domain/models/payment_with_details.dart';
import '../../domain/repositories/payment_repository.dart';

/// Concrete SQLite Drift implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  final AppDatabase _db;
  final Uuid _uuid;
  final AuditLogRepository _auditRepository;

  PaymentRepositoryImpl({
    required AppDatabase db,
    Uuid uuid = const Uuid(),
    AuditLogRepository? auditRepository,
  }) : _db = db,
       _uuid = uuid,
       _auditRepository =
           auditRepository ?? AuditLogRepositoryImpl(db: db, uuid: uuid);

  @override
  Stream<List<PaymentWithDetails>> watchPayments({
    String? saleId,
    String? buyerId,
    String? projectId,
    bool includeVoided = false,
  }) async* {
    yield await getPayments(
      saleId: saleId,
      buyerId: buyerId,
      projectId: projectId,
      includeVoided: includeVoided,
    );
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            _db.paymentsTable,
            _db.salesTable,
            _db.buyersTable,
            _db.projectsTable,
          ]),
        )
        .asyncMap(
          (_) => getPayments(
            saleId: saleId,
            buyerId: buyerId,
            projectId: projectId,
            includeVoided: includeVoided,
          ),
        );
  }

  @override
  Future<List<PaymentWithDetails>> getPayments({
    String? saleId,
    String? buyerId,
    String? projectId,
    bool includeVoided = false,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Fetch payments matching criteria
      final query = _db.select(_db.paymentsTable)
        ..where((p) => p.isDeleted.equals(false));

      if (!includeVoided) {
        query.where((p) => p.isVoided.equals(false));
      }
      if (saleId != null) {
        query.where((p) => p.saleId.equals(saleId));
      }

      query.orderBy([
        (p) => OrderingTerm.desc(p.paymentDate),
        (p) => OrderingTerm.desc(p.createdAt),
      ]);

      var payments = await query.get();
      if (payments.isEmpty) return const [];

      // 2. Fetch associated sales
      final saleIds = payments.map((p) => p.saleId).toSet();
      final sales = await (_db.select(
        _db.salesTable,
      )..where((s) => s.id.isIn(saleIds))).get();
      final saleMap = {for (final s in sales) s.id: s};

      // Filter by projectId or buyerId if specified at sale level
      if (projectId != null || buyerId != null) {
        payments = payments.where((p) {
          final s = saleMap[p.saleId];
          if (s == null) return false;
          if (projectId != null && s.projectId != projectId) return false;
          if (buyerId != null && s.buyerId != buyerId) return false;
          return true;
        }).toList();
      }

      if (payments.isEmpty) return const [];

      // 3. Batch fetch linked buyers and projects
      final activeSales = payments
          .map((p) => saleMap[p.saleId])
          .whereType<Sale>();
      final projectIds = activeSales.map((s) => s.projectId).toSet();
      final projects = await (_db.select(
        _db.projectsTable,
      )..where((pr) => pr.id.isIn(projectIds))).get();
      final projectMap = {for (final pr in projects) pr.id: pr};

      final bIds = activeSales
          .map((s) => s.buyerId)
          .whereType<String>()
          .toSet();
      final buyerMap = <String, Buyer>{};
      if (bIds.isNotEmpty) {
        final buyers = await (_db.select(
          _db.buyersTable,
        )..where((b) => b.id.isIn(bIds))).get();
        for (final b in buyers) {
          buyerMap[b.id] = b;
        }
      }

      // 4. Map into PaymentWithDetails
      return payments.map((p) {
        final sale = saleMap[p.saleId];
        return PaymentWithDetails(
          payment: p,
          sale: sale,
          buyer: sale?.buyerId != null ? buyerMap[sale!.buyerId!] : null,
          project: sale != null ? projectMap[sale.projectId] : null,
        );
      }).toList();
    }, operationName: 'getPayments');
  }

  @override
  Future<PaymentWithDetails?> getPaymentById(String id) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final payment =
          await (_db.select(_db.paymentsTable)
                ..where((p) => p.id.equals(id) & p.isDeleted.equals(false)))
              .getSingleOrNull();

      if (payment == null) return null;

      final sale = await (_db.select(
        _db.salesTable,
      )..where((s) => s.id.equals(payment.saleId))).getSingleOrNull();

      Buyer? buyer;
      Project? project;

      if (sale != null) {
        if (sale.buyerId != null) {
          buyer = await (_db.select(
            _db.buyersTable,
          )..where((b) => b.id.equals(sale.buyerId!))).getSingleOrNull();
        }
        project = await (_db.select(
          _db.projectsTable,
        )..where((pr) => pr.id.equals(sale.projectId))).getSingleOrNull();
      }

      return PaymentWithDetails(
        payment: payment,
        sale: sale,
        buyer: buyer,
        project: project,
      );
    }, operationName: 'getPaymentById');
  }

  @override
  Future<String> recordPayment({
    required String saleId,
    required DateTime paymentDate,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    return DatabaseExceptionMapper.runSafe(() async {
      // 1. Validation
      if (amountMinor <= 0) {
        throw const ValidationFailure(
          'Payment amount must be greater than zero.',
        );
      }

      // 2. Validate sale existence and state
      final sale =
          await (_db.select(_db.salesTable)
                ..where((s) => s.id.equals(saleId) & s.isDeleted.equals(false)))
              .getSingleOrNull();

      if (sale == null) {
        throw const ValidationFailure('Sale transaction not found or deleted.');
      }
      if (sale.isVoided) {
        throw const ValidationFailure(
          'Cannot record payments against a voided commercial sale.',
        );
      }

      // 3. Compute current settled payments and remaining balance
      final existingPayments =
          await (_db.select(_db.paymentsTable)..where(
                (p) =>
                    p.saleId.equals(saleId) &
                    p.isDeleted.equals(false) &
                    p.isVoided.equals(false),
              ))
              .get();

      final currentTotalPaid = existingPayments.fold<int>(
        0,
        (sum, p) => sum + p.amountMinor,
      );

      final remainingBalanceMinor = sale.totalAmountMinor - currentTotalPaid;
      if (remainingBalanceMinor <= 0) {
        throw const ValidationFailure(
          'This commercial sale agreement is already fully settled.',
        );
      }

      if (amountMinor > remainingBalanceMinor) {
        final payFmt = (amountMinor / 100).toStringAsFixed(2);
        final remFmt = (remainingBalanceMinor / 100).toStringAsFixed(2);
        throw ValidationFailure(
          'Payment amount (GH₵ $payFmt) exceeds remaining balance (GH₵ $remFmt).',
        );
      }

      final paymentId = _uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      final newTotalPaid = currentTotalPaid + amountMinor;

      // 4. Atomic execution: insert payment + auto-update sale status
      await _db.transaction(() async {
        await _db
            .into(_db.paymentsTable)
            .insert(
              PaymentsTableCompanion.insert(
                id: paymentId,
                saleId: saleId,
                paymentDate: paymentDate.millisecondsSinceEpoch,
                amountMinor: amountMinor,
                currency: Value(currency),
                paymentMethod: paymentMethod.code,
                referenceNumber: Value(
                  referenceNumber?.trim().isEmpty == true
                      ? null
                      : referenceNumber?.trim(),
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

        // Determine new sale payment status
        final newStatus = newTotalPaid >= sale.totalAmountMinor
            ? 'PAID'
            : 'PARTIAL';

        await (_db.update(
          _db.salesTable,
        )..where((s) => s.id.equals(saleId))).write(
          SalesTableCompanion(
            paymentStatus: Value(newStatus),
            updatedAt: Value(now),
          ),
        );
      });

      return paymentId;
    }, operationName: 'recordPayment');
  }

  @override
  Future<void> voidPayment(String id, {required String reason}) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final trimmedReason = reason.trim();
      if (trimmedReason.isEmpty) {
        throw const ValidationFailure(
          'A reason is required to void a payment.',
        );
      }

      final payment =
          await (_db.select(_db.paymentsTable)
                ..where((p) => p.id.equals(id) & p.isDeleted.equals(false)))
              .getSingleOrNull();

      if (payment == null) {
        throw const ValidationFailure('Payment record not found or deleted.');
      }
      if (payment.isVoided) {
        throw const ValidationFailure('Payment is already voided.');
      }

      final sale = await (_db.select(
        _db.salesTable,
      )..where((s) => s.id.equals(payment.saleId))).getSingleOrNull();

      final now = DateTime.now().millisecondsSinceEpoch;

      await _db.transaction(() async {
        // Soft void the payment
        await (_db.update(
          _db.paymentsTable,
        )..where((p) => p.id.equals(id))).write(
          PaymentsTableCompanion(
            isVoided: const Value(true),
            voidedAt: Value(now),
            voidReason: Value(trimmedReason),
            updatedAt: Value(now),
          ),
        );

        // Recalculate remaining active payments for parent sale
        if (sale != null && !sale.isVoided) {
          final remainingPayments =
              await (_db.select(_db.paymentsTable)..where(
                    (p) =>
                        p.saleId.equals(sale.id) &
                        p.isDeleted.equals(false) &
                        p.isVoided.equals(false) &
                        p.id.equals(id).not(),
                  ))
                  .get();

          final totalRemainingPaid = remainingPayments.fold<int>(
            0,
            (sum, p) => sum + p.amountMinor,
          );

          String newStatus;
          if (totalRemainingPaid >= sale.totalAmountMinor) {
            newStatus = 'PAID';
          } else if (totalRemainingPaid > 0) {
            newStatus = 'PARTIAL';
          } else {
            newStatus = 'UNPAID';
          }

          await (_db.update(
            _db.salesTable,
          )..where((s) => s.id.equals(sale.id))).write(
            SalesTableCompanion(
              paymentStatus: Value(newStatus),
              updatedAt: Value(now),
            ),
          );
        }

        // Record immutable audit log entry
        await _auditRepository.logAction(
          entityTable: 'payments',
          entityId: id,
          action: AuditAction.voidRecord,
          previousState: {
            'id': payment.id,
            'saleId': payment.saleId,
            'amountMinor': payment.amountMinor,
            'currency': payment.currency,
            'isVoided': false,
          },
          newState: {
            'id': payment.id,
            'saleId': payment.saleId,
            'amountMinor': payment.amountMinor,
            'currency': payment.currency,
            'isVoided': true,
            'voidReason': trimmedReason,
            'voidedAt': now,
          },
          reason: trimmedReason,
        );
      });
    }, operationName: 'voidPayment');
  }

  @override
  Future<Money> getSaleOutstandingBalance(String saleId) async {
    return DatabaseExceptionMapper.runSafe(() async {
      final sale =
          await (_db.select(_db.salesTable)
                ..where((s) => s.id.equals(saleId) & s.isDeleted.equals(false)))
              .getSingleOrNull();

      if (sale == null || sale.isVoided) {
        return Money.zero();
      }

      final payments =
          await (_db.select(_db.paymentsTable)..where(
                (p) =>
                    p.saleId.equals(saleId) &
                    p.isDeleted.equals(false) &
                    p.isVoided.equals(false),
              ))
              .get();

      final totalPaid = payments.fold<int>(0, (sum, p) => sum + p.amountMinor);
      final remaining = sale.totalAmountMinor - totalPaid;

      return remaining > 0
          ? Money(BigInt.from(remaining), currency: sale.currency)
          : Money.zero(currency: sale.currency);
    }, operationName: 'getSaleOutstandingBalance');
  }
}
