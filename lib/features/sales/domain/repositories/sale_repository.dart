import '../models/sale_payment_status.dart';
import '../models/sale_with_details.dart';
import '../models/sales_summary.dart';

/// Contract for managing commercial harvest sales, credit agreements,
/// and relational audit trails.
abstract class SaleRepository {
  /// Stream emitting active sales with joined relations and settlement status.
  Stream<List<SaleWithDetails>> watchSales({
    String? projectId,
    String? buyerId,
    String? harvestId,
    bool includeVoided = false,
  });

  /// Fetches a one-time list of sales with joined relations.
  Future<List<SaleWithDetails>> getSales({
    String? projectId,
    String? buyerId,
    String? harvestId,
    bool includeVoided = false,
  });

  /// Retrieves a single sale by unique ID with full relation details.
  Future<SaleWithDetails?> getSaleById(String id);

  /// Records a new commercial harvest sale transaction.
  ///
  /// Automatically computes [totalAmountMinor] as `(quantity * unitPriceMinor).round()`.
  /// If [paymentStatus] is [SalePaymentStatus.paid] or [SalePaymentStatus.partial]
  /// with an [initialPaymentAmountMinor] > 0, an initial payment entry is logged.
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
  });

  /// Updates existing editable details on a non-voided sale transaction.
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
  });

  /// Soft voids a sale transaction, immutably preserving the audit trail
  /// with a required audit reason.
  Future<void> voidSale(String id, {required String reason});

  /// Real-time stream of aggregated sales summary metrics.
  Stream<SalesSummary> watchSalesSummary({String? projectId, String? buyerId});

  /// One-time fetch of aggregated sales summary metrics.
  Future<SalesSummary> getSalesSummary({String? projectId, String? buyerId});
}
