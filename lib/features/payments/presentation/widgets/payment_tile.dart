import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../domain/models/payment_with_details.dart';
import '../providers/payment_providers.dart';
import 'void_payment_dialog.dart';

/// Reusable installment payment tile presenting collection channels (Cash, MoMo, Bank),
/// transaction references, received amount, and audit voiding capabilities.
class PaymentTile extends ConsumerWidget {
  final PaymentWithDetails payment;
  final bool showVoidButton;

  const PaymentTile({
    super.key,
    required this.payment,
    this.showVoidButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isVoided = payment.isVoided;
    final method = payment.method;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isVoided
            ? colors.healthRedBg.withAlpha(50)
            : theme.colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isVoided
              ? colors.healthRed.withAlpha(80)
              : theme.dividerColor.withAlpha(90),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Payment Channel Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isVoided
                  ? colors.healthRedBg
                  : theme.colorScheme.primaryContainer.withAlpha(120),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVoided ? Icons.cancel_outlined : method.icon,
              color: isVoided ? colors.healthRed : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // 2. Channel & Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.displayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isVoided
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(color: theme.dividerColor, fontSize: 10),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      payment.formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (payment.payment.referenceNumber != null &&
                    payment.payment.referenceNumber!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ref: ${payment.payment.referenceNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
                if (payment.payment.notes != null &&
                    payment.payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.payment.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isVoided) ...[
                  const SizedBox(height: 2),
                  Text(
                    'VOIDED: ${payment.payment.voidReason ?? 'No reason stated'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.healthRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Amount & Void Action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+ ${payment.amount.format()}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isVoided ? colors.healthRed : colors.cashIn,
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                ),
              ),
              if (!isVoided && showVoidButton) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  color: colors.healthRed.withAlpha(180),
                  tooltip: 'Void Payment',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => VoidPaymentDialog(
                        payment: payment,
                        onConfirmVoid: (reason) async {
                          final controller = ref.read(
                            paymentControllerProvider.notifier,
                          );
                          return await controller.voidPayment(
                            id: payment.payment.id,
                            reason: reason,
                          );
                        },
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment record successfully voided.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
