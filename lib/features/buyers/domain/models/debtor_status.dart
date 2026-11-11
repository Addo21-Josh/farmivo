import 'package:flutter/material.dart';

/// Debt settlement classification for buyers and commercial off-takers.
enum DebtorStatus {
  /// All purchases are fully paid, or no transactions yet.
  settled,

  /// Buyer has made partial payment but still owes a remaining balance.
  partial,

  /// Buyer has credit purchases with zero payments made.
  owing,

  /// Fresh buyer without any sales history.
  noHistory;

  String get displayName {
    switch (this) {
      case DebtorStatus.settled:
        return 'Fully Settled';
      case DebtorStatus.partial:
        return 'Partial Payment';
      case DebtorStatus.owing:
        return 'Outstanding Debt';
      case DebtorStatus.noHistory:
        return 'New Customer';
    }
  }

  String get shortLabel {
    switch (this) {
      case DebtorStatus.settled:
        return 'Settled';
      case DebtorStatus.partial:
        return 'Partial';
      case DebtorStatus.owing:
        return 'Owing';
      case DebtorStatus.noHistory:
        return 'New';
    }
  }

  Color get color {
    switch (this) {
      case DebtorStatus.settled:
        return Colors.green;
      case DebtorStatus.partial:
        return Colors.orange.shade800;
      case DebtorStatus.owing:
        return Colors.red;
      case DebtorStatus.noHistory:
        return Colors.blueGrey;
    }
  }

  IconData get icon {
    switch (this) {
      case DebtorStatus.settled:
        return Icons.check_circle_outline;
      case DebtorStatus.partial:
        return Icons.timelapse;
      case DebtorStatus.owing:
        return Icons.warning_amber_rounded;
      case DebtorStatus.noHistory:
        return Icons.person_add_outlined;
    }
  }
}
