import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/models/budget_category_presets.dart';

/// Outdoor-optimized tile representing an individual budget category.
class BudgetCategoryTile extends StatelessWidget {
  final BudgetCategory category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCategoryTile({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = BudgetCategoryIconHelper.getIcon(category.iconName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.isSystemDefault
                  ? theme.colorScheme.primaryContainer.withAlpha(120)
                  : theme.colorScheme.secondaryContainer.withAlpha(120),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: category.isSystemDefault
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: category.isSystemDefault
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: category.isSystemDefault
                        ? theme.dividerColor
                        : theme.colorScheme.primary.withAlpha(80),
                  ),
                ),
                child: Text(
                  category.isSystemDefault ? 'Standard' : 'Custom',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: category.isSystemDefault
                        ? Colors.grey.shade700
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          subtitle:
              category.description != null && category.description!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    category.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          trailing: !category.isSystemDefault
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) {
                    if (val == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (val == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Category'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Category',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
