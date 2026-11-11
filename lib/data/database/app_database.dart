import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'connection/connection.dart';
import 'tables/farms_table.dart';
import 'tables/projects_table.dart';
import 'tables/budget_categories_table.dart';
import 'tables/budget_items_table.dart';
import 'tables/expenses_table.dart';
import 'tables/activities_table.dart';
import 'tables/harvests_table.dart';
import 'tables/buyers_table.dart';
import 'tables/sales_table.dart';
import 'tables/payments_table.dart';
import 'tables/cash_transactions_table.dart';
import 'tables/scenarios_table.dart';
import 'tables/risks_table.dart';
import 'tables/audit_logs_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/app_settings_table.dart';
import '../../features/budgets/domain/models/budget_category_presets.dart';

part 'app_database.g.dart';

/// Primary offline-first Drift database for Farmivo.
@DriftDatabase(
  tables: [
    FarmsTable,
    ProjectsTable,
    BudgetCategoriesTable,
    BudgetItemsTable,
    ExpensesTable,
    ActivitiesTable,
    HarvestsTable,
    BuyersTable,
    SalesTable,
    PaymentsTable,
    CashTransactionsTable,
    ScenariosTable,
    RisksTable,
    AuditLogsTable,
    SyncQueueTable,
    AppSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // 1. Enforce SQLite foreign key relationships
      await customStatement('PRAGMA foreign_keys = ON;');
      // 2. Enable write-ahead logging for high concurrency
      await customStatement('PRAGMA journal_mode = WAL;');
      // 3. Optimize high-concurrency read queries via B-Tree indices (Milestone 10.2)
      await _createPerformanceIndices();
    },
    onCreate: (m) async {
      await m.createAll();

      // Seed default standard budget categories
      final now = DateTime.now().millisecondsSinceEpoch;
      const uuid = Uuid();

      for (final preset in BudgetCategoryPreset.standardPresets) {
        await into(budgetCategoriesTable).insert(
          BudgetCategoriesTableCompanion.insert(
            id: uuid.v4(),
            name: preset.name,
            description: Value(preset.description),
            iconName: Value(preset.iconName),
            isSystemDefault: const Value(true),
            displayOrder: Value(preset.displayOrder),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    },
  );

  /// Seeds or updates the standard agricultural budget categories taxonomy.
  Future<void> seedDefaultBudgetCategories() async {
    final existing = await (select(
      budgetCategoriesTable,
    )..where((tbl) => tbl.isDeleted.equals(false))).get();

    if (existing.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      const uuid = Uuid();

      for (final preset in BudgetCategoryPreset.standardPresets) {
        await into(budgetCategoriesTable).insert(
          BudgetCategoriesTableCompanion.insert(
            id: uuid.v4(),
            name: preset.name,
            description: Value(preset.description),
            iconName: Value(preset.iconName),
            isSystemDefault: const Value(true),
            displayOrder: Value(preset.displayOrder),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }

  /// Creates B-Tree performance optimization indices on foreign keys, soft-delete flags,
  /// and date-range query paths for 10,000+ record scale (Milestone 10.2).
  Future<void> createPerformanceIndices() async {
    await _createPerformanceIndices();
  }

  Future<void> _createPerformanceIndices() async {
    const indices = [
      'CREATE INDEX IF NOT EXISTS idx_projects_farm ON projects(farm_id, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_expenses_project ON expenses(project_id, is_deleted, transaction_date);',
      'CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category_id, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(transaction_date, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_expenses_budget_item ON expenses(budget_item_id);',
      'CREATE INDEX IF NOT EXISTS idx_sales_project ON sales(project_id, is_deleted, is_voided, sale_date);',
      'CREATE INDEX IF NOT EXISTS idx_sales_buyer ON sales(buyer_id, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(sale_date);',
      'CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(payment_status, is_voided, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_payments_sale ON payments(sale_id, is_deleted, is_voided);',
      'CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);',
      'CREATE INDEX IF NOT EXISTS idx_harvests_project ON harvests(project_id, is_deleted, harvest_date);',
      'CREATE INDEX IF NOT EXISTS idx_activities_project ON activities(project_id, is_deleted, activity_date);',
      'CREATE INDEX IF NOT EXISTS idx_budget_items_project ON budget_items(project_id, is_deleted);',
      'CREATE INDEX IF NOT EXISTS idx_scenarios_project ON scenarios(project_id, scenario_type);',
      'CREATE INDEX IF NOT EXISTS idx_audit_logs_lookup ON audit_logs(entity_table, entity_id, timestamp);',
      'CREATE INDEX IF NOT EXISTS idx_cash_transactions_project ON cash_transactions(project_id, is_deleted, transaction_date);',
    ];

    for (final sql in indices) {
      await customStatement(sql);
    }
  }
}

/// Global Riverpod provider for the Drift database singleton.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
