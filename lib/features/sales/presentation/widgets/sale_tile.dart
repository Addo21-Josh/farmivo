import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../domain/models/sale_with_details.dart';
import 'sale_detail_sheet.dart';

/// Reusable commercial sale tile displaying transaction specifics,
/// settlement status badges, and buyer receivables.
class SaleTile extends StatelessWidget {
  final SaleWithDetails sale;
  final VoidCallback? onTap;

  const SaleTile({super.key, required this.sale, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isVoided = sale.sale.isVoided;
    final status = sale.effectiveStatus;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVoided
              ? colors.healthRed.withAlpha(90)
              : theme.dividerColor.withAlpha(120),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => SaleDetailSheet.show(context, sale),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Status Icon Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isVoided
                      ? colors.healthRedBg
                      : status.backgroundColor(colors),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isVoided
                        ? colors.healthRed.withAlpha(80)
                        : status.color(colors).withAlpha(80),
                  ),
                ),
                child: Icon(
                  isVoided ? Icons.cancel_outlined : status.icon,
                  color: isVoided ? colors.healthRed : status.color(colors),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // 2. Product, Quantity, Date & Buyer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sale.sale.productName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isVoided
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            sale.formattedQuantity,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            160,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sale.saleDate.toDisplayDate(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                              180,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('•', style: TextStyle(color: theme.dividerColor)),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            160,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sale.buyerDisplayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withAlpha(200),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (sale.harvest != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 12,
                            color: theme.colorScheme.primary.withAlpha(180),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sale.harvest!.batchNumber,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // 3. Amount & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sale.totalAmount.format(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isVoided ? colors.healthRed : colors.cashIn,
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isVoided)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.healthRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'VOIDED',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.healthRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: status.backgroundColor(colors),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status.color(colors),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (sale.isPartiallyPaid) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Due: ${sale.remainingBalance.format()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.healthYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
