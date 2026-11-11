import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/features/audit/domain/models/audit_action.dart';
import 'package:farmivo/features/audit/domain/models/audit_log_entry.dart';
import 'package:farmivo/features/audit/domain/repositories/audit_log_repository.dart';
import 'package:farmivo/features/audit/presentation/audit_log_screen.dart';
import 'package:farmivo/features/audit/presentation/providers/audit_providers.dart';
import 'package:farmivo/features/audit/presentation/widgets/audit_log_tile.dart';
import 'package:farmivo/features/audit/presentation/widgets/entity_audit_trail_sheet.dart';

class FakeAuditLogRepository implements AuditLogRepository {
  final List<AuditLogEntry> _entries = [];
  final StreamController<List<AuditLogEntry>> _controller =
      StreamController<List<AuditLogEntry>>.broadcast();

  void dispose() {
    _controller.close();
  }

  @override
  Future<void> logAction({
    required String entityTable,
    required String entityId,
    required AuditAction action,
    Map<String, dynamic>? previousState,
    Map<String, dynamic>? newState,
    String? reason,
    String performedBy = 'local_user',
    DateTime? timestamp,
  }) async {
    final entry = AuditLogEntry(
      id: 'log-${_entries.length + 1}',
      entityTable: entityTable,
      entityId: entityId,
      action: action,
      previousState: previousState,
      newState: newState,
      reason: reason,
      performedBy: performedBy,
      timestamp: timestamp ?? DateTime.now(),
    );
    _entries.insert(0, entry);
    _controller.add(List.unmodifiable(_entries));
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogs({
    String? entityTable,
    String? entityId,
    AuditAction? action,
    int limit = 100,
    int offset = 0,
  }) async {
    return _filter(
      _entries,
      entityTable: entityTable,
      entityId: entityId,
      action: action,
    ).skip(offset).take(limit).toList();
  }

  @override
  Stream<List<AuditLogEntry>> watchAuditLogs({
    String? entityTable,
    String? entityId,
    AuditAction? action,
    int limit = 100,
  }) async* {
    yield _filter(
      _entries,
      entityTable: entityTable,
      entityId: entityId,
      action: action,
    ).take(limit).toList();
    yield* _controller.stream.map(
      (all) => _filter(
        all,
        entityTable: entityTable,
        entityId: entityId,
        action: action,
      ).take(limit).toList(),
    );
  }

  @override
  Future<List<AuditLogEntry>> getAuditTrailForEntity({
    required String entityTable,
    required String entityId,
  }) async {
    return _entries
        .where(
          (e) =>
              e.entityTable.toLowerCase() == entityTable.toLowerCase() &&
              e.entityId == entityId,
        )
        .toList();
  }

  @override
  Future<int> countAuditLogs({String? entityTable, AuditAction? action}) async {
    return _filter(_entries, entityTable: entityTable, action: action).length;
  }

  List<AuditLogEntry> _filter(
    List<AuditLogEntry> source, {
    String? entityTable,
    String? entityId,
    AuditAction? action,
  }) {
    return source.where((e) {
      if (entityTable != null &&
          e.entityTable.toLowerCase() != entityTable.toLowerCase()) {
        return false;
      }
      if (entityId != null && e.entityId != entityId) {
        return false;
      }
      if (action != null && e.action != action) {
        return false;
      }
      return true;
    }).toList();
  }
}

void main() {
  group('Audit Log UI Widget Tests (Milestone 9.3)', () {
    late FakeAuditLogRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeAuditLogRepository();
    });

    tearDown(() {
      fakeRepository.dispose();
    });

    Widget createWidgetForTesting(Widget child) {
      return ProviderScope(
        overrides: [
          auditLogRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets(
      'AuditLogScreen renders header, filter chips, and empty state when no logs exist',
      (tester) async {
        await tester.pumpWidget(createWidgetForTesting(const AuditLogScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Verify AppBar and Header
        expect(find.text('Audit Trail & Logs'), findsOneWidget);
        expect(find.text('Immutable Forensic Trail'), findsOneWidget);

        // Verify Action Filter Chips
        expect(find.text('All Actions'), findsOneWidget);
        expect(find.text('VOID'), findsOneWidget);
        expect(find.text('UPDATE'), findsOneWidget);
        expect(find.text('CREATE'), findsOneWidget);
        expect(find.text('DELETE'), findsOneWidget);

        // Verify Entity Table Filter Chips
        expect(find.text('All Entities'), findsOneWidget);
        expect(find.text('Expenses'), findsOneWidget);
        expect(find.text('Sales'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);

        // Empty State
        expect(find.text('No Audit Logs Found'), findsOneWidget);
      },
    );

    testWidgets(
      'AuditLogTile renders action badge, reason, and toggles expandable diff view',
      (tester) async {
        final entry = AuditLogEntry(
          id: 'log-1',
          entityTable: 'expenses',
          entityId: 'exp-555',
          action: AuditAction.voidRecord,
          previousState: {
            'id': 'exp-555',
            'amountMinor': 12000,
            'isVoided': false,
          },
          newState: {
            'id': 'exp-555',
            'amountMinor': 12000,
            'isVoided': true,
            'voidReason': 'Voucher cancelled due to supplier insolvency',
          },
          reason: 'Voucher cancelled due to supplier insolvency',
          performedBy: 'Accountant Mensah',
          timestamp: DateTime(2026, 4, 15, 10, 30),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AuditLogTile(entry: entry)),
          ),
        );

        // Check badge and content
        expect(find.text('VOID'), findsOneWidget);
        expect(find.text('Expense Record'), findsOneWidget);
        expect(
          find.text('Reason: Voucher cancelled due to supplier insolvency'),
          findsOneWidget,
        );
        expect(find.text('Accountant Mensah'), findsOneWidget);

        // Diff should show expandable toggle
        expect(find.text('View Changes (2)'), findsOneWidget);

        // Tap View Changes to expand
        await tester.tap(find.text('View Changes (2)'));
        await tester.pump();

        // Diff table should now be visible
        expect(find.text('Hide Changes'), findsOneWidget);
        expect(find.text('isVoided'), findsOneWidget);
        expect(find.text('false'), findsOneWidget);
        expect(find.text('true'), findsOneWidget);
      },
    );

    testWidgets('AuditLogScreen filters entries when tapping filter chips', (
      tester,
    ) async {
      await fakeRepository.logAction(
        entityTable: 'expenses',
        entityId: 'exp-1',
        action: AuditAction.voidRecord,
        reason: 'Expense void reason',
      );
      await fakeRepository.logAction(
        entityTable: 'sales',
        entityId: 'sale-1',
        action: AuditAction.update,
        reason: 'Price adjustment',
      );

      await tester.pumpWidget(createWidgetForTesting(const AuditLogScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Both should be visible initially under All Actions & All Entities
      expect(find.textContaining('Expense void reason'), findsOneWidget);
      expect(find.textContaining('Price adjustment'), findsOneWidget);

      // Tap 'VOID' action filter
      await tester.tap(find.byKey(const Key('audit_action_void')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Only expense void should be displayed
      expect(find.textContaining('Expense void reason'), findsOneWidget);
      expect(find.textContaining('Price adjustment'), findsNothing);

      // Tap 'Sales' table filter (while action is VOID)
      await tester.tap(find.byKey(const Key('audit_table_sales')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No entries match VOID + Sales
      expect(find.text('No Audit Logs Found'), findsOneWidget);

      // Switch action back to 'All Actions'
      await tester.tap(find.byKey(const Key('audit_action_all')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Now the sales update is visible
      expect(find.textContaining('Price adjustment'), findsOneWidget);
    });

    testWidgets(
      'EntityAuditTrailSheet displays entity-specific audit history in bottom sheet',
      (tester) async {
        await fakeRepository.logAction(
          entityTable: 'expenses',
          entityId: 'target-exp-99',
          action: AuditAction.voidRecord,
          reason: 'Specific audit trail record',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              auditLogRepositoryProvider.overrideWithValue(fakeRepository),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      EntityAuditTrailSheet.show(
                        context,
                        entityTable: 'expenses',
                        entityId: 'target-exp-99',
                      );
                    },
                    child: const Text('Open Sheet'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open sheet
        await tester.tap(find.text('Open Sheet'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Audit Trail & History'), findsOneWidget);
        expect(find.text('expenses • ID: target-exp-99'), findsOneWidget);
        expect(
          find.textContaining('Specific audit trail record'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AuditLogScreen info button triggers forensic information dialog',
      (tester) async {
        await tester.pumpWidget(createWidgetForTesting(const AuditLogScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Tap info icon in AppBar
        await tester.tap(find.byIcon(Icons.info_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify dialog is shown
        expect(find.text('About Audit Trail'), findsOneWidget);
        expect(
          find.textContaining('tamper-evident forensic ledger'),
          findsOneWidget,
        );

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('About Audit Trail'), findsNothing);
      },
    );
  });
}
