import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/farm_providers.dart';
import '../widgets/farm_card.dart';

/// Screen listing all user landholdings and farm properties.
class FarmsScreen extends ConsumerStatefulWidget {
  const FarmsScreen({super.key});

  @override
  ConsumerState<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends ConsumerState<FarmsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTenureFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(Farm farm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${farm.name}"?'),
        content: const Text(
          'Are you sure you want to remove this farm? Existing project records will remain archived safely.',
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
                  .deleteFarm(farm.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Farm "${farm.name}" deleted.'
                        : 'Failed to delete farm.',
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
    final farmsAsync = ref.watch(farmsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farms & Landholdings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register Farm',
            onPressed: () => context.push(AppRoutes.createFarm),
          ),
        ],
      ),
      body: farmsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading farms: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(farmsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (farms) {
          if (farms.isEmpty) {
            return _EmptyFarmsView(
              onAddFarm: () => context.push(AppRoutes.createFarm),
            );
          }

          // Filter by search query
          final filteredFarms = farms.where((farm) {
            final matchesQuery =
                _searchQuery.isEmpty ||
                farm.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                farm.location.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (farm.district != null &&
                    farm.district!.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    )) ||
                farm.region.toLowerCase().contains(_searchQuery.toLowerCase());

            final matchesTenure =
                _selectedTenureFilter == null ||
                farm.ownershipType.toLowerCase().contains(
                  _selectedTenureFilter!.toLowerCase(),
                );

            return matchesQuery && matchesTenure;
          }).toList();

          // Aggregate statistics
          final totalFarms = farms.length;
          final totalArea = farms.fold<double>(
            0.0,
            (sum, f) => sum + f.totalArea,
          );

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            children: [
              // Summary Banner Card
              AppCard(
                title: 'Landholdings Summary',
                leadingIcon: const Icon(Icons.terrain_outlined),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Farms',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalFarms ${totalFarms == 1 ? 'Farm' : 'Farms'}',
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
                            'Total Area',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${totalArea.toStringAsFixed(1)} Total Acres',
                            style: const TextStyle(
                              fontSize: 18,
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
                    hintText: 'Search farms by name, location, region...',
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

              // Tenure Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedTenureFilter == null,
                      onSelected: (_) =>
                          setState(() => _selectedTenureFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Owned'),
                      selected: _selectedTenureFilter == 'Owned',
                      onSelected: (val) => setState(
                        () => _selectedTenureFilter = val ? 'Owned' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Family Land'),
                      selected: _selectedTenureFilter == 'Family',
                      onSelected: (val) => setState(
                        () => _selectedTenureFilter = val ? 'Family' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Rented'),
                      selected: _selectedTenureFilter == 'Rented',
                      onSelected: (val) => setState(
                        () => _selectedTenureFilter = val ? 'Rented' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Leased'),
                      selected: _selectedTenureFilter == 'Leased',
                      onSelected: (val) => setState(
                        () => _selectedTenureFilter = val ? 'Leased' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Abunu / Abusa'),
                      selected: _selectedTenureFilter == 'Shared',
                      onSelected: (val) => setState(
                        () => _selectedTenureFilter = val ? 'Shared' : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              if (filteredFarms.isEmpty)
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
                          'No farms match your search filters.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredFarms.map(
                  (farm) => FarmCard(
                    farm: farm,
                    onTap: () => context.push('/farms/${farm.id}'),
                    onEdit: () => context.push('/farms/${farm.id}/edit'),
                    onDelete: () => _confirmDelete(farm),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.createFarm),
        icon: const Icon(Icons.add),
        label: const Text('Add Farm'),
      ),
    );
  }
}

class _EmptyFarmsView extends StatelessWidget {
  final VoidCallback onAddFarm;

  const _EmptyFarmsView({required this.onAddFarm});

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
                Icons.landscape,
                size: 64,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Farms Registered Yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Register your farm plots, family lands, or leased landholdings. All agricultural ventures and projects will be mapped to your farms.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              onPressed: onAddFarm,
              icon: const Icon(Icons.add),
              label: const Text('Register First Farm'),
            ),
          ],
        ),
      ),
    );
  }
}
