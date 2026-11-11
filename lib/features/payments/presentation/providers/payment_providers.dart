import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../expenses/domain/models/payment_method.dart';
import '../../../sales/domain/models/sale_with_details.dart';
import '../../../sales/presentation/providers/sale_providers.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/models/payment_with_details.dart';
import '../../domain/repositories/payment_repository.dart';

/// Provider for [PaymentRepository].
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PaymentRepositoryImpl(db: db);
});

/// Reactive stream of installment payments received for a specific sale.
final salePaymentsProvider =
    StreamProvider.family<List<PaymentWithDetails>, String>((ref, saleId) {
      final repository = ref.watch(paymentRepositoryProvider);
      return repository.watchPayments(saleId: saleId, includeVoided: true);
    });

/// Reactive stream of all payments logged across sales for a specific buyer.
final buyerPaymentsProvider =
    StreamProvider.family<List<PaymentWithDetails>, String>((ref, buyerId) {
      final repository = ref.watch(paymentRepositoryProvider);
      return repository.watchPayments(buyerId: buyerId, includeVoided: false);
    });

/// Live remaining accounts receivable balance on a specific sale.
final saleOutstandingBalanceProvider = FutureProvider.family<Money, String>((
  ref,
  saleId,
) {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getSaleOutstandingBalance(saleId);
});

/// Reactive stream of commercial sales that currently hold an open receivable balance.
final unsettledSalesProvider = StreamProvider<List<SaleWithDetails>>((ref) {
  final allSalesAsync = ref.watch(allSalesProvider);
  return allSalesAsync.when(
    data: (sales) => Stream.value(
      sales.where((s) => s.isCredit && !s.sale.isVoided).toList(),
    ),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// Controller handling stateful operations (record installment, void payment).
class PaymentController extends StateNotifier<AsyncValue<void>> {
  final PaymentRepository _repository;

  PaymentController(this._repository) : super(const AsyncValue.data(null));

  Future<String?> recordPayment({
    required String saleId,
    required DateTime paymentDate,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.recordPayment(
        saleId: saleId,
        paymentDate: paymentDate,
        amountMinor: amountMinor,
        currency: currency,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> voidPayment({required String id, required String reason}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.voidPayment(id, reason: reason);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for [PaymentController].
final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return PaymentController(repository);
    });
