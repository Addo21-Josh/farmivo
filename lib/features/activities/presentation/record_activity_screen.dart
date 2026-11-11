import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/core/extensions/date_time_extensions.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/features/activities/domain/models/activity_status.dart';
import 'package:farmivo/features/activities/domain/models/activity_type.dart';
import 'package:farmivo/features/activities/presentation/providers/activity_providers.dart';
import 'package:farmivo/features/budgets/presentation/providers/budget_category_providers.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/shared/widgets/app_button.dart';

/// Form screen for logging agronomic field operations, casual labour,
/// and automatically creating corresponding financial ledger expenses.
class RecordActivityScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;

  const RecordActivityScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<RecordActivityScreen> createState() =>
      _RecordActivityScreenState();
}

class _RecordActivityScreenState extends ConsumerState<RecordActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProjectId;
  ActivityType _selectedType = ActivityType.landPreparation;
  ActivityStatus _selectedStatus = ActivityStatus.completed;
  DateTime _activityDate = DateTime.now();

  final _titleController = TextEditingController();
  final _labourCountController = TextEditingController(text: '0');
  final _durationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  bool _createLinkedExpense = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  String? _selectedExpenseCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
    _costController.addListener(_onCostChanged);
  }

  @override
  void dispose() {
    _costController.removeListener(_onCostChanged);
    _titleController.dispose();
    _labourCountController.dispose();
    _durationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCostChanged() {
    final parsed = Money.tryParse(_costController.text.trim());
    if (parsed != null && parsed.isPositive && !_createLinkedExpense) {
      setState(() {
        _createLinkedExpense = true;
      });
    }
  }

  void _onTypeChanged(ActivityType type) {
    setState(() {
      _selectedType = type;
      // Pre-fill or clear title if it was an auto-suggestion
      if (_titleController.text.isEmpty && type.suggestedTitles.isNotEmpty) {
        _titleController.text = type.suggestedTitles.first;
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _activityDate = picked);
    }
  }

  void _adjustLabour(int delta) {
    final current = int.tryParse(_labourCountController.text) ?? 0;
    final updated = (current + delta).clamp(0, 9999);
    setState(() {
      _labourCountController.text = updated.toString();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a project.')));
      return;
    }

    final labourCount = int.tryParse(_labourCountController.text.trim()) ?? 0;
    final durationHours = double.tryParse(_durationController.text.trim());
    final parsedCost = Money.tryParse(_costController.text.trim());
    final costMinor = parsedCost?.minorUnits.toInt() ?? 0;

    final id = await ref
        .read(activityControllerProvider.notifier)
        .recordActivity(
          projectId: _selectedProjectId!,
          activityType: _selectedType,
          title: _titleController.text.trim(),
          activityDate: _activityDate,
          labourCount: labourCount,
          durationHours: durationHours,
          costMinor: costMinor,
          status: _selectedStatus,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          createLinkedExpense: _createLinkedExpense && costMinor > 0,
          expensePaymentMethod: _selectedPaymentMethod,
          expenseCategoryId: _selectedExpenseCategoryId,
        );

    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _createLinkedExpense && costMinor > 0
                ? 'Activity logged & linked to project ledger'
                : 'Activity logged successfully',
          ),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);
    final isSaving = ref.watch(activityControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Log Field Activity')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Project Selector
            Text(
              'Farm Project *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading projects: $err'),
              data: (projects) {
                if (projects.isEmpty) {
                  return const Text(
                    'No projects available. Create a project first.',
                  );
                }
                // Default to first project if none selected
                _selectedProjectId ??= projects.first.id;

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedProjectId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.folder_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: projects.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.name} (${p.commodity})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedProjectId = val);
                  },
                  validator: (val) =>
                      val == null ? 'Please select a project' : null,
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. Activity Type Picker
            Text(
              'Activity Type *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ActivityType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        type.icon,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                      label: Text(type.displayName),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      checkmarkColor: theme.colorScheme.onPrimary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) _onTypeChanged(type);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Operation Title & Suggested Chips
            Text(
              'Activity Title / Operation *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Tractor Ploughing, Urea Top Dressing',
                prefixIcon: const Icon(Icons.edit_note),
                suffixIcon: _titleController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () =>
                            setState(() => _titleController.clear()),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter an activity title';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Quick suggestion chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _selectedType.suggestedTitles.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() => _titleController.text = suggestion);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Date and Status Row
            Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date *',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          child: Text(_activityDate.toDisplayDate()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ActivityStatus>(
                        isExpanded: true,
                        initialValue: _selectedStatus,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            _selectedStatus.icon,
                            size: 20,
                            color: _selectedStatus.color,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: ActivityStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. Casual Labour & Duration
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor.withAlpha(100)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Casual Labour & Manpower',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Workers Headcount with stepper
                    Text('Workers Headcount', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _adjustLabour(-1),
                          tooltip: 'Decrease workers',
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _labourCountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add),
                          onPressed: () => _adjustLabour(1),
                          tooltip: 'Increase workers',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Duration in Hours
                    Text('Duration (Hours)', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 6.5',
                        suffixText: 'hrs',
                        prefixIcon: const Icon(
                          Icons.schedule_outlined,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Cost & Financial Ledger Linking
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor.withAlpha(100)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Labour Cost & Expenditure',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount input
                    TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Total Operation / Labour Cost',
                        prefixText: 'GH₵ ',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Auto-record as Expense Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Record as Expense in Project Ledger',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: const Text(
                        'Deducts from project budget and logs in financial statements.',
                        style: TextStyle(fontSize: 11),
                      ),
                      value: _createLinkedExpense,
                      onChanged: (val) {
                        setState(() => _createLinkedExpense = val);
                      },
                    ),

                    if (_createLinkedExpense) ...[
                      const Divider(height: 16),
                      // Payment Method Selector
                      Text(
                        'Payment Channel',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              PaymentMethod.cash,
                              PaymentMethod.mtnMoMo,
                              PaymentMethod.telecelCash,
                              PaymentMethod.bankTransfer,
                            ].map((method) {
                              final isSelected =
                                  _selectedPaymentMethod == method;
                              return ChoiceChip(
                                avatar: Icon(method.icon, size: 16),
                                label: Text(
                                  method.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(
                                      () => _selectedPaymentMethod = method,
                                    );
                                  }
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Category Selector (defaults to Labour)
                      categoriesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (categories) {
                          if (categories.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          _selectedExpenseCategoryId ??= categories
                              .firstWhere(
                                (c) => c.name.toLowerCase().contains('labour'),
                                orElse: () => categories.first,
                              )
                              .id;

                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedExpenseCategoryId,
                            decoration: InputDecoration(
                              labelText: 'Budget Category',
                              prefixIcon: const Icon(
                                Icons.category_outlined,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: categories.map((c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(
                              () => _selectedExpenseCategoryId = val,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 7. Notes
            Text(
              'Field Observations & Notes',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Weather conditions, chemical dosage, worker names, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 8. Submit Button
            AppButton(
              label: 'Save Field Activity',
              onPressed: _submit,
              isLoading: isSaving,
              icon: Icons.check,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
