import 'package:flutter/foundation.dart';

/// Represents a precise monetary amount stored internally as an integer of minor units
/// (e.g., Pesewas for GHS, Cents for USD, Kobo for NGN).
///
/// Avoids IEEE-754 floating-point inaccuracies in financial calculations.
@immutable
class Money implements Comparable<Money> {
  /// The amount stored in minor units (e.g. 100 GHS = 10000 pesewas).
  final BigInt minorUnits;

  /// The 3-letter ISO-4217 currency code (default: 'GHS').
  final String currency;

  const Money(this.minorUnits, {this.currency = 'GHS'});

  /// Creates a [Money] instance from a major unit quantity (e.g. 12.50 GHS).
  factory Money.fromMajor(num major, {String currency = 'GHS'}) {
    if (major is int) {
      return Money(BigInt.from(major) * BigInt.from(100), currency: currency);
    }
    // Convert to minor units without floating-point drift
    final minor = (major * 100).round();
    return Money(BigInt.from(minor), currency: currency);
  }

  /// Creates a [Money] instance representing zero in the specified currency.
  factory Money.zero({String currency = 'GHS'}) {
    return Money(BigInt.zero, currency: currency);
  }

  /// Parses a string representation into a [Money] instance with robust error tolerance.
  /// Handles currency symbols ("GH₵", "$", "₦", "€", "KSh", "GHS"), commas, spaces,
  /// parentheses for negative amounts, and positive/negative signs.
  ///
  /// Throws [FormatException] if the string cannot be parsed.
  factory Money.parse(String input, {String currency = 'GHS'}) {
    final parsed = tryParse(input, currency: currency);
    if (parsed == null) {
      throw FormatException('Invalid currency amount format: "$input"');
    }
    return parsed;
  }

  /// Parses a string representation into a [Money] instance, returning null on failure.
  static Money? tryParse(String? input, {String currency = 'GHS'}) {
    if (input == null) return null;
    var sanitized = input.trim();
    if (sanitized.isEmpty) return null;

    // Check for negative in parentheses: (1,250.50) -> -1250.50
    var isNegative = false;
    if (sanitized.startsWith('(') && sanitized.endsWith(')')) {
      isNegative = true;
      sanitized = sanitized.substring(1, sanitized.length - 1).trim();
    } else if (sanitized.startsWith('-')) {
      isNegative = true;
      sanitized = sanitized.substring(1).trim();
    } else if (sanitized.startsWith('+')) {
      sanitized = sanitized.substring(1).trim();
    }

    // Strip known currency symbols and 3-letter codes
    final symbolsToRemove = [
      'GH₵',
      'GH¢',
      'GHS',
      'USD',
      'EUR',
      'NGN',
      'KES',
      r'$',
      '€',
      '₦',
      'KSh',
      'Ksh',
    ];
    for (final sym in symbolsToRemove) {
      if (sanitized.toUpperCase().startsWith(sym.toUpperCase())) {
        sanitized = sanitized.substring(sym.length).trim();
      }
    }

    // Check negative sign again in case it was after the currency symbol: GH₵ -50
    if (sanitized.startsWith('-')) {
      isNegative = true;
      sanitized = sanitized.substring(1).trim();
    }

    // Remove commas and spaces
    sanitized = sanitized.replaceAll(',', '').replaceAll(' ', '');
    if (sanitized.isEmpty) return null;

    // Split whole and fractional parts
    final dotIndex = sanitized.indexOf('.');
    BigInt whole;
    int minorCents = 0;

    if (dotIndex == -1) {
      // Whole number only
      final w = BigInt.tryParse(sanitized);
      if (w == null) return null;
      whole = w;
    } else {
      final wholePart = sanitized.substring(0, dotIndex);
      final fracPart = sanitized.substring(dotIndex + 1);

      // Validate digits
      if (wholePart.isEmpty && fracPart.isEmpty) return null;
      whole = wholePart.isEmpty
          ? BigInt.zero
          : (BigInt.tryParse(wholePart) ?? BigInt.from(-1));
      if (whole < BigInt.zero) return null;

      if (fracPart.isNotEmpty) {
        if (!RegExp(r'^\d+$').hasMatch(fracPart)) return null;
        if (fracPart.length == 1) {
          minorCents = int.parse(fracPart) * 10;
        } else if (fracPart.length == 2) {
          minorCents = int.parse(fracPart);
        } else {
          // Round third digit
          final twoDigits = int.parse(fracPart.substring(0, 2));
          final thirdDigit = int.parse(fracPart[2]);
          minorCents = twoDigits + (thirdDigit >= 5 ? 1 : 0);
        }
      }
    }

    final totalMinor = (whole * BigInt.from(100)) + BigInt.from(minorCents);
    return Money(isNegative ? -totalMinor : totalMinor, currency: currency);
  }

  /// Returns the major unit value as a [double] (for display/chart purposes only).
  double toMajor() => minorUnits.toInt() / 100.0;

  /// Adds another [Money] value. Throws [ArgumentError] if currencies differ.
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  /// Subtracts another [Money] value. Throws [ArgumentError] if currencies differ.
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  /// Multiplies the monetary amount by an integer factor using pure BigInt arithmetic.
  Money multiplyInt(int factor) {
    return Money(minorUnits * BigInt.from(factor), currency: currency);
  }

  /// Divides this money amount by an integer divisor with half-away-from-zero rounding.
  Money divideInt(int divisor) {
    if (divisor == 0) {
      throw ArgumentError('Cannot divide Money by zero');
    }
    final divBig = BigInt.from(divisor);
    final quotient = minorUnits ~/ divBig;
    final remainder = minorUnits.remainder(divBig);

    final shouldRoundUp =
        (remainder.abs() * BigInt.two) >= BigInt.from(divisor.abs());
    final adjustment = shouldRoundUp
        ? (minorUnits.isNegative ? -BigInt.one : BigInt.one)
        : BigInt.zero;
    return Money(quotient + adjustment, currency: currency);
  }

  /// Multiplies the monetary amount by a scalar quantity (integer or fractional).
  /// Preserves integer precision using rational scaling.
  Money multiply(num quantity) {
    if (quantity is int) return multiplyInt(quantity);
    // Scale by 10,000 for exact 4-decimal precision in BigInt space
    final scaled = (quantity * 10000).round();
    final result = (minorUnits * BigInt.from(scaled)) ~/ BigInt.from(10000);
    return Money(result, currency: currency);
  }

  /// Divides this money amount by a scalar divisor.
  Money divide(num divisor) {
    if (divisor == 0) {
      throw ArgumentError('Cannot divide Money by zero');
    }
    if (divisor is int) return divideInt(divisor);
    final scaled = (divisor * 10000).round();
    final result = (minorUnits * BigInt.from(10000)) ~/ BigInt.from(scaled);
    return Money(result, currency: currency);
  }

  /// Formats the money into a clean currency string (e.g., "GH₵ 1,250.50").
  String format() {
    final major = toMajor().abs();
    final parts = major.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final fraction = parts[1];

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedWhole = whole.replaceAllMapped(reg, (Match m) => '${m[1]},');
    final symbol = _currencySymbol(currency);
    final sign = isNegative ? '-' : '';
    return '$sign$symbol$formattedWhole.$fraction';
  }

  /// Returns true if this amount is strictly positive (> 0).
  bool get isPositive => minorUnits > BigInt.zero;

  /// Returns true if this amount is strictly negative (< 0).
  bool get isNegative => minorUnits < BigInt.zero;

  /// Returns true if this amount is zero.
  bool get isZero => minorUnits == BigInt.zero;

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Currency mismatch: Cannot operate on $currency and ${other.currency} without explicit conversion',
      );
    }
  }

  static String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'GHS':
        return 'GH₵ ';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'NGN':
        return '₦';
      case 'KES':
        return 'KSh ';
      default:
        return '$code ';
    }
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;
  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          minorUnits == other.minorUnits &&
          currency == other.currency;

  @override
  int get hashCode => minorUnits.hashCode ^ currency.hashCode;

  @override
  String toString() =>
      '$currency ${toMajor().toStringAsFixed(2)} ($minorUnits minor units)';
}
