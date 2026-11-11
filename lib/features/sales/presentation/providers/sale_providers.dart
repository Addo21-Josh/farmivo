import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../domain/models/sale_payment_status.dart';
import '../../domain/models/sale_with_details.dart';
import '../../domain/models/sales_summary.dart';
import '../../domain/repositories/sale_repository.dart';

/// Provider for [SaleRepository].
final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SaleRepositoryImpl(db: db);
});

/// Reactive stream of all active commercial sales across all projects.
final allSalesProvider = StreamProvider<List<SaleWithDetails>>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return repository.watchSales(includeVoided: false);
});

/// Reactive stream of sales for a specific project.
final projectSalesWithDetailsProvider =
    StreamProvider.family<List<SaleWithDetails>, String>((ref, projectId) {
      final repository = ref.watch(saleRepositoryProvider);
      return repository.watchSales(projectId: projectId, includeVoided: false);
    });

/// Reactive stream of sales for a specific buyer/customer.
final buyerSalesWithDetailsProvider =
    StreamProvider.family<List<SaleWithDetails>, String>((ref, buyerId) {
      final repository = ref.watch(saleRepositoryProvider);
      return repository.watchSales(buyerId: buyerId, includeVoided: false);
    });

/// Reactive stream of sales drawn from a specific physical harvest lot.
final harvestSalesWithDetailsProvider =
    StreamProvider.family<List<SaleWithDetails>, String>((ref, harvestId) {
      final repository = ref.watch(saleRepositoryProvider);
      return repository.watchSales(harvestId: harvestId, includeVoided: false);
    });

/// Reactive stream of sales summary metrics for a specific project.
final projectSalesSummaryProvider = StreamProvider.family<SalesSummary, String>(
  (ref, projectId) {
    final repository = ref.watch(saleRepositoryProvider);
    return repository.watchSalesSummary(projectId: projectId);
  },
);

/// Reactive stream of sales summary metrics for a specific buyer.
final buyerSalesSummaryProvider = StreamProvider.family<SalesSummary, String>((
  ref,
  buyerId,
) {
  final repository = ref.watch(saleRepositoryProvider);
  return repository.watchSalesSummary(buyerId: buyerId);
});

/// Single sale transaction with rich relational details.
final saleDetailProvider = FutureProvider.family<SaleWithDetails?, String>((
  ref,
  id,
) {
  final repository = ref.watch(saleRepositoryProvider);
  return repository.getSaleById(id);
});

/// Controller managing stateful sale mutations (record, update, void).
class SaleController extends StateNotifier<AsyncValue<void>> {
  final SaleRepository _repository;

  SaleController(this._repository) : super(const AsyncValue.data(null));

  Future<String?> recordSale({
    required String projectId,
    String? buyerId,
    String? harvestId,
    required DateTime saleDate,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    String currency = 'GHS',
    required SalePaymentStatus paymentStatus,
    int? initialPaymentAmountMinor,
    String? paymentMethod,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.recordSale(
        projectId: projectId,
        buyerId: buyerId,
        harvestId: harvestId,
        saleDate: saleDate,
        productName: productName,
        quantity: quantity,
        unit: unit,
        unitPriceMinor: unitPriceMinor,
        currency: currency,
        paymentStatus: paymentStatus,
        initialPaymentAmountMinor: initialPaymentAmountMinor,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateSale({
    required String id,
    String? buyerId,
    String? harvestId,
    required DateTime saleDate,
    required String productName,
    required double quantity,
    required String unit,
    required int unitPriceMinor,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateSale(
        id: id,
        buyerId: buyerId,
        harvestId: harvestId,
        saleDate: saleDate,
        productName: productName,
        quantity: quantity,
        unit: unit,
        unitPriceMinor: unitPriceMinor,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> voidSale({required String id, required String reason}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.voidSale(id, reason: reason);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for [SaleController].
final saleControllerProvider =
    StateNotifierProvider<SaleController, AsyncValue<void>>((ref) {
      final repository = ref.watch(saleRepositoryProvider);
      return SaleController(repository);
    });
