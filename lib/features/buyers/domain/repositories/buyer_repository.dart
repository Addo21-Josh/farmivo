import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/buyers/domain/models/buyer_summary.dart';
import 'package:farmivo/features/buyers/domain/models/buyers_directory_summary.dart';

/// Contract governing customer directory operations, credit terms, and real-time debtor calculations.
abstract class BuyerRepository {
  /// Watches active commercial buyers with live purchase and debtor calculations.
  Stream<List<BuyerSummary>> watchBuyers({
    String? searchQuery,
    bool onlyDebtors = false,
  });

  /// Retrieves commercial buyers matching search and debtor criteria.
  Future<List<BuyerSummary>> getBuyers({
    String? searchQuery,
    bool onlyDebtors = false,
  });

  /// Watches a single buyer by ID with live transaction metrics.
  Stream<BuyerSummary?> watchBuyerSummaryById(String id);

  /// Retrieves a single buyer summary by ID.
  Future<BuyerSummary?> getBuyerSummaryById(String id);

  /// Retrieves raw buyer record by ID.
  Future<Buyer?> getBuyerById(String id);

  /// Registers a new commercial buyer or market customer.
  Future<String> createBuyer({
    required String name,
    String? phone,
    String? businessName,
    String? location,
    String? notes,
  });

  /// Updates an existing buyer's contact or profile information.
  Future<void> updateBuyer({
    required String id,
    required String name,
    String? phone,
    String? businessName,
    String? location,
    String? notes,
  });

  /// Soft deletes a buyer from active directory.
  Future<void> deleteBuyer(String id);

  /// Watches overall directory debt, sales volume, and debtor count totals.
  Stream<BuyersDirectorySummary> watchDirectorySummary();

  /// Retrieves current snapshot of directory totals.
  Future<BuyersDirectorySummary> getDirectorySummary();
}
