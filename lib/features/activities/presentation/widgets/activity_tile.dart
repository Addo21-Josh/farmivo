import 'package:flutter/material.dart';

import 'package:farmivo/core/extensions/date_time_extensions.dart';
import 'package:farmivo/features/activities/domain/models/activity_with_details.dart';
import 'package:farmivo/features/activities/presentation/widgets/activity_detail_sheet.dart';
import 'package:farmivo/shared/widgets/money_display.dart';

/// Reusable list tile displaying field operation details, labour headcount,
/// duration, monetary costs, and financial ledger link indicators.
class ActivityTile extends StatelessWidget {
  final ActivityWithDetails activity;
  final VoidCallback? onTap;

  const ActivityTile({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap ?? () => ActivityDetailSheet.show(context, activity),
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
            // 1. Activity Type Icon in circular container
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
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // 2. Title, Type & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Linked to financial ledger badge
                      if (activity.hasLinkedExpense)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Tooltip(
                            message: 'Linked to financial expense',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.green.withAlpha(100),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.receipt_outlined,
                                    size: 11,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Ledger',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        activity.type.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ${activity.activityDate.toDisplayDate()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  // Labour info line if recorded
                  if (activity.hasLabour || activity.durationHours != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (activity.hasLabour) ...[
                            Icon(
                              Icons.people_outline,
                              size: 13,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${activity.labourCount} ${activity.labourCount == 1 ? "worker" : "workers"}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                          if (activity.hasLabour &&
                              activity.formattedDuration != null)
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                            ),
                          if (activity.formattedDuration != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 13,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              activity.formattedDuration!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 3. Monetary Cost & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activity.costMinor > 0)
                  MoneyDisplay(
                    money: activity.cost,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'No Cost',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 4),
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: activity.status.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activity.status.color.withAlpha(120),
                    ),
                  ),
                  child: Text(
                    activity.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: activity.status.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
