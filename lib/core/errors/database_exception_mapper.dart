import 'package:drift/native.dart';
import 'failures.dart';
import '../utils/app_logger.dart';

/// Intercepts low-level SQLite and Drift exceptions and maps them into
/// polite, understandable [DatabaseFailure] objects (hiding raw SQL syntax).
class DatabaseExceptionMapper {
  DatabaseExceptionMapper._();

  /// Maps an unknown caught database exception to a typed [DatabaseFailure].
  static DatabaseFailure map(Object error, [StackTrace? stackTrace]) {
    AppLogger.error('Database operation failed', error, stackTrace);

    if (error is SqliteException) {
      final code = error.extendedResultCode;
      final message = error.message.toLowerCase();

      // SQLite Foreign Key Constraint (787 = SQLITE_CONSTRAINT_FOREIGNKEY)
      if (code == 787 || message.contains('foreign key')) {
        return const DatabaseFailure(
          'This record cannot be removed because other records currently link to it.',
          code: 'FOREIGN_KEY_VIOLATION',
        );
      }

      // SQLite Unique Constraint (2067 = SQLITE_CONSTRAINT_UNIQUE)
      if (code == 2067 || message.contains('unique constraint')) {
        return const DatabaseFailure(
          'A record with this information already exists in your farm ledger.',
          code: 'UNIQUE_CONSTRAINT_VIOLATION',
        );
      }

      // SQLite Not Null Constraint (1299 = SQLITE_CONSTRAINT_NOTNULL)
      if (code == 1299 || message.contains('not null constraint')) {
        return const DatabaseFailure(
          'A required field was missing from the record.',
          code: 'NOT_NULL_VIOLATION',
        );
      }

      // Database Locked / Busy (5 = SQLITE_BUSY)
      if (code == 5 || message.contains('busy') || message.contains('locked')) {
        return const DatabaseFailure(
          'The database is temporarily busy. Please try again in a moment.',
          code: 'DATABASE_BUSY',
        );
      }

      // Database disk full or IO error
      if (code == 13 || message.contains('disk full')) {
        return const DatabaseFailure(
          'Device storage is almost full. Please free up space to continue recording farm data.',
          code: 'DISK_FULL',
        );
      }

      return DatabaseFailure(
        'Database error occurred: ${error.message}',
        code: 'SQLITE_ERROR_$code',
      );
    }

    return DatabaseFailure(
      'An unexpected storage error occurred while saving your data.',
      details: error.toString(),
    );
  }

  /// Helper wrapper that executes a database operation inside a safe try/catch mapper.
  static Future<T> runSafe<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } on AppFailure {
      rethrow;
    } catch (e, st) {
      if (operationName != null) {
        AppLogger.error('Failed to $operationName: $e', e, st);
      }
      throw map(e, st);
    }
  }
}
