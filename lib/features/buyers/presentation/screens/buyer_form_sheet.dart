import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/shared/widgets/app_button.dart';

/// Modal bottom sheet for registering a new commercial buyer or editing an existing customer profile.
class BuyerFormSheet extends ConsumerStatefulWidget {
  final Buyer? buyerToEdit;

  const BuyerFormSheet({super.key, this.buyerToEdit});

  static Future<String?> show(
    BuildContext context, {
    BuyerSummary? buyerToEdit,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BuyerFormSheet(buyerToEdit: buyerToEdit?.buyer),
    );
  }

  @override
  ConsumerState<BuyerFormSheet> createState() => _BuyerFormSheetState();
}

class _BuyerFormSheetState extends ConsumerState<BuyerFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _businessController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.buyerToEdit != null;

  @override
  void initState() {
    super.initState();
    final b = widget.buyerToEdit;
    _nameController = TextEditingController(text: b?.name ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _businessController = TextEditingController(text: b?.businessName ?? '');
    _locationController = TextEditingController(text: b?.location ?? '');
    _notesController = TextEditingController(text: b?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final business = _businessController.text.trim();
    final location = _locationController.text.trim();
    final notes = _notesController.text.trim();

    if (_isEditing) {
      final success = await ref
          .read(buyerControllerProvider.notifier)
          .updateBuyer(
            id: widget.buyerToEdit!.id,
            name: name,
            phone: phone.isNotEmpty ? phone : null,
            businessName: business.isNotEmpty ? business : null,
            location: location.isNotEmpty ? location : null,
            notes: notes.isNotEmpty ? notes : null,
          );

      if (success && mounted) {
        Navigator.of(context).pop(widget.buyerToEdit!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "$name" updated successfully.'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } else {
      final id = await ref
          .read(buyerControllerProvider.notifier)
          .createBuyer(
            name: name,
            phone: phone.isNotEmpty ? phone : null,
            businessName: business.isNotEmpty ? business : null,
            location: location.isNotEmpty ? location : null,
            notes: notes.isNotEmpty ? notes : null,
          );

      if (id != null && mounted) {
        Navigator.of(context).pop(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "$name" added to directory.'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSaving = ref.watch(buyerControllerProvider).isLoading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Customer Profile' : 'Add New Customer',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // 1. Full Name
              Text(
                'Full Name *',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Mama Beatrice Osei, Kwame Mensah',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Phone Number
              Text(
                'Phone Number',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'e.g. 024 123 4567, +233 50 987 6543',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Business / Stall Name
              Text(
                'Business / Market Stall Name',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _businessController,
                decoration: const InputDecoration(
                  hintText: 'e.g. AgroTrade Ltd, Stall #14 Vegetables',
                  prefixIcon: Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Market / Town Location
              Text(
                'Market / Town Location',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Makola Market, Accra; Techiman Market',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Notes / Terms
              Text(
                'Credit Terms & Notes',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Pays 50% upfront, remainder within 14 days.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 6. Submit Button
              AppButton(
                label: _isEditing
                    ? 'Save Profile Changes'
                    : 'Add to Customer Directory',
                icon: Icons.check,
                isLoading: isSaving,
                onPressed: isSaving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
