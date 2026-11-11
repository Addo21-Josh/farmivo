import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';

/// Interactive modal sheet providing quick contact actions:
/// direct phone calling, SMS reminder drafting, and clipboard copying for Mobile Money or dialing.
class BuyerContactActionSheet extends StatelessWidget {
  final BuyerSummary buyer;

  const BuyerContactActionSheet({super.key, required this.buyer});

  static Future<void> show(BuildContext context, BuyerSummary buyer) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BuyerContactActionSheet(buyer: buyer),
    );
  }

  String _generateSmsMessage() {
    if (buyer.hasDebt) {
      return 'Hello ${buyer.name}, this is a gentle reminder regarding your outstanding balance of ${buyer.outstandingBalance.format()} for produce supplied by our farm. Kindly arrange payment via Mobile Money or cash at your earliest convenience. Thank you!';
    }
    return 'Hello ${buyer.name}, we have fresh harvest inventory available from our farm. Please let us know if you would like to place an order. Thank you!';
  }

  void _copyPhone(BuildContext context) {
    if (buyer.phone != null) {
      Clipboard.setData(ClipboardData(text: buyer.phone!));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number "${buyer.phone}" copied to clipboard.'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  void _copySmsReminder(BuildContext context) {
    final msg = _generateSmsMessage();
    Clipboard.setData(ClipboardData(text: msg));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment reminder message copied to clipboard.'),
        backgroundColor: Colors.green.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phone = buyer.phone ?? 'No phone recorded';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
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

            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    buyer.name.isNotEmpty ? buyer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyer.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (buyer.hasDebt)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withAlpha(80)),
                    ),
                    child: Text(
                      '${buyer.outstandingBalance.format()} Due',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),

            if (buyer.hasPhone) ...[
              // Action 1: Call Phone
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_outlined, color: Colors.green),
                ),
                title: const Text('Call Customer'),
                subtitle: Text('Dial $phone directly'),
                onTap: () => _copyPhone(context),
              ),

              // Action 2: Copy Phone Number
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.copy_outlined),
                ),
                title: const Text('Copy Phone Number'),
                subtitle: const Text('For Mobile Money transfer or dialing'),
                onTap: () => _copyPhone(context),
              ),

              // Action 3: SMS Debt Reminder
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    color: Colors.amber,
                  ),
                ),
                title: Text(
                  buyer.hasDebt
                      ? 'Copy Debt Collection SMS'
                      : 'Copy Customer Message',
                ),
                subtitle: Text(
                  buyer.hasDebt
                      ? 'Pre-composed reminder for ${buyer.outstandingBalance.format()}'
                      : 'Greeting & new harvest notification',
                ),
                onTap: () => _copySmsReminder(context),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No phone number recorded for this customer. Edit customer profile to add contact details.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
