import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/shared/widgets/widgets.dart';

void main() {
  testWidgets('AppStatusBadge renders icon and text (never color alone)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return AppStatusBadge.fromHealth(
                context,
                ProjectHealthStatus.atRisk,
              );
            },
          ),
        ),
      ),
    );

    // Verify both text and icon exist
    expect(find.text('At Risk'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('AppButton enforces minimum 48dp touch target', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppButton(label: 'Record Expense', onPressed: () {}),
        ),
      ),
    );

    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    final size = tester.getSize(buttonFinder);
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('MoneyDisplay displays formatted currency cleanly', (
    WidgetTester tester,
  ) async {
    final amount = Money.fromMajor(12500); // GH₵ 12,500.00

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: MoneyDisplay(
            money: amount,
            sentiment: MoneyDisplaySentiment.positive,
          ),
        ),
      ),
    );

    expect(find.text('GH₵ 12,500.00'), findsOneWidget);
  });
}
