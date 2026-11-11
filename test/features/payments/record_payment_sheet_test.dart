import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/payments/domain/repositories/payment_repository.dart';
import 'package:farmivo/features/payments/presentation/providers/payment_providers.dart';
import 'package:farmivo/features/payments/presentation/widgets/record_payment_sheet.dart';
import 'package:farmivo/features/sales/domain/models/sale_with_details.dart';

class MockPaymentRepository implements PaymentRepository {
  String? recordedSaleId;
  DateTime? recordedPaymentDate;
  int? recordedAmountMinor;
  PaymentMethod? recordedPaymentMethod;
  String? recordedReferenceNumber;

  @override
  Future<String> recordPayment({
    required String saleId,
    required DateTime paymentDate,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    recordedSaleId = saleId;
    recordedPaymentDate = paymentDate;
    recordedAmountMinor = amountMinor;
    recordedPaymentMethod = paymentMethod;
    recordedReferenceNumber = referenceNumber;
    return 'pay-id-mock-123';
  }

  @override
  Future<Money> getSaleOutstandingBalance(String saleId) async {
    return Money.fromMajor(1500);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testProject = Project(
    id: 'proj-pay-1',
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
    id: 'buyer-pay-1',
    name: 'Madam Akosua Agbogbloshie',
    phone: '0244112233',
    businessName: 'Akosua Produce Ltd',
    location: 'Agbogbloshie Market',
    notes: null,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testSale = Sale(
    id: 'sale-pay-1',
    projectId: 'proj-pay-1',
    buyerId: 'buyer-pay-1',
    harvestId: null,
    saleDate: 0,
    productName: 'Roma Tomato',
    quantity: 20.0,
    unit: 'Crates',
    unitPriceMinor: 15000,
    totalAmountMinor: 300000, // GH₵ 3,000.00
    currency: 'GHS',
    paymentStatus: 'PARTIAL',
    notes: null,
    isVoided: false,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  // SaleWithDetails with GH₵ 1,500.00 paid and GH₵ 1,500.00 remaining
  final testSaleWithDetails = SaleWithDetails(
    sale: testSale,
    project: testProject,
    buyer: testBuyer,
    totalPaidMinor: 150000,
  );

  late MockPaymentRepository mockRepo;

  setUp(() {
    mockRepo = MockPaymentRepository();
  });

  Widget createWidgetUnderTest({SaleWithDetails? sale, String? saleId}) {
    return ProviderScope(
      overrides: [
        paymentRepositoryProvider.overrideWithValue(mockRepo),
        unsettledSalesProvider.overrideWith(
          (ref) => Stream.value([testSaleWithDetails]),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: RecordPaymentSheet(initialSale: sale, initialSaleId: saleId),
        ),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RecordPaymentSheet Widget Tests', () {
    testWidgets('renders open debt details and quick Pay Full button', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest(sale: testSaleWithDetails));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Record Payment Received'), findsOneWidget);
      expect(find.text('CURRENT OUTSTANDING DEBT'), findsOneWidget);
      // Balance is GH₵ 1,500.00
      expect(find.text('GH₵ 1,500.00'), findsOneWidget);
      expect(find.text('Pay Full (GH₵ 1,500.00)'), findsOneWidget);
      expect(find.text('Confirm Payment Received'), findsOneWidget);
    });

    testWidgets(
      'tapping Pay Full chip fills amount and shows full settlement message',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(
          createWidgetUnderTest(sale: testSaleWithDetails),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap 'Pay Full' chip
        await tester.tap(find.text('Pay Full (GH₵ 1,500.00)'));
        await tester.pump();

        // Field should contain 1500.00
        expect(find.text('1500.00'), findsOneWidget);
        // Celebratory full settlement banner
        expect(find.text('✨ Fully Settles Agreement!'), findsOneWidget);
      },
    );

    testWidgets('partial amount entry calculates dynamic remaining balance', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest(sale: testSaleWithDetails));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Enter 500.00 -> remaining balance should be GH₵ 1,000.00
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. 500.00'),
        '500',
      );
      await tester.pump();

      expect(find.text('New Balance Remaining:'), findsOneWidget);
      expect(find.text('GH₵ 1,000.00'), findsOneWidget);
    });

    testWidgets('switching payment channel updates method selection', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest(sale: testSaleWithDetails));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Default is Cash
      expect(find.text('Cash'), findsOneWidget);

      // Tap MTN MoMo
      await tester.tap(find.text('MTN MoMo'));
      await tester.pump();

      // Enters reference number
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'MOMO-1029384756',
      );
      await tester.pump();

      expect(find.text('MOMO-1029384756'), findsOneWidget);
    });

    testWidgets('submits payment and invokes repository with typed values', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest(sale: testSaleWithDetails));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Fill in 750.00 payment
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. 500.00'),
        '750',
      );

      // Select Telecel Cash
      await tester.tap(find.text('Telecel Cash'));

      // Enter Reference
      await tester.enterText(find.byType(TextFormField).at(1), 'TEL-998811');
      await tester.pump();

      // Submit
      await tester.ensureVisible(find.text('Confirm Payment Received'));
      await tester.tap(find.text('Confirm Payment Received'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(mockRepo.recordedSaleId, equals('sale-pay-1'));
      expect(mockRepo.recordedAmountMinor, equals(75000)); // GH₵ 750.00
      expect(mockRepo.recordedPaymentMethod, equals(PaymentMethod.telecelCash));
      expect(mockRepo.recordedReferenceNumber, equals('TEL-998811'));
    });
  });
}
