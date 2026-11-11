import 'package:flutter/material.dart';

import 'package:farmivo/features/sales/domain/models/sale_with_details.dart';
import 'widgets/record_payment_sheet.dart';

/// Full screen wrapper for [RecordPaymentSheet].
class RecordPaymentScreen extends StatelessWidget {
  final SaleWithDetails? initialSale;
  final String? initialSaleId;

  const RecordPaymentScreen({super.key, this.initialSale, this.initialSaleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment Received')),
      body: SafeArea(
        child: RecordPaymentSheet(
          initialSale: initialSale,
          initialSaleId: initialSaleId,
        ),
      ),
    );
  }
}
