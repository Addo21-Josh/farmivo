import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/validators/input_validators.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/budget_category_presets.dart';
import '../providers/budget_category_providers.dart';

/// Modal dialog or bottom sheet for creating or updating a custom budget category.
class CreateBudgetCategoryDialog extends ConsumerStatefulWidget {
  final BudgetCategory? existingCategory;

  const CreateBudgetCategoryDialog({super.key, this.existingCategory});

  static Future<void> show(
    BuildContext context, {
    BudgetCategory? existingCategory,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CreateBudgetCategoryDialog(existingCategory: existingCategory),
      ),
    );
  }

  @override
  ConsumerState<CreateBudgetCategoryDialog> createState() =>
      _CreateBudgetCategoryDialogState();
}

class _CreateBudgetCategoryDialogState
    extends ConsumerState<CreateBudgetCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedIcon;

  bool get isEditing => widget.existingCategory != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingCategory?.description ?? '',
    );
    _selectedIcon = widget.existingCategory?.iconName ?? 'category';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(budgetCategoryControllerProvider.notifier);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (isEditing) {
      final updated = widget.existingCategory!.copyWith(
        name: name,
        description: Value(description.isNotEmpty ? description : null),
        iconName: Value(_selectedIcon),
      );
      final success = await controller.updateCategory(updated);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget category updated.')),
          );
        } else {
          final error = ref.read(budgetCategoryControllerProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${error ?? "Unknown error"}')),
          );
        }
      }
    } else {
      final created = await controller.createCustomCategory(
        name: name,
        description: description.isNotEmpty ? description : null,
        iconName: _selectedIcon,
      );
      if (mounted) {
        if (created != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Created "$name" category.')));
        } else {
          final error = ref.read(budgetCategoryControllerProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${error ?? "Unknown error"}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOperating = ref.watch(budgetCategoryControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Custom Category' : 'New Custom Category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name *',
                hintText: 'e.g. Organic Compost, Solar Irrigation',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (val) =>
                  InputValidators.requiredText(val, fieldName: 'Category name'),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'What kind of expenses or budget items belong here?',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Icon Picker Label
            Text(
              'CHOOSE AN ICON',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Icon Picker Grid
            SizedBox(
              height: 110,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: BudgetCategoryIconHelper.availableIcons.length,
                itemBuilder: (ctx, index) {
                  final entry = BudgetCategoryIconHelper.availableIcons.entries
                      .elementAt(index);
                  final isSelected = entry.key == _selectedIcon;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedIcon = entry.key);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            AppButton(
              label: isEditing ? 'Save Changes' : 'Create Category',
              icon: isEditing ? Icons.save : Icons.add,
              isLoading: isOperating,
              onPressed: isOperating ? null : _submit,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
