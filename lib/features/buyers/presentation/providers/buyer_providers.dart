import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/data/repositories/buyer_repository_impl.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/domain/models/buyers_directory_summary.dart';
import 'package:farmivo/features/buyers/domain/repositories/buyer_repository.dart';

/// Provider for [BuyerRepository].
final buyerRepositoryProvider = Provider<BuyerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BuyerRepositoryImpl(db: db);
});

/// Search query state provider for directory filtering.
final buyerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filter toggle for displaying only customers with outstanding debt.
final buyerOnlyDebtorsFilterProvider = StateProvider<bool>((ref) => false);

/// Reactive stream of commercial buyers matching the active search query and debt filter.
final buyersStreamProvider = StreamProvider<List<BuyerSummary>>((ref) {
  final query = ref.watch(buyerSearchQueryProvider);
  final onlyDebtors = ref.watch(buyerOnlyDebtorsFilterProvider);
  final repository = ref.watch(buyerRepositoryProvider);
  return repository.watchBuyers(searchQuery: query, onlyDebtors: onlyDebtors);
});

/// Reactive stream of a single buyer's summary by ID.
final buyerSummaryProvider = StreamProvider.family<BuyerSummary?, String>((
  ref,
  buyerId,
) {
  final repository = ref.watch(buyerRepositoryProvider);
  return repository.watchBuyerSummaryById(buyerId);
});

/// Reactive stream of directory-level totals (total receivables, active debtors count, sales).
final buyersDirectorySummaryProvider = StreamProvider<BuyersDirectorySummary>((
  ref,
) {
  final repository = ref.watch(buyerRepositoryProvider);
  return repository.watchDirectorySummary();
});

/// Controller handling stateful operations (create, update, delete) for buyers.
class BuyerController extends StateNotifier<AsyncValue<void>> {
  final BuyerRepository _repository;

  BuyerController(this._repository) : super(const AsyncValue.data(null));

  Future<String?> createBuyer({
    required String name,
    String? phone,
    String? businessName,
    String? location,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.createBuyer(
        name: name,
        phone: phone,
        businessName: businessName,
        location: location,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateBuyer({
    required String id,
    required String name,
    String? phone,
    String? businessName,
    String? location,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBuyer(
        id: id,
        name: name,
        phone: phone,
        businessName: businessName,
        location: location,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteBuyer(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBuyer(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for [BuyerController].
final buyerControllerProvider =
    StateNotifierProvider<BuyerController, AsyncValue<void>>((ref) {
      final repository = ref.watch(buyerRepositoryProvider);
      return BuyerController(repository);
    });
