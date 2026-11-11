import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:farmivo/app/router/routes.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/presentation/widgets/buyer_contact_action_sheet.dart';

/// Reusable list tile displaying a commercial buyer's profile, outstanding balance,
/// debtor status badge, and one-tap contact shortcuts.
class BuyerTile extends StatelessWidget {
  final BuyerSummary buyer;
  final VoidCallback? onTap;

  const BuyerTile({super.key, required this.buyer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = buyer.debtorStatus;

    return InkWell(
      onTap:
          onTap ??
          () {
            try {
              context.push(
                AppRoutes.buyerDetails.replaceFirst(':buyerId', buyer.id),
              );
            } catch (_) {}
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withAlpha(80)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Avatar with initials
            CircleAvatar(
              radius: 22,
              backgroundColor: status.color.withAlpha(30),
              child: Text(
                buyer.name.isNotEmpty ? buyer.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: status.color,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // 2. Buyer Profile & Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          buyer.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (buyer.hasLocation) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            buyer.location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (buyer.hasPhone) ...[
                        Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          buyer.phone!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Debtor Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: status.color.withAlpha(100)),
                    ),
                    child: Text(
                      buyer.hasDebt
                          ? '${buyer.outstandingBalance.format()} Due'
                          : status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 3. Fast Dial / Contact Action Button
            IconButton(
              iconSize: 22,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                backgroundColor: buyer.hasPhone
                    ? Colors.green.withAlpha(20)
                    : theme.colorScheme.surfaceContainerHighest,
              ),
              icon: Icon(
                Icons.phone_outlined,
                color: buyer.hasPhone ? Colors.green : theme.disabledColor,
              ),
              tooltip: 'Contact Buyer',
              onPressed: () => BuyerContactActionSheet.show(context, buyer),
            ),
          ],
        ),
      ),
    );
  }
}
