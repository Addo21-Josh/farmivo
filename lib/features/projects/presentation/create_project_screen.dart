import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../farms/presentation/providers/farm_providers.dart';
import 'providers/project_providers.dart';

/// Screen for creating a new agricultural project or editing an existing one.
class CreateProjectScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? initialFarmId;

  const CreateProjectScreen({super.key, this.projectId, this.initialFarmId});

  bool get isEditing => projectId != null && projectId!.isNotEmpty;

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _commodityCustomController;
  late final TextEditingController _varietyController;
  late final TextEditingController _sizeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;

  String? _selectedFarmId;
  String _selectedType = 'Crop';
  String _selectedCommodity = 'Pepper';
  bool _isCustomCommodity = false;
  String _selectedUnit = 'Acres';
  String _selectedCurrency = AppConstants.defaultCurrency;

  DateTime _startDate = DateTime.now();
  DateTime? _expectedHarvestDate;

  bool _initialized = false;
  bool _userEditedName = false;
  Project? _existingProject;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _commodityCustomController = TextEditingController();
    _varietyController = TextEditingController();
    _sizeController = TextEditingController();
    _descriptionController = TextEditingController();
    _notesController = TextEditingController();

    _selectedFarmId = widget.initialFarmId;
    _updateDefaultHarvestDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commodityCustomController.dispose();
    _varietyController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateExistingProject(Project project) {
    if (_initialized) return;
    _initialized = true;
    _existingProject = project;

    _nameController.text = project.name;
    _selectedFarmId = project.farmId;
    _selectedType = project.projectType;

    // Check if commodity is in preset list
    final presets = _getCommoditiesForType(project.projectType);
    if (presets.contains(project.commodity)) {
      _selectedCommodity = project.commodity;
      _isCustomCommodity = false;
    } else {
      _selectedCommodity = 'Custom...';
      _isCustomCommodity = true;
      _commodityCustomController.text = project.commodity;
    }

    _varietyController.text = project.variety ?? '';
    _sizeController.text = project.landSize.toString();
    _selectedUnit = project.landUnit;
    _selectedCurrency = project.currency;
    _startDate = DateTime.fromMillisecondsSinceEpoch(project.startDate);
    if (project.expectedFirstHarvestDate != null) {
      _expectedHarvestDate = DateTime.fromMillisecondsSinceEpoch(
        project.expectedFirstHarvestDate!,
      );
    }
    _descriptionController.text = project.description ?? '';
    _notesController.text = project.notes ?? '';
    _userEditedName = true;
  }

  List<String> _getCommoditiesForType(String type) {
    switch (type) {
      case 'Crop':
        return AppConstants.defaultCrops;
      case 'Livestock':
        return AppConstants.defaultLivestock;
      case 'Aquaculture':
        return AppConstants.defaultAquaculture;
      default:
        return [];
    }
  }

  List<String> _getUnitsForType(String type) {
    switch (type) {
      case 'Crop':
        return const ['Acres', 'Hectares', 'Plots', 'Square Metre', 'Beds'];
      case 'Livestock':
        return const [
          'Birds',
          'Heads',
          'Animals',
          'Pairs',
          'Cattle',
          'Pigs',
          'Goats',
          'Sheep',
        ];
      case 'Aquaculture':
        return const ['Fingerlings', 'Ponds', 'Cages', 'Tanks'];
      default:
        return const ['Units', 'Acres', 'Plots', 'Pieces'];
    }
  }

  void _onTypeChanged(String newType) {
    setState(() {
      _selectedType = newType;
      final commodities = _getCommoditiesForType(newType);
      if (commodities.isNotEmpty) {
        _selectedCommodity = commodities.first;
        _isCustomCommodity = false;
      } else {
        _selectedCommodity = 'Custom...';
        _isCustomCommodity = true;
      }
      _selectedUnit = _getUnitsForType(newType).first;
      _updateDefaultHarvestDate();
      _suggestName();
    });
  }

  void _onCommodityChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedCommodity = val;
      _isCustomCommodity = val == 'Custom...';
      _updateDefaultHarvestDate();
      _suggestName();
    });
  }

  void _updateDefaultHarvestDate() {
    final commodity = _isCustomCommodity
        ? _commodityCustomController.text
        : _selectedCommodity;
    final duration = AppConstants.defaultCommodityDurations[commodity] ?? 90;
    _expectedHarvestDate = _startDate.add(Duration(days: duration));
  }

  void _suggestName() {
    if (_userEditedName) return;
    final commodity = _isCustomCommodity
        ? (_commodityCustomController.text.isNotEmpty
              ? _commodityCustomController.text
              : 'Custom')
        : _selectedCommodity;
    final size = _sizeController.text.trim();
    if (size.isNotEmpty) {
      _nameController.text = '$size $_selectedUnit $commodity Project';
    } else {
      _nameController.text = '$commodity Project';
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _updateDefaultHarvestDate();
      });
    }
  }

  Future<void> _selectHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _expectedHarvestDate ?? _startDate.add(const Duration(days: 90)),
      firstDate: _startDate,
      lastDate: DateTime(2045),
    );
    if (picked != null) {
      setState(() {
        _expectedHarvestDate = picked;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFarmId == null || _selectedFarmId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or register a farm for this project.'),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final commodity = _isCustomCommodity
        ? _commodityCustomController.text.trim()
        : _selectedCommodity;
    final variety = _varietyController.text.trim();
    final landSize = double.parse(
      _sizeController.text.replaceAll(',', '').trim(),
    );
    final description = _descriptionController.text.trim();
    final notes = _notesController.text.trim();

    final controller = ref.read(projectControllerProvider.notifier);

    if (widget.isEditing && _existingProject != null) {
      final updated = _existingProject!.copyWith(
        farmId: _selectedFarmId!,
        name: name,
        projectType: _selectedType,
        commodity: commodity,
        variety: Value(variety.isNotEmpty ? variety : null),
        landSize: landSize,
        landUnit: _selectedUnit,
        startDate: _startDate.millisecondsSinceEpoch,
        expectedFirstHarvestDate: Value(
          _expectedHarvestDate?.millisecondsSinceEpoch,
        ),
        currency: _selectedCurrency,
        description: Value(description.isNotEmpty ? description : null),
        notes: Value(notes.isNotEmpty ? notes : null),
      );

      final success = await controller.updateProject(updated);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project updated successfully.')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update project.')),
          );
        }
      }
    } else {
      final created = await controller.createProject(
        farmId: _selectedFarmId!,
        name: name,
        projectType: _selectedType,
        commodity: commodity,
        variety: variety.isNotEmpty ? variety : null,
        landSize: landSize,
        landUnit: _selectedUnit,
        startDate: _startDate.millisecondsSinceEpoch,
        expectedFirstHarvestDate: _expectedHarvestDate?.millisecondsSinceEpoch,
        currency: _selectedCurrency,
        description: description.isNotEmpty ? description : null,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (mounted) {
        if (created != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agricultural project launched successfully!'),
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to launch project.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final projectAsync = ref.watch(projectDetailProvider(widget.projectId!));
      projectAsync.whenData((project) {
        if (project != null) {
          _populateExistingProject(project);
        }
      });
    }

    final farmsAsync = ref.watch(farmsStreamProvider);
    final isOperating = ref.watch(projectControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Project' : 'New Farm Project'),
      ),
      body: SafeArea(
        child: farmsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading farms: $err')),
          data: (farms) {
            if (farms.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.landscape_outlined,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A Farm is Required',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Every agricultural venture must be tied to a registered landholding or farm property. Please register a farm first.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 48),
                        ),
                        onPressed: () => context.push(AppRoutes.createFarm),
                        icon: const Icon(Icons.add),
                        label: const Text('Register Farm First'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Default farm if none selected yet
            if (_selectedFarmId == null && farms.isNotEmpty) {
              _selectedFarmId = farms.first.id;
            }

            final commodityPresets = _getCommoditiesForType(_selectedType);
            final unitPresets = _getUnitsForType(_selectedType);

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                children: [
                  // Farm Selector Dropdown
                  DropdownButtonFormField<String>(
                    key: ValueKey('farm_$_selectedFarmId'),
                    initialValue: _selectedFarmId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Farm / Landholding *',
                      prefixIcon: Icon(Icons.landscape_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: farms.map((f) {
                      return DropdownMenuItem<String>(
                        value: f.id,
                        child: Text(
                          '${f.name} (${f.totalArea} ${f.areaUnit})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedFarmId = val);
                      }
                    },
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Select a farm' : null,
                  ),
                  const SizedBox(height: 16),

                  // Project Type Segmented Selector
                  Text(
                    'Venture Type *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: AppConstants.projectTypes.map((type) {
                      return ButtonSegment<String>(
                        value: type,
                        label: Text(type),
                      );
                    }).toList(),
                    selected: {_selectedType},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) {
                        _onTypeChanged(set.first);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Commodity Dropdown & Custom Field
                  if (_selectedType != 'Custom') ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        'commodity_${_selectedType}_$_selectedCommodity',
                      ),
                      initialValue: _selectedCommodity,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Commodity Preset *',
                        prefixIcon: Icon(Icons.eco_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ...commodityPresets.map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'Custom...',
                          child: Text(
                            'Other / Custom...',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: _onCommodityChanged,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_isCustomCommodity || _selectedType == 'Custom') ...[
                    TextFormField(
                      controller: _commodityCustomController,
                      decoration: const InputDecoration(
                        labelText: 'Commodity Name *',
                        hintText: 'e.g. Ginger, Snail, Mushroom, Turkey',
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => _suggestName(),
                      validator: (val) => InputValidators.requiredText(
                        val,
                        fieldName: 'Commodity name',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Variety / Breed (Optional)
                  TextFormField(
                    controller: _varietyController,
                    decoration: const InputDecoration(
                      labelText: 'Variety / Breed / Hybrid (Optional)',
                      hintText:
                          'e.g. Legon 18, Obatanpa, Cobb 500, Local Guinea',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Land Size / Herd Size & Unit Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _sizeController,
                          decoration: InputDecoration(
                            labelText: _selectedType == 'Livestock'
                                ? 'Flock / Herd Size *'
                                : 'Land / Production Size *',
                            hintText: 'e.g. 2.0',
                            prefixIcon: const Icon(Icons.straighten),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => _suggestName(),
                          validator: (val) => InputValidators.positiveNumber(
                            val,
                            fieldName: 'Size',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('unit_${_selectedType}_$_selectedUnit'),
                          initialValue: _selectedUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Unit *',
                            border: OutlineInputBorder(),
                          ),
                          items: unitPresets.map((u) {
                            return DropdownMenuItem<String>(
                              value: u,
                              child: Text(u, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedUnit = val;
                                _suggestName();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Project Name (Auto-suggested, user can edit)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name *',
                      hintText: 'e.g. 2-Acre Pepper Season 1',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) {
                      _userEditedName = true;
                    },
                    validator: (val) => InputValidators.requiredText(
                      val,
                      fieldName: 'Project name',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Pickers Row (Start Date & Target Harvest Date)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectStartDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              prefixIcon: Icon(Icons.calendar_month),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_startDate.toDisplayDate()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectHarvestDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Expected Harvest',
                              prefixIcon: Icon(Icons.event_available),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _expectedHarvestDate != null
                                  ? _expectedHarvestDate!.toDisplayDate()
                                  : 'Select date',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Currency Dropdown
                  DropdownButtonFormField<String>(
                    key: ValueKey('currency_$_selectedCurrency'),
                    initialValue: _selectedCurrency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Financial Currency *',
                      prefixIcon: Icon(Icons.currency_exchange),
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.supportedCurrencies.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCurrency = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description / Season Notes
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Season / Purpose Description (Optional)',
                      hintText:
                          'e.g. 2027 Major Rainy Season, for Accra wholesale market',
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Agronomic & Field Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText:
                          'Agronomic Notes / Seedlings Source (Optional)',
                      hintText:
                          'e.g. Certified seeds bought from Agri-Impact Juaboso',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 28),

                  // Submit Button (>= 48dp)
                  AppButton(
                    label: widget.isEditing
                        ? 'Update Project'
                        : 'Launch Project',
                    icon: widget.isEditing
                        ? Icons.save
                        : Icons.rocket_launch_outlined,
                    isLoading: isOperating,
                    onPressed: isOperating ? null : _saveProject,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
