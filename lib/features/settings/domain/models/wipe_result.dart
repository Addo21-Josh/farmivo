/// Result of an emergency data wipe and factory reset operation (Milestone 9.4).
class WipeResult {
  /// Whether the factory reset completed successfully.
  final bool success;

  /// Number of database tables truncated.
  final int tablesCleared;

  /// Number of local backup archives deleted (if requested).
  final int backupsDeleted;

  /// Error message if the wipe failed.
  final String? errorMessage;

  /// Timestamp when the wipe was completed.
  final DateTime timestamp;

  const WipeResult({
    required this.success,
    this.tablesCleared = 0,
    this.backupsDeleted = 0,
    this.errorMessage,
    required this.timestamp,
  });

  @override
  String toString() =>
      'WipeResult(success: $success, tablesCleared: $tablesCleared, backupsDeleted: $backupsDeleted, error: $errorMessage)';
}
