import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Cryptographic service providing salted SHA-256 hashing and constant-time
/// verification for user security PINs (Milestone 9.1).
class PinHasher {
  PinHasher._();

  static final Random _secureRandom = Random.secure();

  /// Generates a cryptographically secure random hexadecimal salt string.
  static String generateSalt([int byteLength = 16]) {
    final values = List<int>.generate(
      byteLength,
      (_) => _secureRandom.nextInt(256),
    );
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Computes a salted SHA-256 hash using the PIN and salt with 1,000 iterations
  /// of iterative key-stretching to prevent rainbow table attacks.
  static String hashPin(String pin, String salt) {
    var digest = sha256.convert(utf8.encode('$salt$pin$salt'));
    for (var i = 0; i < 999; i++) {
      digest = sha256.convert(digest.bytes + utf8.encode(salt));
    }
    return digest.toString();
  }

  /// Verifies an entered PIN against a stored salted hash using constant-time comparison.
  static bool verifyPin({
    required String enteredPin,
    required String storedHash,
    required String salt,
  }) {
    if (enteredPin.isEmpty || storedHash.isEmpty || salt.isEmpty) {
      return false;
    }
    final computedHash = hashPin(enteredPin, salt);
    return constantTimeEquals(computedHash, storedHash);
  }

  /// Performs a constant-time comparison of two strings to prevent timing side-channel attacks.
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
