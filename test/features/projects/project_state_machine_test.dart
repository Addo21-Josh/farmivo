import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'package:farmivo/core/constants/app_constants.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/projects/data/repositories/project_repository_impl.dart';
import 'package:farmivo/features/projects/domain/state_machine/project_state_machine.dart';

void main() {
  late AppDatabase db;
  late ProjectRepositoryImpl repository;
  const uuid = Uuid();
  late String testFarmId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProjectRepositoryImpl(db);

    testFarmId = uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.farmsTable)
        .insert(
          FarmsTableCompanion.insert(
            id: testFarmId,
            name: 'State Machine Test Farm',
            location: 'Koforidua',
            region: 'Eastern',
            totalArea: 10.0,
            ownershipType: 'Owned',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Project sampleProject({String status = 'PLANNING'}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Project(
      id: uuid.v4(),
      farmId: testFarmId,
      name: 'State Transition Project',
      projectType: 'Crop',
      commodity: 'Maize',
      landSize: 5.0,
      landUnit: 'Acres',
      startDate: now,
      currency: 'GHS',
      status: status,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  group('ProjectStateMachine Structural Transitions', () {
    test('Allowed forward and backward transitions from PLANNING', () {
      final allowed = ProjectStateMachine.getAllowedNextStates(
        ProjectLifecycleState.planning,
      );
      expect(allowed.contains(ProjectLifecycleState.active), isTrue);
      expect(allowed.contains(ProjectLifecycleState.archived), isTrue);
      expect(allowed.contains(ProjectLifecycleState.completed), isFalse);
      expect(allowed.contains(ProjectLifecycleState.harvesting), isFalse);
    });

    test('Allowed transitions from ACTIVE and PRODUCTION', () {
      final fromActive = ProjectStateMachine.getAllowedNextStates(
        ProjectLifecycleState.active,
      );
      expect(fromActive.contains(ProjectLifecycleState.production), isTrue);
      expect(
        fromActive.contains(ProjectLifecycleState.planning),
        isTrue,
      ); // Rollback
      expect(fromActive.contains(ProjectLifecycleState.archived), isTrue);

      final fromProduction = ProjectStateMachine.getAllowedNextStates(
        ProjectLifecycleState.production,
      );
      expect(fromProduction.contains(ProjectLifecycleState.harvesting), isTrue);
      expect(
        fromProduction.contains(ProjectLifecycleState.active),
        isTrue,
      ); // Rollback
      expect(fromProduction.contains(ProjectLifecycleState.archived), isTrue);
    });

    test('Allowed transitions from HARVESTING and SELLING', () {
      final fromHarvesting = ProjectStateMachine.getAllowedNextStates(
        ProjectLifecycleState.harvesting,
      );
      expect(fromHarvesting.contains(ProjectLifecycleState.selling), isTrue);
      expect(fromHarvesting.contains(ProjectLifecycleState.production), isTrue);

      final fromSelling = ProjectStateMachine.getAllowedNextStates(
        ProjectLifecycleState.selling,
      );
      expect(fromSelling.contains(ProjectLifecycleState.completed), isTrue);
      expect(fromSelling.contains(ProjectLifecycleState.harvesting), isTrue);
    });

    test('canTransition() enforces direct edge connectivity', () {
      expect(
        ProjectStateMachine.canTransition(
          ProjectLifecycleState.planning,
          ProjectLifecycleState.active,
        ),
        isTrue,
      );
      expect(
        ProjectStateMachine.canTransition(
          ProjectLifecycleState.planning,
          ProjectLifecycleState.completed,
        ),
        isFalse,
      );
      expect(
        ProjectStateMachine.canTransition(
          ProjectLifecycleState.selling,
          ProjectLifecycleState.completed,
        ),
        isTrue,
      );
    });
  });

  group('ProjectStateMachine Domain Validation & Guard Rules', () {
    test('Validates warning when activating project without budget items', () {
      final project = sampleProject(status: 'PLANNING');
      final val = ProjectStateMachine.validateTransition(
        project: project,
        targetState: ProjectLifecycleState.active,
        budgetItemCount: 0,
      );

      expect(val.isPermitted, isTrue);
      expect(val.hasWarning, isTrue);
      expect(val.warningMessage, contains('No pre-season budget items'));
    });

    test(
      'Requires reason when rolling back stage (e.g. PRODUCTION -> ACTIVE)',
      () {
        final project = sampleProject(status: 'PRODUCTION');
        final val = ProjectStateMachine.validateTransition(
          project: project,
          targetState: ProjectLifecycleState.active,
        );

        expect(val.isPermitted, isTrue);
        expect(val.hasWarning, isTrue);
        expect(val.requiresReason, isTrue);
        expect(val.warningMessage, contains('Moving backwards'));
      },
    );

    test('Warns when completing a project with outstanding receivables', () {
      final project = sampleProject(status: 'SELLING');
      final val = ProjectStateMachine.validateTransition(
        project: project,
        targetState: ProjectLifecycleState.completed,
        unpaidReceivablesMinor: 50000, // GH₵ 500.00
      );

      expect(val.isPermitted, isTrue);
      expect(val.hasWarning, isTrue);
      expect(val.warningMessage, contains('outstanding debtor balances'));
    });

    test('Requires reason and warns when archiving a project', () {
      final project = sampleProject(status: 'ACTIVE');
      final val = ProjectStateMachine.validateTransition(
        project: project,
        targetState: ProjectLifecycleState.archived,
      );

      expect(val.isPermitted, isTrue);
      expect(val.hasWarning, isTrue);
      expect(val.requiresReason, isTrue);
      expect(val.warningMessage, contains('seal historical ledgers'));
    });
  });

  group('ProjectStateMachine Automated Suggestions', () {
    test(
      'Suggests HARVESTING when first harvest is logged during PRODUCTION',
      () {
        final project = sampleProject(status: 'PRODUCTION');
        final suggestion = ProjectStateMachine.detectSuggestion(
          project: project,
          harvestCount: 1,
        );

        expect(suggestion, isNotNull);
        expect(suggestion!.suggestedState, ProjectLifecycleState.harvesting);
        expect(suggestion.reasonTitle, 'Harvest Logged');
      },
    );

    test('Suggests SELLING when sales are recorded during HARVESTING', () {
      final project = sampleProject(status: 'HARVESTING');
      final suggestion = ProjectStateMachine.detectSuggestion(
        project: project,
        salesCount: 2,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.suggestedState, ProjectLifecycleState.selling);
      expect(suggestion.reasonTitle, 'Produce Sales Recorded');
    });

    test('Suggests COMPLETED when all harvests sold during SELLING', () {
      final project = sampleProject(status: 'SELLING');
      final suggestion = ProjectStateMachine.detectSuggestion(
        project: project,
        salesCount: 5,
        allHarvestSold: true,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.suggestedState, ProjectLifecycleState.completed);
      expect(suggestion.reasonTitle, 'All Yields Distributed');
    });
  });

  group('Audit Trail Logging on Status Transitions', () {
    test(
      'updateStatus() writes to auditLogsTable with immutable previous & new status',
      () async {
        final project = sampleProject(status: 'PLANNING');
        await repository.create(project);

        await repository.updateStatus(
          project.id,
          'ACTIVE',
          reason: 'Budget approved by cooperative',
        );

        // Verify project status changed
        final updated = await repository.getById(project.id);
        expect(updated!.status, 'ACTIVE');

        // Verify forensic audit log entry was created
        final auditLogs = await db.select(db.auditLogsTable).get();
        expect(auditLogs.length, 1);

        final log = auditLogs.first;
        expect(log.entityTable, 'projects');
        expect(log.entityId, project.id);
        expect(log.action, 'STATUS_CHANGE');
        expect(log.previousStateJson, contains('PLANNING'));
        expect(log.newStateJson, contains('ACTIVE'));
        expect(log.reason, 'Budget approved by cooperative');
        expect(log.performedBy, 'local_user');
      },
    );
  });
}
