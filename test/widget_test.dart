import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmivo/app/app.dart';

void main() {
  testWidgets('FarmivoApp smoke test with router', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FarmivoApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify app renders dashboard through GoRouter
    expect(find.text('Farm Project Manager'), findsOneWidget);
    expect(find.text('Farm Financial Overview'), findsOneWidget);
    expect(find.text('Active Projects'), findsOneWidget);
  });
}
