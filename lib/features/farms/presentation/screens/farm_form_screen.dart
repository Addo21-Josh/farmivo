import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/farm_providers.dart';

/// Screen for registering a new agricultural landholding or updating an existing one.
class FarmFormScreen extends ConsumerStatefulWidget {
  final String? farmId;

  const FarmFormScreen({super.key, this.farmId});

  bool get isEditing => farmId != null && farmId!.isNotEmpty;

  @override
  ConsumerState<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends ConsumerState<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _districtController;
  late final TextEditingController _totalAreaController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _notesController;

  String _selectedRegion = AppConstants.ghanaRegions.first;
  String _selectedAreaUnit = AppConstants.landUnits.first;
  String _selectedTenure = AppConstants.landTenureTypes.first;
  String? _photoPath;

  bool _initialized = false;
  Farm? _existingFarm;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _districtController = TextEditingController();
    _totalAreaController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _districtController.dispose();
    _totalAreaController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateExistingFarm(Farm farm) {
    if (_initialized) return;
    _initialized = true;
    _existingFarm = farm;

    _nameController.text = farm.name;
    _locationController.text = farm.location;
    _districtController.text = farm.district ?? '';
    _totalAreaController.text = farm.totalArea.toString();
    _latitudeController.text = farm.latitude?.toString() ?? '';
    _longitudeController.text = farm.longitude?.toString() ?? '';
    _notesController.text = farm.notes ?? '';

    if (AppConstants.ghanaRegions.contains(farm.region)) {
      _selectedRegion = farm.region;
    } else if (AppConstants.ghanaRegions.isNotEmpty) {
      _selectedRegion = AppConstants.ghanaRegions.first;
    }

    if (AppConstants.landUnits.contains(farm.areaUnit)) {
      _selectedAreaUnit = farm.areaUnit;
    }

    if (AppConstants.landTenureTypes.contains(farm.ownershipType)) {
      _selectedTenure = farm.ownershipType;
    }

    _photoPath = farm.photoPath;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (picked != null) {
        setState(() {
          _photoPath = picked.path;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to access camera/gallery: ${e.message}'),
          ),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _photoPath = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final district = _districtController.text.trim();
    final totalArea = double.parse(
      _totalAreaController.text.replaceAll(',', '').trim(),
    );
    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    final notes = _notesController.text.trim();

    final controller = ref.read(farmControllerProvider.notifier);

    if (widget.isEditing && _existingFarm != null) {
      final updated = _existingFarm!.copyWith(
        name: name,
        location: location,
        district: Value(district.isNotEmpty ? district : null),
        region: _selectedRegion,
        totalArea: totalArea,
        areaUnit: _selectedAreaUnit,
        ownershipType: _selectedTenure,
        latitude: Value(lat),
        longitude: Value(lng),
        notes: Value(notes.isNotEmpty ? notes : null),
        photoPath: Value(_photoPath),
      );

      final success = await controller.updateFarm(updated);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Farm updated successfully.')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update farm. Please try again.'),
            ),
          );
        }
      }
    } else {
      final created = await controller.createFarm(
        name: name,
        location: location,
        district: district.isNotEmpty ? district : null,
        region: _selectedRegion,
        totalArea: totalArea,
        areaUnit: _selectedAreaUnit,
        ownershipType: _selectedTenure,
        latitude: lat,
        longitude: lng,
        notes: notes.isNotEmpty ? notes : null,
        photoPath: _photoPath,
      );

      if (mounted) {
        if (created != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Farm registered successfully!')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create farm. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final farmAsync = ref.watch(farmDetailProvider(widget.farmId!));
      farmAsync.whenData((farm) {
        if (farm != null) {
          _populateExistingFarm(farm);
        }
      });
    }

    final isOperating = ref.watch(farmControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Farm' : 'Register Farm'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            children: [
              // Photo attachment header
              Center(
                child: GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withAlpha(80),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                    ),
                    child: _photoPath != null && File(_photoPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Farm Photo (Optional)',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to take photo or choose from gallery',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Farm Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Farm Name *',
                  hintText: 'e.g. Juaboso Valley Farm',
                  prefixIcon: Icon(Icons.agriculture_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) =>
                    InputValidators.requiredText(val, fieldName: 'Farm name'),
              ),
              const SizedBox(height: 16),

              // Location / Community / Town
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location / Town / Village *',
                  hintText: 'e.g. Juaboso Nkwanta',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) =>
                    InputValidators.requiredText(val, fieldName: 'Location'),
              ),
              const SizedBox(height: 16),

              // District (Optional)
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District (Optional)',
                  hintText: 'e.g. Juaboso District',
                  prefixIcon: Icon(Icons.map_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Region Dropdown (16 Ghanaian regions)
              DropdownButtonFormField<String>(
                key: ValueKey('region_$_selectedRegion'),
                initialValue: _selectedRegion,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Region *',
                  prefixIcon: Icon(Icons.public),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.ghanaRegions.map((region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRegion = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Total Area & Unit Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _totalAreaController,
                      decoration: const InputDecoration(
                        labelText: 'Total Land Area *',
                        hintText: 'e.g. 5.5',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => InputValidators.positiveNumber(
                        val,
                        fieldName: 'Total land area',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('unit_$_selectedAreaUnit'),
                      initialValue: _selectedAreaUnit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.landUnits.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedAreaUnit = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Land Tenure / Ownership Model Dropdown
              DropdownButtonFormField<String>(
                key: ValueKey('tenure_$_selectedTenure'),
                initialValue: _selectedTenure,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Ownership / Land Tenure Model *',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.landTenureTypes.map((tenure) {
                  return DropdownMenuItem<String>(
                    value: tenure,
                    child: Text(tenure, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedTenure = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // GPS Coordinates Row (Optional)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude (Optional)',
                        hintText: 'e.g. 6.3456',
                        prefixIcon: Icon(Icons.my_location),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: InputValidators.latitude,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude (Optional)',
                        hintText: 'e.g. -2.8234',
                        prefixIcon: Icon(Icons.my_location),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: InputValidators.longitude,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes / Landmark Observations
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes / Landmarks (Optional)',
                  hintText:
                      'e.g. Near the main stream, sandy loam soil, bordered by cocoa farms',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 28),

              // Save Button (>= 48dp)
              AppButton(
                label: widget.isEditing ? 'Update Farm' : 'Register Farm',
                icon: widget.isEditing ? Icons.save : Icons.add_business,
                isLoading: isOperating,
                onPressed: isOperating ? null : _saveFarm,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
