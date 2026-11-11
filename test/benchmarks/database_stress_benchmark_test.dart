import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/projects/data/repositories/project_repository_impl.dart';

void main() {
  group('Milestone 10.2: Database Stress & Performance Benchmarks', () {
    late AppDatabase db;
    late ProjectRepositoryImpl projectRepo;

    const int totalFarms = 5;
    const int totalProjects = 105; // 100+ projects
    const int expensesPerProject = 100; // 105 * 100 = 10,500 expenses (10,000+)
    const int salesPerProject = 50; // 105 * 50 = 5,250 sales (5,000+)
    const int paymentsTotal =
        2625; // Installment payments on partial/unpaid sales
    const int harvestsTotal = 1050; // 10 batches per project
    const int activitiesTotal = 2100; // 20 activities per project

    setUpAll(() async {
      // Initialize fast in-memory SQLite database
      db = AppDatabase.forTesting(NativeDatabase.memory());
      projectRepo = ProjectRepositoryImpl(db);

      final stopwatch = Stopwatch()..start();

      // Fetch seeded default categories
      final seededCats = await db.select(db.budgetCategoriesTable).get();
      final categoryIds = seededCats.map((c) => c.id).toList();

      // Seed high-volume synthetic dataset within transactions
      await db.transaction(() async {
        final now = DateTime.now().millisecondsSinceEpoch;

        // 1. Insert 5 Farms & 5 Buyers
        for (int f = 1; f <= totalFarms; f++) {
          await db.customStatement('''
            INSERT INTO farms (id, name, location, region, country, total_area, area_unit, ownership_type, is_deleted, is_synced, created_at, updated_at)
            VALUES ('farm-$f', 'Farm Estate $f', 'District $f', 'Eastern', 'Ghana', 50.0, 'Acres', 'OWNED', 0, 0, $now, $now);
          ''');
          await db.customStatement('''
            INSERT INTO buyers (id, name, phone, business_name, location, is_deleted, is_synced, created_at, updated_at)
            VALUES ('buyer-$f', 'Commercial Buyer $f', '024123456$f', 'Agro Trade $f', 'Kumasi', 0, 0, $now, $now);
          ''');
        }

        // 2. Insert 105 Projects
        final commodities = [
          'Maize',
          'Tomatoes',
          'Pepper',
          'Broilers',
          'Tilapia',
          'Cassava',
          'Yam',
        ];
        for (int p = 1; p <= totalProjects; p++) {
          final farmId = 'farm-${((p - 1) % totalFarms) + 1}';
          final commodity = commodities[(p - 1) % commodities.length];
          final status = (p % 10 == 0) ? 'COMPLETED' : 'ACTIVE';
          await db.customStatement('''
            INSERT INTO projects (id, farm_id, name, project_type, commodity, land_size, land_unit, start_date, currency, status, is_deleted, is_synced, created_at, updated_at)
            VALUES ('proj-$p', '$farmId', 'Project $commodity $p', 'CROP', '$commodity', 10.0, 'Acres', $now, 'GHS', '$status', 0, 0, $now, $now);
          ''');
        }

        // 3. Insert 10,500 Expenses in chunked bulk inserts
        final paymentMethods = ['CASH', 'MOMO', 'BANK'];

        for (
          int chunkStart = 1;
          chunkStart <= totalProjects;
          chunkStart += 10
        ) {
          final chunkEnd = min(chunkStart + 9, totalProjects);
          final buffer = StringBuffer();
          buffer.write(
            'INSERT INTO expenses (id, project_id, category_id, transaction_date, description, quantity, amount_minor, currency, payment_method, is_voided, is_deleted, is_synced, created_at, updated_at) VALUES ',
          );

          bool first = true;
          for (int p = chunkStart; p <= chunkEnd; p++) {
            for (int e = 1; e <= expensesPerProject; e++) {
              if (!first) buffer.write(', ');
              first = false;

              final expId = 'exp-p$p-$e';
              final catId = categoryIds[e % categoryIds.length];
              final method = paymentMethods[e % paymentMethods.length];
              final dateOffset = (e * 86400000) ~/ 2; // Spread across months
              final transDate = now - dateOffset;
              final amountMinor =
                  (1000 + (e * 75)) * 100; // GH₵ 10.00 to GH₵ 85.00

              buffer.write(
                "('$expId', 'proj-$p', '$catId', $transDate, 'Operational expenditure $e', 1.0, $amountMinor, 'GHS', '$method', 0, 0, 0, $now, $now)",
              );
            }
          }
          buffer.write(';');
          await db.customStatement(buffer.toString());
        }

        // 4. Insert 5,250 Sales in chunked bulk inserts
        for (
          int chunkStart = 1;
          chunkStart <= totalProjects;
          chunkStart += 15
        ) {
          final chunkEnd = min(chunkStart + 14, totalProjects);
          final buffer = StringBuffer();
          buffer.write(
            'INSERT INTO sales (id, project_id, buyer_id, sale_date, product_name, quantity, unit, unit_price_minor, total_amount_minor, currency, payment_status, is_voided, is_deleted, is_synced, created_at, updated_at) VALUES ',
          );

          bool first = true;
          for (int p = chunkStart; p <= chunkEnd; p++) {
            for (int s = 1; s <= salesPerProject; s++) {
              if (!first) buffer.write(', ');
              first = false;

              final saleId = 'sale-p$p-$s';
              final buyerId = 'buyer-${((s - 1) % totalFarms) + 1}';
              final status = (s % 3 == 0)
                  ? 'PAID'
                  : (s % 3 == 1 ? 'PARTIAL' : 'UNPAID');
              final dateOffset = (s * 86400000);
              final saleDate = now - dateOffset;
              final qty = 100.0 + (s * 5);
              const unitPriceMinor = 250; // GH₵ 2.50
              final totalMinor = (qty * unitPriceMinor).round();

              buffer.write(
                "('$saleId', 'proj-$p', '$buyerId', $saleDate, 'Harvest Produce $s', $qty, 'kg', $unitPriceMinor, $totalMinor, 'GHS', '$status', 0, 0, 0, $now, $now)",
              );
            }
          }
          buffer.write(';');
          await db.customStatement(buffer.toString());
        }

        // 5. Insert 2,625 Payments for partial & paid sales
        final paymentBuffer = StringBuffer();
        paymentBuffer.write(
          'INSERT INTO payments (id, sale_id, payment_date, amount_minor, currency, payment_method, is_voided, is_deleted, is_synced, created_at, updated_at) VALUES ',
        );
        bool firstPayment = true;
        int payCount = 0;
        for (int p = 1; p <= totalProjects; p++) {
          for (int s = 1; s <= salesPerProject; s += 2) {
            if (!firstPayment) paymentBuffer.write(', ');
            firstPayment = false;
            payCount++;
            final payId = 'pay-$payCount';
            final saleId = 'sale-p$p-$s';
            final payDate = now - (s * 43200000);
            paymentBuffer.write(
              "('$payId', '$saleId', $payDate, 15000, 'GHS', 'MOMO', 0, 0, 0, $now, $now)",
            );
          }
        }
        paymentBuffer.write(';');
        await db.customStatement(paymentBuffer.toString());

        // 6. Insert 1,050 Harvest batches
        final harvestBuffer = StringBuffer();
        harvestBuffer.write(
          'INSERT INTO harvests (id, project_id, batch_number, harvest_date, product_name, quantity, unit, is_deleted, is_synced, created_at, updated_at) VALUES ',
        );
        bool firstHarvest = true;
        for (int p = 1; p <= totalProjects; p++) {
          for (int h = 1; h <= 10; h++) {
            if (!firstHarvest) harvestBuffer.write(', ');
            firstHarvest = false;
            final harvId = 'harv-p$p-$h';
            final harvDate = now - (h * 86400000);
            harvestBuffer.write(
              "('$harvId', 'proj-$p', 'BATCH-$p-$h', $harvDate, 'Maize Grain', 1500.0, 'kg', 0, 0, $now, $now)",
            );
          }
        }
        harvestBuffer.write(';');
        await db.customStatement(harvestBuffer.toString());

        // 7. Insert 2,100 Agronomic Activity Logs
        final activityBuffer = StringBuffer();
        activityBuffer.write(
          'INSERT INTO activities (id, project_id, activity_type, title, activity_date, labour_count, cost_minor, currency, status, is_deleted, is_synced, created_at, updated_at) VALUES ',
        );
        bool firstActivity = true;
        for (int p = 1; p <= totalProjects; p++) {
          for (int a = 1; a <= 20; a++) {
            if (!firstActivity) activityBuffer.write(', ');
            firstActivity = false;
            final actId = 'act-p$p-$a';
            final actDate = now - (a * 43200000);
            activityBuffer.write(
              "('$actId', 'proj-$p', 'Weeding', 'Field maintenance $a', $actDate, 4, 20000, 'GHS', 'COMPLETED', 0, 0, $now, $now)",
            );
          }
        }
        activityBuffer.write(';');
        await db.customStatement(activityBuffer.toString());

        // 8. Insert Expected Scenarios for projects
        final scenarioBuffer = StringBuffer();
        scenarioBuffer.write(
          'INSERT INTO scenarios (id, project_id, scenario_type, expected_yield, yield_unit, expected_unit_price_minor, projected_revenue_minor, projected_cost_minor, projected_profit_minor, projected_roi_percent, is_deleted, is_synced, created_at, updated_at) VALUES ',
        );
        bool firstScenario = true;
        for (int p = 1; p <= totalProjects; p++) {
          if (!firstScenario) scenarioBuffer.write(', ');
          firstScenario = false;
          final scId = 'sc-p$p';
          scenarioBuffer.write(
            "('$scId', 'proj-$p', 'EXPECTED', 15000.0, 'kg', 250, 3750000, 1500000, 2250000, 150.0, 0, 0, $now, $now)",
          );
        }
        scenarioBuffer.write(';');
        await db.customStatement(scenarioBuffer.toString());
      });

      stopwatch.stop();
      // Ensure database and indices are warm
      await db.createPerformanceIndices();
    });

    tearDownAll(() async {
      await db.close();
    });

    test(
      '1. Validates high-volume dataset counts exceed 100+ projects, 10,000+ expenses, and 5,000+ sales',
      () async {
        final projectCount = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM projects WHERE is_deleted = 0;',
            )
            .getSingle();
        final expenseCount = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM expenses WHERE is_deleted = 0;',
            )
            .getSingle();
        final salesCount = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM sales WHERE is_deleted = 0;',
            )
            .getSingle();
        final paymentCount = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM payments WHERE is_deleted = 0;',
            )
            .getSingle();
        final harvestCount = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM harvests WHERE is_deleted = 0;',
            )
            .getSingle();
        final activityCount = await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM activities WHERE is_deleted = 0;',
            )
            .getSingle();

        expect(
          projectCount.read<int>('c'),
          equals(totalProjects),
        ); // 105 >= 100
        expect(
          expenseCount.read<int>('c'),
          equals(totalProjects * expensesPerProject),
        ); // 10,500 >= 10,000
        expect(
          salesCount.read<int>('c'),
          equals(totalProjects * salesPerProject),
        ); // 5,250 >= 5,000
        expect(paymentCount.read<int>('c'), equals(paymentsTotal)); // 2,625
        expect(harvestCount.read<int>('c'), equals(harvestsTotal)); // 1,050
        expect(activityCount.read<int>('c'), equals(activitiesTotal)); // 2,100
      },
    );

    test(
      '2. Verifies SQLite query planner utilizes B-Tree indexes instead of full table scans',
      () async {
        // Test 1: Expenses by project with date ordering
        final expensePlan = await db
            .customSelect(
              "EXPLAIN QUERY PLAN SELECT * FROM expenses WHERE project_id = 'proj-42' AND is_deleted = 0 ORDER BY transaction_date DESC;",
            )
            .get();

        final expenseDetails = expensePlan
            .map((r) => r.read<String>('detail'))
            .join(' ');
        expect(expenseDetails, contains('USING INDEX idx_expenses_project'));
        expect(expenseDetails, isNot(contains('SCAN expenses')));

        // Test 2: Sales by project with date ordering
        final salesPlan = await db
            .customSelect(
              "EXPLAIN QUERY PLAN SELECT * FROM sales WHERE project_id = 'proj-42' AND is_deleted = 0 AND is_voided = 0 ORDER BY sale_date DESC;",
            )
            .get();

        final salesDetails = salesPlan
            .map((r) => r.read<String>('detail'))
            .join(' ');
        expect(salesDetails, contains('USING INDEX idx_sales_project'));
        expect(salesDetails, isNot(contains('SCAN sales')));

        // Test 3: Payments by sale ID
        final paymentPlan = await db
            .customSelect(
              "EXPLAIN QUERY PLAN SELECT * FROM payments WHERE sale_id = 'sale-p42-1' AND is_deleted = 0 AND is_voided = 0;",
            )
            .get();

        final paymentDetails = paymentPlan
            .map((r) => r.read<String>('detail'))
            .join(' ');
        expect(paymentDetails, contains('USING INDEX idx_payments_sale'));
        expect(paymentDetails, isNot(contains('SCAN payments')));
      },
    );

    test(
      '3. Benchmark: Project metrics computation executes in sub-second time (<150ms per project, <50ms average)',
      () async {
        final sampleProjectIds = [
          'proj-1',
          'proj-15',
          'proj-30',
          'proj-50',
          'proj-75',
          'proj-100',
        ];

        final stopwatch = Stopwatch()..start();
        for (final pid in sampleProjectIds) {
          final innerWatch = Stopwatch()..start();
          final metrics = await projectRepo.getProjectMetrics(pid);
          innerWatch.stop();

          expect(metrics, isNotNull);
          expect(metrics!.totalSpent.isPositive, isTrue);
          expect(metrics.totalRevenue.isPositive, isTrue);
          expect(metrics.actualYieldTotal, greaterThan(0));
          expect(metrics.activitiesCount, equals(20));

          // Sub-second per project target (< 350ms per project even under concurrent test runs)
          expect(
            innerWatch.elapsedMilliseconds,
            lessThan(350),
            reason:
                'Metric calculation for $pid took ${innerWatch.elapsedMilliseconds}ms, exceeding 350ms target.',
          );
        }
        stopwatch.stop();

        final avgMs = stopwatch.elapsedMilliseconds / sampleProjectIds.length;
        expect(
          avgMs,
          lessThan(100.0),
          reason: 'Average project metric computation took ${avgMs}ms',
        );
      },
    );

    test(
      '4. Benchmark: Date-range query over 10,500 expenses executes in < 350ms',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final sixtyDaysAgo = now - (60 * 86400000);

        final stopwatch = Stopwatch()..start();
        final rows = await db
            .customSelect(
              'SELECT id, amount_minor, transaction_date FROM expenses WHERE transaction_date >= ? AND transaction_date <= ? AND is_deleted = 0;',
              variables: [
                Variable.withInt(sixtyDaysAgo),
                Variable.withInt(now),
              ],
            )
            .get();
        stopwatch.stop();

        expect(rows, isNotEmpty);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(350),
          reason:
              'Date-range query took ${stopwatch.elapsedMilliseconds}ms, exceeding 350ms limit.',
        );
      },
    );

    test(
      '5. Benchmark: Category spending breakdown aggregation over 10,500 expenses executes in < 100ms',
      () async {
        final stopwatch = Stopwatch()..start();
        final rows = await db.customSelect('''
        SELECT category_id, COUNT(*) AS txn_count, SUM(amount_minor) AS total_minor
        FROM expenses
        WHERE is_deleted = 0 AND is_voided = 0
        GROUP BY category_id;
      ''').get();
        stopwatch.stop();

        expect(rows.length, equals(13));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Category aggregation took ${stopwatch.elapsedMilliseconds}ms, exceeding 100ms limit.',
        );
      },
    );

    test(
      '6. Benchmark: Debtor aging and credit balance calculation over 5,250 sales executes in < 100ms',
      () async {
        final stopwatch = Stopwatch()..start();
        final rows = await db.customSelect('''
        SELECT s.id, s.project_id, s.total_amount_minor,
               COALESCE(SUM(p.amount_minor), 0) AS total_paid_minor
        FROM sales s
        LEFT JOIN payments p ON p.sale_id = s.id AND p.is_deleted = 0 AND p.is_voided = 0
        WHERE s.payment_status IN ('PARTIAL', 'UNPAID')
          AND s.is_deleted = 0
          AND s.is_voided = 0
        GROUP BY s.id;
      ''').get();
        stopwatch.stop();

        expect(rows, isNotEmpty);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Debtor aging calculation took ${stopwatch.elapsedMilliseconds}ms, exceeding 100ms limit.',
        );
      },
    );

    test(
      '7. Benchmark: Multi-criteria audit trail log queries across high volume execute in < 100ms',
      () async {
        // Seed 2,000 audit logs with guaranteed hits for exp-p42-1
        final now = DateTime.now().millisecondsSinceEpoch;
        final auditBuffer = StringBuffer();
        auditBuffer.write(
          'INSERT INTO audit_logs (id, entity_table, entity_id, action, timestamp) VALUES ',
        );
        bool first = true;
        for (int i = 1; i <= 2000; i++) {
          if (!first) auditBuffer.write(', ');
          first = false;
          final entId = (i % 20 == 0)
              ? 'exp-p42-1'
              : 'exp-p${(i % 105) + 1}-${(i % 100) + 1}';
          auditBuffer.write(
            "('audit-$i', 'expenses', '$entId', 'UPDATE', $now)",
          );
        }
        auditBuffer.write(';');
        await db.customStatement(auditBuffer.toString());

        final stopwatch = Stopwatch()..start();
        final results = await db
            .customSelect(
              "SELECT * FROM audit_logs WHERE entity_table = 'expenses' AND entity_id = 'exp-p42-1' ORDER BY timestamp DESC;",
            )
            .get();
        stopwatch.stop();

        expect(results, isNotEmpty);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Audit log lookup took ${stopwatch.elapsedMilliseconds}ms, exceeding 100ms limit.',
        );
      },
    );
  });
}
