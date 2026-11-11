import 'package:drift/native.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/expenses/domain/models/expense_with_details.dart';
import 'package:farmivo/features/expenses/presentation/widgets/expense_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BudgetCategory testCategory;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final categories = await db.select(db.budgetCategoriesTable).get();
    testCategory = categories.first;
  });

  tearDown(() async {
    await db.close();
  });

  Expense createTestExpense({
    required String id,
    required String description,
    required int amountMinor,
    String paymentMethod = 'CASH',
    String? vendorName,
    bool isVoided = false,
    String? voidReason,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Expense(
      id: id,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
      projectId: 'proj-1',
      categoryId: testCategory.id,
      transactionDate: now,
      description: description,
      quantity: 1.0,
      amountMinor: amountMinor,
      currency: 'GHS',
      paymentMethod: paymentMethod,
      vendorName: vendorName,
      isVoided: isVoided,
      voidReason: voidReason,
    );
  }

  testWidgets('ExpenseTile displays active expense details properly', (
    tester,
  ) async {
    final expense = createTestExpense(
      id: 'exp-1',
      description: 'Bought 3 Cutlasses',
      amountMinor: 15000,
      paymentMethod: 'MOMO_MTN',
      vendorName: 'Ejura Hardware Store',
    );

    final details = ExpenseWithDetails(
      expense: expense,
      category: testCategory,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ExpenseTile(expense: details)),
        ),
      ),
    );

    expect(find.text('Bought 3 Cutlasses'), findsOneWidget);
    expect(find.text('MTN MoMo'), findsOneWidget);
    expect(find.text('Ejura Hardware Store'), findsOneWidget);
    expect(find.text('- GH₵ 150.00'), findsOneWidget);
    expect(find.text('VOID'), findsNothing);
  });

  testWidgets('ExpenseTile displays VOID banner when expense is voided', (
    tester,
  ) async {
    final expense = createTestExpense(
      id: 'exp-2',
      description: 'Canceled tractor booking',
      amountMinor: 50000,
      isVoided: true,
      voidReason: 'Rain prevented field work',
    );

    final details = ExpenseWithDetails(
      expense: expense,
      category: testCategory,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ExpenseTile(expense: details)),
        ),
      ),
    );

    expect(find.text('Canceled tractor booking'), findsOneWidget);
    expect(find.text('VOID'), findsOneWidget);
  });

  testWidgets('Tapping ExpenseTile opens detail sheet', (tester) async {
    final expense = createTestExpense(
      id: 'exp-3',
      description: 'Herbicide chemical',
      amountMinor: 8500,
      paymentMethod: 'MOMO_TELECEL',
    );

    final details = ExpenseWithDetails(
      expense: expense,
      category: testCategory,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ExpenseTile(expense: details)),
        ),
      ),
    );

    // Tap tile
    await tester.tap(find.text('Herbicide chemical'));
    await tester.pumpAndSettle();

    // Verify detail sheet is displayed
    expect(find.text('Transaction Date'), findsOneWidget);
    expect(find.text('Payment Channel'), findsOneWidget);
    expect(find.text('Telecel Cash'), findsWidgets);
    expect(find.text('Budget Category'), findsOneWidget);
    expect(find.text('Void Transaction'), findsOneWidget);
  });
}
