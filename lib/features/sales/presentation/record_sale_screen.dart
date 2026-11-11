import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/app/theme/app_theme_extension.dart';
import 'package:farmivo/core/extensions/date_time_extensions.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/features/buyers/presentation/screens/buyer_form_sheet.dart';
import 'package:farmivo/features/expenses/domain/models/payment_method.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/presentation/providers/harvest_providers.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/features/sales/domain/models/sale_payment_status.dart';
import 'package:farmivo/features/sales/presentation/providers/sale_providers.dart';
import 'package:farmivo/shared/widgets/app_button.dart';

/// Production tactile screen for recording commercial harvest sales agreements,
/// unit pricing, buyer credit terms, and initial payment settlements.
class RecordSaleScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final String? initialHarvestId;
  final String? initialBuyerId;

  const RecordSaleScreen({
    super.key,
    this.initialProjectId,
    this.initialHarvestId,
    this.initialBuyerId,
  });

  @override
  ConsumerState<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends ConsumerState<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProjectId;
  String? _selectedHarvestId;
  String? _selectedBuyerId;

  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'Crates');
  final _unitPriceController = TextEditingController();
  final _depositAmountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  SalePaymentStatus _selectedPaymentStatus = SalePaymentStatus.paid;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  static const List<String> _suggestedUnits = [
    'Crates',
    'Bags',
    '50kg Bags',
    'Kg',
    'Tonnes',
    'Boxes',
    'Sacks',
    'Pieces',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
    _selectedHarvestId = widget.initialHarvestId;
    _selectedBuyerId = widget.initialBuyerId;

    _quantityController.addListener(_onPriceInputsChanged);
    _unitPriceController.addListener(_onPriceInputsChanged);
    _depositAmountController.addListener(_onPriceInputsChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onPriceInputsChanged);
    _unitPriceController.removeListener(_onPriceInputsChanged);
    _depositAmountController.removeListener(_onPriceInputsChanged);

    _productNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _depositAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPriceInputsChanged() {
    setState(() {});
  }

  double get _quantity =>
      double.tryParse(_quantityController.text.trim()) ?? 0.0;

  double get _unitPriceMajor =>
      double.tryParse(_unitPriceController.text.trim()) ?? 0.0;

  int get _unitPriceMinor => (_unitPriceMajor * 100).round();

  int get _calculatedTotalMinor => (_quantity * _unitPriceMinor).round();

  Money get _calculatedTotal => Money(BigInt.from(_calculatedTotalMinor));

  double get _depositMajor =>
      double.tryParse(_depositAmountController.text.trim()) ?? 0.0;

  int get _depositMinor => (_depositMajor * 100).round();

  Money get _remainingBalance {
    if (_selectedPaymentStatus == SalePaymentStatus.paid) {
      return Money.zero();
    }
    if (_selectedPaymentStatus == SalePaymentStatus.unpaid) {
      return _calculatedTotal;
    }
    final balanceMinor = _calculatedTotalMinor - _depositMinor;
    return balanceMinor > 0 ? Money(BigInt.from(balanceMinor)) : Money.zero();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _openNewBuyerSheet() async {
    final newBuyerId = await BuyerFormSheet.show(context);
    if (newBuyerId != null && mounted) {
      setState(() => _selectedBuyerId = newBuyerId);
      ref.invalidate(buyersStreamProvider);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farming project.')),
      );
      return;
    }

    if (_selectedPaymentStatus == SalePaymentStatus.partial) {
      if (_depositMinor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter an initial deposit amount greater than zero.',
            ),
          ),
        );
        return;
      }
      if (_depositMinor >= _calculatedTotalMinor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Initial deposit cannot meet or exceed the total sale amount. Select "Full Payment" instead.',
            ),
          ),
        );
        return;
      }
    }

    final controller = ref.read(saleControllerProvider.notifier);
    final saleId = await controller.recordSale(
      projectId: _selectedProjectId!,
      buyerId: _selectedBuyerId,
      harvestId: _selectedHarvestId,
      saleDate: _selectedDate,
      productName: _productNameController.text.trim(),
      quantity: _quantity,
      unit: _unitController.text.trim(),
      unitPriceMinor: _unitPriceMinor,
      currency: 'GHS',
      paymentStatus: _selectedPaymentStatus,
      initialPaymentAmountMinor:
          _selectedPaymentStatus == SalePaymentStatus.partial
          ? _depositMinor
          : null,
      paymentMethod: _selectedPaymentStatus != SalePaymentStatus.unpaid
          ? _selectedPaymentMethod.code
          : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (saleId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sale of ${_productNameController.text.trim()} recorded successfully!',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final projectsAsync = ref.watch(projectsStreamProvider);
    final buyersAsync = ref.watch(buyersStreamProvider);
    final controllerState = ref.watch(saleControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Record Harvest Sale')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Project Selection
                Text(
                  'Farming Project *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (Object err, _) =>
                      Text('Error loading projects: $err'),
                  data: (List<Project> projects) {
                    if (projects.isEmpty) {
                      return const Text(
                        'No farming projects available. Please create a project first.',
                      );
                    }

                    // Auto-select first project if none selected
                    if (_selectedProjectId == null && projects.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedProjectId = projects.first.id;
                          });
                        }
                      });
                    }

                    return DropdownButtonFormField<String>(
                      initialValue:
                          _selectedProjectId ??
                          (projects.isNotEmpty ? projects.first.id : null),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.agriculture_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: projects.map((Project p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text('${p.name} (${p.commodity})'),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        setState(() {
                          _selectedProjectId = val;
                          _selectedHarvestId = null;
                        });
                      },
                      validator: (val) => val == null
                          ? 'Please select a farming project'
                          : null,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 2. Harvest Batch Link (Optional)
                if (_selectedProjectId != null) ...[
                  ref
                      .watch(
                        projectHarvestsWithDetailsProvider(_selectedProjectId!),
                      )
                      .when(
                        loading: () => const SizedBox.shrink(),
                        error: (Object _, __) => const SizedBox.shrink(),
                        data: (List<HarvestWithDetails> harvests) {
                          if (harvests.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Draw From Harvest Batch (Optional)',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String?>(
                                initialValue: _selectedHarvestId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.inventory_2_outlined),
                                  border: OutlineInputBorder(),
                                  hintText: 'Direct Field Sale / Unlinked Lot',
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      'Direct Field Sale (No lot link)',
                                    ),
                                  ),
                                  ...harvests.map((HarvestWithDetails h) {
                                    return DropdownMenuItem<String?>(
                                      value: h.harvest.id,
                                      child: Text(
                                        '${h.harvest.batchNumber} • ${h.harvest.productName} (${h.formattedQuantity})',
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (String? val) {
                                  setState(() {
                                    _selectedHarvestId = val;
                                    if (val != null) {
                                      final selectedLot = harvests.firstWhere(
                                        (h) => h.harvest.id == val,
                                      );
                                      _productNameController.text =
                                          selectedLot.harvest.productName;
                                      _unitController.text =
                                          selectedLot.harvest.unit;
                                      if (_quantityController.text.isEmpty) {
                                        _quantityController.text = selectedLot
                                            .harvest
                                            .quantity
                                            .toString();
                                      }
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                ],

                // 3. Buyer & Customer Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Buyer / Off-taker (Optional)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: _openNewBuyerSheet,
                      icon: const Icon(Icons.person_add_alt_outlined, size: 16),
                      label: const Text('New Buyer'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                buyersAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (Object err, _) => Text('Error loading buyers: $err'),
                  data: (List<BuyerSummary> buyers) {
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedBuyerId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Walk-in / Cash Buyer',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Walk-in / Cash Buyer (No registration)'),
                        ),
                        ...buyers.map((BuyerSummary b) {
                          final biz = b.businessName != null
                              ? ' • ${b.businessName}'
                              : '';
                          return DropdownMenuItem<String?>(
                            value: b.id,
                            child: Text('${b.name}$biz'),
                          );
                        }),
                      ],
                      onChanged: (String? val) {
                        setState(() => _selectedBuyerId = val);
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 4. Produce Name
                Text(
                  'Produce / Commodity Name *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.eco_outlined),
                    hintText: 'e.g. Roma Tomato, Yellow Corn, Fresh Chili',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter the produce name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 5. Quantity & Unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity *',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.scale_outlined),
                              hintText: 'e.g. 50',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter quantity';
                              }
                              final num = double.tryParse(val.trim());
                              if (num == null || num <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit *',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              hintText: 'Crates, Bags',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter unit';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Unit Suggestions Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _suggestedUnits.map((u) {
                    final isSelected =
                        _unitController.text.trim().toLowerCase() ==
                        u.toLowerCase();
                    return ActionChip(
                      label: Text(u),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : null,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onPressed: () {
                        setState(() => _unitController.text = u);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // 6. Unit Price (in Cedis)
                Text(
                  'Unit Price (GH₵ per unit) *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _unitPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.sell_outlined),
                    prefixText: 'GH₵ ',
                    hintText: 'e.g. 150.00',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter the unit price';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num < 0) {
                      return 'Price cannot be negative';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 7. Live Total Amount Calculation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.healthGreenBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.healthGreen.withAlpha(90)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SALE VALUE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: colors.healthGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _quantity > 0 && _unitPriceMajor > 0
                                ? '$_quantity ${_unitController.text} × GH₵ ${_unitPriceMajor.toStringAsFixed(2)}'
                                : 'Enter quantity and unit price above',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.healthGreen.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _calculatedTotal.format(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.healthGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 8. Payment Status (Full Payment, Partial, Credit Sale)
                Text(
                  'Payment Status *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<SalePaymentStatus>(
                  segments: const [
                    ButtonSegment<SalePaymentStatus>(
                      value: SalePaymentStatus.paid,
                      label: Text('Full Payment'),
                      icon: Icon(Icons.check_circle_outlined, size: 16),
                    ),
                    ButtonSegment<SalePaymentStatus>(
                      value: SalePaymentStatus.partial,
                      label: Text('Partial'),
                      icon: Icon(Icons.timelapse_outlined, size: 16),
                    ),
                    ButtonSegment<SalePaymentStatus>(
                      value: SalePaymentStatus.unpaid,
                      label: Text('Credit Sale'),
                      icon: Icon(Icons.pending_actions_outlined, size: 16),
                    ),
                  ],
                  selected: {_selectedPaymentStatus},
                  onSelectionChanged: (Set<SalePaymentStatus> val) {
                    setState(() => _selectedPaymentStatus = val.first);
                  },
                ),

                const SizedBox(height: 16),

                // 9. Payment Method (for Paid or Partial)
                if (_selectedPaymentStatus != SalePaymentStatus.unpaid) ...[
                  Text(
                    'Payment Channel',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          PaymentMethod.cash,
                          PaymentMethod.mtnMoMo,
                          PaymentMethod.telecelCash,
                          PaymentMethod.bankTransfer,
                          PaymentMethod.other,
                        ].map((PaymentMethod method) {
                          final isSelected = _selectedPaymentMethod == method;
                          return ChoiceChip(
                            avatar: Icon(method.icon, size: 16),
                            label: Text(method.displayName),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() => _selectedPaymentMethod = method);
                              }
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // 10. Partial Deposit Amount Input & Remaining Debt
                if (_selectedPaymentStatus == SalePaymentStatus.partial) ...[
                  Text(
                    'Initial Deposit Collected (GH₵) *',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _depositAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.payments_outlined),
                      prefixText: 'GH₵ ',
                      hintText: 'e.g. 50.00',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter deposit amount';
                      }
                      final num = double.tryParse(val.trim());
                      if (num == null || num <= 0) {
                        return 'Deposit must be > 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.healthYellowBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.healthYellow.withAlpha(90),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining Buyer Debt:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.healthYellow,
                          ),
                        ),
                        Text(
                          _remainingBalance.format(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.healthYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 11. Sale Date Picker
                Text(
                  'Sale Agreement Date *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedDate.toDisplayDate()),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 12. Notes & Agreements
                Text(
                  'Notes / Terms (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.edit_note_outlined),
                    hintText:
                        'e.g. Buyer to settle remaining balance in 14 days',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // 13. Submit Button
                AppButton(
                  label: 'Record Commercial Sale',
                  icon: Icons.check_circle_outline,
                  isLoading: controllerState.isLoading,
                  onPressed: controllerState.isLoading ? null : _submit,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
