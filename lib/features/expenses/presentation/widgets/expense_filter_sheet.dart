import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/money/money.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../budgets/presentation/providers/budget_category_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/models/expense_filter.dart';
import '../../domain/models/payment_method.dart';
import '../providers/expense_providers.dart';

/// Modal bottom sheet allowing multi-dimensional filtering across projects,
/// categories, payment methods, date ranges, and monetary bounds.
class ExpenseFilterSheet extends ConsumerStatefulWidget {
  const ExpenseFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ExpenseFilterSheet(),
    );
  }

  @override
  ConsumerState<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends ConsumerState<ExpenseFilterSheet> {
  late ExpenseStatusFilter _status;
  String? _projectId;
  String? _categoryId;
  PaymentMethod? _paymentMethod;
  DateTime? _startDate;
  DateTime? _endDate;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final current = ref.read(expenseFilterProvider);
    _status = current.status;
    _projectId = current.projectId;
    _categoryId = current.categoryId;
    _paymentMethod = current.paymentMethod;
    _startDate = current.startDate;
    _endDate = current.endDate;
    if (current.minAmountMinor != null) {
      _minAmountController.text = (current.minAmountMinor! / 100.0)
          .toStringAsFixed(2);
    }
    if (current.maxAmountMinor != null) {
      _maxAmountController.text = (current.maxAmountMinor! / 100.0)
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _status = ExpenseStatusFilter.all;
      _projectId = null;
      _categoryId = null;
      _paymentMethod = null;
      _startDate = null;
      _endDate = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _apply() {
    int? minMinor;
    if (_minAmountController.text.trim().isNotEmpty) {
      final parsed = Money.tryParse(_minAmountController.text.trim());
      if (parsed != null && parsed.isPositive) {
        minMinor = parsed.minorUnits.toInt();
      }
    }

    int? maxMinor;
    if (_maxAmountController.text.trim().isNotEmpty) {
      final parsed = Money.tryParse(_maxAmountController.text.trim());
      if (parsed != null && parsed.isPositive) {
        maxMinor = parsed.minorUnits.toInt();
      }
    }

    final updated = ref
        .read(expenseFilterProvider)
        .copyWith(
          status: _status,
          projectId: _projectId,
          clearProject: _projectId == null,
          categoryId: _categoryId,
          clearCategory: _categoryId == null,
          paymentMethod: _paymentMethod,
          clearPaymentMethod: _paymentMethod == null,
          startDate: _startDate,
          endDate: _endDate,
          clearDates: _startDate == null && _endDate == null,
          minAmountMinor: minMinor,
          maxAmountMinor: maxMinor,
          clearAmountRange: minMinor == null && maxMinor == null,
        );

    ref.read(expenseFilterProvider.notifier).state = updated;
    Navigator.of(context).pop();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: _startDate ?? now.subtract(const Duration(days: 30)),
      end: _endDate ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsStreamProvider);
    final categoriesAsync = ref.watch(budgetCategoriesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Filter Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(onPressed: _reset, child: const Text('Reset All')),
                ],
              ),
              const Divider(height: 16),

              // 1. Transaction Status (All, Active, Voided)
              Text(
                'Transaction Status',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<ExpenseStatusFilter>(
                segments: const [
                  ButtonSegment(
                    value: ExpenseStatusFilter.all,
                    label: Text('All'),
                  ),
                  ButtonSegment(
                    value: ExpenseStatusFilter.activeOnly,
                    label: Text('Active'),
                  ),
                  ButtonSegment(
                    value: ExpenseStatusFilter.voidedOnly,
                    label: Text('Voided'),
                  ),
                ],
                selected: {_status},
                onSelectionChanged: (selected) {
                  setState(() => _status = selected.first);
                },
              ),
              const SizedBox(height: 16),

              // 2. Project Filter
              Text(
                'Farm Project',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              projectsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (projects) {
                  return DropdownButtonFormField<String?>(
                    initialValue: _projectId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.folder_outlined),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Projects'),
                      ),
                      ...projects.map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.commodity})'),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _projectId = val),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 3. Category Filter
              Text(
                'Budget Category',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) {
                  return DropdownButtonFormField<String?>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _categoryId = val),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 4. Payment Method Filter
              Text(
                'Payment Channel',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Channels'),
                    selected: _paymentMethod == null,
                    onSelected: (selected) {
                      if (selected) setState(() => _paymentMethod = null);
                    },
                  ),
                  ...PaymentMethod.values.map((method) {
                    final isSelected = _paymentMethod == method;
                    return ChoiceChip(
                      avatar: Icon(method.icon, size: 14),
                      label: Text(method.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(
                          () => _paymentMethod = selected ? method : null,
                        );
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Date Range Presets & Custom Picker
              Text(
                'Date Range',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Time'),
                    selected: _startDate == null && _endDate == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('This Month'),
                    selected: _isThisMonth(),
                    onSelected: (selected) {
                      if (selected) {
                        final now = DateTime.now();
                        setState(() {
                          _startDate = DateTime(now.year, now.month, 1);
                          _endDate = DateTime(now.year, now.month + 1, 0);
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Last 30 Days'),
                    selected: _isLast30Days(),
                    onSelected: (selected) {
                      if (selected) {
                        final now = DateTime.now();
                        setState(() {
                          _startDate = now.subtract(const Duration(days: 30));
                          _endDate = now;
                        });
                      }
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.date_range, size: 14),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${_startDate!.toDisplayDate()} – ${_endDate!.toDisplayDate()}'
                          : 'Custom Range',
                    ),
                    onPressed: _pickCustomDateRange,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Amount Range Bounds
              Text(
                'Amount Range (GH₵)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Min (GH₵)',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.arrow_downward, size: 16),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Max (GH₵)',
                        hintText: '5,000.00',
                        prefixIcon: Icon(Icons.arrow_upward, size: 16),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 7. Apply Button
              AppButton(
                label: 'Apply Filters',
                icon: Icons.check,
                height: 50,
                onPressed: _apply,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  bool _isThisMonth() {
    if (_startDate == null || _endDate == null) return false;
    final now = DateTime.now();
    return _startDate!.year == now.year &&
        _startDate!.month == now.month &&
        _startDate!.day == 1 &&
        _endDate!.month == now.month;
  }

  bool _isLast30Days() {
    if (_startDate == null || _endDate == null) return false;
    final now = DateTime.now();
    return _endDate!.difference(now).inDays.abs() <= 1 &&
        _endDate!.difference(_startDate!).inDays >= 29;
  }
}
