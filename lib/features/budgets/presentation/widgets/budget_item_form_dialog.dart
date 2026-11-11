import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/money/money.dart';
import '../../domain/models/budget_category_presets.dart';
import '../../domain/models/budget_item_with_category.dart';
import '../providers/budget_category_providers.dart';
import '../providers/budget_item_providers.dart';

/// Modal sheet or dialog for creating or editing a project budget item with real-time formula calculation.
class BudgetItemFormDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String currency;
  final BudgetItemWithCategory? initialItem;
  final String? preselectedCategoryId;

  const BudgetItemFormDialog({
    super.key,
    required this.projectId,
    this.currency = 'GHS',
    this.initialItem,
    this.preselectedCategoryId,
  });

  /// Displays the budget item form as a responsive bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required String projectId,
    String currency = 'GHS',
    BudgetItemWithCategory? initialItem,
    String? preselectedCategoryId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BudgetItemFormDialog(
          projectId: projectId,
          currency: currency,
          initialItem: initialItem,
          preselectedCategoryId: preselectedCategoryId,
        ),
      ),
    );
  }

  @override
  ConsumerState<BudgetItemFormDialog> createState() =>
      _BudgetItemFormDialogState();
}

class _BudgetItemFormDialogState extends ConsumerState<BudgetItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _descriptionController;

  String? _selectedCategoryId;
  String _selectedUnit = 'Bags';
  Money? _calculatedPlannedAmount;
  bool _isSubmitting = false;

  static const List<String> _commonUnits = [
    'Bags',
    'Kg',
    'Litres',
    'Trips',
    'Days',
    'Acres',
    'Hectares',
    'Seedlings',
    'Crates',
    'Cartons',
    'Bundles',
    'Pieces',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem?.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: item != null
          ? (item.quantity % 1 == 0
                ? item.quantity.toInt().toString()
                : item.quantity.toString())
          : '1',
    );
    _unitCostController = TextEditingController(
      text: item != null
          ? Money(
              BigInt.from(item.unitCostMinor),
              currency: widget.currency,
            ).toMajor().toStringAsFixed(2)
          : '',
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    _selectedCategoryId = item?.categoryId ?? widget.preselectedCategoryId;
    if (item != null && item.unit.isNotEmpty) {
      _selectedUnit = item.unit;
    }

    _quantityController.addListener(_recalculateFormula);
    _unitCostController.addListener(_recalculateFormula);
    _recalculateFormula();
  }

  @override
  void dispose() {
    _quantityController.removeListener(_recalculateFormula);
    _unitCostController.removeListener(_recalculateFormula);
    _nameController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Dynamically computes Planned Amount = Quantity * Unit Cost in real time.
  void _recalculateFormula() {
    final qty = double.tryParse(_quantityController.text.trim());
    final costMoney = Money.tryParse(
      _unitCostController.text.trim(),
      currency: widget.currency,
    );

    if (qty != null && qty > 0 && costMoney != null && !costMoney.isNegative) {
      final plannedMinor = (qty * costMoney.minorUnits.toInt()).round();
      setState(() {
        _calculatedPlannedAmount = Money(
          BigInt.from(plannedMinor),
          currency: widget.currency,
        );
      });
    } else {
      if (_calculatedPlannedAmount != null) {
        setState(() {
          _calculatedPlannedAmount = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a budget category.')),
      );
      return;
    }

    final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final costMoney = Money.tryParse(
      _unitCostController.text.trim(),
      currency: widget.currency,
    );
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than zero.')),
      );
      return;
    }
    if (costMoney == null || costMoney.isNegative) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid non-negative unit cost.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(budgetItemControllerProvider.notifier);
      if (widget.initialItem == null) {
        // Create new item
        await controller.createBudgetItem(
          projectId: widget.projectId,
          categoryId: _selectedCategoryId!,
          name: _nameController.text.trim(),
          quantity: qty,
          unit: _selectedUnit,
          unitCostMinor: costMoney.minorUnits.toInt(),
          currency: widget.currency,
          description: _descriptionController.text.trim(),
        );
      } else {
        // Update existing item
        await controller.updateBudgetItem(
          id: widget.initialItem!.item.id,
          categoryId: _selectedCategoryId!,
          name: _nameController.text.trim(),
          quantity: qty,
          unit: _selectedUnit,
          unitCostMinor: costMoney.minorUnits.toInt(),
          description: _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);
    final isEditing = widget.initialItem != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEditing
                        ? 'Edit Budget Item'
                        : 'Add Pre-Season Budget Item',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                  tooltip: 'Cancel',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Dynamic Formula Calculation Callout Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _calculatedPlannedAmount != null
                            ? colors.healthGreenBg
                            : theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(100),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _calculatedPlannedAmount != null
                              ? colors.healthGreen.withAlpha(120)
                              : theme.dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calculate_outlined,
                                size: 18,
                                color: _calculatedPlannedAmount != null
                                    ? colors.healthGreen
                                    : theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'DYNAMIC FORMULA: QUANTITY × UNIT COST',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: _calculatedPlannedAmount != null
                                      ? colors.healthGreen
                                      : theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_calculatedPlannedAmount != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_quantityController.text.trim()} $_selectedUnit × ${Money.tryParse(_unitCostController.text.trim(), currency: widget.currency)?.format() ?? ''}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _calculatedPlannedAmount!.format(),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: colors.healthGreen,
                                      ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              'Enter a valid quantity and unit cost to calculate planned amount.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha(180),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Budget Category Selector
                    categoriesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Error loading categories: $err'),
                      data: (categories) {
                        if (_selectedCategoryId == null &&
                            categories.isNotEmpty) {
                          _selectedCategoryId = categories.first.id;
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Budget Category *',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: categories.map((cat) {
                            final icon = BudgetCategoryIconHelper.getIcon(
                              cat.iconName,
                            );
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (cat.isSystemDefault)
                                    Text(
                                      'Standard',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withAlpha(140),
                                          ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategoryId = val);
                            }
                          },
                          validator: (val) =>
                              val == null ? 'Category is required' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Item Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText:
                            'e.g. NPK 15:15:15 Fertilizer, Tractor Ploughing',
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter an item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. Quantity and Unit Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity Input
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity *',
                              hintText: '1.0',
                              prefixIcon: Icon(Icons.numbers_outlined),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter quantity';
                              }
                              final q = double.tryParse(val.trim());
                              if (q == null || q <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Unit Selector
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _commonUnits.contains(_selectedUnit)
                                ? _selectedUnit
                                : _commonUnits.first,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Unit *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            items: _commonUnits.map((u) {
                              return DropdownMenuItem<String>(
                                value: u,
                                child: Text(u, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedUnit = val;
                                  _recalculateFormula();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. Unit Cost Field (minor unit input with immediate calculation)
                    TextFormField(
                      controller: _unitCostController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Unit Cost (${widget.currency}) *',
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        prefixText: '${widget.currency} ',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter unit cost';
                        }
                        final money = Money.tryParse(
                          val.trim(),
                          currency: widget.currency,
                        );
                        if (money == null || money.isNegative) {
                          return 'Must be valid positive cost';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 6. Optional Description / Notes
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Specifications (Optional)',
                        hintText:
                            'e.g. 50kg bags from local MoFA certified distributor',
                        prefixIcon: Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7. Submit Button (>= 48dp touch target)
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(isEditing ? Icons.check : Icons.add),
                        label: Text(
                          _isSubmitting
                              ? 'Saving...'
                              : (isEditing ? 'Save Changes' : 'Add to Budget'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
