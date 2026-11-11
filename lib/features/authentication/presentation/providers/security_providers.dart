import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/route_guards.dart';
import '../../domain/models/auto_lock_timeout.dart';
import '../../domain/models/security_settings.dart';
import '../../domain/services/biometric_auth_service.dart';
import '../../domain/services/security_repository.dart';

/// Provider exposing the [BiometricAuthService].
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

/// Provider exposing the [SecurityRepository].
final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return const SecurityRepository();
});

/// State notifier managing user security settings and credentials lifecycle.
class SecuritySettingsNotifier
    extends StateNotifier<AsyncValue<SecuritySettings>> {
  final SecurityRepository _repository;
  final BiometricAuthService _biometricService;

  SecuritySettingsNotifier(this._repository, this._biometricService)
    : super(const AsyncValue.loading()) {
    refresh();
  }

  /// Refreshes security settings from secure storage and biometric hardware.
  Future<void> refresh() async {
    try {
      final settings = await _repository.loadSecuritySettings(
        _biometricService,
      );
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sets a new numeric PIN (4 to 6 digits).
  Future<void> savePin(String pin) async {
    await _repository.savePin(pin);
    await refresh();
  }

  /// Verifies entered PIN and updates failed attempts counter.
  Future<bool> verifyPin(String enteredPin) async {
    final current = state.value ?? const SecuritySettings();

    // Check if currently locked out
    if (current.isLockedOut) {
      return false;
    }

    final isValid = await _repository.verifyPin(enteredPin);
    if (isValid) {
      // Reset failed attempts upon successful verification
      state = AsyncValue.data(
        current.copyWith(failedAttempts: 0, lockoutUntil: null),
      );
      return true;
    } else {
      // Increment failed attempts and trigger lockout if limit reached
      final newFailed = current.failedAttempts + 1;
      DateTime? lockout;
      if (newFailed >= 5) {
        lockout = DateTime.now().add(const Duration(seconds: 30));
      }
      state = AsyncValue.data(
        current.copyWith(failedAttempts: newFailed, lockoutUntil: lockout),
      );
      return false;
    }
  }

  /// Disables and clears the stored PIN.
  Future<void> removePin() async {
    await _repository.removePin();
    await refresh();
  }

  /// Enables or disables mandatory app lock.
  Future<void> setAppLockEnabled(bool enabled) async {
    await _repository.setAppLockEnabled(enabled);
    await refresh();
  }

  /// Enables or disables biometric authentication shortcut.
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _repository.setBiometricsEnabled(enabled);
    await refresh();
  }

  /// Configures auto-lock timeout duration.
  Future<void> setAutoLockTimeout(AutoLockTimeout timeout) async {
    await _repository.setAutoLockTimeout(timeout);
    await refresh();
  }
}

/// Provider managing [SecuritySettings].
final securitySettingsProvider =
    StateNotifierProvider<
      SecuritySettingsNotifier,
      AsyncValue<SecuritySettings>
    >((ref) {
      final repo = ref.watch(securityRepositoryProvider);
      final bio = ref.watch(biometricAuthServiceProvider);
      return SecuritySettingsNotifier(repo, bio);
    });

/// Controller handling app locking, background timer checks, and unlocking.
class AppLockController {
  final Ref _ref;
  final SecurityRepository _repository;
  final BiometricAuthService _biometricService;

  AppLockController(this._ref, this._repository, this._biometricService);

  /// Initializes lock state on cold app launch.
  Future<void> initializeOnLaunch() async {
    final isLockEnabled = await _repository.isAppLockEnabled();
    final hasPin = await _repository.hasPin();

    if (isLockEnabled && hasPin) {
      _ref.read(authLockProvider.notifier).state = true;
    }
  }

  /// Manually locks the application immediately.
  void lock() {
    _ref.read(authLockProvider.notifier).state = true;
  }

  /// Unlocks the application after successful verification.
  Future<void> unlock() async {
    await _repository.clearBackgroundTimestamp();
    _ref.read(authLockProvider.notifier).state = false;
  }

  /// Triggers biometric authentication and unlocks on success.
  Future<bool> authenticateWithBiometrics() async {
    final isBiometricsEnabled = await _repository.isBiometricsEnabled();
    if (!isBiometricsEnabled) return false;

    final success = await _biometricService.authenticate();
    if (success) {
      await unlock();
      return true;
    }
    return false;
  }

  /// Handles AppLifecycleState transitions to enforce auto-lock timeouts.
  Future<void> handleLifecycleState(AppLifecycleState state) async {
    final isAppLockEnabled = await _repository.isAppLockEnabled();
    final hasPin = await _repository.hasPin();

    if (!isAppLockEnabled || !hasPin) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      final timeout = await _repository.getAutoLockTimeout();
      if (timeout == AutoLockTimeout.immediate) {
        lock();
      } else {
        await _repository.recordBackgroundTimestamp(DateTime.now());
      }
    } else if (state == AppLifecycleState.resumed) {
      final isCurrentlyLocked = _ref.read(authLockProvider);
      if (isCurrentlyLocked) return;

      final lastBg = await _repository.getLastBackgroundTimestamp();
      if (lastBg != null) {
        final timeout = await _repository.getAutoLockTimeout();
        final elapsed = DateTime.now().difference(lastBg);
        if (timeout.shouldLock(elapsed)) {
          lock();
        }
      }
    }
  }
}

/// Provider managing [AppLockController].
final appLockControllerProvider = Provider<AppLockController>((ref) {
  final repo = ref.watch(securityRepositoryProvider);
  final bio = ref.watch(biometricAuthServiceProvider);
  return AppLockController(ref, repo, bio);
});
