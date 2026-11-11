import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/authentication/domain/services/security_repository.dart';
import 'package:farmivo/features/settings/domain/models/wipe_result.dart';
import 'package:farmivo/features/settings/domain/services/data_wipe_service.dart';
import 'package:farmivo/features/settings/presentation/providers/wipe_providers.dart';
import 'package:farmivo/features/settings/presentation/settings_screen.dart';
import 'package:farmivo/features/settings/presentation/widgets/data_wipe_confirmation_dialog.dart';

class FakeDataWipeService extends DataWipeService {
  final bool pinRequired;
  final String validPin;
  bool executeCalled = false;
  bool lastDeleteBackups = false;

  FakeDataWipeService({this.pinRequired = false, this.validPin = '1234'})
    : super(
        db: AppDatabase.forTesting(NativeDatabase.memory()),
        securityRepository: const SecurityRepository(),
      );

  @override
  Future<bool> isPinVerificationRequired() async => pinRequired;

  @override
  Future<bool> verifyWipeAuthorization(String enteredPin) async {
    if (!pinRequired) return true;
    return enteredPin == validPin;
  }

  @override
  Future<WipeResult> executeFactoryReset({bool deleteBackups = false}) async {
    executeCalled = true;
    lastDeleteBackups = deleteBackups;
    return WipeResult(
      success: true,
      tablesCleared: 16,
      backupsDeleted: deleteBackups ? 3 : 0,
      timestamp: DateTime.now(),
    );
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Data Wipe UI Widget Tests (Milestone 9.4)', () {
    Widget createWidgetForTesting({
      required Widget child,
      required DataWipeService wipeService,
    }) {
      return ProviderScope(
        overrides: [
          dataWipeServiceProvider.overrideWithValue(wipeService),
          isPinRequiredForWipeProvider.overrideWith(
            (ref) => wipeService.isPinVerificationRequired(),
          ),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets(
      'SettingsScreen displays emergency data wipe tile and opens dialog on tap',
      (tester) async {
        final fakeService = FakeDataWipeService(pinRequired: false);

        await tester.pumpWidget(
          createWidgetForTesting(
            child: const SettingsScreen(),
            wipeService: fakeService,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Scroll down to reveal Emergency Wipe tile
        await tester.scrollUntilVisible(
          find.byKey(const Key('settings_emergency_wipe_tile')),
          500.0,
        );
        expect(
          find.byKey(const Key('settings_emergency_wipe_tile')),
          findsOneWidget,
        );
        expect(
          find.text('Emergency Data Wipe & Factory Reset'),
          findsOneWidget,
        );

        // Tap tile to open dialog
        await tester.tap(find.byKey(const Key('settings_emergency_wipe_tile')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Dialog should be visible
        expect(find.text('Emergency Factory Reset'), findsOneWidget);
        expect(
          find.textContaining('DANGER: This action cannot be undone'),
          findsOneWidget,
        );
        expect(find.text('Type RESET to confirm deletion:'), findsOneWidget);
      },
    );

    testWidgets(
      'DataWipeConfirmationDialog enforces challenge text and toggles backup checkbox',
      (tester) async {
        final fakeService = FakeDataWipeService(pinRequired: false);

        await tester.pumpWidget(
          createWidgetForTesting(
            child: const Scaffold(body: DataWipeConfirmationDialog()),
            wipeService: fakeService,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify button initially disabled
        final confirmButtonFinder = find.byKey(
          const Key('wipe_confirm_button'),
        );
        ElevatedButton button = tester.widget(confirmButtonFinder);
        expect(button.onPressed, isNull);

        // Enter invalid challenge
        await tester.enterText(
          find.byKey(const Key('wipe_challenge_input')),
          'DELETE',
        );
        await tester.pump();
        button = tester.widget(confirmButtonFinder);
        expect(button.onPressed, isNull);

        // Toggle backup deletion checkbox
        final checkboxFinder = find.byType(Checkbox);
        expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);
        await tester.tap(checkboxFinder);
        await tester.pump();
        expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

        // Enter correct challenge 'RESET'
        await tester.enterText(
          find.byKey(const Key('wipe_challenge_input')),
          'RESET',
        );
        await tester.pump();
        button = tester.widget(confirmButtonFinder);
        expect(button.onPressed, isNotNull);

        // Tap confirm button
        await tester.tap(confirmButtonFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify service was called with deleteBackups: true
        expect(fakeService.executeCalled, isTrue);
        expect(fakeService.lastDeleteBackups, isTrue);
      },
    );

    testWidgets(
      'DataWipeConfirmationDialog enforces security PIN verification when lock is active',
      (tester) async {
        final fakeService = FakeDataWipeService(
          pinRequired: true,
          validPin: '7788',
        );

        await tester.pumpWidget(
          createWidgetForTesting(
            child: const Scaffold(body: DataWipeConfirmationDialog()),
            wipeService: fakeService,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify PIN field is visible
        expect(find.text('Enter Security PIN to authorize:'), findsOneWidget);
        expect(find.byKey(const Key('wipe_pin_input')), findsOneWidget);

        final confirmButtonFinder = find.byKey(
          const Key('wipe_confirm_button'),
        );
        ElevatedButton button = tester.widget(confirmButtonFinder);
        expect(button.onPressed, isNull);

        // Enter challenge 'RESET' without PIN -> still disabled
        await tester.enterText(
          find.byKey(const Key('wipe_challenge_input')),
          'RESET',
        );
        await tester.pump();
        button = tester.widget(confirmButtonFinder);
        expect(button.onPressed, isNull);

        // Enter wrong PIN
        await tester.enterText(find.byKey(const Key('wipe_pin_input')), '0000');
        await tester.pump();
        button = tester.widget(confirmButtonFinder);
        expect(button.onPressed, isNotNull);

        // Tap confirm with wrong PIN
        await tester.tap(confirmButtonFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should display error message and NOT execute wipe
        expect(find.textContaining('Incorrect security PIN'), findsOneWidget);
        expect(fakeService.executeCalled, isFalse);

        // Enter correct PIN
        await tester.enterText(find.byKey(const Key('wipe_pin_input')), '7788');
        await tester.pump();

        // Tap confirm with correct PIN
        await tester.tap(confirmButtonFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Now execution succeeds
        expect(fakeService.executeCalled, isTrue);
      },
    );
  });
}
