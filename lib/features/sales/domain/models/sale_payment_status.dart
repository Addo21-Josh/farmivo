import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';

/// Payment fulfillment status of a commercial harvest sale agreement.
enum SalePaymentStatus {
  paid,
  partial,
  unpaid;

  /// Database string code stored in [SalesTable].
  String get code {
    switch (this) {
      case SalePaymentStatus.paid:
        return 'PAID';
      case SalePaymentStatus.partial:
        return 'PARTIAL';
      case SalePaymentStatus.unpaid:
        return 'UNPAID';
    }
  }

  /// User-friendly label for display.
  String get displayName {
    switch (this) {
      case SalePaymentStatus.paid:
        return 'Paid';
      case SalePaymentStatus.partial:
        return 'Partial Payment';
      case SalePaymentStatus.unpaid:
        return 'Credit / Unpaid';
    }
  }

  /// Icon associated with the payment status.
  IconData get icon {
    switch (this) {
      case SalePaymentStatus.paid:
        return Icons.check_circle_outlined;
      case SalePaymentStatus.partial:
        return Icons.timelapse_outlined;
      case SalePaymentStatus.unpaid:
        return Icons.pending_actions_outlined;
    }
  }

  /// Theme-aware text/foreground color.
  Color color(AppThemeExtension colors) {
    switch (this) {
      case SalePaymentStatus.paid:
        return colors.healthGreen;
      case SalePaymentStatus.partial:
        return colors.healthYellow;
      case SalePaymentStatus.unpaid:
        return colors.healthRed;
    }
  }

  /// Theme-aware badge background color.
  Color backgroundColor(AppThemeExtension colors) {
    switch (this) {
      case SalePaymentStatus.paid:
        return colors.healthGreenBg;
      case SalePaymentStatus.partial:
        return colors.healthYellowBg;
      case SalePaymentStatus.unpaid:
        return colors.healthRedBg;
    }
  }

  /// Parses a string code with safe fallback to [unpaid].
  static SalePaymentStatus fromCode(String? code) {
    if (code == null) return SalePaymentStatus.unpaid;
    final normalized = code.trim().toUpperCase();
    switch (normalized) {
      case 'PAID':
        return SalePaymentStatus.paid;
      case 'PARTIAL':
      case 'PARTIALLY_PAID':
        return SalePaymentStatus.partial;
      case 'UNPAID':
      case 'CREDIT':
        return SalePaymentStatus.unpaid;
      default:
        return SalePaymentStatus.unpaid;
    }
  }
}
