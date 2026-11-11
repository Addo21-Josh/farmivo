import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/services/receipt_photo_service.dart';
import '../../domain/models/expense_filter.dart';
import '../../domain/models/expense_with_details.dart';
import '../../domain/models/payment_method.dart';
import '../../domain/repositories/expense_repository.dart';

/// Provider exposing the receipt photo capture and compression service.
final receiptPhotoServiceProvider = Provider<ReceiptPhotoService>((ref) {
  return ReceiptPhotoService();
});

/// Provider exposing the [ExpenseRepository] implementation.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepositoryImpl(db: db);
});

/// Reactive stream of detailed expenses for a specific project.
final projectExpensesWithDetailsProvider =
    StreamProvider.family<List<ExpenseWithDetails>, String>((ref, projectId) {
      final repository = ref.watch(expenseRepositoryProvider);
      return repository.watchExpensesByProject(projectId);
    });

/// Reactive stream of all detailed expenses across the farm ledger.
final allExpensesWithDetailsProvider = StreamProvider<List<ExpenseWithDetails>>(
  (ref) {
    final repository = ref.watch(expenseRepositoryProvider);
    return repository.watchAllExpenses();
  },
);

/// Current active transaction ledger filter criteria.
final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) {
  return const ExpenseFilter();
});

/// Reactive stream of ledger expenses filtered by multi-dimensional criteria
/// (Project, Category, Payment Method, Date Range, Amount Range, Status, Search).
final filteredExpensesProvider = StreamProvider<List<ExpenseWithDetails>>((
  ref,
) {
  final filter = ref.watch(expenseFilterProvider);
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpensesWithFilter(filter);
});

/// Retrieves distinct vendor names for auto-suggest in the expense form.
final frequentVendorsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.getFrequentVendors();
});

/// Controller managing expense operations (create, void, delete).
class ExpenseController extends StateNotifier<AsyncValue<void>> {
  final ExpenseRepository _repository;
  final Ref _ref;

  ExpenseController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  /// Records a new expense and invalidates vendor cache on success.
  Future<String?> recordExpense({
    required String projectId,
    required String categoryId,
    String? budgetItemId,
    String? activityId,
    required DateTime transactionDate,
    required String description,
    double quantity = 1.0,
    String? unit,
    int? unitCostMinor,
    required int amountMinor,
    String currency = 'GHS',
    required PaymentMethod paymentMethod,
    String? vendorName,
    String? receiptPhotoPath,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.recordExpense(
        projectId: projectId,
        categoryId: categoryId,
        budgetItemId: budgetItemId,
        activityId: activityId,
        transactionDate: transactionDate,
        description: description,
        quantity: quantity,
        unit: unit,
        unitCostMinor: unitCostMinor,
        amountMinor: amountMinor,
        currency: currency,
        paymentMethod: paymentMethod,
        vendorName: vendorName,
        receiptPhotoPath: receiptPhotoPath,
        notes: notes,
      );
      _ref.invalidate(frequentVendorsProvider);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Soft voids an expense, maintaining full historic audit trail.
  Future<bool> voidExpense({required String id, required String reason}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.voidExpense(id: id, reason: reason);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Soft deletes an expense.
  Future<bool> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteExpense(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider exposing the [ExpenseController].
final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) {
      final repository = ref.watch(expenseRepositoryProvider);
      return ExpenseController(repository, ref);
    });
