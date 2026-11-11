import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/presentation/providers/harvest_providers.dart';
import 'package:farmivo/shared/widgets/app_button.dart';

/// Modal bottom sheet presenting in-depth details of a harvest lot,
/// its quality grade, storage location, notes, and deletion options.
class HarvestDetailSheet extends ConsumerWidget {
  final HarvestWithDetails harvest;

  const HarvestDetailSheet({super.key, required this.harvest});

  static Future<void> show(BuildContext context, HarvestWithDetails harvest) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HarvestDetailSheet(harvest: harvest),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Harvest Lot?'),
        content: Text(
          'Are you sure you want to remove batch "${harvest.batchNumber}" (${harvest.formattedQuantity}) from harvest inventory records?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete Batch'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(harvestControllerProvider.notifier)
          .deleteHarvest(harvest.id);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Harvest batch deleted successfully'
                  : 'Failed to delete harvest batch',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final grade = harvest.grade;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle
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

              // 2. Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: grade.color.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: grade.color.withAlpha(100)),
                    ),
                    child: Icon(grade.icon, color: grade.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          harvest.batchNumber,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          harvest.productName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // 3. Badges Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Grade Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: grade.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: grade.color.withAlpha(120)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(grade.icon, size: 14, color: grade.color),
                        const SizedBox(width: 5),
                        Text(
                          grade.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: grade.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Project Badge
                  if (harvest.project != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.agriculture_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            harvest.projectName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Primary Detail Metrics
              _buildDetailRow(
                context,
                icon: Icons.scale_outlined,
                label: 'Harvested Volume',
                value: harvest.formattedQuantity,
                isEmphasized: true,
              ),
              const SizedBox(height: 14),

              _buildDetailRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Harvest Date',
                value: harvest.formattedDate,
              ),
              const SizedBox(height: 14),

              _buildDetailRow(
                context,
                icon: Icons.warehouse_outlined,
                label: 'Storage Facility',
                value: harvest.storageLocation?.isNotEmpty == true
                    ? harvest.storageLocation!
                    : 'Not Specified (Unallocated)',
              ),
              const SizedBox(height: 16),

              // 5. Notes Section
              if (harvest.notes != null && harvest.notes!.isNotEmpty) ...[
                const Divider(height: 20),
                Text(
                  'Harvest Notes / Quality Remarks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      120,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    harvest.notes!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 6. Photo Attachment
              if (harvest.photoPath != null &&
                  harvest.photoPath!.isNotEmpty) ...[
                const Divider(height: 20),
                Text(
                  'Photo Documentation',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(harvest.photoPath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Photo file not found on device'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Divider(height: 24),

              // 7. Action Button
              Center(
                child: AppButton(
                  label: 'Delete Harvest Batch',
                  variant: AppButtonVariant.destructive,
                  icon: Icons.delete_outline,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isEmphasized = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: isEmphasized
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    )
                  : theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
