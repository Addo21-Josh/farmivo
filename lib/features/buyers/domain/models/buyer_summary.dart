import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/debtor_status.dart';

/// Comprehensive aggregation of a customer / buyer's purchase history,
/// cumulative cash paid, and remaining accounts receivable debt.
class BuyerSummary {
  final Buyer buyer;
  final Money totalPurchased;
  final Money totalPaid;
  final Money outstandingBalance;
  final int salesCount;
  final DateTime? lastTransactionDate;

  const BuyerSummary({
    required this.buyer,
    required this.totalPurchased,
    required this.totalPaid,
    required this.outstandingBalance,
    required this.salesCount,
    this.lastTransactionDate,
  });

  String get id => buyer.id;
  String get name => buyer.name;
  String? get phone => buyer.phone;
  String? get businessName => buyer.businessName;
  String? get location => buyer.location;
  String? get notes => buyer.notes;
  bool get isDeleted => buyer.isDeleted;
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(buyer.createdAt);

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;
  bool get hasLocation => location != null && location!.trim().isNotEmpty;
  bool get hasBusinessName =>
      businessName != null && businessName!.trim().isNotEmpty;

  /// Whether the customer has active debt owed to the farm.
  bool get hasDebt => outstandingBalance.isPositive;

  /// Formatted headline with business name if available.
  String get displayName {
    if (hasBusinessName) {
      return '${buyer.name} (${buyer.businessName})';
    }
    return buyer.name;
  }

  /// Categorical debtor status for color coding and filtering.
  DebtorStatus get debtorStatus {
    if (salesCount == 0) {
      return DebtorStatus.noHistory;
    }
    if (outstandingBalance.minorUnits <= BigInt.zero) {
      return DebtorStatus.settled;
    }
    if (totalPaid.minorUnits > BigInt.zero) {
      return DebtorStatus.partial;
    }
    return DebtorStatus.owing;
  }
}
