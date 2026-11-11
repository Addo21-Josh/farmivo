import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/core/extensions/date_time_extensions.dart';
import 'package:farmivo/features/activities/domain/models/activity_with_details.dart';
import 'package:farmivo/features/activities/presentation/providers/activity_providers.dart';
import 'package:farmivo/shared/widgets/app_button.dart';
import 'package:farmivo/shared/widgets/money_display.dart';

/// Modal bottom sheet presenting in-depth details of a field operation,
/// its casual labour headcounts, financial ledger connections, and deletion options.
class ActivityDetailSheet extends ConsumerWidget {
  final ActivityWithDetails activity;

  const ActivityDetailSheet({super.key, required this.activity});

  static Future<void> show(BuildContext context, ActivityWithDetails activity) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ActivityDetailSheet(activity: activity),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    bool deleteLinked = activity.hasLinkedExpense;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Delete Activity Log?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete "${activity.title}" from field operation records?',
                ),
                if (activity.hasLinkedExpense) ...[
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.amber.withAlpha(30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.amber.withAlpha(120)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Linked Financial Expense',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'This activity generated an expense in the financial ledger.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: const Text(
                              'Also remove linked expense from ledger',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: deleteLinked,
                            onChanged: (val) {
                              setDialogState(() {
                                deleteLinked = val ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: const Text('Delete Activity'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(activityControllerProvider.notifier)
          .deleteActivity(activity.id, deleteLinkedExpense: deleteLinked);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Activity deleted successfully'
                  : 'Failed to delete activity',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(160),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity.type.icon,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activity.type.displayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // 3. Status and Project Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: activity.status.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: activity.status.color.withAlpha(120),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          activity.status.icon,
                          size: 14,
                          color: activity.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: activity.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Project Badge
                  if (activity.project != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.folder_outlined, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            activity.project!.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Detail Tiles Grid / Column
              _buildDetailRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Activity Date',
                value: activity.activityDate.toDisplayDate(),
              ),
              const SizedBox(height: 12),

              _buildDetailRow(
                context,
                icon: Icons.people_outline,
                label: 'Casual Labour',
                value: activity.hasLabour
                    ? '${activity.labourCount} ${activity.labourCount == 1 ? "worker" : "workers"}'
                    : 'No casual labour assigned',
              ),
              const SizedBox(height: 12),

              if (activity.formattedDuration != null) ...[
                _buildDetailRow(
                  context,
                  icon: Icons.timer_outlined,
                  label: 'Work Duration',
                  value: activity.formattedDuration!,
                ),
                const SizedBox(height: 12),
              ],

              _buildDetailRow(
                context,
                icon: Icons.monetization_on_outlined,
                label: 'Operation Cost',
                valueWidget: activity.costMinor > 0
                    ? MoneyDisplay(
                        money: activity.cost,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        'GH₵ 0.00 (Uncosted)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // 5. Linked Financial Expense Card
              if (activity.hasLinkedExpense) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Linked to Financial Ledger',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Expense ID: ${activity.linkedExpense!.id.substring(0, 8)}... • ${activity.linkedExpense!.paymentMethod}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 6. Description / Notes
              if (activity.description?.isNotEmpty == true) ...[
                Text(
                  'Description',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity.description!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],

              if (activity.notes?.isNotEmpty == true) ...[
                Text(
                  'Field Notes / Observations',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity.notes!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
              ],

              const Divider(height: 24),

              // 7. Delete Action
              Center(
                child: AppButton(
                  label: 'Delete Activity Record',
                  variant: AppButtonVariant.destructive,
                  icon: Icons.delete_outline,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (valueWidget != null)
              valueWidget
            else
              Text(
                value ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
