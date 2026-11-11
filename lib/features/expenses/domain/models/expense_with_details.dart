import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import 'payment_method.dart';

/// Aggregated expense record joined with its associated category, project, and budget item.
class ExpenseWithDetails {
  final Expense expense;
  final BudgetCategory category;
  final Project? project;
  final BudgetItem? budgetItem;

  const ExpenseWithDetails({
    required this.expense,
    required this.category,
    this.project,
    this.budgetItem,
  });

  /// The unique identifier of the expense.
  String get id => expense.id;

  /// The project identifier this expenditure was billed to.
  String get projectId => expense.projectId;

  /// Human-readable description of the expense.
  String get description => expense.description;

  /// Formatted monetary amount in minor units.
  Money get amount =>
      Money(BigInt.from(expense.amountMinor), currency: expense.currency);

  /// Typed payment channel used for this transaction.
  PaymentMethod get paymentMethod =>
      PaymentMethod.fromCode(expense.paymentMethod);

  /// Transaction date when the expense took place.
  DateTime get transactionDate =>
      DateTime.fromMillisecondsSinceEpoch(expense.transactionDate);

  /// Optional vendor, merchant, or supplier name.
  String? get vendorName => expense.vendorName;

  /// Local file system path to the compressed receipt photo.
  String? get receiptPhotoPath => expense.receiptPhotoPath;

  /// Whether a valid local receipt photo is attached.
  bool get hasReceipt =>
      receiptPhotoPath != null && receiptPhotoPath!.trim().isNotEmpty;

  /// Audit notes or field remarks.
  String? get notes => expense.notes;

  /// Quantity purchased.
  double get quantity => expense.quantity;

  /// Unit of measurement (e.g. bags, litres, days).
  String? get unit => expense.unit;

  /// Soft voiding flag.
  bool get isVoided => expense.isVoided;

  /// Timestamp when voided (if applicable).
  DateTime? get voidedAt => expense.voidedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(expense.voidedAt!)
      : null;

  /// Explanation for why the transaction was voided.
  String? get voidReason => expense.voidReason;
}
