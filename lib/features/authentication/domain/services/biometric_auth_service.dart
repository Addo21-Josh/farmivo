import 'package:local_auth/local_auth.dart';

/// Service managing device biometric hardware capabilities and authentication (Milestone 9.1).
class BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  /// Checks whether the device hardware supports biometrics and credentials exist.
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Returns the specific types of biometrics enrolled on the device (e.g. fingerprint, face).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Prompts the user with the native OS biometric dialog (Fingerprint / Face ID).
  Future<bool> authenticate({
    String localizedReason = 'Unlock Farmivo to access your farm financials',
  }) async {
    try {
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Cancels any ongoing biometric authentication prompt.
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {}
  }
}
