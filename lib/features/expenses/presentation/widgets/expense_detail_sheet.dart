import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../budgets/domain/models/budget_category_presets.dart';
import '../../domain/models/expense_with_details.dart';
import '../providers/expense_providers.dart';
import 'void_expense_dialog.dart';

/// Modal bottom sheet presenting complete transactional audit details for an expense.
class ExpenseDetailSheet extends ConsumerWidget {
  final ExpenseWithDetails expense;

  const ExpenseDetailSheet({super.key, required this.expense});

  static Future<void> show(BuildContext context, ExpenseWithDetails expense) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExpenseDetailSheet(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final categoryIcon = BudgetCategoryIconHelper.getIcon(
      expense.category.iconName,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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

              // Voided Banner (if voided)
              if (expense.isVoided) ...[
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
                            'VOIDED TRANSACTION',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.healthRed,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reason: ${expense.voidReason ?? "Not specified"}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.healthRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (expense.voidedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Voided on ${expense.voidedAt!.toDisplayDateTime()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.healthRed.withAlpha(200),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Header: Amount & Category Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MoneyDisplay(
                          money: expense.amount,
                          sentiment: expense.isVoided
                              ? MoneyDisplaySentiment.neutral
                              : MoneyDisplaySentiment.negative,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            decoration: expense.isVoided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Detail Key-Value Pairs
              _buildDetailRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Transaction Date',
                value: expense.transactionDate.toDisplayDate(),
              ),
              _buildDetailRow(
                context,
                icon: expense.paymentMethod.icon,
                label: 'Payment Channel',
                value: expense.paymentMethod.displayName,
              ),
              _buildDetailRow(
                context,
                icon: Icons.category_outlined,
                label: 'Budget Category',
                value: expense.category.name,
              ),
              if (expense.project != null)
                _buildDetailRow(
                  context,
                  icon: Icons.folder_outlined,
                  label: 'Project',
                  value:
                      '${expense.project!.name} (${expense.project!.commodity})',
                ),
              if (expense.budgetItem != null)
                _buildDetailRow(
                  context,
                  icon: Icons.link_outlined,
                  label: 'Linked Budget Item',
                  value: expense.budgetItem!.name,
                ),
              if (expense.vendorName != null && expense.vendorName!.isNotEmpty)
                _buildDetailRow(
                  context,
                  icon: Icons.storefront_outlined,
                  label: 'Vendor / Merchant',
                  value: expense.vendorName!,
                ),
              if (expense.notes != null && expense.notes!.isNotEmpty)
                _buildDetailRow(
                  context,
                  icon: Icons.note_outlined,
                  label: 'Notes',
                  value: expense.notes!,
                ),

              // Receipt Photo
              if (expense.hasReceipt) ...[
                const SizedBox(height: 16),
                Text(
                  'Receipt Photo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(expense.receiptPhotoPath!),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Receipt image not found on disk',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions: Void button if active
              if (!expense.isVoided) ...[
                AppButton(
                  label: 'Void Transaction',
                  icon: Icons.cancel_outlined,
                  variant: AppButtonVariant.destructive,
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => VoidExpenseDialog(
                        expense: expense,
                        onConfirmVoid: (reason) async {
                          final controller = ref.read(
                            expenseControllerProvider.notifier,
                          );
                          return await controller.voidExpense(
                            id: expense.id,
                            reason: reason,
                          );
                        },
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Expense successfully voided.'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
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
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
