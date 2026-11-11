import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/presentation/providers/harvest_providers.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';
import 'package:farmivo/features/sales/domain/repositories/sale_repository.dart';
import 'package:farmivo/features/sales/presentation/providers/sale_providers.dart';
import 'package:farmivo/features/sales/presentation/record_sale_screen.dart';

class MockSaleRepository implements SaleRepository {
  String? recordedProjectId;
  String? recordedProductName;
  double? recordedQuantity;
  int? recordedUnitPriceMinor;
  SalePaymentStatus? recordedPaymentStatus;

  @override
  Future<String> recordSale({
    required String projectId,
    String? buyerId,
    String? harvestId,
    required DateTime saleDate,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    String currency = 'GHS',
    required SalePaymentStatus paymentStatus,
    int? initialPaymentAmountMinor,
    String? paymentMethod,
    String? notes,
  }) async {
    recordedProjectId = projectId;
    recordedProductName = productName;
    recordedQuantity = quantity;
    recordedUnitPriceMinor = unitPriceMinor;
    recordedPaymentStatus = paymentStatus;
    return 'sale-id-mock-123';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testProjectId = 'proj-screen-1';

  const testProject = Project(
    id: testProjectId,
    farmId: 'farm-1',
    name: 'Commercial Tomato 2026',
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
    id: 'buyer-screen-1',
    name: 'Madam Akosua Agbogbloshie',
    phone: '0244112233',
    businessName: 'Akosua & Sons',
    location: 'Agbogbloshie Market',
    notes: null,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  final testBuyerSummary = BuyerSummary(
    buyer: testBuyer,
    totalPurchased: Money.zero(),
    totalPaid: Money.zero(),
    outstandingBalance: Money.zero(),
    salesCount: 0,
  );

  late MockSaleRepository mockRepo;

  setUp(() {
    mockRepo = MockSaleRepository();
  });

  Widget createWidgetUnderTest({String? initialProjectId = testProjectId}) {
    return ProviderScope(
      overrides: [
        saleRepositoryProvider.overrideWithValue(mockRepo),
        projectsStreamProvider.overrideWith(
          (ref) => Stream.value([testProject]),
        ),
        buyersStreamProvider.overrideWith(
          (ref) => Stream.value([testBuyerSummary]),
        ),
        projectHarvestsWithDetailsProvider(
          testProjectId,
        ).overrideWith((ref) => Stream.value(<HarvestWithDetails>[])),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: RecordSaleScreen(initialProjectId: initialProjectId),
        ),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RecordSaleScreen Tests', () {
    testWidgets('renders all essential fields and pre-selects project', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Record Harvest Sale'), findsOneWidget);
      expect(find.text('Farming Project *'), findsOneWidget);
      expect(find.text('Produce / Commodity Name *'), findsOneWidget);
      expect(find.text('Quantity *'), findsOneWidget);
      expect(find.text('Unit *'), findsOneWidget);
      expect(find.text('Unit Price (GH₵ per unit) *'), findsOneWidget);
      expect(find.text('TOTAL SALE VALUE'), findsOneWidget);
      expect(find.text('Payment Status *'), findsOneWidget);
      expect(find.text('Full Payment'), findsOneWidget);
      expect(find.text('Partial'), findsOneWidget);
      expect(find.text('Credit Sale'), findsOneWidget);
      expect(find.text('Record Commercial Sale'), findsOneWidget);
    });

    testWidgets(
      'dynamically calculates total amount when quantity and price change',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Enter quantity 20
        final quantityFinder = find.widgetWithText(TextFormField, 'e.g. 50');
        await tester.enterText(quantityFinder, '20');

        // Enter unit price 150
        final priceFinder = find.widgetWithText(TextFormField, 'e.g. 150.00');
        await tester.enterText(priceFinder, '150');

        await tester.pump();

        // Formula should show 20.0 Crates x GH₵ 150.00
        expect(find.textContaining('20.0 Crates × GH₵ 150.00'), findsOneWidget);
        // Total amount should be GH₵ 3,000.00
        expect(find.text('GH₵ 3,000.00'), findsOneWidget);
      },
    );

    testWidgets(
      'switching to Partial payment reveals deposit input and remaining debt',
      (tester) async {
        setupScreen(tester);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Enter quantity 10, unit price 100 -> Total = GH₵ 1,000.00
        await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. 50'),
          '10',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. 150.00'),
          '100',
        );
        await tester.pump();

        // Tap 'Partial'
        await tester.tap(find.text('Partial'));
        await tester.pump();

        expect(find.text('Initial Deposit Collected (GH₵) *'), findsOneWidget);
        expect(find.text('Remaining Buyer Debt:'), findsOneWidget);

        // Enter deposit of GH₵ 300
        await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. 50.00'),
          '300',
        );
        await tester.pump();

        // Remaining debt should show GH₵ 700.00
        expect(find.text('GH₵ 700.00'), findsOneWidget);
      },
    );

    testWidgets('validates required fields before submitting', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to bottom and tap submit button
      await tester.ensureVisible(find.text('Record Commercial Sale'));
      await tester.tap(find.text('Record Commercial Sale'));
      await tester.pump();

      // Form validation error texts
      expect(find.text('Please enter the produce name'), findsOneWidget);
      expect(find.text('Enter quantity'), findsOneWidget);
      expect(find.text('Please enter the unit price'), findsOneWidget);
    });

    testWidgets('successfully records sale and invokes repository', (
      tester,
    ) async {
      setupScreen(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Fill in all required fields
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'e.g. Roma Tomato, Yellow Corn, Fresh Chili',
        ),
        'Roma Tomato',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. 50'),
        '25',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. 150.00'),
        '120',
      );
      await tester.pump();

      // Tap submit
      await tester.ensureVisible(find.text('Record Commercial Sale'));
      await tester.tap(find.text('Record Commercial Sale'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify repository was invoked with correct arguments
      expect(mockRepo.recordedProjectId, equals(testProjectId));
      expect(mockRepo.recordedProductName, equals('Roma Tomato'));
      expect(mockRepo.recordedQuantity, equals(25.0));
      // 120 GHS = 12,000 minor units
      expect(mockRepo.recordedUnitPriceMinor, equals(12000));
      expect(mockRepo.recordedPaymentStatus, equals(SalePaymentStatus.paid));
    });
  });
}
