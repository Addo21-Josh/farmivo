import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme_extension.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../core/money/money.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/app_button.dart';
import '../../budgets/domain/models/budget_category_presets.dart';
import '../../budgets/domain/models/budget_item_with_category.dart';
import '../../budgets/presentation/providers/budget_category_providers.dart';
import '../../budgets/presentation/providers/budget_item_providers.dart';
import '../../projects/presentation/providers/project_providers.dart';
import '../domain/models/payment_method.dart';
import 'providers/expense_providers.dart';

/// Highly-optimized, low-latency expense recording screen designed to meet the
/// <15-second benchmark for field operations in Ghana & West Africa.
class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;

  const AddExpenseScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProjectId;
  String? _selectedCategoryId;
  String? _selectedBudgetItemId;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _transactionDate = DateTime.now();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vendorController = TextEditingController();
  final _notesController = TextEditingController();

  String? _receiptPhotoPath;
  bool _isCapturingPhoto = false;
  final _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
    // Auto-focus amount field for immediate numpad entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _vendorController.dispose();
    _notesController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt(bool fromCamera) async {
    setState(() => _isCapturingPhoto = true);
    try {
      final service = ref.read(receiptPhotoServiceProvider);
      final path = fromCamera
          ? await service.captureFromCamera()
          : await service.pickFromGallery();
      if (path != null && mounted) {
        setState(() => _receiptPhotoPath = path);
      }
    } finally {
      if (mounted) setState(() => _isCapturingPhoto = false);
    }
  }

  void _removeReceipt() {
    if (_receiptPhotoPath != null) {
      ref
          .read(receiptPhotoServiceProvider)
          .deleteReceiptPhoto(_receiptPhotoPath);
      setState(() => _receiptPhotoPath = null);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && mounted) {
      setState(() => _transactionDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a project.')));
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a budget category.')),
      );
      return;
    }

    final parsedMoney = Money.tryParse(_amountController.text.trim());
    if (parsedMoney == null || !parsedMoney.isPositive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expense amount greater than 0.'),
        ),
      );
      return;
    }

    final controller = ref.read(expenseControllerProvider.notifier);
    final expenseId = await controller.recordExpense(
      projectId: _selectedProjectId!,
      categoryId: _selectedCategoryId!,
      budgetItemId: _selectedBudgetItemId,
      transactionDate: _transactionDate,
      description: _descriptionController.text.trim(),
      amountMinor: parsedMoney.minorUnits.toInt(),
      currency: parsedMoney.currency,
      paymentMethod: _selectedPaymentMethod,
      vendorName: _vendorController.text.trim().isNotEmpty
          ? _vendorController.text.trim()
          : null,
      receiptPhotoPath: _receiptPhotoPath,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (expenseId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Expense of ${parsedMoney.format()} recorded successfully!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final projectsAsync = ref.watch(projectsStreamProvider);
    final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);
    final vendorsAsync = ref.watch(frequentVendorsProvider);
    final isSaving = ref.watch(expenseControllerProvider).isLoading;

    // Auto-select single project if only one exists and none was selected
    projectsAsync.whenData((List<Project> projects) {
      if (_selectedProjectId == null && projects.length == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedProjectId == null) {
            setState(() => _selectedProjectId = projects.first.id);
          }
        });
      }
    });

    // Auto-select first category if none selected
    categoriesAsync.whenData((List<BudgetCategory> categories) {
      if (_selectedCategoryId == null && categories.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedCategoryId == null) {
            setState(() => _selectedCategoryId = categories.first.id);
          }
        });
      }
    });

    // Budget items for linking (if project is selected)
    final budgetItemsAsync = _selectedProjectId != null
        ? ref.watch(projectBudgetItemsWithCategoryProvider(_selectedProjectId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: isSaving ? null : _saveExpense,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Project Selector
            projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading projects: $err'),
              data: (List<Project> projects) {
                if (projects.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.healthRedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'No active projects found. Create a project first.',
                    ),
                  );
                }

                // If initialProjectId was provided and matches, show as fixed card
                if (widget.initialProjectId != null) {
                  final currentProject = projects.firstWhere(
                    (p) => p.id == _selectedProjectId,
                    orElse: () => projects.first,
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.spa,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Project: ${currentProject.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${currentProject.commodity} • Currency: ${currentProject.currency}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProjectId,
                    decoration: const InputDecoration(
                      labelText: 'Select Project *',
                      prefixIcon: Icon(Icons.folder_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: projects.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.name} (${p.commodity})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProjectId = val;
                        _selectedBudgetItemId = null;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Project is required' : null,
                  ),
                );
              },
            ),

            // 2. Prominent Numpad-First Amount Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(40),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPENSE AMOUNT *',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'GH₵',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            final parsed = Money.tryParse(val.trim());
                            if (parsed == null || !parsed.isPositive) {
                              return 'Enter valid positive amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Quick Category Selector (Horizontal chips with icons)
            Text(
              'Budget Category *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Error loading categories: $err'),
              data: (List<BudgetCategory> categories) {
                return SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat.id == _selectedCategoryId;
                      final icon = BudgetCategoryIconHelper.getIcon(
                        cat.iconName,
                      );

                      return FilterChip(
                        selected: isSelected,
                        avatar: Icon(
                          icon,
                          size: 18,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                        label: Text(cat.name),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategoryId = cat.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 4. Description Field
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description / Purpose *',
                hintText: 'e.g., 2 bags of NPK, casual labour weeding',
                prefixIcon: Icon(Icons.edit_note_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please describe the expense.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 5. West African Payment Method Selector (Pills)
            Text(
              'Payment Method *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentMethod.values.map((method) {
                final isSelected = method == _selectedPaymentMethod;
                return ChoiceChip(
                  avatar: Icon(
                    method.icon,
                    size: 16,
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  label: Text(method.displayName),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPaymentMethod = method);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 6. Vendor Auto-Suggest Field
            vendorsAsync.when(
              loading: () => TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor / Merchant (Optional)',
                  hintText: 'e.g. Agricare Inputs, Kumasi Depot',
                  prefixIcon: Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              error: (_, __) => TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor / Merchant (Optional)',
                  prefixIcon: Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              data: (List<String> frequentVendors) {
                return Autocomplete<String>(
                  initialValue: TextEditingValue(text: _vendorController.text),
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return frequentVendors.take(5);
                    }
                    return frequentVendors.where(
                      (v) => v.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  onSelected: (selection) {
                    _vendorController.text = selection;
                  },
                  fieldViewBuilder:
                      (
                        context,
                        fieldTextEditingController,
                        fieldFocusNode,
                        onFieldSubmitted,
                      ) {
                        // Sync controllers
                        fieldTextEditingController.addListener(() {
                          _vendorController.text =
                              fieldTextEditingController.text;
                        });
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Vendor / Merchant (Optional)',
                            hintText: 'e.g. Agricare Inputs, Kumasi Depot',
                            prefixIcon: Icon(Icons.storefront_outlined),
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                );
              },
            ),
            const SizedBox(height: 16),

            // 7. Date Selector (Defaults to Today)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Transaction Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _transactionDate.isSameDay(DateTime.now())
                      ? 'Today (${_transactionDate.toDisplayDate()})'
                      : _transactionDate.toDisplayDate(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 8. Optional Budget Line Item Link
            if (budgetItemsAsync != null)
              budgetItemsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (List<BudgetItemWithCategory> budgetItems) {
                  if (budgetItems.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBudgetItemId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Link to Budget Item (Optional)',
                        hintText: 'Track spending against budget item',
                        prefixIcon: Icon(Icons.link_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None (General Project Expense)'),
                        ),
                        ...budgetItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.item.id,
                            child: Text(
                              '${item.item.name} (${item.category.name})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedBudgetItemId = val;
                          // If linked, also sync the category!
                          if (val != null) {
                            final matched = budgetItems.firstWhere(
                              (b) => b.item.id == val,
                            );
                            _selectedCategoryId = matched.item.categoryId;
                          }
                        });
                      },
                    ),
                  );
                },
              ),

            // 9. Receipt Photo Attachment
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Receipt Photo (Optional)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_receiptPhotoPath != null) ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_receiptPhotoPath!),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              height: 60,
                              child: Center(child: Text('Receipt Attached')),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black87,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: _removeReceipt,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            icon: _isCapturingPhoto
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.photo_camera),
                            label: const Text('Take Photo'),
                            onPressed: _isCapturingPhoto
                                ? null
                                : () => _pickReceipt(true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('From Gallery'),
                            onPressed: _isCapturingPhoto
                                ? null
                                : () => _pickReceipt(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 10. Save Expense Button
            AppButton(
              label: 'Save Expense',
              icon: Icons.check_circle_outline,
              isLoading: isSaving,
              height: 52,
              onPressed: _saveExpense,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
