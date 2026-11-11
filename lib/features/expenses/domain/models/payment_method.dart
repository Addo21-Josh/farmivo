import 'package:flutter/material.dart';

/// Supported transactional payment channels across Ghana and West Africa.
enum PaymentMethod {
  cash,
  mtnMoMo,
  telecelCash,
  atMoney,
  bankTransfer,
  credit,
  other;

  /// Standard database string identifier.
  String get code {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.mtnMoMo:
        return 'MOMO_MTN';
      case PaymentMethod.telecelCash:
        return 'MOMO_TELECEL';
      case PaymentMethod.atMoney:
        return 'MOMO_AT';
      case PaymentMethod.bankTransfer:
        return 'BANK';
      case PaymentMethod.credit:
        return 'CREDIT';
      case PaymentMethod.other:
        return 'OTHER';
    }
  }

  /// User-friendly label for display.
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mtnMoMo:
        return 'MTN MoMo';
      case PaymentMethod.telecelCash:
        return 'Telecel Cash';
      case PaymentMethod.atMoney:
        return 'AT Money';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.credit:
        return 'Credit / Due';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  /// Icon representing the payment mechanism.
  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.mtnMoMo:
        return Icons.phone_android;
      case PaymentMethod.telecelCash:
        return Icons.contactless_outlined;
      case PaymentMethod.atMoney:
        return Icons.mobile_friendly_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.credit:
        return Icons.access_time_outlined;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  /// Parses a string code into a typed [PaymentMethod] with safe fallback to cash.
  static PaymentMethod fromCode(String? code) {
    if (code == null) return PaymentMethod.cash;
    final normalized = code.trim().toUpperCase();
    switch (normalized) {
      case 'CASH':
        return PaymentMethod.cash;
      case 'MOMO':
      case 'MOMO_MTN':
      case 'MTN_MOMO':
        return PaymentMethod.mtnMoMo;
      case 'MOMO_TELECEL':
      case 'TELECEL':
      case 'VODAFONE_CASH':
        return PaymentMethod.telecelCash;
      case 'MOMO_AT':
      case 'AIRTELTIGO':
      case 'AT_MONEY':
        return PaymentMethod.atMoney;
      case 'BANK':
      case 'BANK_TRANSFER':
        return PaymentMethod.bankTransfer;
      case 'CREDIT':
        return PaymentMethod.credit;
      default:
        return PaymentMethod.other;
    }
  }
}
