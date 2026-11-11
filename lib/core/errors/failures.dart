import 'package:flutter/foundation.dart';

/// Base class for all failure and error types in Farmivo.
@immutable
abstract class AppFailure {
  final String message;
  final String? code;
  final dynamic details;

  const AppFailure(this.message, {this.code, this.details});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

/// Failures originating from the local Drift/SQLite database.
class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message, {super.code, super.details});
}

/// Failures originating from domain calculation or business rule breaches.
class FinancialRuleFailure extends AppFailure {
  const FinancialRuleFailure(super.message, {super.code, super.details});
}

/// Failures originating from local biometric or PIN authentication.
class SecurityFailure extends AppFailure {
  const SecurityFailure(super.message, {super.code, super.details});
}

/// Failures originating from form or input validation.
class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code, super.details});
}

/// Failures originating from backup and restore operations.
class BackupFailure extends AppFailure {
  const BackupFailure(super.message, {super.code, super.details});
}
