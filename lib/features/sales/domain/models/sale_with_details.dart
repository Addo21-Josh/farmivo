import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import 'sale_payment_status.dart';

/// Rich projection combining a [Sale] entity with its relational references
/// (Project, Buyer, Harvest batch) and aggregated settlement balances.
class SaleWithDetails {
  final Sale sale;
  final Project? project;
  final Buyer? buyer;
  final Harvest? harvest;
  final int totalPaidMinor;

  const SaleWithDetails({
    required this.sale,
    this.project,
    this.buyer,
    this.harvest,
    this.totalPaidMinor = 0,
  });

  /// Total sale value in typed minor currency units.
  Money get totalAmount =>
      Money(BigInt.from(sale.totalAmountMinor), currency: sale.currency);

  /// Unit price in typed minor currency units.
  Money get unitPrice =>
      Money(BigInt.from(sale.unitPriceMinor), currency: sale.currency);

  /// Aggregated liquid cash received against this sale.
  Money get paidAmount =>
      Money(BigInt.from(totalPaidMinor), currency: sale.currency);

  /// Outstanding accounts receivable balance.
  Money get remainingBalance {
    if (sale.isVoided) return Money.zero(currency: sale.currency);
    return totalAmount > paidAmount
        ? totalAmount - paidAmount
        : Money.zero(currency: sale.currency);
  }

  /// Whether the sale is completely settled with zero remaining balance.
  bool get isFullyPaid =>
      !sale.isVoided && remainingBalance.isZero && totalAmount.isPositive;

  /// Whether the sale has received partial settlement but retains open credit.
  bool get isPartiallyPaid =>
      !sale.isVoided && totalPaidMinor > 0 && remainingBalance.isPositive;

  /// Whether no payments have been received against this sale.
  bool get isUnpaid => !sale.isVoided && totalPaidMinor == 0;

  /// Whether the buyer holds open credit under this transaction.
  bool get isCredit => !sale.isVoided && remainingBalance.isPositive;

  /// Effective dynamic payment status derived from verified payment records.
  SalePaymentStatus get effectiveStatus {
    if (isFullyPaid) return SalePaymentStatus.paid;
    if (isPartiallyPaid) return SalePaymentStatus.partial;
    if (sale.isVoided) return SalePaymentStatus.fromCode(sale.paymentStatus);
    return SalePaymentStatus.unpaid;
  }

  /// Payment status as recorded on the sale entity.
  SalePaymentStatus get recordedStatus =>
      SalePaymentStatus.fromCode(sale.paymentStatus);

  /// Human-readable customer or off-taker identification.
  String get buyerDisplayName => buyer?.name ?? 'Walk-in Buyer';

  /// Human-readable farming project name.
  String get projectDisplayName => project?.name ?? 'Unassigned Project';

  /// Display string formatting quantity and unit (e.g. "50 Bags", "12.5 Crates").
  String get formattedQuantity {
    final qtyStr = sale.quantity % 1 == 0
        ? sale.quantity.toInt().toString()
        : sale.quantity.toString();
    return '$qtyStr ${sale.unit}';
  }

  /// Date the commercial sale agreement took place.
  DateTime get saleDate => DateTime.fromMillisecondsSinceEpoch(sale.saleDate);

  SaleWithDetails copyWith({
    Sale? sale,
    Project? project,
    Buyer? buyer,
    Harvest? harvest,
    int? totalPaidMinor,
  }) {
    return SaleWithDetails(
      sale: sale ?? this.sale,
      project: project ?? this.project,
      buyer: buyer ?? this.buyer,
      harvest: harvest ?? this.harvest,
      totalPaidMinor: totalPaidMinor ?? this.totalPaidMinor,
    );
  }
}
