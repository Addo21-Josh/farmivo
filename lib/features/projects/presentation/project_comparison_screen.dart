import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_theme_extension.dart';
import '../../../shared/widgets/app_card.dart';
import 'providers/project_comparison_providers.dart';
import 'providers/project_providers.dart';
import 'widgets/project_comparison_matrix_card.dart';

/// Screen enabling side-by-side benchmarking and comparison of active and past farm ventures (Milestone 7.5).
class ProjectComparisonScreen extends ConsumerWidget {
  const ProjectComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final allRecordsAsync = ref.watch(allProjectsComparisonProvider);
    final selectedIds = ref.watch(selectedProjectIdsForComparisonProvider);
    final matrixAsync = ref.watch(projectComparisonMatrixProvider);
    final lifecycleFilter = ref.watch(projectComparisonLifecycleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Comparison Matrix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(allProjectsComparisonProvider),
          ),
        ],
      ),
      body: allRecordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading projects: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(allProjectsComparisonProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allRecords) {
          if (allRecords.isEmpty) {
            return const Center(
              child: Text('No projects available for comparison.'),
            );
          }

          // Filter records by lifecycle toggle
          final filteredRecords = allRecords.where((r) {
            if (lifecycleFilter == 'ACTIVE') {
              return r.status.toUpperCase() != 'COMPLETED' &&
                  r.status.toUpperCase() != 'ARCHIVED';
            } else if (lifecycleFilter == 'PAST') {
              return r.status.toUpperCase() == 'COMPLETED' ||
                  r.status.toUpperCase() == 'ARCHIVED';
            }
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            children: [
              // 1. Project Selection & Filtering Controls
              AppCard(
                title: 'Select Projects to Benchmark',
                subtitle: 'Tap ventures to include in side-by-side matrix',
                leadingIcon: const Icon(Icons.checklist_rounded),
                trailingAction: TextButton.icon(
                  onPressed: () {
                    final notifier = ref.read(
                      selectedProjectIdsForComparisonProvider.notifier,
                    );
                    if (selectedIds.length == filteredRecords.length) {
                      notifier.clearSelection();
                    } else {
                      notifier.selectProjects(
                        filteredRecords.map((r) => r.projectId),
                      );
                    }
                  },
                  icon: Icon(
                    selectedIds.length == filteredRecords.length
                        ? Icons.clear_all_rounded
                        : Icons.done_all_rounded,
                    size: 16,
                  ),
                  label: Text(
                    selectedIds.length == filteredRecords.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lifecycle Stage Filter Segmented Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All Projects (${allRecords.length})',
                            isSelected: lifecycleFilter == 'ALL',
                            onSelected: () =>
                                ref
                                        .read(
                                          projectComparisonLifecycleFilterProvider
                                              .notifier,
                                        )
                                        .state =
                                    'ALL',
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Active Only',
                            isSelected: lifecycleFilter == 'ACTIVE',
                            onSelected: () {
                              ref
                                      .read(
                                        projectComparisonLifecycleFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  'ACTIVE';
                              final pwf =
                                  ref
                                      .read(projectsWithFarmStreamProvider)
                                      .value ??
                                  [];
                              ref
                                  .read(
                                    selectedProjectIdsForComparisonProvider
                                        .notifier,
                                  )
                                  .selectActiveOnly(pwf);
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Past / Completed',
                            isSelected: lifecycleFilter == 'PAST',
                            onSelected: () {
                              ref
                                      .read(
                                        projectComparisonLifecycleFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  'PAST';
                              final pwf =
                                  ref
                                      .read(projectsWithFarmStreamProvider)
                                      .value ??
                                  [];
                              ref
                                  .read(
                                    selectedProjectIdsForComparisonProvider
                                        .notifier,
                                  )
                                  .selectPastOnly(pwf);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Multi-selection Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredRecords.map((r) {
                        final isSelected = selectedIds.contains(r.projectId);
                        return FilterChip(
                          selected: isSelected,
                          showCheckmark: true,
                          selectedColor: colors.healthGreenBg,
                          label: Text(
                            r.projectName,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? colors.healthGreen : null,
                            ),
                          ),
                          onSelected: (_) {
                            ref
                                .read(
                                  selectedProjectIdsForComparisonProvider
                                      .notifier,
                                )
                                .toggleProject(r.projectId);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 2. Comparison Matrix View or Guidance Card
              matrixAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) =>
                    Center(child: Text('Error generating matrix: $e')),
                data: (matrix) {
                  if (matrix.records.length < 2) {
                    return AppCard(
                      title: 'Multi-Project Benchmarking',
                      subtitle:
                          'Side-by-side agricultural viability comparison',
                      leadingIcon: const Icon(Icons.compare_arrows_rounded),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.dividerColor.withAlpha(70),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 24,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Select at least 2 ventures to compare',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose two or more active or past farm projects from the chips above to examine side-by-side performance across land size, capital invested, gross revenue, net profit, ROI %, cycle duration, and land efficiency.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ProjectComparisonMatrixCard(matrix: matrix);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.healthGreen
              : theme.dividerColor.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
