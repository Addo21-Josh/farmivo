import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/authentication/domain/models/auto_lock_timeout.dart';
import 'package:farmivo/features/authentication/domain/models/security_settings.dart';

void main() {
  group('AutoLockTimeout & Lockout Tests', () {
    test(
      'AutoLockTimeout.fromSeconds resolves known durations and defaults to oneMinute',
      () {
        expect(AutoLockTimeout.fromSeconds(0), AutoLockTimeout.immediate);
        expect(AutoLockTimeout.fromSeconds(60), AutoLockTimeout.oneMinute);
        expect(AutoLockTimeout.fromSeconds(300), AutoLockTimeout.fiveMinutes);
        expect(
          AutoLockTimeout.fromSeconds(900),
          AutoLockTimeout.fifteenMinutes,
        );
        expect(AutoLockTimeout.fromSeconds(-1), AutoLockTimeout.never);
        expect(AutoLockTimeout.fromSeconds(null), AutoLockTimeout.oneMinute);
        expect(AutoLockTimeout.fromSeconds(9999), AutoLockTimeout.oneMinute);
      },
    );

    test(
      'shouldLock correctly evaluates elapsed duration against timeout thresholds',
      () {
        // Immediate timeout
        expect(AutoLockTimeout.immediate.shouldLock(Duration.zero), isTrue);
        expect(
          AutoLockTimeout.immediate.shouldLock(const Duration(seconds: 1)),
          isTrue,
        );

        // 1 minute timeout (60 seconds)
        expect(
          AutoLockTimeout.oneMinute.shouldLock(const Duration(seconds: 59)),
          isFalse,
        );
        expect(
          AutoLockTimeout.oneMinute.shouldLock(const Duration(seconds: 60)),
          isTrue,
        );
        expect(
          AutoLockTimeout.oneMinute.shouldLock(const Duration(seconds: 120)),
          isTrue,
        );

        // 5 minutes timeout (300 seconds)
        expect(
          AutoLockTimeout.fiveMinutes.shouldLock(const Duration(seconds: 299)),
          isFalse,
        );
        expect(
          AutoLockTimeout.fiveMinutes.shouldLock(const Duration(seconds: 300)),
          isTrue,
        );

        // 15 minutes timeout (900 seconds)
        expect(
          AutoLockTimeout.fifteenMinutes.shouldLock(
            const Duration(seconds: 899),
          ),
          isFalse,
        );
        expect(
          AutoLockTimeout.fifteenMinutes.shouldLock(
            const Duration(seconds: 900),
          ),
          isTrue,
        );

        // Never timeout
        expect(AutoLockTimeout.never.shouldLock(Duration.zero), isFalse);
        expect(
          AutoLockTimeout.never.shouldLock(const Duration(days: 365)),
          isFalse,
        );
      },
    );

    test('SecuritySettings lockout detection and remaining duration', () {
      final now = DateTime.now();

      // Not locked out
      const normalSettings = SecuritySettings(
        failedAttempts: 2,
        lockoutUntil: null,
      );
      expect(normalSettings.isLockedOut, isFalse);
      expect(normalSettings.remainingLockoutSeconds, 0);

      // Locked out for 30 seconds
      final lockedSettings = SecuritySettings(
        failedAttempts: 5,
        lockoutUntil: now.add(const Duration(seconds: 30)),
      );
      expect(lockedSettings.isLockedOut, isTrue);
      expect(lockedSettings.remainingLockoutSeconds, greaterThanOrEqualTo(28));

      // Expired lockout
      final expiredSettings = SecuritySettings(
        failedAttempts: 5,
        lockoutUntil: now.subtract(const Duration(seconds: 1)),
      );
      expect(expiredSettings.isLockedOut, isFalse);
      expect(expiredSettings.remainingLockoutSeconds, 0);
    });
  });
}
