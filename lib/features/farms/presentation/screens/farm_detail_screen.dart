import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../providers/farm_providers.dart';

/// Comprehensive detail view for an individual farm holding.
class FarmDetailScreen extends ConsumerWidget {
  final String farmId;

  const FarmDetailScreen({super.key, required this.farmId});

  void _confirmDelete(BuildContext context, WidgetRef ref, int projectCount) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Farm?'),
        content: Text(
          projectCount > 0
              ? 'This farm has $projectCount active project(s) assigned to it. Deleting this farm will archive the landholding record while preserving historical project records.'
              : 'Are you sure you want to delete this farm? This action can be undone from archived records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(farmControllerProvider.notifier)
                  .deleteFarm(farmId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Farm removed successfully.')),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete farm.')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmAsync = ref.watch(farmDetailProvider(farmId));
    final projectCountAsync = ref.watch(farmProjectsCountProvider(farmId));
    final allocatedAreaAsync = ref.watch(farmAllocatedAreaProvider(farmId));

    return farmAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Farm Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Farm Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading farm: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      data: (farm) {
        if (farm == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Farm Details')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Farm not found or has been removed.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Return to Farms'),
                  ),
                ],
              ),
            ),
          );
        }

        final projectCount = projectCountAsync.valueOrNull ?? 0;
        final allocatedArea = allocatedAreaAsync.valueOrNull ?? 0.0;
        final remainingArea = (farm.totalArea - allocatedArea).clamp(
          0.0,
          farm.totalArea,
        );
        final districtText = farm.district != null && farm.district!.isNotEmpty
            ? '${farm.district}, '
            : '';

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(farm.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Farm',
                onPressed: () => context.push('/farms/$farmId/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Farm',
                onPressed: () => _confirmDelete(context, ref, projectCount),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // Photo Header or Nature Banner
              if (farm.photoPath != null &&
                  farm.photoPath!.isNotEmpty &&
                  File(farm.photoPath!).existsSync())
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.file(File(farm.photoPath!), fit: BoxFit.cover),
                )
              else
                Container(
                  height: 140,
                  width: double.infinity,
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          farm.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Overview Details Card
              AppCard(
                title: 'Landholding Overview',
                subtitle: '$districtText${farm.region}, ${farm.country}',
                leadingIcon: const Icon(Icons.landscape_outlined),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Land Tenure',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AppStatusBadge.fromTenure(
                              context,
                              farm.ownershipType,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Size',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${farm.totalArea.toStringAsFixed(farm.totalArea.truncateToDouble() == farm.totalArea ? 0 : 1)} ${farm.areaUnit}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailStat(
                            label: 'Active Projects',
                            value: '$projectCount',
                            icon: Icons.assignment_outlined,
                          ),
                        ),
                        Expanded(
                          child: _DetailStat(
                            label: 'Allocated Area',
                            value:
                                '${allocatedArea.toStringAsFixed(1)} ${farm.areaUnit}',
                            icon: Icons.pie_chart_outline,
                          ),
                        ),
                        Expanded(
                          child: _DetailStat(
                            label: 'Available Land',
                            value:
                                '${remainingArea.toStringAsFixed(1)} ${farm.areaUnit}',
                            icon: Icons.crop_free,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Location & Coordinates Card
              AppCard(
                title: 'Geographic Location',
                subtitle: farm.location,
                leadingIcon: const Icon(Icons.pin_drop_outlined),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFDBEAFE),
                        child: Icon(
                          Icons.my_location,
                          color: Color(0xFF1D4ED8),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        farm.latitude != null && farm.longitude != null
                            ? 'GPS: ${farm.latitude!.toStringAsFixed(5)}, ${farm.longitude!.toStringAsFixed(5)}'
                            : 'GPS Coordinates not recorded',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        farm.latitude != null && farm.longitude != null
                            ? 'Accurate location stored for field navigation'
                            : 'Edit farm to record latitude and longitude',
                      ),
                    ),
                  ],
                ),
              ),

              // Notes Card if available
              if (farm.notes != null && farm.notes!.isNotEmpty)
                AppCard(
                  title: 'Field Notes & Soil Characteristics',
                  leadingIcon: const Icon(Icons.notes_outlined),
                  child: Text(farm.notes!, style: theme.textTheme.bodyMedium),
                ),

              const SizedBox(height: 12),

              // Launch Project Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AppButton(
                  label: 'Launch Project on this Farm',
                  icon: Icons.add_task,
                  onPressed: () {
                    // Navigate to project creation pre-selecting this farm
                    context.push('${AppRoutes.createProject}?farmId=$farmId');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
