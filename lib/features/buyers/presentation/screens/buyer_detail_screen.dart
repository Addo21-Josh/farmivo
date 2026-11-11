import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farmivo/app/theme/app_theme_extension.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/features/buyers/presentation/screens/buyer_form_sheet.dart';
import 'package:farmivo/features/buyers/presentation/widgets/buyer_contact_action_sheet.dart';
import 'package:farmivo/features/payments/presentation/widgets/record_payment_sheet.dart';
import 'package:farmivo/shared/widgets/app_button.dart';
import 'package:farmivo/shared/widgets/app_card.dart';
import 'package:farmivo/shared/widgets/money_display.dart';

/// Detailed customer inspection screen presenting financial ledger aggregates,
/// trade credit terms, transaction history, and direct debt collection shortcuts.
class BuyerDetailScreen extends ConsumerWidget {
  final String buyerId;

  const BuyerDetailScreen({super.key, required this.buyerId});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BuyerSummary buyer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer Record?'),
        content: Text(
          'Are you sure you want to remove "${buyer.name}" from your customer directory? Historical sales records will remain preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Customer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(buyerControllerProvider.notifier)
          .deleteBuyer(buyerId);

      if (context.mounted) {
        if (success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer "${buyer.name}" removed from directory.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete customer.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final buyerAsync = ref.watch(buyerSummaryProvider(buyerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          buyerAsync.maybeWhen(
            data: (buyer) => buyer != null
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Profile',
                    onPressed: () =>
                        BuyerFormSheet.show(context, buyerToEdit: buyer),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: buyerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading customer: $err'),
          ),
        ),
        data: (buyer) {
          if (buyer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  const Text('Customer not found or has been deleted.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Return to Directory'),
                  ),
                ],
              ),
            );
          }

          final status = buyer.debtorStatus;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Customer Profile Card
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: status.color.withAlpha(30),
                      child: Text(
                        buyer.name.isNotEmpty
                            ? buyer.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (buyer.hasBusinessName) ...[
                            const SizedBox(height: 2),
                            Text(
                              buyer.businessName!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          if (buyer.hasLocation)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    buyer.location!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          if (buyer.hasPhone) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  buyer.phone!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Direct Contact & Payment Action Bar
              if (buyer.hasPhone || buyer.hasDebt)
                Row(
                  children: [
                    if (buyer.hasPhone)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          onPressed: () =>
                              BuyerContactActionSheet.show(context, buyer),
                          icon: const Icon(
                            Icons.phone_outlined,
                            color: Colors.green,
                          ),
                          label: const Text('Call / SMS Buyer'),
                        ),
                      ),
                    if (buyer.hasPhone && buyer.hasDebt)
                      const SizedBox(width: 8),
                    if (buyer.hasDebt)
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          onPressed: () => RecordPaymentSheet.show(context),
                          icon: const Icon(Icons.add_card_outlined),
                          label: const Text('Collect Payment'),
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 16),

              // 3. Financial Receivables Summary Card
              AppCard(
                title: 'Financial Ledger & Credit Standing',
                subtitle: 'Accrued purchases vs collected cash',
                leadingIcon: Icon(
                  Icons.receipt_long_outlined,
                  color: status.color,
                ),
                trailingAction: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: status.color.withAlpha(120)),
                  ),
                  child: Text(
                    status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status.color,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Outstanding Debt
                    Text(
                      'Outstanding Balance Owed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    MoneyDisplay(
                      money: buyer.outstandingBalance,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: buyer.hasDebt
                            ? colors.healthRed
                            : colors.healthGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Total Purchased & Total Paid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryColumn(
                          context,
                          label: 'Total Purchases',
                          money: buyer.totalPurchased,
                        ),
                        _buildSummaryColumn(
                          context,
                          label: 'Total Cash Paid',
                          money: buyer.totalPaid,
                          sentimentColor: colors.healthGreen,
                        ),
                        _buildCountColumn(
                          context,
                          label: 'Completed Sales',
                          count: buyer.salesCount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Credit Terms & Field Notes
              if (buyer.notes != null && buyer.notes!.isNotEmpty) ...[
                AppCard(
                  title: 'Credit Terms & Notes',
                  leadingIcon: const Icon(Icons.notes_outlined),
                  child: Text(buyer.notes!, style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 24),
              ],

              // 5. Delete Customer Action
              Center(
                child: AppButton(
                  label: 'Delete Customer Record',
                  variant: AppButtonVariant.destructive,
                  icon: Icons.delete_outline,
                  onPressed: () => _confirmDelete(context, ref, buyer),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryColumn(
    BuildContext context, {
    required String label,
    required Money money,
    Color? sentimentColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        MoneyDisplay(
          money: money,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: sentimentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCountColumn(
    BuildContext context, {
    required String label,
    required int count,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count ${count == 1 ? "Sale" : "Sales"}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
