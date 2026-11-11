import '../../../../core/money/money.dart';
import '../../../expenses/domain/models/payment_method.dart';
import '../models/payment_with_details.dart';

/// Contract for managing commercial sale installments, cash/MoMo collections,
/// and relational audit trails.
abstract class PaymentRepository {
  /// Stream emitting payment records with linked relations.
  Stream<List<PaymentWithDetails>> watchPayments({
    String? saleId,
    String? buyerId,
    String? projectId,
    bool includeVoided = false,
  });

  /// Fetches a one-time list of payment records matching filter criteria.
  Future<List<PaymentWithDetails>> getPayments({
    String? saleId,
    String? buyerId,
    String? projectId,
    bool includeVoided = false,
  });

  /// Retrieves an individual payment record by unique ID.
  Future<PaymentWithDetails?> getPaymentById(String id);

  /// Records a new installment payment against a specific commercial sale.
  ///
  /// Strictly validates that:
  /// 1. [amountMinor] > 0
  /// 2. The referenced [saleId] exists and is not voided
  /// 3. [amountMinor] does not exceed the remaining outstanding balance of the sale
  ///
  /// Automatically updates the parent sale's `paymentStatus` (PAID or PARTIAL)
  /// and timestamp in a single atomic database transaction.
  Future<String> recordPayment({
    required String saleId,
    required DateTime paymentDate,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  });

  /// Soft voids an existing payment transaction for audit compliance with a required reason.
  ///
  /// Re-evaluates the parent sale's remaining balance and updates its `paymentStatus`
  /// accordingly in a single atomic database transaction.
  Future<void> voidPayment(String id, {required String reason});

  /// Calculates the current uncollected accounts receivable balance on a sale.
  Future<Money> getSaleOutstandingBalance(String saleId);
}
