import 'package:flutter/material.dart';

import 'package:farmivo/features/harvests/domain/models/harvest_with_details.dart';
import 'package:farmivo/features/harvests/presentation/widgets/harvest_detail_sheet.dart';

/// Reusable list tile displaying harvest batch number, commodity, date, quantity,
/// quality grade indicator badge, and storage location.
class HarvestTile extends StatelessWidget {
  final HarvestWithDetails harvest;
  final VoidCallback? onTap;

  const HarvestTile({super.key, required this.harvest, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grade = harvest.grade;

    return InkWell(
      onTap: onTap ?? () => HarvestDetailSheet.show(context, harvest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withAlpha(80)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Quality Grade Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: grade.color.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: grade.color.withAlpha(80)),
              ),
              child: Icon(grade.icon, color: grade.color, size: 22),
            ),
            const SizedBox(width: 14),

            // 2. Batch Number, Product & Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          harvest.batchNumber,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          harvest.productName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        harvest.formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Grade Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: grade.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: grade.color.withAlpha(100)),
                        ),
                        child: Text(
                          grade.shortLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: grade.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (harvest.storageLocation != null &&
                      harvest.storageLocation!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warehouse_outlined,
                            size: 13,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              harvest.storageLocation!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 3. Harvested Quantity & Photo indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  harvest.formattedQuantity,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (harvest.photoPath != null &&
                    harvest.photoPath!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 14,
                    color: theme.hintColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
