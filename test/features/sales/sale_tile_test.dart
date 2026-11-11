import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmivo/app/theme/app_theme.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/sales/domain/models/sale_with_details.dart';
import 'package:farmivo/features/sales/presentation/widgets/sale_detail_sheet.dart';
import 'package:farmivo/features/sales/presentation/widgets/sale_tile.dart';

void main() {
  const testProject = Project(
    id: 'proj-1',
    farmId: 'farm-1',
    name: 'Dry Season Commercial Tomato',
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
    businessName: 'Akosua Produce Ltd',
    location: 'Agbogbloshie Market',
    notes: null,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  const testHarvest = Harvest(
    id: 'harvest-1',
    projectId: 'proj-1',
    batchNumber: 'HV-TOM-2611-01',
    harvestDate: 0,
    productName: 'Roma Tomato',
    quantity: 100.0,
    unit: 'Crates',
    grade: 'Grade A',
    storageLocation: 'Shed 1',
    notes: null,
    photoPath: null,
    createdAt: 0,
    updatedAt: 0,
    isSynced: false,
    isDeleted: false,
  );

  Sale createTestSale({
    required String id,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    required int totalAmountMinor,
    String paymentStatus = 'PAID',
    bool isVoided = false,
    String? voidReason,
    int? voidedAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Sale(
      id: id,
      projectId: 'proj-1',
      buyerId: 'buyer-1',
      harvestId: 'harvest-1',
      saleDate: now,
      productName: productName,
      quantity: quantity,
      unit: unit,
      unitPriceMinor: unitPriceMinor,
      totalAmountMinor: totalAmountMinor,
      currency: 'GHS',
      paymentStatus: paymentStatus,
      notes: 'Delivered at farm gate',
      isVoided: isVoided,
      voidedAt: voidedAt,
      voidReason: voidReason,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  Widget createWidgetUnderTest(SaleWithDetails saleWithDetails) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: SaleTile(sale: saleWithDetails)),
      ),
    );
  }

  group('SaleTile Widget Tests', () {
    testWidgets('renders product name, quantity, and buyer name correctly', (
      tester,
    ) async {
      final sale = createTestSale(
        id: 's-1',
        productName: 'Roma Tomato',
        quantity: 20.0,
        unit: 'Crates',
        unitPriceMinor: 15000,
        totalAmountMinor: 300000,
      );

      final saleWithDetails = SaleWithDetails(
        sale: sale,
        project: testProject,
        buyer: testBuyer,
        harvest: testHarvest,
        totalPaidMinor: 300000,
      );

      await tester.pumpWidget(createWidgetUnderTest(saleWithDetails));
      await tester.pumpAndSettle();

      expect(find.text('Roma Tomato'), findsOneWidget);
      expect(find.text('20 Crates'), findsOneWidget);
      expect(find.text('Madam Akosua Agbogbloshie'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('HV-TOM-2611-01'), findsOneWidget);
    });

    testWidgets('renders partial settlement badge and remaining due amount', (
      tester,
    ) async {
      final sale = createTestSale(
        id: 's-2',
        productName: 'Yellow Corn',
        quantity: 10.0,
        unit: 'Bags',
        unitPriceMinor: 20000,
        totalAmountMinor: 200000, // GH₵ 2,000.00
        paymentStatus: 'PARTIAL',
      );

      final saleWithDetails = SaleWithDetails(
        sale: sale,
        project: testProject,
        buyer: testBuyer,
        totalPaidMinor: 50000, // GH₵ 500.00 paid, GH₵ 1,500.00 due
      );

      await tester.pumpWidget(createWidgetUnderTest(saleWithDetails));
      await tester.pumpAndSettle();

      expect(find.text('Yellow Corn'), findsOneWidget);
      expect(find.text('10 Bags'), findsOneWidget);
      expect(find.text('Partial Payment'), findsOneWidget);
      expect(find.textContaining('Due:'), findsOneWidget);
    });

    testWidgets('renders credit / unpaid status badge for unsettled sales', (
      tester,
    ) async {
      final sale = createTestSale(
        id: 's-3',
        productName: 'Bell Peppers',
        quantity: 5.0,
        unit: 'Boxes',
        unitPriceMinor: 10000,
        totalAmountMinor: 50000,
        paymentStatus: 'UNPAID',
      );

      final saleWithDetails = SaleWithDetails(
        sale: sale,
        project: testProject,
        buyer: testBuyer,
        totalPaidMinor: 0,
      );

      await tester.pumpWidget(createWidgetUnderTest(saleWithDetails));
      await tester.pumpAndSettle();

      expect(find.text('Credit / Unpaid'), findsOneWidget);
    });

    testWidgets('renders VOIDED badge and strikethrough for voided sales', (
      tester,
    ) async {
      final sale = createTestSale(
        id: 's-4',
        productName: 'Cucumbers',
        quantity: 15.0,
        unit: 'Sacks',
        unitPriceMinor: 5000,
        totalAmountMinor: 75000,
        isVoided: true,
        voidReason: 'Produce returned due to quality issue',
        voidedAt: DateTime.now().millisecondsSinceEpoch,
      );

      final saleWithDetails = SaleWithDetails(
        sale: sale,
        project: testProject,
        buyer: testBuyer,
      );

      await tester.pumpWidget(createWidgetUnderTest(saleWithDetails));
      await tester.pumpAndSettle();

      expect(find.text('VOIDED'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('tapping SaleTile opens SaleDetailSheet', (tester) async {
      final sale = createTestSale(
        id: 's-5',
        productName: 'Fresh Cabbage',
        quantity: 25.0,
        unit: 'Bags',
        unitPriceMinor: 8000,
        totalAmountMinor: 200000,
      );

      final saleWithDetails = SaleWithDetails(
        sale: sale,
        project: testProject,
        buyer: testBuyer,
        harvest: testHarvest,
        totalPaidMinor: 200000,
      );

      await tester.pumpWidget(createWidgetUnderTest(saleWithDetails));
      await tester.pumpAndSettle();

      // Tap tile
      await tester.tap(find.byType(SaleTile));
      await tester.pumpAndSettle();

      // Verify SaleDetailSheet is shown
      expect(find.byType(SaleDetailSheet), findsOneWidget);
      expect(find.text('PRICING FORMULA'), findsOneWidget);
      expect(find.text('SETTLEMENT BREAKDOWN'), findsOneWidget);
      expect(find.text('CUSTOMER DETAILS'), findsOneWidget);
    });
  });
}
