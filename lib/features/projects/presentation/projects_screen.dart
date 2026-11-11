import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../domain/models/project_with_farm.dart';
import 'providers/project_providers.dart';
import 'widgets/project_card.dart';

/// Screen listing all agricultural projects across farms.
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatusFilter;
  String? _selectedTypeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(ProjectWithFarm projectWithFarm) {
    final project = projectWithFarm.project;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${project.name}"?'),
        content: const Text(
          'Are you sure you want to delete this project? Financial records and logged expenses will be preserved in archived records.',
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
                  .deleteProject(project.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Project "${project.name}" deleted.'
                        : 'Failed to delete project.',
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsWithFarmStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Compare Projects',
            onPressed: () => context.push(AppRoutes.projectComparison),
          ),
          IconButton(
            icon: const Icon(Icons.landscape_outlined),
            tooltip: 'My Farms',
            onPressed: () => context.push(AppRoutes.farms),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Project',
            onPressed: () => context.push(AppRoutes.createProject),
          ),
        ],
      ),
      body: projectsAsync.when(
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
                onPressed: () => ref.refresh(projectsWithFarmStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyProjectsView(
              onCreateProject: () => context.push(AppRoutes.createProject),
              onManageFarms: () => context.push(AppRoutes.farms),
            );
          }

          // Filter by search query
          final filteredProjects = projects.where((pwf) {
            final p = pwf.project;
            final f = pwf.farm;

            final matchesQuery =
                _searchQuery.isEmpty ||
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.commodity.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (p.variety != null &&
                    p.variety!.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    )) ||
                (f != null &&
                    f.name.toLowerCase().contains(_searchQuery.toLowerCase()));

            final matchesStatus =
                _selectedStatusFilter == null ||
                p.status.toUpperCase() == _selectedStatusFilter!.toUpperCase();

            final matchesType =
                _selectedTypeFilter == null ||
                p.projectType.toUpperCase() ==
                    _selectedTypeFilter!.toUpperCase();

            return matchesQuery && matchesStatus && matchesType;
          }).toList();

          // Aggregate statistics
          final totalCount = projects.length;
          final cropCount = projects
              .where((p) => p.project.projectType == 'Crop')
              .length;
          final livestockCount = projects
              .where((p) => p.project.projectType == 'Livestock')
              .length;

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            children: [
              // Summary Banner Card
              AppCard(
                title: 'Projects Summary',
                leadingIcon: const Icon(Icons.hub_outlined),
                trailingAction: TextButton.icon(
                  onPressed: () => context.push(AppRoutes.projectComparison),
                  icon: const Icon(Icons.table_chart_outlined, size: 16),
                  label: const Text('Compare'),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Projects',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalCount ${totalCount == 1 ? 'Project' : 'Projects'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crops / Livestock',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$cropCount Crops • $livestockCount Livestock',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search & Filter Box
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search projects by commodity, variety, farm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
              ),

              // Type Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Types'),
                      selected: _selectedTypeFilter == null,
                      onSelected: (_) =>
                          setState(() => _selectedTypeFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Crops'),
                      selected: _selectedTypeFilter == 'Crop',
                      onSelected: (val) => setState(
                        () => _selectedTypeFilter = val ? 'Crop' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Livestock'),
                      selected: _selectedTypeFilter == 'Livestock',
                      onSelected: (val) => setState(
                        () => _selectedTypeFilter = val ? 'Livestock' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Aquaculture'),
                      selected: _selectedTypeFilter == 'Aquaculture',
                      onSelected: (val) => setState(
                        () => _selectedTypeFilter = val ? 'Aquaculture' : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Stages'),
                      selected: _selectedStatusFilter == null,
                      onSelected: (_) =>
                          setState(() => _selectedStatusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Planning'),
                      selected: _selectedStatusFilter == 'PLANNING',
                      onSelected: (val) => setState(
                        () => _selectedStatusFilter = val ? 'PLANNING' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Active'),
                      selected: _selectedStatusFilter == 'ACTIVE',
                      onSelected: (val) => setState(
                        () => _selectedStatusFilter = val ? 'ACTIVE' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Harvesting'),
                      selected: _selectedStatusFilter == 'HARVESTING',
                      onSelected: (val) => setState(
                        () => _selectedStatusFilter = val ? 'HARVESTING' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Completed'),
                      selected: _selectedStatusFilter == 'COMPLETED',
                      onSelected: (val) => setState(
                        () => _selectedStatusFilter = val ? 'COMPLETED' : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              if (filteredProjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No projects match your search filters.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredProjects.map(
                  (projectWithFarm) => ProjectCard(
                    projectWithFarm: projectWithFarm,
                    onTap: () =>
                        context.push('/projects/${projectWithFarm.project.id}'),
                    onEdit: () => context.push(
                      '/projects/${projectWithFarm.project.id}/edit',
                    ),
                    onDelete: () => _confirmDelete(projectWithFarm),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.createProject),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}

class _EmptyProjectsView extends StatelessWidget {
  final VoidCallback onCreateProject;
  final VoidCallback onManageFarms;

  const _EmptyProjectsView({
    required this.onCreateProject,
    required this.onManageFarms,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF16A34A), width: 2),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 64,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Projects Yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Launch your first crop, livestock, or aquaculture project to start tracking pre-season budgets, actual operational expenses, and sales.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
              onPressed: onCreateProject,
              icon: const Icon(Icons.add_task),
              label: const Text('Create First Project'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(220, 48)),
              onPressed: onManageFarms,
              icon: const Icon(Icons.landscape_outlined),
              label: const Text('Manage Farms & Land'),
            ),
          ],
        ),
      ),
    );
  }
}
