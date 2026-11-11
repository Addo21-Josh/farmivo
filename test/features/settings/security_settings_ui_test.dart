import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/features/authentication/domain/models/auto_lock_timeout.dart';
import 'package:farmivo/features/authentication/domain/services/security_repository.dart';
import 'package:farmivo/features/authentication/presentation/providers/security_providers.dart';
import 'package:farmivo/features/settings/presentation/screens/security_settings_screen.dart';
import '../authentication/lock_screen_test.dart';
import '../authentication/security_repository_test.dart';

void main() {
  group('SecuritySettingsScreen Widget Tests', () {
    late FakeFlutterSecureStorage fakeStorage;
    late SecurityRepository repository;
    late MockBiometricService mockBiometrics;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      repository = SecurityRepository(storage: fakeStorage);
      mockBiometrics = MockBiometricService();
    });

    testWidgets(
      'renders security settings with status card and toggle controls',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            securityRepositoryProvider.overrideWithValue(repository),
            biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const SecuritySettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Security & PIN Lock'), findsOneWidget);
        expect(find.text('Application Lock Disabled'), findsOneWidget);
        expect(find.text('Require PIN to Open App'), findsOneWidget);
        expect(find.text('Set Up Security PIN'), findsOneWidget);
        expect(find.text('Biometric Unlock'), findsOneWidget);
        expect(find.text('Auto-Lock Timeout'), findsOneWidget);
      },
    );

    testWidgets('creates a new PIN through the two-step setup modal sheet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          securityRepositoryProvider.overrideWithValue(repository),
          biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SecuritySettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Set Up Security PIN'
      await tester.tap(find.text('Set Up Security PIN'));
      await tester.pumpAndSettle();

      // Step 1: Create 4-Digit Security PIN
      expect(find.text('Create 4-Digit Security PIN'), findsOneWidget);

      // Enter digits '1', '2', '3', '4'
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Step 2: Confirm Your 4-Digit PIN
      expect(find.text('Confirm Your 4-Digit PIN'), findsOneWidget);

      // Re-enter '1', '2', '3', '4'
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Sheet closes, PIN is saved
      expect(await repository.hasPin(), isTrue);
      expect(await repository.verifyPin('1234'), isTrue);

      // Status card updates
      expect(find.text('Application Lock Active'), findsOneWidget);
    });

    testWidgets('allows changing auto-lock timeout via dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await repository.savePin('1234');

      final container = ProviderContainer(
        overrides: [
          securityRepositoryProvider.overrideWithValue(repository),
          biometricAuthServiceProvider.overrideWithValue(mockBiometrics),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SecuritySettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Auto-Lock Timeout'
      await tester.tap(find.text('Auto-Lock Timeout'));
      await tester.pumpAndSettle();

      // Dialog opens with timeout options
      expect(find.text('Immediately'), findsOneWidget);
      expect(find.text('After 5 minutes'), findsOneWidget);

      // Select 'Immediately'
      await tester.tap(find.text('Immediately'));
      await tester.pumpAndSettle();

      expect(await repository.getAutoLockTimeout(), AutoLockTimeout.immediate);
    });
  });
}
