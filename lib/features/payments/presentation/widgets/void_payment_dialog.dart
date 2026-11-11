import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../domain/models/payment_with_details.dart';

/// Modal dialog prompting the user for an audit reason before voiding a payment record.
class VoidPaymentDialog extends StatefulWidget {
  final PaymentWithDetails payment;
  final Future<bool> Function(String reason) onConfirmVoid;

  const VoidPaymentDialog({
    super.key,
    required this.payment,
    required this.onConfirmVoid,
  });

  @override
  State<VoidPaymentDialog> createState() => _VoidPaymentDialogState();
}

class _VoidPaymentDialogState extends State<VoidPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await widget.onConfirmVoid(_reasonController.text.trim());
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.healthRed, size: 28),
          const SizedBox(width: 10),
          const Expanded(child: Text('Void Payment Record')),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to void this payment of ${widget.payment.amount.format()} (${widget.payment.method.displayName}) received on ${widget.payment.formattedDate}?',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.healthRedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.healthRed.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.healthRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voiding retains the record for financial auditing but restores the customer\'s outstanding debt on the parent sale agreement.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.healthRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                autofocus: true,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reason for Voiding *',
                  hintText:
                      'e.g. MoMo reversal, bounced cheque, wrong amount entered',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please state why this payment is being voided.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: colors.healthRed,
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Confirm Void'),
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}
