import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/domain/models/buyers_directory_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/features/buyers/presentation/screens/buyer_form_sheet.dart';
import 'package:farmivo/features/buyers/presentation/screens/buyers_directory_screen.dart';
import 'package:farmivo/features/buyers/presentation/widgets/buyer_contact_action_sheet.dart';

void main() {
  const testBuyer1 = Buyer(
    id: 'buyer-1',
    name: 'Mama Beatrice Osei',
    phone: '0241234567',
    businessName: 'Stall #14 Makola Market',
    location: 'Makola Market, Accra',
    notes: 'Credit terms: 14 days',
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testBuyer2 = Buyer(
    id: 'buyer-2',
    name: 'Kofi Mensah',
    phone: '0509876543',
    businessName: 'Mensah Wholesalers',
    location: 'Techiman Market',
    notes: null,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testSummary1 = BuyerSummary(
    buyer: testBuyer1,
    totalPurchased: Money(BigInt.from(150000)), // GH₵ 1,500.00
    totalPaid: Money(BigInt.from(60000)), // GH₵ 600.00
    outstandingBalance: Money(BigInt.from(90000)), // GH₵ 900.00
    salesCount: 2,
  );

  final testSummary2 = BuyerSummary(
    buyer: testBuyer2,
    totalPurchased: Money(BigInt.from(80000)), // GH₵ 800.00
    totalPaid: Money(BigInt.from(80000)), // GH₵ 800.00
    outstandingBalance: Money.zero(),
    salesCount: 1,
  );

  final testDirSummary = BuyersDirectorySummary(
    totalBuyers: 2,
    activeDebtorsCount: 1,
    totalReceivables: Money(BigInt.from(90000)), // GH₵ 900.00
    totalSalesVolume: Money(BigInt.from(230000)), // GH₵ 2,300.00
    totalCashCollected: Money(BigInt.from(140000)), // GH₵ 1,400.00
  );

  Widget createWidget({
    List<BuyerSummary> buyers = const [],
    BuyersDirectorySummary? directorySummary,
  }) {
    return ProviderScope(
      overrides: [
        buyersStreamProvider.overrideWith((ref) => Stream.value(buyers)),
        buyersDirectorySummaryProvider.overrideWith(
          (ref) =>
              Stream.value(directorySummary ?? BuyersDirectorySummary.empty()),
        ),
      ],
      child: const MaterialApp(home: BuyersDirectoryScreen()),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('BuyersDirectoryScreen Widget Tests', () {
    testWidgets('Renders empty state when no buyers exist', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget(buyers: []));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Customer Directory'), findsOneWidget);
      expect(find.text('No Customers in Directory'), findsOneWidget);
      expect(find.text('Add First Customer'), findsOneWidget);
    });

    testWidgets(
      'Renders summary card, search bar, and buyer tiles when populated',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(
          createWidget(
            buyers: [testSummary1, testSummary2],
            directorySummary: testDirSummary,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Header summary
        expect(find.text('Commercial Receivables'), findsOneWidget);
        expect(find.text('Debtors (1)'), findsOneWidget);

        // Buyer tiles
        expect(
          find.text('Mama Beatrice Osei (Stall #14 Makola Market)'),
          findsOneWidget,
        );
        expect(find.text('Kofi Mensah (Mensah Wholesalers)'), findsOneWidget);
        expect(find.text('GH₵ 900.00 Due'), findsOneWidget);
        expect(find.text('Fully Settled'), findsOneWidget);
      },
    );

    testWidgets('Tapping contact icon button opens BuyerContactActionSheet', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(
        createWidget(buyers: [testSummary1], directorySummary: testDirSummary),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on contact button
      await tester.tap(find.byTooltip('Contact Buyer').first);
      await tester.pumpAndSettle();

      expect(find.byType(BuyerContactActionSheet), findsOneWidget);
      expect(find.text('Call Customer'), findsOneWidget);
      expect(find.text('Copy Debt Collection SMS'), findsOneWidget);
      expect(find.text('Copy Phone Number'), findsOneWidget);
    });

    testWidgets('Tapping New Customer FAB opens BuyerFormSheet', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidget(buyers: [testSummary1]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('New Customer'));
      await tester.pumpAndSettle();

      expect(find.byType(BuyerFormSheet), findsOneWidget);
      expect(find.text('Add New Customer'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
    });
  });
}
