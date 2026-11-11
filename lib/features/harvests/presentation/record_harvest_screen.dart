import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:farmivo/core/extensions/date_time_extensions.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';
import 'package:farmivo/features/harvests/presentation/providers/harvest_providers.dart';
import 'package:farmivo/features/projects/presentation/providers/project_providers.dart';
import 'package:farmivo/shared/widgets/app_button.dart';

/// Form screen for logging physical crop harvest inventory lots,
/// assigning quality grades, recording storage facilities, and capturing lot photos.
class RecordHarvestScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;

  const RecordHarvestScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<RecordHarvestScreen> createState() =>
      _RecordHarvestScreenState();
}

class _RecordHarvestScreenState extends ConsumerState<RecordHarvestScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProjectId;
  String? _selectedCommodity;
  DateTime _harvestDate = DateTime.now();
  HarvestGrade _selectedGrade = HarvestGrade.gradeA;
  String? _photoPath;
  bool _isAutoBatch = true;

  final _productNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: '50kg Bag');
  final _storageLocationController = TextEditingController();
  final _notesController = TextEditingController();

  static const _standardUnits = [
    '50kg Bag',
    '100kg Bag',
    'kg',
    'Crate',
    'Basket',
    'Tonne',
  ];

  static const _storageSuggestions = [
    'Main Barn',
    'Silo 1',
    'Cold Room',
    'Packhouse',
    'Field Shed',
    'Grain Store',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.initialProjectId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProjectAndBatch();
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _batchNumberController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _storageLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeProjectAndBatch() async {
    final projects = await ref.read(projectsStreamProvider.future);
    if (!mounted || projects.isEmpty) return;

    Project? currentProject;
    if (_selectedProjectId != null) {
      currentProject = projects
          .where((p) => p.id == _selectedProjectId)
          .firstOrNull;
    }
    currentProject ??= projects.first;

    setState(() {
      _selectedProjectId = currentProject!.id;
      _selectedCommodity = currentProject.commodity;
      if (_productNameController.text.trim().isEmpty) {
        _productNameController.text = currentProject.commodity;
      }
    });

    await _regenerateBatchNumber();
  }

  Future<void> _regenerateBatchNumber() async {
    if (_selectedProjectId == null) return;
    final generated = await ref
        .read(harvestControllerProvider.notifier)
        .generateNextBatchNumber(
          _selectedProjectId!,
          commodity: _selectedCommodity ?? _productNameController.text,
          date: _harvestDate,
        );
    if (mounted) {
      setState(() {
        _batchNumberController.text = generated;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _harvestDate = picked;
      });
      if (_isAutoBatch) {
        await _regenerateBatchNumber();
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (picked != null && mounted) {
        setState(() {
          _photoPath = picked.path;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: ${e.message}')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo with Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farm project.')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid harvest quantity.')),
      );
      return;
    }

    final id = await ref
        .read(harvestControllerProvider.notifier)
        .recordHarvest(
          projectId: _selectedProjectId!,
          batchNumber: _batchNumberController.text.trim().isNotEmpty
              ? _batchNumberController.text.trim()
              : null,
          harvestDate: _harvestDate,
          productName: _productNameController.text.trim(),
          quantity: quantity,
          unit: _unitController.text.trim(),
          grade: _selectedGrade,
          storageLocation: _storageLocationController.text.trim().isNotEmpty
              ? _storageLocationController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          photoPath: _photoPath,
        );

    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harvest batch "${_batchNumberController.text}" logged successfully.',
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
    final isSaving = ref.watch(harvestControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Record Harvest Batch')),
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
                return DropdownButtonFormField<String>(
                  initialValue: _selectedProjectId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.agriculture_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: projects.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        '${p.name} (${p.commodity})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null && newId != _selectedProjectId) {
                      final project = projects.firstWhere((p) => p.id == newId);
                      setState(() {
                        _selectedProjectId = newId;
                        _selectedCommodity = project.commodity;
                        if (_productNameController.text.isEmpty ||
                            _productNameController.text == _selectedCommodity) {
                          _productNameController.text = project.commodity;
                        }
                      });
                      if (_isAutoBatch) {
                        _regenerateBatchNumber();
                      }
                    }
                  },
                  validator: (v) =>
                      v == null ? 'Please select a project' : null,
                );
              },
            ),
            const SizedBox(height: 18),

            // 2. Produce / Commodity Name
            Text(
              'Produce / Commodity Name *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Yellow Maize, Habanero Pepper, Cassava',
                prefixIcon: Icon(Icons.grass_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter the produce name';
                }
                return null;
              },
              onChanged: (_) {
                if (_isAutoBatch) {
                  _regenerateBatchNumber();
                }
              },
            ),
            const SizedBox(height: 18),

            // 3. Batch Number & Refresh
            Text(
              'Batch / Lot Number *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _batchNumberController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. HV-MAI-2611-01',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      _isAutoBatch = false;
                    },
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Batch number cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Regenerate Batch Number',
                  onPressed: () {
                    _isAutoBatch = true;
                    _regenerateBatchNumber();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Harvest Date
            Text(
              'Harvest Date *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _harvestDate.toDisplayDate(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 5. Quantity & Unit
            Text(
              'Harvest Quantity & Unit *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity Field
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.0',
                      prefixIcon: Icon(Icons.scale_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Required';
                      }
                      final d = double.tryParse(v.trim());
                      if (d == null || d <= 0) {
                        return 'Must be > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Custom Unit Field
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      hintText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Unit required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick Unit Chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _standardUnits.map((u) {
                final isSelected = _unitController.text.trim() == u;
                return ChoiceChip(
                  label: Text(u),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _unitController.text = u;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 6. Quality Grade Selector
            Text(
              'Quality Grade *',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HarvestGrade.values.map((grade) {
                final isSelected = _selectedGrade == grade;
                return ChoiceChip(
                  avatar: Icon(
                    grade.icon,
                    size: 16,
                    color: isSelected ? Colors.white : grade.color,
                  ),
                  label: Text(
                    grade.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: grade.color,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedGrade = grade);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 7. Storage Facility / Location
            Text(
              'Storage Facility / Location',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _storageLocationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Main Barn, Silo 1, Cold Room',
                prefixIcon: Icon(Icons.warehouse_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _storageSuggestions.map((loc) {
                return ActionChip(
                  avatar: const Icon(Icons.add, size: 14),
                  label: Text(loc),
                  onPressed: () {
                    setState(() {
                      _storageLocationController.text = loc;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 8. Field Notes / Remarks
            Text(
              'Field Notes / Observations',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Harvested during dry morning; moisture level tested at 13%.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),

            // 9. Photo Attachment
            Text(
              'Photo Documentation (Optional)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_photoPath != null && _photoPath!.isNotEmpty) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_photoPath!),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() => _photoPath = null);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _photoPath != null
                    ? 'Change Harvest Photo'
                    : 'Attach Harvest Photo',
              ),
            ),
            const SizedBox(height: 32),

            // 10. Submit Button
            AppButton(
              label: 'Save Harvest Batch',
              icon: Icons.check,
              isLoading: isSaving,
              onPressed: isSaving ? null : _submit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
