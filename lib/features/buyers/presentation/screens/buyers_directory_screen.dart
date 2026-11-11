import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/features/buyers/presentation/providers/buyer_providers.dart';
import 'package:farmivo/features/buyers/presentation/screens/buyer_form_sheet.dart';
import 'package:farmivo/features/buyers/presentation/widgets/buyer_tile.dart';
import 'package:farmivo/features/buyers/presentation/widgets/debtor_summary_card.dart';

/// Screen presenting the searchable commercial customer directory,
/// real-time debtor receivables tracking, and rapid debt collection shortcuts.
class BuyersDirectoryScreen extends ConsumerStatefulWidget {
  const BuyersDirectoryScreen({super.key});

  @override
  ConsumerState<BuyersDirectoryScreen> createState() =>
      _BuyersDirectoryScreenState();
}

class _BuyersDirectoryScreenState extends ConsumerState<BuyersDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final query = ref.read(buyerSearchQueryProvider);
    _searchController.text = query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    ref.read(buyerSearchQueryProvider.notifier).state = val;
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(buyerSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(buyersDirectorySummaryProvider);
    final buyersAsync = ref.watch(buyersStreamProvider);
    final searchQuery = ref.watch(buyerSearchQueryProvider);
    final onlyDebtors = ref.watch(buyerOnlyDebtorsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Customer',
            onPressed: () => BuyerFormSheet.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => BuyerFormSheet.show(context),
        icon: const Icon(Icons.person_add),
        label: const Text('New Customer'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(buyersStreamProvider);
          ref.invalidate(buyersDirectorySummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // 1. Directory Receivables Summary Card
            summaryAsync.when(
              data: (summary) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: DebtorSummaryCard(summary: summary),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading directory summary: $err'),
              ),
            ),

            const SizedBox(height: 8),

            // 2. Search & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search customer, business, market, or phone...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
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
              ),
            ),

            // 3. Customer List
            buyersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading customers: $err'),
              ),
              data: (buyers) {
                if (buyers.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          searchQuery.isNotEmpty || onlyDebtors
                              ? 'No Matching Customers Found'
                              : 'No Customers in Directory',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          searchQuery.isNotEmpty || onlyDebtors
                              ? 'Try adjusting your search criteria or resetting the debtors filter.'
                              : 'Register commercial produce buyers, market women, and off-takers.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (searchQuery.isNotEmpty || onlyDebtors) {
                              _clearSearch();
                              ref
                                      .read(
                                        buyerOnlyDebtorsFilterProvider.notifier,
                                      )
                                      .state =
                                  false;
                            } else {
                              BuyerFormSheet.show(context);
                            }
                          },
                          icon: Icon(
                            searchQuery.isNotEmpty || onlyDebtors
                                ? Icons.filter_alt_off
                                : Icons.person_add,
                          ),
                          label: Text(
                            searchQuery.isNotEmpty || onlyDebtors
                                ? 'Reset Filters'
                                : 'Add First Customer',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: buyers.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final buyer = buyers[index];
                    return BuyerTile(buyer: buyer);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
