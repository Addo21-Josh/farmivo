import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/database/app_database.dart';
import '../domain/models/project_metrics.dart';
import 'providers/project_providers.dart';
import 'tabs/project_activities_tab.dart';
import 'tabs/project_budget_tab.dart';
import 'tabs/project_expenses_tab.dart';
import 'tabs/project_financials_tab.dart';
import 'tabs/project_harvests_tab.dart';
import 'tabs/project_overview_tab.dart';
import 'tabs/project_sales_tab.dart';
import 'widgets/project_status_transition_dialog.dart';
import 'widgets/project_vital_metrics_header.dart';

/// Central management hub and multi-tab operational overview for an agricultural project.
///
/// Houses vital metrics at the top and sub-navigation across:
/// 1. Overview
/// 2. Budget
/// 3. Expenses
/// 4. Activities
/// 5. Harvests
/// 6. Sales
/// 7. Financials
class ProjectDetailsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  void _confirmDelete(BuildContext context, WidgetRef ref, Project project) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${project.name}"?'),
        content: const Text(
          'Are you sure you want to remove this project? Logged records and expense archives will be preserved safely.',
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
                  .read(projectControllerProvider.notifier)
                  .deleteProject(projectId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project removed successfully.'),
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete project.')),
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
    final theme = Theme.of(context);
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final metricsAsync = ref.watch(projectMetricsProvider(projectId));

    return projectAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Project Hub')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Project Hub')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading project: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project Hub')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Project not found or has been removed.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Return to Projects'),
                  ),
                ],
              ),
            ),
          );
        }

        // Live computed metrics with immediate fallback
        final metrics =
            metricsAsync.valueOrNull ??
            ProjectMetrics.compute(
              project: project,
              budgetItems: const [],
              expenses: const [],
              activities: const [],
              harvests: const [],
              sales: const [],
            );

        return DefaultTabController(
          length: 7,
          child: Scaffold(
            appBar: AppBar(
              title: Text(project.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.alt_route),
                  tooltip: 'Change Stage',
                  onPressed: () => ProjectStatusTransitionDialog.show(
                    context,
                    project: project,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Project',
                  onPressed: () => context.push('/projects/$projectId/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Project',
                  onPressed: () => _confirmDelete(context, ref, project),
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: ProjectVitalMetricsHeader(
                      project: project,
                      metrics: metrics,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: theme.colorScheme.primary,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.textTheme.bodyMedium?.color
                            ?.withAlpha(160),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.dashboard_outlined),
                            text: 'Overview',
                          ),
                          Tab(
                            icon: Icon(Icons.calculate_outlined),
                            text: 'Budget',
                          ),
                          Tab(
                            icon: Icon(Icons.receipt_long_outlined),
                            text: 'Expenses',
                          ),
                          Tab(
                            icon: Icon(Icons.agriculture_outlined),
                            text: 'Activities',
                          ),
                          Tab(
                            icon: Icon(Icons.inventory_2_outlined),
                            text: 'Harvests',
                          ),
                          Tab(
                            icon: Icon(Icons.point_of_sale_outlined),
                            text: 'Sales',
                          ),
                          Tab(
                            icon: Icon(Icons.trending_up_outlined),
                            text: 'Financials',
                          ),
                        ],
                      ),
                      backgroundColor: theme.scaffoldBackgroundColor,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  ProjectOverviewTab(project: project, metrics: metrics),
                  ProjectBudgetTab(project: project, metrics: metrics),
                  ProjectExpensesTab(project: project, metrics: metrics),
                  ProjectActivitiesTab(project: project, metrics: metrics),
                  ProjectHarvestsTab(project: project, metrics: metrics),
                  ProjectSalesTab(project: project, metrics: metrics),
                  ProjectFinancialsTab(project: project, metrics: metrics),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this._tabBar, {required this.backgroundColor});

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
