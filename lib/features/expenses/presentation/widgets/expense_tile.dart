import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../budgets/domain/models/budget_category_presets.dart';
import '../../domain/models/expense_with_details.dart';
import 'expense_detail_sheet.dart';

/// Outdoor-optimized list item presenting an individual expense transaction.
class ExpenseTile extends StatelessWidget {
  final ExpenseWithDetails expense;
  final VoidCallback? onTap;

  const ExpenseTile({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final categoryIcon = BudgetCategoryIconHelper.getIcon(
      expense.category.iconName,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expense.isVoided
              ? colors.healthRed.withAlpha(90)
              : theme.dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => ExpenseDetailSheet.show(context, expense),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 1. Category Icon Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: expense.isVoided
                      ? colors.healthRedBg
                      : theme.colorScheme.primaryContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  expense.isVoided ? Icons.cancel_outlined : categoryIcon,
                  color: expense.isVoided
                      ? colors.healthRed
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // 2. Description, Date, Payment Method & Vendor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: expense.isVoided
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          expense.transactionDate.toDisplayDate(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        // Payment Channel Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                expense.paymentMethod.icon,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                expense.paymentMethod.displayName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (expense.hasReceipt)
                          Icon(
                            Icons.receipt_outlined,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                    if (expense.vendorName != null &&
                        expense.vendorName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.vendorName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant.withAlpha(
                            200,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 3. Amount & Void Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '- ${expense.amount.format()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      decoration: expense.isVoided
                          ? TextDecoration.lineThrough
                          : null,
                      color: expense.isVoided
                          ? theme.hintColor
                          : colors.cashOut,
                    ),
                  ),
                  if (expense.isVoided) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: colors.healthRedBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.healthRed, width: 0.8),
                      ),
                      child: Text(
                        'VOID',
                        style: TextStyle(
                          color: colors.healthRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
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
