import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/features/buyers/presentation/screens/buyer_detail_screen.dart';
import 'package:farmivo/features/buyers/presentation/widgets/buyer_contact_action_sheet.dart';

void main() {
  const testBuyer = Buyer(
    id: 'buyer-detail-1',
    name: 'Mama Beatrice Osei',
    phone: '0241234567',
    businessName: 'Stall #14 Makola Market',
    location: 'Makola Market, Accra',
    notes: 'Credit terms: 14 days net payment.',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testSummary = BuyerSummary(
    buyer: testBuyer,
    totalPurchased: Money(BigInt.from(250000)), // GH₵ 2,500.00
    totalPaid: Money(BigInt.from(180000)), // GH₵ 1,800.00
    outstandingBalance: Money(BigInt.from(70000)), // GH₵ 700.00
    salesCount: 3,
  );

  Widget createWidget({BuyerSummary? summary}) {
    return ProviderScope(
      overrides: [
        buyerSummaryProvider(
          'buyer-detail-1',
        ).overrideWith((ref) => Stream.value(summary)),
      ],
      child: const MaterialApp(
        home: BuyerDetailScreen(buyerId: 'buyer-detail-1'),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('BuyerDetailScreen Widget Tests', () {
    testWidgets(
      'Renders complete buyer profile, contact actions, and financial cards',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(createWidget(summary: testSummary));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Profile details
        expect(find.text('Mama Beatrice Osei'), findsOneWidget);
        expect(find.text('Stall #14 Makola Market'), findsOneWidget);
        expect(find.text('Makola Market, Accra'), findsOneWidget);
        expect(find.text('0241234567'), findsOneWidget);
        expect(find.text('Call / SMS Buyer'), findsOneWidget);

        // Financials
        expect(find.text('Financial Ledger & Credit Standing'), findsOneWidget);
        expect(find.text('Outstanding Balance Owed'), findsOneWidget);
        expect(find.text('GH₵ 700.00'), findsOneWidget);
        expect(find.text('Partial Payment'), findsOneWidget);
        expect(find.text('3 Sales'), findsOneWidget);

        // Notes
        expect(find.text('Credit terms: 14 days net payment.'), findsOneWidget);
        expect(find.text('Delete Customer Record'), findsOneWidget);
      },
    );

    testWidgets('Tapping Call / SMS Buyer opens BuyerContactActionSheet', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget(summary: testSummary));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Call / SMS Buyer'));
      await tester.pumpAndSettle();

      expect(find.byType(BuyerContactActionSheet), findsOneWidget);
      expect(find.text('Call Customer'), findsOneWidget);
      expect(find.text('Copy Debt Collection SMS'), findsOneWidget);
    });

    testWidgets('Tapping Delete Customer Record triggers confirmation dialog', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget(summary: testSummary));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Delete Customer Record'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Customer Record?'), findsOneWidget);
      expect(find.text('Delete Customer'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
