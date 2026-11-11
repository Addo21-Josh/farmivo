import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/audit/data/repositories/audit_log_repository_impl.dart';
import 'package:farmivo/features/audit/domain/models/audit_action.dart';
import 'package:farmivo/features/audit/domain/repositories/audit_log_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('AuditLogRepository Unit Tests (Milestone 9.3)', () {
    late AppDatabase db;
    late AuditLogRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = AuditLogRepositoryImpl(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'logAction inserts an immutable audit record and returns domain entry',
      () async {
        await repository.logAction(
          entityTable: 'expenses',
          entityId: 'exp-101',
          action: AuditAction.voidRecord,
          previousState: {
            'id': 'exp-101',
            'amountMinor': 5000,
            'isVoided': false,
          },
          newState: {'id': 'exp-101', 'amountMinor': 5000, 'isVoided': true},
          reason: 'Duplicate payment receipt',
          performedBy: 'Accountant',
        );

        final trail = await repository.getAuditTrailForEntity(
          entityTable: 'expenses',
          entityId: 'exp-101',
        );
        expect(trail, isNotEmpty);
        final entry = trail.first;

        expect(entry.id, isNotEmpty);
        expect(entry.entityTable, equals('expenses'));
        expect(entry.entityId, equals('exp-101'));
        expect(entry.action, equals(AuditAction.voidRecord));
        expect(entry.reason, equals('Duplicate payment receipt'));
        expect(entry.performedBy, equals('Accountant'));
        expect(entry.previousState?['isVoided'], isFalse);
        expect(entry.newState?['isVoided'], isTrue);

        // Verify diff
        final diff = entry.changedFields;
        expect(diff.containsKey('isVoided'), isTrue);
        expect(diff['isVoided'], equals((false, true)));
        expect(diff.containsKey('amountMinor'), isFalse); // Did not change
      },
    );

    test('getAuditLogs filters by action and entityTable correctly', () async {
      await repository.logAction(
        entityTable: 'expenses',
        entityId: 'exp-1',
        action: AuditAction.create,
        newState: {'amount': 100},
      );

      await repository.logAction(
        entityTable: 'expenses',
        entityId: 'exp-1',
        action: AuditAction.voidRecord,
        previousState: {'isVoided': false},
        newState: {'isVoided': true},
        reason: 'Cancelled by owner',
      );

      await repository.logAction(
        entityTable: 'sales',
        entityId: 'sale-1',
        action: AuditAction.voidRecord,
        previousState: {'isVoided': false},
        newState: {'isVoided': true},
        reason: 'Buyer declined goods',
      );

      await repository.logAction(
        entityTable: 'sales',
        entityId: 'sale-1',
        action: AuditAction.update,
        previousState: {'quantity': 10},
        newState: {'quantity': 12},
      );

      // 1. Total records
      final allLogs = await repository.getAuditLogs();
      expect(allLogs.length, equals(4));

      // 2. Filter by action = VOID
      final voidLogs = await repository.getAuditLogs(
        action: AuditAction.voidRecord,
      );
      expect(voidLogs.length, equals(2));
      expect(voidLogs.every((e) => e.action == AuditAction.voidRecord), isTrue);

      // 3. Filter by entityTable = 'expenses'
      final expenseLogs = await repository.getAuditLogs(
        entityTable: 'expenses',
      );
      expect(expenseLogs.length, equals(2));
      expect(expenseLogs.every((e) => e.entityTable == 'expenses'), isTrue);

      // 4. Combined filter: entityTable = 'sales' AND action = VOID
      final salesVoidLogs = await repository.getAuditLogs(
        entityTable: 'sales',
        action: AuditAction.voidRecord,
      );
      expect(salesVoidLogs.length, equals(1));
      expect(salesVoidLogs.first.entityId, equals('sale-1'));
      expect(salesVoidLogs.first.reason, equals('Buyer declined goods'));
    });

    test('countAuditLogs accurately counts filtered rows', () async {
      await repository.logAction(
        entityTable: 'expenses',
        entityId: 'exp-1',
        action: AuditAction.voidRecord,
      );
      await repository.logAction(
        entityTable: 'sales',
        entityId: 'sale-1',
        action: AuditAction.voidRecord,
      );
      await repository.logAction(
        entityTable: 'payments',
        entityId: 'pay-1',
        action: AuditAction.create,
      );

      final totalCount = await repository.countAuditLogs();
      expect(totalCount, equals(3));

      final voidCount = await repository.countAuditLogs(
        action: AuditAction.voidRecord,
      );
      expect(voidCount, equals(2));

      final paymentsCount = await repository.countAuditLogs(
        entityTable: 'payments',
      );
      expect(paymentsCount, equals(1));
    });

    test(
      'getAuditTrailForEntity retrieves only the specific entity timeline',
      () async {
        await repository.logAction(
          entityTable: 'expenses',
          entityId: 'exp-A',
          action: AuditAction.create,
          newState: {'amount': 1500},
        );
        await repository.logAction(
          entityTable: 'expenses',
          entityId: 'exp-B',
          action: AuditAction.create,
          newState: {'amount': 3000},
        );
        await repository.logAction(
          entityTable: 'expenses',
          entityId: 'exp-A',
          action: AuditAction.voidRecord,
          reason: 'Duplicate voucher',
        );

        final trailA = await repository.getAuditTrailForEntity(
          entityTable: 'expenses',
          entityId: 'exp-A',
        );

        expect(trailA.length, equals(2));
        expect(
          trailA[0].action,
          equals(AuditAction.voidRecord),
        ); // Newest first
        expect(trailA[1].action, equals(AuditAction.create));

        final trailB = await repository.getAuditTrailForEntity(
          entityTable: 'expenses',
          entityId: 'exp-B',
        );
        expect(trailB.length, equals(1));
        expect(trailB.first.entityId, equals('exp-B'));
      },
    );

    test(
      'watchAuditLogs emits reactive updates upon new log insertions',
      () async {
        final stream = repository.watchAuditLogs(entityTable: 'expenses');

        expectLater(stream, emitsInOrder([isEmpty, hasLength(1)]));

        await pumpEventQueue();

        await repository.logAction(
          entityTable: 'expenses',
          entityId: 'exp-reactive',
          action: AuditAction.voidRecord,
          reason: 'Stream test void',
        );
      },
    );
  });
}
