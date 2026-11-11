/// Configurable inactivity durations before Farmivo automatically locks
/// behind biometric / PIN protection (Milestone 9.1).
enum AutoLockTimeout {
  immediate(0, 'Immediately'),
  oneMinute(60, 'After 1 minute'),
  fiveMinutes(300, 'After 5 minutes'),
  fifteenMinutes(900, 'After 15 minutes'),
  never(-1, 'Never');

  final int seconds;
  final String displayName;

  const AutoLockTimeout(this.seconds, this.displayName);

  /// Resolves an [AutoLockTimeout] from stored seconds, defaulting to 1 minute.
  static AutoLockTimeout fromSeconds(int? seconds) {
    if (seconds == null) return AutoLockTimeout.oneMinute;
    return AutoLockTimeout.values.firstWhere(
      (e) => e.seconds == seconds,
      orElse: () => AutoLockTimeout.oneMinute,
    );
  }

  /// Whether the app should lock given the [elapsedDuration] in the background.
  bool shouldLock(Duration elapsedDuration) {
    if (this == AutoLockTimeout.never) return false;
    if (this == AutoLockTimeout.immediate) return true;
    return elapsedDuration.inSeconds >= seconds;
  }
}
