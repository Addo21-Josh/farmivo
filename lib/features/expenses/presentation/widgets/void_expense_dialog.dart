import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/expense_with_details.dart';

/// Modal dialog prompting the user for an audit reason before voiding an expense.
class VoidExpenseDialog extends StatefulWidget {
  final ExpenseWithDetails expense;
  final Future<bool> Function(String reason) onConfirmVoid;

  const VoidExpenseDialog({
    super.key,
    required this.expense,
    required this.onConfirmVoid,
  });

  @override
  State<VoidExpenseDialog> createState() => _VoidExpenseDialogState();
}

class _VoidExpenseDialogState extends State<VoidExpenseDialog> {
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
          const Expanded(child: Text('Void Expense')),
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
                'Are you sure you want to void this expense of ${widget.expense.amount.format()} for "${widget.expense.description}"?',
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
                        'Voiding preserves the record for financial auditing but subtracts its amount from total project expenditure.',
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
                      'e.g. Duplicate entry, wrong price entered, refunded',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please state why this expense is being voided.';
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
        AppButton(
          label: 'Confirm Void',
          icon: Icons.cancel_outlined,
          isLoading: _isLoading,
          variant: AppButtonVariant.destructive,
          width: 150,
          onPressed: _submit,
        ),
      ],
    );
  }
}
