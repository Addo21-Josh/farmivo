import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../expenses/domain/models/payment_method.dart';
import '../../../sales/domain/models/sale_with_details.dart';
import '../../../sales/presentation/providers/sale_providers.dart';
import '../providers/payment_providers.dart';

/// Interactive modal sheet for recording cash or mobile money installments
/// against an open commercial sale agreement.
class RecordPaymentSheet extends ConsumerStatefulWidget {
  final SaleWithDetails? initialSale;
  final String? initialSaleId;

  const RecordPaymentSheet({super.key, this.initialSale, this.initialSaleId});

  static Future<bool?> show(
    BuildContext context, {
    SaleWithDetails? sale,
    String? saleId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RecordPaymentSheet(
        initialSale: sale,
        initialSaleId: saleId ?? sale?.sale.id,
      ),
    );
  }

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSaleId;
  SaleWithDetails? _currentSale;

  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _selectedSaleId = widget.initialSaleId ?? widget.initialSale?.sale.id;
    _currentSale = widget.initialSale;

    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _enteredAmountMajor =>
      double.tryParse(_amountController.text.trim()) ?? 0.0;

  int get _enteredAmountMinor => (_enteredAmountMajor * 100).round();

  Money get _enteredMoney => Money(BigInt.from(_enteredAmountMinor));

  Money _calculateRemaining(Money currentBalance) {
    final curMinor = currentBalance.minorUnits.toInt();
    final newMinor = curMinor - _enteredAmountMinor;
    return newMinor > 0 ? Money(BigInt.from(newMinor)) : Money.zero();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  Future<void> _submit(Money outstandingBalance) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSaleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a commercial sale.')),
      );
      return;
    }

    if (_enteredAmountMinor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than zero.'),
        ),
      );
      return;
    }

    if (_enteredAmountMinor > outstandingBalance.minorUnits.toInt()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment amount cannot exceed the remaining balance of ${outstandingBalance.format()}.',
          ),
        ),
      );
      return;
    }

    final controller = ref.read(paymentControllerProvider.notifier);
    final paymentId = await controller.recordPayment(
      saleId: _selectedSaleId!,
      paymentDate: _paymentDate,
      amountMinor: _enteredAmountMinor,
      currency: 'GHS',
      paymentMethod: _selectedMethod,
      referenceNumber: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (paymentId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment of ${_enteredMoney.format()} recorded successfully!',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final controllerState = ref.watch(paymentControllerProvider);
    final unsettledSalesAsync = ref.watch(unsettledSalesProvider);

    // If sale details were provided directly, use them; otherwise fetch details
    SaleWithDetails? targetSale = _currentSale;
    if (targetSale == null && _selectedSaleId != null) {
      final saleAsync = ref.watch(saleDetailProvider(_selectedSaleId!));
      targetSale = saleAsync.valueOrNull;
    }

    final outstanding = targetSale?.remainingBalance ?? Money.zero();
    final remainingAfterPayment = _calculateRemaining(outstanding);
    final isFullSettlement =
        _enteredAmountMinor > 0 &&
        _enteredAmountMinor >= outstanding.minorUnits.toInt();
    final isOverpayment =
        _enteredAmountMinor > outstanding.minorUnits.toInt() &&
        outstanding.isPositive;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 2. Title
                Text(
                  'Record Payment Received',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log installment receipts against customer credit terms.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Sale Selection / Information
                if (widget.initialSale != null) ...[
                  // Read-only sale card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(80),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.dividerColor.withAlpha(120),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SALE TRANSACTION',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${targetSale?.sale.productName} (${targetSale?.formattedQuantity})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buyer: ${targetSale?.buyerDisplayName} • Total: ${targetSale?.totalAmount.format()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                              180,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Dynamic sale picker
                  Text(
                    'Select Credit Sale Agreement *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  unsettledSalesAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, _) => Text('Error loading credit sales: $err'),
                    data: (unsettled) {
                      if (unsettled.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.healthGreenBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No open credit sales. All customer sales are fully settled!',
                            style: TextStyle(
                              color: colors.healthGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedSaleId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.receipt_long_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Select a customer sale with open balance',
                        ),
                        items: unsettled.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.sale.id,
                            child: Text(
                              '${s.sale.productName} • ${s.buyerDisplayName} (Due: ${s.remainingBalance.format()})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSaleId = val;
                            _currentSale = unsettled.firstWhere(
                              (s) => s.sale.id == val,
                            );
                            _amountController.clear();
                          });
                        },
                        validator: (val) =>
                            val == null ? 'Please select a sale' : null,
                      );
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // 4. Outstanding Debt Indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.healthYellowBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.healthYellow.withAlpha(90),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT OUTSTANDING DEBT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: colors.healthYellow,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pending collection from customer',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.healthYellow.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        outstanding.format(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.healthYellow,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Amount Received (in Cedis)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Received *',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (outstanding.isPositive)
                      ActionChip(
                        avatar: const Icon(Icons.flash_on, size: 14),
                        label: Text('Pay Full (${outstanding.format()})'),
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final major = (outstanding.minorUnits.toInt() / 100.0)
                              .toStringAsFixed(2);
                          _amountController.text = major;
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.payments_outlined),
                    prefixText: 'GH₵ ',
                    hintText: 'e.g. 500.00',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter payment amount';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    if (num * 100 > outstanding.minorUnits.toInt()) {
                      return 'Amount exceeds remaining debt';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // 6. Dynamic Settlement Outcome Banner
                if (_enteredAmountMinor > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isOverpayment
                          ? colors.healthRedBg
                          : (isFullSettlement
                                ? colors.healthGreenBg
                                : theme.colorScheme.surfaceContainerHighest
                                      .withAlpha(80)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOverpayment
                            ? colors.healthRed
                            : (isFullSettlement
                                  ? colors.healthGreen
                                  : theme.dividerColor),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFullSettlement
                              ? '✨ Fully Settles Agreement!'
                              : 'New Balance Remaining:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isFullSettlement
                                ? colors.healthGreen
                                : (isOverpayment ? colors.healthRed : null),
                          ),
                        ),
                        Text(
                          remainingAfterPayment.format(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isFullSettlement
                                ? colors.healthGreen
                                : (isOverpayment ? colors.healthRed : null),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 7. Payment Channel
                Text(
                  'Payment Channel *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        PaymentMethod.cash,
                        PaymentMethod.mtnMoMo,
                        PaymentMethod.telecelCash,
                        PaymentMethod.atMoney,
                        PaymentMethod.bankTransfer,
                        PaymentMethod.other,
                      ].map((PaymentMethod method) {
                        final isSelected = _selectedMethod == method;
                        return ChoiceChip(
                          avatar: Icon(method.icon, size: 16),
                          label: Text(method.displayName),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() => _selectedMethod = method);
                            }
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),

                // 8. Reference Number (e.g. MoMo Transaction ID)
                Text(
                  'Transaction Reference No. (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    hintText:
                        _selectedMethod == PaymentMethod.mtnMoMo ||
                            _selectedMethod == PaymentMethod.telecelCash ||
                            _selectedMethod == PaymentMethod.atMoney
                        ? 'e.g. 10928374928 (MoMo Transaction ID)'
                        : 'e.g. Cheque / Deposit Slip No.',
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // 9. Payment Date Picker
                Text(
                  'Payment Date *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_paymentDate.toDisplayDate()),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 10. Notes
                Text(
                  'Notes (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.edit_note_outlined),
                    hintText: 'e.g. Balance collected at market stall',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // 11. Submit Button
                AppButton(
                  label: 'Confirm Payment Received',
                  icon: Icons.check_circle_outline,
                  isLoading: controllerState.isLoading,
                  onPressed: controllerState.isLoading
                      ? null
                      : () => _submit(outstanding),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
