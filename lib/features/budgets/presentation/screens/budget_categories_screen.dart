import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/budget_category_providers.dart';
import '../widgets/budget_category_tile.dart';
import '../widgets/create_budget_category_dialog.dart';

/// Screen allowing farmers and farm managers to browse standard agricultural
/// taxonomy categories and configure custom user-defined budget categories.
class BudgetCategoriesScreen extends ConsumerStatefulWidget {
  const BudgetCategoriesScreen({super.key});

  @override
  ConsumerState<BudgetCategoriesScreen> createState() =>
      _BudgetCategoriesScreenState();
}

class _BudgetCategoriesScreenState
    extends ConsumerState<BudgetCategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BudgetCategory category) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${category.name}"?'),
        content: const Text(
          'Are you sure you want to remove this custom budget category? Categories linked to existing budget items or expenses cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(budgetCategoryControllerProvider.notifier)
                  .deleteCategory(category.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category "${category.name}" deleted.'),
                    ),
                  );
                } else {
                  final error = ref
                      .read(budgetCategoryControllerProvider)
                      .error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cannot delete: ${error ?? "Category is in use."}',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Category',
            onPressed: () => CreateBudgetCategoryDialog.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => CreateBudgetCategoryDialog.show(context),
        icon: const Icon(Icons.add),
        label: const Text('New Category'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error loading categories: $err')),
        data: (categories) {
          final query = _searchQuery.trim().toLowerCase();
          final filtered = categories.where((c) {
            if (query.isEmpty) return true;
            return c.name.toLowerCase().contains(query) ||
                (c.description != null &&
                    c.description!.toLowerCase().contains(query));
          }).toList();

          final customCategories = filtered
              .where((c) => !c.isSystemDefault)
              .toList();
          final standardCategories = filtered
              .where((c) => c.isSystemDefault)
              .toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              // 1. Search Box
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // 2. Educational Taxonomy Banner
              AppCard(
                title: 'Standard Agricultural Taxonomy',
                subtitle: 'Categorized capital planning and cost tracking',
                leadingIcon: const Icon(Icons.info_outline),
                child: Text(
                  'Standard categories structure your pre-season planning across seeds, mechanization, agro-chemicals, casual labour, and transport. You can also add custom categories specific to your enterprise.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                    height: 1.4,
                  ),
                ),
              ),

              // 3. Custom Categories Section (if any)
              if (customCategories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'CUSTOM ENTERPRISE CATEGORIES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${customCategories.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...customCategories.map(
                  (c) => BudgetCategoryTile(
                    category: c,
                    onEdit: () => CreateBudgetCategoryDialog.show(
                      context,
                      existingCategory: c,
                    ),
                    onDelete: () => _confirmDelete(c),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 4. Standard Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'STANDARD AGRICULTURAL TAXONOMY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${standardCategories.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...standardCategories.map((c) => BudgetCategoryTile(category: c)),

              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text('No categories matching "$_searchQuery"'),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
