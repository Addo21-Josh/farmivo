import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmivo/app/app.dart';

void main() {
  testWidgets('GoRouter bottom navigation switches between all 5 tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FarmivoApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Initial tab is Home / Dashboard
    expect(find.text('Farm Financial Overview'), findsOneWidget);

    // 2. Tap Projects Tab
    await tester.tap(find.text('Projects'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Farm Projects'), findsOneWidget);

    // 3. Tap Transactions Tab
    await tester.tap(find.text('Transactions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Transactions Ledger'), findsOneWidget);

    // 4. Tap Reports Tab
    await tester.tap(find.text('Reports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Reports & Analytics'), findsOneWidget);

    // 5. Tap Settings Tab
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Visual Theme Preset'), findsOneWidget);
  });

  testWidgets('Quick Action FAB opens quick actions sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FarmivoApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap the Quick Action FAB
    await tester.tap(find.text('Quick Action'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify modal bottom sheet opens with quick options
    expect(find.text('Record Expense'), findsOneWidget);
    expect(find.text('Record Harvest Sale'), findsOneWidget);
    expect(find.text('Launch New Project'), findsOneWidget);
  });
}
