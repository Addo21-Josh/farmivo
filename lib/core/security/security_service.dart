import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../errors/failures.dart';
import '../utils/app_logger.dart';

/// Handles device biometric authentication and encrypted PIN verification.
class SecurityService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _pinHashKey = 'user_pin_hash';
  static const String _pinSaltKey = 'user_pin_salt';
  static const String _biometricsEnabledKey = 'biometrics_enabled';

  SecurityService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Checks if the device hardware supports biometrics.
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e, st) {
      AppLogger.error('Failed to query biometric capability', e, st);
      return false;
    }
  }

  /// Prompts for biometric authentication (Fingerprint / Face Unlock).
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access Farmivo financial records',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e, st) {
      AppLogger.error('Biometric authentication failed', e, st);
      throw SecurityFailure('Biometric authentication failed: $e');
    }
  }

  /// Checks whether a PIN has been set by the user.
  Future<bool> hasPinSet() async {
    final hash = await _secureStorage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// Sets or updates the user's secure 4-6 digit numeric PIN.
  Future<void> setPin(String rawPin) async {
    if (rawPin.length < 4 || rawPin.length > 6) {
      throw const ValidationFailure('PIN must be between 4 and 6 digits.');
    }
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hashPin(rawPin, salt);

    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinHashKey, value: hash);
  }

  /// Verifies entered PIN against stored salted hash.
  Future<bool> verifyPin(String enteredPin) async {
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    final storedSalt = await _secureStorage.read(key: _pinSaltKey);

    if (storedHash == null || storedSalt == null) {
      return false;
    }
    final computedHash = _hashPin(enteredPin, storedSalt);
    return storedHash == computedHash;
  }

  /// Clears stored PIN and biometric settings (e.g. upon app data wipe).
  Future<void> clearSecurityData() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _biometricsEnabledKey);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt:farmivo_secure_v1');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
