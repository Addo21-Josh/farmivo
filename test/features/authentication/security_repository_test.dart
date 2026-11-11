import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/authentication/domain/models/auto_lock_timeout.dart';
import 'package:farmivo/features/authentication/domain/services/biometric_auth_service.dart';
import 'package:farmivo/features/authentication/domain/services/security_repository.dart';

class FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  FakeFlutterSecureStorage() : super();

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear();
  }
}

class FakeBiometricAuthService extends BiometricAuthService {
  final bool isAvailable;

  FakeBiometricAuthService({this.isAvailable = true});

  @override
  Future<bool> isBiometricsAvailable() async => isAvailable;
}

void main() {
  group('SecurityRepository Unit Tests', () {
    late FakeFlutterSecureStorage fakeStorage;
    late SecurityRepository repository;
    late FakeBiometricAuthService fakeBiometrics;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      repository = SecurityRepository(storage: fakeStorage);
      fakeBiometrics = FakeBiometricAuthService(isAvailable: true);
    });

    test('initial state reports no PIN and disabled app lock', () async {
      expect(await repository.hasPin(), isFalse);
      expect(await repository.isAppLockEnabled(), isFalse);
      expect(await repository.isBiometricsEnabled(), isFalse);
      expect(await repository.getPinLength(), 4);
      expect(await repository.getAutoLockTimeout(), AutoLockTimeout.oneMinute);
    });

    test(
      'savePin saves salt, hash, length, and auto-enables app lock',
      () async {
        await repository.savePin('7531');

        expect(await repository.hasPin(), isTrue);
        expect(await repository.isAppLockEnabled(), isTrue);
        expect(await repository.getPinLength(), 4);

        // Verify correct PIN passes
        expect(await repository.verifyPin('7531'), isTrue);

        // Verify wrong PIN fails
        expect(await repository.verifyPin('0000'), isFalse);
      },
    );

    test(
      'removePin cleans up credentials and disables app lock and biometrics',
      () async {
        await repository.savePin('1234');
        await repository.setBiometricsEnabled(true);

        expect(await repository.hasPin(), isTrue);
        expect(await repository.isBiometricsEnabled(), isTrue);

        await repository.removePin();

        expect(await repository.hasPin(), isFalse);
        expect(await repository.isAppLockEnabled(), isFalse);
        expect(await repository.isBiometricsEnabled(), isFalse);
      },
    );

    test('setAutoLockTimeout persists and updates timeout duration', () async {
      await repository.setAutoLockTimeout(AutoLockTimeout.immediate);
      expect(await repository.getAutoLockTimeout(), AutoLockTimeout.immediate);

      await repository.setAutoLockTimeout(AutoLockTimeout.fifteenMinutes);
      expect(
        await repository.getAutoLockTimeout(),
        AutoLockTimeout.fifteenMinutes,
      );

      await repository.setAutoLockTimeout(AutoLockTimeout.never);
      expect(await repository.getAutoLockTimeout(), AutoLockTimeout.never);
    });

    test(
      'recordBackgroundTimestamp stores and retrieves DateTime properly',
      () async {
        expect(await repository.getLastBackgroundTimestamp(), isNull);

        final now = DateTime(2026, 3, 15, 14, 30);
        await repository.recordBackgroundTimestamp(now);

        final retrieved = await repository.getLastBackgroundTimestamp();
        expect(retrieved, isNotNull);
        expect(retrieved!.millisecondsSinceEpoch, now.millisecondsSinceEpoch);

        await repository.clearBackgroundTimestamp();
        expect(await repository.getLastBackgroundTimestamp(), isNull);
      },
    );

    test('loadSecuritySettings compiles complete settings DTO', () async {
      await repository.savePin('8888');
      await repository.setBiometricsEnabled(true);
      await repository.setAutoLockTimeout(AutoLockTimeout.fiveMinutes);

      final settings = await repository.loadSecuritySettings(fakeBiometrics);

      expect(settings.hasPin, isTrue);
      expect(settings.isAppLockEnabled, isTrue);
      expect(settings.pinLength, 4);
      expect(settings.isBiometricsEnabled, isTrue);
      expect(settings.isBiometricsAvailableOnDevice, isTrue);
      expect(settings.autoLockTimeout, AutoLockTimeout.fiveMinutes);
    });
  });
}
