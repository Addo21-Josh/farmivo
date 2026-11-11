import 'package:flutter/material.dart';
import 'record_sale_screen.dart';

/// Legacy wrapper for [RecordSaleScreen].
class AddSaleScreen extends StatelessWidget {
  final String? initialProjectId;
  final String? initialHarvestId;
  final String? initialBuyerId;

  const AddSaleScreen({
    super.key,
    this.initialProjectId,
    this.initialHarvestId,
    this.initialBuyerId,
  });

  @override
  Widget build(BuildContext context) {
    return RecordSaleScreen(
      initialProjectId: initialProjectId,
      initialHarvestId: initialHarvestId,
      initialBuyerId: initialBuyerId,
    );
  }
}
