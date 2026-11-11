import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/authentication/domain/services/pin_hasher.dart';

void main() {
  group('PinHasher Unit Tests', () {
    test('generateSalt produces a unique non-empty hexadecimal string', () {
      final salt1 = PinHasher.generateSalt();
      final salt2 = PinHasher.generateSalt();

      expect(salt1, isNotEmpty);
      expect(salt2, isNotEmpty);
      expect(salt1.length, 32); // 16 bytes * 2 hex chars
      expect(salt1, isNot(equals(salt2))); // Cryptographically random
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(salt1), isTrue);
    });

    test(
      'hashPin returns deterministic SHA-256 hash for identical PIN and salt',
      () {
        const pin = '4826';
        final salt = PinHasher.generateSalt();

        final hash1 = PinHasher.hashPin(pin, salt);
        final hash2 = PinHasher.hashPin(pin, salt);

        expect(hash1, equals(hash2));
        expect(hash1.length, 64); // 256 bits = 64 hex chars
      },
    );

    test(
      'hashPin produces different hashes for different salts with identical PIN',
      () {
        const pin = '1234';
        final salt1 = PinHasher.generateSalt();
        final salt2 = PinHasher.generateSalt();

        final hash1 = PinHasher.hashPin(pin, salt1);
        final hash2 = PinHasher.hashPin(pin, salt2);

        expect(hash1, isNot(equals(hash2)));
      },
    );

    test('verifyPin validates correct PIN and rejects incorrect PINs', () {
      const correctPin = '9876';
      const wrongPin = '1234';
      final salt = PinHasher.generateSalt();
      final storedHash = PinHasher.hashPin(correctPin, salt);

      // Positive verification
      expect(
        PinHasher.verifyPin(
          enteredPin: correctPin,
          storedHash: storedHash,
          salt: salt,
        ),
        isTrue,
      );

      // Negative verification (wrong PIN)
      expect(
        PinHasher.verifyPin(
          enteredPin: wrongPin,
          storedHash: storedHash,
          salt: salt,
        ),
        isFalse,
      );

      // Negative verification (empty inputs)
      expect(
        PinHasher.verifyPin(enteredPin: '', storedHash: storedHash, salt: salt),
        isFalse,
      );
      expect(
        PinHasher.verifyPin(enteredPin: correctPin, storedHash: '', salt: salt),
        isFalse,
      );
      expect(
        PinHasher.verifyPin(
          enteredPin: correctPin,
          storedHash: storedHash,
          salt: '',
        ),
        isFalse,
      );
    });

    test(
      'constantTimeEquals compares strings without early exit timing leaks',
      () {
        expect(
          PinHasher.constantTimeEquals('secret_hash', 'secret_hash'),
          isTrue,
        );
        expect(
          PinHasher.constantTimeEquals('secret_hash', 'wrong_hash'),
          isFalse,
        );
        expect(PinHasher.constantTimeEquals('short', 'longer_string'), isFalse);
        expect(PinHasher.constantTimeEquals('', ''), isTrue);
      },
    );
  });
}
