import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../domain/models/budget_category_presets.dart';
import '../../domain/models/budget_item_with_category.dart';
import '../../domain/models/budget_tracking.dart';

/// Presentation card displaying a single budget line item with its dynamic formula,
/// planned allocation, and real-time actual transaction tracking.
class BudgetItemTile extends StatelessWidget {
  final BudgetItemWithCategory itemWithCategory;
  final BudgetItemTracking? tracking;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const BudgetItemTile({
    super.key,
    required this.itemWithCategory,
    this.tracking,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final item = itemWithCategory.item;
    final category = itemWithCategory.category;
    final catIcon = BudgetCategoryIconHelper.getIcon(category.iconName);

    final hasTracking = tracking != null;
    final actualSpent = tracking?.actualSpent;
    final isOverBudget = tracking?.isOverBudget ?? false;
    final spentRatio = (tracking != null && tracking!.plannedAmount.isPositive)
        ? (tracking!.actualSpent.toMajor() / tracking!.plannedAmount.toMajor())
              .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverBudget
              ? colors.healthRed.withAlpha(120)
              : theme.dividerColor.withAlpha(80),
          width: isOverBudget ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon Indicator
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.healthYellowBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        catIcon,
                        size: 20,
                        color: colors.healthYellow,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Item Details & Dynamic Formula
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                itemWithCategory.plannedAmount.format(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Formula Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withAlpha(120),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${itemWithCategory.formattedQuantity} ${item.unit} × ${itemWithCategory.unitCost.format()}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Action Popup
                              PopupMenuButton<String>(
                                tooltip: 'Options for ${item.name}',
                                icon: const Icon(Icons.more_vert, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    onEdit?.call();
                                  } else if (value == 'delete') {
                                    onDelete?.call();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit Item'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: colors.healthRed,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Delete Item',
                                          style: TextStyle(
                                            color: colors.healthRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha(160),
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Real-time Actual Spending Tracking Indicator (if tracking provided)
                if (hasTracking && tracking!.transactionCount > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: spentRatio,
                      minHeight: 5,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget
                            ? colors.healthRed
                            : (tracking!.spentPercentage >= 80
                                  ? colors.healthYellow
                                  : colors.healthGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actual Spent: ${actualSpent!.format()} (${tracking!.spentPercentage.toStringAsFixed(0)}%)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverBudget
                              ? colors.healthRed
                              : (tracking!.spentPercentage >= 80
                                    ? colors.healthYellow
                                    : colors.healthGreen),
                        ),
                      ),
                      Text(
                        isOverBudget
                            ? 'Overrun: +${(actualSpent - tracking!.plannedAmount).format()}'
                            : '${tracking!.remainingAmount.format()} remaining',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOverBudget
                              ? colors.healthRed
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isOverBudget
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
