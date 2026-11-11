import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../buyers/domain/models/buyer_summary.dart';
import '../../../buyers/presentation/widgets/buyer_contact_action_sheet.dart';
import '../../../payments/domain/models/payment_with_details.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../payments/presentation/widgets/payment_tile.dart';
import '../../../payments/presentation/widgets/record_payment_sheet.dart';
import '../../domain/models/sale_with_details.dart';
import '../providers/sale_providers.dart';
import 'void_sale_dialog.dart';

/// Modal bottom sheet presenting full commercial sales contract details,
/// unit economics calculation, settlement state, and voiding audit workflow.
class SaleDetailSheet extends ConsumerWidget {
  final SaleWithDetails sale;

  const SaleDetailSheet({super.key, required this.sale});

  static Future<void> show(BuildContext context, SaleWithDetails sale) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SaleDetailSheet(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isVoided = sale.sale.isVoided;
    final status = sale.effectiveStatus;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

              // 2. Voided Alert Banner
              if (isVoided) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.healthRedBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.healthRed),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: colors.healthRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'VOIDED COMMERCIAL SALE',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.healthRed,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reason: ${sale.sale.voidReason ?? 'No reason provided'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.healthRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (sale.sale.voidedAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Voided on: ${DateTime.fromMillisecondsSinceEpoch(sale.sale.voidedAt!).toDisplayDateTime()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.healthRed.withAlpha(200),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // 3. Header: Produce & Settlement Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.sale.productName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isVoided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sale Date: ${sale.saleDate.toDisplayDate()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                              180,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isVoided
                          ? colors.healthRedBg
                          : status.backgroundColor(colors),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isVoided
                            ? colors.healthRed.withAlpha(80)
                            : status.color(colors).withAlpha(80),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVoided ? Icons.cancel_outlined : status.icon,
                          size: 14,
                          color: isVoided
                              ? colors.healthRed
                              : status.color(colors),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVoided ? 'VOIDED' : status.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isVoided
                                ? colors.healthRed
                                : status.color(colors),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Financial Calculation Banner (Quantity x Price = Total)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    80,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withAlpha(120)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICING FORMULA',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${sale.formattedQuantity} × ${sale.unitPrice.format()} / ${sale.sale.unit}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '=',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MoneyDisplay(
                          money: sale.totalAmount,
                          sentiment: isVoided
                              ? MoneyDisplaySentiment.neutral
                              : MoneyDisplaySentiment.positive,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            decoration: isVoided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5. Settlement Overview (Gross, Paid, Balance)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withAlpha(140)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SETTLEMENT BREAKDOWN',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                              180,
                            ),
                          ),
                        ),
                        if (sale.remainingBalance.isPositive && !isVoided)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                            onPressed: () =>
                                RecordPaymentSheet.show(context, sale: sale),
                            icon: const Icon(Icons.add_card_outlined, size: 14),
                            label: const Text('Record Payment'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildBalanceRow(
                      context,
                      label: 'Gross Sale Total',
                      amount: sale.totalAmount.format(),
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildBalanceRow(
                      context,
                      label: 'Cash / MoMo Collected',
                      amount: sale.paidAmount.format(),
                      color: colors.cashIn,
                    ),
                    const SizedBox(height: 6),
                    _buildBalanceRow(
                      context,
                      label: 'Outstanding Balance',
                      amount: sale.remainingBalance.format(),
                      color: sale.remainingBalance.isPositive
                          ? colors.healthRed
                          : colors.healthGreen,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5b. Payment Installment History
              ref
                  .watch(salePaymentsProvider(sale.sale.id))
                  .when(
                    loading: () => const SizedBox.shrink(),
                    error: (Object _, __) => const SizedBox.shrink(),
                    data: (List<PaymentWithDetails> payments) {
                      if (payments.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.dividerColor.withAlpha(140),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PAYMENT INSTALLMENTS (${payments.length})',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withAlpha(180),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...payments.map(
                                  (PaymentWithDetails p) => PaymentTile(
                                    payment: p,
                                    showVoidButton: !isVoided,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

              const SizedBox(height: 16),

              // 6. Customer & Off-taker Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withAlpha(140)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CUSTOMER DETAILS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                              180,
                            ),
                          ),
                        ),
                        if (sale.buyer?.phone != null && !isVoided)
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                            onPressed: () {
                              BuyerContactActionSheet.show(
                                context,
                                BuyerSummary(
                                  buyer: sale.buyer!,
                                  totalPurchased: sale.totalAmount,
                                  totalPaid: sale.paidAmount,
                                  outstandingBalance: sale.remainingBalance,
                                  salesCount: 1,
                                  lastTransactionDate: sale.saleDate,
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone_outlined, size: 14),
                            label: const Text('Contact Buyer'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Buyer Name',
                      value: sale.buyerDisplayName,
                    ),
                    if (sale.buyer?.businessName != null)
                      _buildDetailRow(
                        context,
                        icon: Icons.storefront_outlined,
                        label: 'Trading / Business',
                        value: sale.buyer!.businessName!,
                      ),
                    if (sale.buyer?.location != null)
                      _buildDetailRow(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Market / Location',
                        value: sale.buyer!.location!,
                      ),
                    if (sale.buyer?.phone != null)
                      _buildDetailRow(
                        context,
                        icon: Icons.phone_android_outlined,
                        label: 'Phone Number',
                        value: sale.buyer!.phone!,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 7. Relational Farming Links
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withAlpha(140)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FARMING LINKS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      context,
                      icon: Icons.agriculture_outlined,
                      label: 'Project',
                      value: sale.projectDisplayName,
                    ),
                    if (sale.harvest != null) ...[
                      _buildDetailRow(
                        context,
                        icon: Icons.inventory_2_outlined,
                        label: 'Harvest Batch',
                        value:
                            '${sale.harvest!.batchNumber} (${sale.harvest!.grade ?? 'Ungraded'})',
                      ),
                    ],
                  ],
                ),
              ),

              if (sale.sale.notes != null &&
                  sale.sale.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withAlpha(140),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOTES & AGREEMENTS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(sale.sale.notes!, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 8. Void Action Button
              if (!isVoided) ...[
                AppButton(
                  label: 'Void Commercial Sale',
                  icon: Icons.cancel_outlined,
                  variant: AppButtonVariant.destructive,
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => VoidSaleDialog(
                        sale: sale,
                        onConfirmVoid: (reason) async {
                          final controller = ref.read(
                            saleControllerProvider.notifier,
                          );
                          return await controller.voidSale(
                            id: sale.sale.id,
                            reason: reason,
                          );
                        },
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sale transaction successfully voided.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceRow(
    BuildContext context, {
    required String label,
    required String amount,
    Color? color,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
