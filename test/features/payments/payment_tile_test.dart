import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/payments/domain/models/payment_with_details.dart';
import 'package:farmivo/features/payments/presentation/widgets/payment_tile.dart';
import 'package:farmivo/features/payments/presentation/widgets/void_payment_dialog.dart';

void main() {
  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Tomato Project 2026',
    projectType: 'CROP',
    commodity: 'Tomato',
    landSize: 5.0,
    landUnit: 'Acres',
    currency: 'GHS',
    status: 'ACTIVE',
    startDate: 0,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testBuyer = Buyer(
    id: 'buyer-1',
    name: 'Madam Akosua Agbogbloshie',
    phone: '0244112233',
    businessName: 'Akosua Produce',
    location: 'Agbogbloshie Market',
    notes: null,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testSale = Sale(
    id: 'sale-1',
    projectId: 'proj-1',
    buyerId: 'buyer-1',
    harvestId: null,
    saleDate: 0,
    productName: 'Roma Tomato',
    quantity: 20.0,
    unit: 'Crates',
    unitPriceMinor: 15000,
    totalAmountMinor: 300000,
    currency: 'GHS',
    paymentStatus: 'PARTIAL',
    notes: null,
    isVoided: false,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  Payment createTestPayment({
    required String id,
    required int amountMinor,
    String paymentMethod = 'MOMO_MTN',
    String? referenceNumber,
    String? notes,
    bool isVoided = false,
    String? voidReason,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Payment(
      id: id,
      saleId: 'sale-1',
      paymentDate: now,
      amountMinor: amountMinor,
      currency: 'GHS',
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      isVoided: isVoided,
      voidReason: voidReason,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  Widget createWidgetUnderTest(
    PaymentWithDetails paymentWithDetails, {
    bool showVoidButton = true,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PaymentTile(
            payment: paymentWithDetails,
            showVoidButton: showVoidButton,
          ),
        ),
      ),
    );
  }

  group('PaymentTile Widget Tests', () {
    testWidgets('renders active MTN MoMo installment correctly', (
      tester,
    ) async {
      final payment = createTestPayment(
        id: 'pay-1',
        amountMinor: 100000, // GH₵ 1,000.00
        paymentMethod: 'MOMO_MTN',
        referenceNumber: 'MOMO-998822',
        notes: 'Deposit paid via MoMo',
      );

      final paymentWithDetails = PaymentWithDetails(
        payment: payment,
        sale: testSale,
        buyer: testBuyer,
        project: testProject,
      );

      await tester.pumpWidget(createWidgetUnderTest(paymentWithDetails));
      await tester.pumpAndSettle();

      expect(find.text('MTN MoMo'), findsOneWidget);
      expect(find.text('+ GH₵ 1,000.00'), findsOneWidget);
      expect(find.text('Ref: MOMO-998822'), findsOneWidget);
      expect(find.text('Deposit paid via MoMo'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.byTooltip('Void Payment'), findsOneWidget);
    });

    testWidgets('renders voided payment with strikethrough and void reason', (
      tester,
    ) async {
      final payment = createTestPayment(
        id: 'pay-2',
        amountMinor: 50000, // GH₵ 500.00
        paymentMethod: 'CASH',
        isVoided: true,
        voidReason: 'Duplicate entry entered in error',
      );

      final paymentWithDetails = PaymentWithDetails(
        payment: payment,
        sale: testSale,
        buyer: testBuyer,
      );

      await tester.pumpWidget(createWidgetUnderTest(paymentWithDetails));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('+ GH₵ 500.00'), findsOneWidget);
      expect(
        find.text('VOIDED: Duplicate entry entered in error'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      // Void button should not be present on already voided payment
      expect(find.byTooltip('Void Payment'), findsNothing);
    });

    testWidgets(
      'tapping void button on active payment opens VoidPaymentDialog',
      (tester) async {
        final payment = createTestPayment(
          id: 'pay-3',
          amountMinor: 80000,
          paymentMethod: 'BANK',
        );

        final paymentWithDetails = PaymentWithDetails(
          payment: payment,
          sale: testSale,
          buyer: testBuyer,
        );

        await tester.pumpWidget(createWidgetUnderTest(paymentWithDetails));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Void Payment'));
        await tester.pumpAndSettle();

        expect(find.byType(VoidPaymentDialog), findsOneWidget);
        expect(find.text('Void Payment Record'), findsOneWidget);
        expect(find.text('Reason for Voiding *'), findsOneWidget);
      },
    );
  });
}
