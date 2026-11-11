import '../money/money.dart';

/// User input validation utilities for financial forms, land sizes, and field records.
class InputValidators {
  InputValidators._();

  /// Validates required text fields (e.g. project name, farm name).
  static String? requiredText(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates monetary input using robust [Money.tryParse] (e.g. "GH₵ 1,250.50", "1500").
  static String? monetaryAmount(
    String? value, {
    String fieldName = 'Amount',
    bool allowZero = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final money = Money.tryParse(value);
    if (money == null) {
      return 'Enter a valid monetary amount (e.g. 1500 or GH₵ 1,500.00).';
    }
    if (!allowZero && money.isZero) {
      return '$fieldName must be greater than zero.';
    }
    if (money.isNegative) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  /// Validates non-negative numerical amounts (e.g. quantities).
  static String? nonNegativeNumber(
    String? value, {
    String fieldName = 'Quantity',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final parsed = double.tryParse(value.replaceAll(',', '').trim());
    if (parsed == null) {
      return 'Enter a valid number.';
    }
    if (parsed < 0) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  /// Validates strictly positive numbers (e.g. land size, unit price > 0).
  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final parsed = double.tryParse(value.replaceAll(',', '').trim());
    if (parsed == null) {
      return 'Enter a valid number.';
    }
    if (parsed <= 0) {
      return '$fieldName must be greater than zero.';
    }
    return null;
  }

  /// Validates phone number input format (allowing African standard formats).
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(clean)) {
      return 'Enter a valid phone number (e.g. 0244123456 or +233244123456).';
    }
    return null;
  }

  /// Validates optional GPS latitude coordinate (-90.0 to 90.0).
  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid decimal latitude.';
    }
    if (parsed < -90.0 || parsed > 90.0) {
      return 'Latitude must be between -90.0 and 90.0.';
    }
    return null;
  }

  /// Validates optional GPS longitude coordinate (-180.0 to 180.0).
  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid decimal longitude.';
    }
    if (parsed < -180.0 || parsed > 180.0) {
      return 'Longitude must be between -180.0 and 180.0.';
    }
    return null;
  }
}
