import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';

/// Outdoor high-contrast card representing an agricultural landholding.
class FarmCard extends StatelessWidget {
  final Farm farm;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FarmCard({
    super.key,
    required this.farm,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final districtText = farm.district != null && farm.district!.isNotEmpty
        ? ', ${farm.district}'
        : '';
    final locationSubtitle = '${farm.location}$districtText • ${farm.region}';

    Widget leadingWidget;
    if (farm.photoPath != null && farm.photoPath!.isNotEmpty) {
      final file = File(farm.photoPath!);
      if (file.existsSync()) {
        leadingWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultIcon(context),
          ),
        );
      } else {
        leadingWidget = _defaultIcon(context);
      }
    } else {
      leadingWidget = _defaultIcon(context);
    }

    return AppCard(
      title: farm.name,
      subtitle: locationSubtitle,
      leadingIcon: leadingWidget,
      onTap: onTap,
      trailingAction: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Farm actions',
        onSelected: (value) {
          if (value == 'edit') {
            onEdit?.call();
          } else if (value == 'delete') {
            onDelete?.call();
          }
        },
        itemBuilder: (ctx) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(width: 8),
                Text('Edit Farm'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Farm', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tenure badge
              AppStatusBadge.fromTenure(context, farm.ownershipType),

              // Area chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    120,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.straighten, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${farm.totalArea.toStringAsFixed(farm.totalArea.truncateToDouble() == farm.totalArea ? 0 : 1)} ${farm.areaUnit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (farm.notes != null && farm.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              farm.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(180),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _defaultIcon(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.agriculture, color: Color(0xFF15803D), size: 26),
    );
  }
}
