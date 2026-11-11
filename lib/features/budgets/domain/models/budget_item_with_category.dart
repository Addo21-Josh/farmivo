import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';

/// Aggregates a [BudgetItem] with its parent [BudgetCategory] definition.
class BudgetItemWithCategory {
  final BudgetItem item;
  final BudgetCategory category;

  const BudgetItemWithCategory({required this.item, required this.category});

  /// The unit cost as a strongly typed [Money] object.
  Money get unitCost =>
      Money(BigInt.from(item.unitCostMinor), currency: item.currency);

  /// The total planned amount as a strongly typed [Money] object.
  Money get plannedAmount =>
      Money(BigInt.from(item.plannedAmountMinor), currency: item.currency);

  /// Formatted calculation string (e.g. "5 Bags @ GH₵ 120.00 = GH₵ 600.00").
  String get formulaDisplay =>
      '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit} @ ${unitCost.format()} = ${plannedAmount.format()}';

  /// Returns a clean quantity string without trailing .0 if integer.
  String get formattedQuantity => item.quantity % 1 == 0
      ? item.quantity.toInt().toString()
      : item.quantity.toString();
}
