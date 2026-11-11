import 'package:flutter/material.dart';

import 'package:farmivo/features/sales/domain/models/sale_with_details.dart';
import 'record_payment_screen.dart';

/// Legacy alias for [RecordPaymentScreen].
class AddPaymentScreen extends StatelessWidget {
  final SaleWithDetails? initialSale;
  final String? initialSaleId;

  const AddPaymentScreen({super.key, this.initialSale, this.initialSaleId});

  @override
  Widget build(BuildContext context) {
    return RecordPaymentScreen(
      initialSale: initialSale,
      initialSaleId: initialSaleId,
    );
  }
}
