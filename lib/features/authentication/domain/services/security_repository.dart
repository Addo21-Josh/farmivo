import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auto_lock_timeout.dart';
import '../models/security_settings.dart';
import 'biometric_auth_service.dart';
import 'pin_hasher.dart';

/// Repository managing persistent encrypted credentials and security preferences
/// in Android Keystore / iOS Keychain via [FlutterSecureStorage] (Milestone 9.1).
class SecurityRepository {
  final FlutterSecureStorage _storage;

  static const String _keyPinHash = 'farmivo_security_pin_hash';
  static const String _keyPinSalt = 'farmivo_security_pin_salt';
  static const String _keyPinLength = 'farmivo_security_pin_length';
  static const String _keyAppLockEnabled = 'farmivo_security_app_lock_enabled';
  static const String _keyBiometricsEnabled =
      'farmivo_security_biometrics_enabled';
  static const String _keyAutoLockTimeout =
      'farmivo_security_autolock_timeout_seconds';
  static const String _keyLastBackgroundTimestamp =
      'farmivo_security_last_bg_timestamp';

  const SecurityRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Saves a newly created or updated numeric PIN.
  Future<void> savePin(String pin) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hashPin(pin, salt);

    await _storage.write(key: _keyPinSalt, value: salt);
    await _storage.write(key: _keyPinHash, value: hash);
    await _storage.write(key: _keyPinLength, value: pin.length.toString());
    await _storage.write(key: _keyAppLockEnabled, value: 'true');
  }

  /// Verifies an entered PIN against stored salted hash.
  Future<bool> verifyPin(String enteredPin) async {
    final salt = await _storage.read(key: _keyPinSalt);
    final storedHash = await _storage.read(key: _keyPinHash);

    if (salt == null || storedHash == null) {
      return false;
    }

    return PinHasher.verifyPin(
      enteredPin: enteredPin,
      storedHash: storedHash,
      salt: salt,
    );
  }

  /// Whether a PIN has been established.
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null && hash.trim().isNotEmpty;
  }

  /// Gets the expected length of the PIN (defaults to 4).
  Future<int> getPinLength() async {
    final lenStr = await _storage.read(key: _keyPinLength);
    return int.tryParse(lenStr ?? '') ?? 4;
  }

  /// Removes the stored PIN and disables app lock.
  Future<void> removePin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
    await _storage.delete(key: _keyPinLength);
    await _storage.write(key: _keyAppLockEnabled, value: 'false');
    await _storage.write(key: _keyBiometricsEnabled, value: 'false');
  }

  /// Enables or disables mandatory app lock.
  Future<void> setAppLockEnabled(bool enabled) async {
    await _storage.write(
      key: _keyAppLockEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  /// Whether mandatory app lock is active.
  Future<bool> isAppLockEnabled() async {
    final val = await _storage.read(key: _keyAppLockEnabled);
    return val == 'true';
  }

  /// Enables or disables biometric unlock shortcut.
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricsEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  /// Whether biometric unlock is enabled by user.
  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: _keyBiometricsEnabled);
    return val == 'true';
  }

  /// Updates the auto-lock timeout duration.
  Future<void> setAutoLockTimeout(AutoLockTimeout timeout) async {
    await _storage.write(
      key: _keyAutoLockTimeout,
      value: timeout.seconds.toString(),
    );
  }

  /// Reads the current auto-lock timeout duration.
  Future<AutoLockTimeout> getAutoLockTimeout() async {
    final str = await _storage.read(key: _keyAutoLockTimeout);
    final seconds = int.tryParse(str ?? '');
    return AutoLockTimeout.fromSeconds(seconds);
  }

  /// Persists the epoch timestamp when the app moved to background.
  Future<void> recordBackgroundTimestamp(DateTime timestamp) async {
    await _storage.write(
      key: _keyLastBackgroundTimestamp,
      value: timestamp.millisecondsSinceEpoch.toString(),
    );
  }

  /// Retrieves the recorded background timestamp.
  Future<DateTime?> getLastBackgroundTimestamp() async {
    final str = await _storage.read(key: _keyLastBackgroundTimestamp);
    if (str == null) return null;
    final ms = int.tryParse(str);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Clears the background timestamp once unlocked.
  Future<void> clearBackgroundTimestamp() async {
    await _storage.delete(key: _keyLastBackgroundTimestamp);
  }

  /// Loads full [SecuritySettings] snapshot including hardware biometrics.
  Future<SecuritySettings> loadSecuritySettings(
    BiometricAuthService biometricService,
  ) async {
    final pinConfigured = await hasPin();
    final pinLen = await getPinLength();
    final appLock = await isAppLockEnabled();
    final biometricsEnabled = await isBiometricsEnabled();
    final timeout = await getAutoLockTimeout();
    final biometricsHardwareAvailable = await biometricService
        .isBiometricsAvailable();

    return SecuritySettings(
      isAppLockEnabled: pinConfigured && appLock,
      hasPin: pinConfigured,
      pinLength: pinLen,
      isBiometricsEnabled: biometricsEnabled && biometricsHardwareAvailable,
      isBiometricsAvailableOnDevice: biometricsHardwareAvailable,
      autoLockTimeout: timeout,
    );
  }
}
