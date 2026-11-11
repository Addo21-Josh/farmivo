import 'auto_lock_timeout.dart';

/// Aggregated user security preferences and device biometric readiness (Milestone 9.1).
class SecuritySettings {
  /// Whether an application security lock is enforced.
  final bool isAppLockEnabled;

  /// Whether a custom numeric PIN has been configured.
  final bool hasPin;

  /// Configured PIN length (typically 4 or 6 digits).
  final int pinLength;

  /// Whether biometric unlock (Fingerprint / Face ID) is active.
  final bool isBiometricsEnabled;

  /// Whether device hardware supports biometrics and has enrolled credentials.
  final bool isBiometricsAvailableOnDevice;

  /// Configurable auto-lock timeout duration when app goes into background.
  final AutoLockTimeout autoLockTimeout;

  /// Number of consecutive failed PIN attempts in the current session.
  final int failedAttempts;

  /// Cooldown lock timestamp if too many failed PIN attempts occurred.
  final DateTime? lockoutUntil;

  const SecuritySettings({
    this.isAppLockEnabled = false,
    this.hasPin = false,
    this.pinLength = 4,
    this.isBiometricsEnabled = false,
    this.isBiometricsAvailableOnDevice = false,
    this.autoLockTimeout = AutoLockTimeout.oneMinute,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  /// Whether user is currently in a failed attempts lockout period.
  bool get isLockedOut {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }

  /// Remaining seconds in the lockout cooldown.
  int get remainingLockoutSeconds {
    if (lockoutUntil == null) return 0;
    final diff = lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  SecuritySettings copyWith({
    bool? isAppLockEnabled,
    bool? hasPin,
    int? pinLength,
    bool? isBiometricsEnabled,
    bool? isBiometricsAvailableOnDevice,
    AutoLockTimeout? autoLockTimeout,
    int? failedAttempts,
    DateTime? lockoutUntil,
  }) {
    return SecuritySettings(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      hasPin: hasPin ?? this.hasPin,
      pinLength: pinLength ?? this.pinLength,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isBiometricsAvailableOnDevice:
          isBiometricsAvailableOnDevice ?? this.isBiometricsAvailableOnDevice,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }
}
