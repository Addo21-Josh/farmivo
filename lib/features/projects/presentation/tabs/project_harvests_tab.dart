import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farmivo/app/router/routes.dart';
import 'package:farmivo/app/theme/app_theme_extension.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/harvests.dart';
import 'package:farmivo/features/projects/domain/models/project_metrics.dart';
import 'package:farmivo/shared/widgets/app_card.dart';

/// Sub-navigation tab presenting harvest yields, quality grade breakdowns,
/// storage allocations, and batch inventory.
class ProjectHarvestsTab extends ConsumerWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectHarvestsTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final summaryAsync = ref.watch(projectYieldSummaryProvider(project.id));
    final harvestsAsync = ref.watch(
      projectHarvestsWithDetailsProvider(project.id),
    );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 60),
      children: [
        // 1. Harvest Yield Summary & Quality Metrics Card
        summaryAsync.when(
          data: (summary) => HarvestYieldCard(summary: summary),
          loading: () => AppCard(
            title: 'Total Harvest Production',
            subtitle: 'Calculating yield summary...',
            leadingIcon: const Icon(Icons.inventory_2_outlined),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading harvest summary: $err'),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Action Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Harvest Inventory Lots',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () => context.push(
                  '${AppRoutes.addHarvest}?projectId=${project.id}',
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Batch'),
              ),
            ],
          ),
        ),

        // 3. Harvest Batches List
        harvestsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading harvests: $err'),
          ),
          data: (harvests) {
            if (harvests.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: colors.healthGreen.withAlpha(160),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Harvest Batches Recorded',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Log harvest output by quantity, grade, and storage location as harvesting starts.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 48),
                      ),
                      onPressed: () => context.push(
                        '${AppRoutes.addHarvest}?projectId=${project.id}',
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Record Harvest Batch'),
                    ),
                  ],
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withAlpha(120),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: harvests.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final h = harvests[index];
                    return HarvestTile(harvest: h);
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
