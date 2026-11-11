import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../expenses/domain/models/payment_method.dart';

/// Projection uniting a [Payment] entry with its referenced commercial [Sale],
/// purchasing [Buyer], and parent [Project].
class PaymentWithDetails {
  final Payment payment;
  final Sale? sale;
  final Buyer? buyer;
  final Project? project;

  const PaymentWithDetails({
    required this.payment,
    this.sale,
    this.buyer,
    this.project,
  });

  /// Monetary amount of this installment payment.
  Money get amount =>
      Money(BigInt.from(payment.amountMinor), currency: payment.currency);

  /// Parsed payment method / channel (Cash, MTN MoMo, Telecel, Bank, etc.).
  PaymentMethod get method => PaymentMethod.fromCode(payment.paymentMethod);

  /// Date the payment was received.
  DateTime get paymentDate =>
      DateTime.fromMillisecondsSinceEpoch(payment.paymentDate);

  /// Formatted date string for user display.
  String get formattedDate => paymentDate.toDisplayDate();

  /// Whether this payment record has been soft-voided.
  bool get isVoided => payment.isVoided;

  /// Customer / Buyer display identification.
  String get buyerDisplayName => buyer?.name ?? 'Walk-in Buyer';

  /// Sale produce identification.
  String get productDisplayName => sale?.productName ?? 'Produce Sale';

  PaymentWithDetails copyWith({
    Payment? payment,
    Sale? sale,
    Buyer? buyer,
    Project? project,
  }) {
    return PaymentWithDetails(
      payment: payment ?? this.payment,
      sale: sale ?? this.sale,
      buyer: buyer ?? this.buyer,
      project: project ?? this.project,
    );
  }
}
