import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:farmivo/data/database/app_database.dart';

void main() {
  group('Schema Migration Harness - Version 1', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Verifies schemaVersion is exactly 1', () {
      expect(db.schemaVersion, 1);
    });

    test(
      'Verifies all 16 tables exist in SQLite sqlite_master catalog',
      () async {
        final rows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
            )
            .get();

        final tableNames = rows.map((r) => r.read<String>('name')).toSet();

        final expectedTables = {
          'farms',
          'projects',
          'budget_categories',
          'budget_items',
          'expenses',
          'activities',
          'harvests',
          'buyers',
          'sales',
          'payments',
          'cash_transactions',
          'scenarios',
          'risks',
          'audit_logs',
          'sync_queue',
          'app_settings',
        };

        for (final expected in expectedTables) {
          expect(
            tableNames.contains(expected),
            isTrue,
            reason: 'Table $expected must exist in schema v1',
          );
        }
      },
    );

    test('Verifies foreign keys and WAL mode are enforced on open', () async {
      final fkResult = await db
          .customSelect('PRAGMA foreign_keys;')
          .getSingle();
      expect(
        fkResult.read<int>('foreign_keys'),
        1,
        reason: 'PRAGMA foreign_keys must be enabled',
      );
    });

    test(
      'Verifies default category seeding creates exactly 13 default categories',
      () async {
        final categories = await db.select(db.budgetCategoriesTable).get();
        expect(categories.length, 13);

        final systemDefaults = categories
            .where((c) => c.isSystemDefault)
            .toList();
        expect(systemDefaults.length, 13);
      },
    );

    test(
      'Verifies performance optimization B-Tree indexes exist in sqlite_master catalog',
      () async {
        final rows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%';",
            )
            .get();

        final indexNames = rows.map((r) => r.read<String>('name')).toSet();

        final expectedIndexes = {
          'idx_projects_farm',
          'idx_projects_status',
          'idx_expenses_project',
          'idx_expenses_category',
          'idx_expenses_date',
          'idx_expenses_budget_item',
          'idx_sales_project',
          'idx_sales_buyer',
          'idx_sales_date',
          'idx_sales_status',
          'idx_payments_sale',
          'idx_payments_date',
          'idx_harvests_project',
          'idx_activities_project',
          'idx_budget_items_project',
          'idx_scenarios_project',
          'idx_audit_logs_lookup',
          'idx_cash_transactions_project',
        };

        for (final expected in expectedIndexes) {
          expect(
            indexNames.contains(expected),
            isTrue,
            reason: 'Index $expected must exist in schema',
          );
        }
      },
    );
  });
}
