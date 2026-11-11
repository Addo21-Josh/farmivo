import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/router/route_guards.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/features/authentication/domain/models/security_settings.dart';
import 'package:farmivo/features/authentication/domain/services/biometric_auth_service.dart';
import 'package:farmivo/features/authentication/domain/services/security_repository.dart';
import 'package:farmivo/features/authentication/presentation/lock_screen.dart';
import 'package:farmivo/features/authentication/presentation/providers/security_providers.dart';
import 'security_repository_test.dart';

class MockBiometricService extends BiometricAuthService {
  bool authenticateResult = false;
  int authenticateCallCount = 0;

  @override
  Future<bool> isBiometricsAvailable() async => true;

  @override
  Future<bool> authenticate({String localizedReason = ''}) async {
    authenticateCallCount++;
    return authenticateResult;
  }
}

void main() {
  group('LockScreen Widget Tests', () {
    late FakeFlutterSecureStorage fakeStorage;
    late SecurityRepository repository;
    late MockBiometricService mockBiometrics;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      repository = SecurityRepository(storage: fakeStorage);
      mockBiometrics = MockBiometricService();
    });

    testWidgets(
      'renders LockScreen with branding, prompt, and numeric keypad',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await repository.savePin('1234');

        final container = ProviderContainer(
          overrides: [
            securityRepositoryProvider.overrideWithValue(repository),
            biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
            authLockProvider.overrideWith((ref) => true),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const LockScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Farmivo Security Lock'), findsOneWidget);
        expect(
          find.text('Enter your 4-digit security PIN to unlock'),
          findsOneWidget,
        );
        expect(find.text('1'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'entering correct PIN triggers unlock and updates authLockProvider',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await repository.savePin('2468');

        final container = ProviderContainer(
          overrides: [
            securityRepositoryProvider.overrideWithValue(repository),
            biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
            authLockProvider.overrideWith((ref) => true),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const LockScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(container.read(authLockProvider), isTrue);

        // Tap digits '2', '4', '6', '8'
        await tester.tap(find.text('2'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('4'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('6'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        // Should now be unlocked
        expect(container.read(authLockProvider), isFalse);
      },
    );

    testWidgets(
      'entering incorrect PIN displays error message and preserves lock',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await repository.savePin('1234');

        final container = ProviderContainer(
          overrides: [
            securityRepositoryProvider.overrideWithValue(repository),
            biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
            authLockProvider.overrideWith((ref) => true),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const LockScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter wrong PIN: '9', '9', '9', '9'
        await tester.tap(find.text('9'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('9'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('9'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();

        // App remains locked
        expect(container.read(authLockProvider), isTrue);
        expect(find.textContaining('Incorrect PIN'), findsOneWidget);
      },
    );

    testWidgets('lockout mode disables keypad and displays countdown message', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final lockedSettings = SecuritySettings(
        hasPin: true,
        isAppLockEnabled: true,
        pinLength: 4,
        failedAttempts: 5,
        lockoutUntil: DateTime.now().add(const Duration(seconds: 30)),
      );

      final container = ProviderContainer(
        overrides: [
          securitySettingsProvider.overrideWith(
            (ref) =>
                SecuritySettingsNotifier(repository, mockBiometrics)
                  ..state = AsyncValue.data(lockedSettings),
          ),
          authLockProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LockScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Locked for'), findsOneWidget);
      expect(find.textContaining('due to failed attempts'), findsOneWidget);
    });

    testWidgets(
      'tapping biometric shortcut icon triggers biometric authentication',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await repository.savePin('1234');
        await repository.setBiometricsEnabled(true);
        mockBiometrics.authenticateResult = true;

        final container = ProviderContainer(
          overrides: [
            securityRepositoryProvider.overrideWithValue(repository),
            biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
            authLockProvider.overrideWith((ref) => true),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const LockScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.fingerprint_rounded));
        await tester.pumpAndSettle();

        expect(mockBiometrics.authenticateCallCount, greaterThanOrEqualTo(1));
        expect(container.read(authLockProvider), isFalse);
      },
    );
  });
}
