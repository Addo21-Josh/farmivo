import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../data/database/app_database.dart';
import '../../../authentication/domain/services/security_repository.dart';
import '../models/wipe_result.dart';

/// Service orchestrating atomic database truncation, credential wiping,
/// and factory resets for emergency situations and device handovers (Milestone 9.4).
class DataWipeService {
  final AppDatabase _db;
  final SecurityRepository _securityRepo;
  final FlutterSecureStorage _storage;
  final Directory? _customBackupsDir;
  final Directory? _customDocsDir;

  const DataWipeService({
    required AppDatabase db,
    required SecurityRepository securityRepository,
    FlutterSecureStorage? storage,
    Directory? customBackupsDirectory,
    Directory? customDocumentsDirectory,
  }) : _db = db,
       _securityRepo = securityRepository,
       _storage = storage ?? const FlutterSecureStorage(),
       _customBackupsDir = customBackupsDirectory,
       _customDocsDir = customDocumentsDirectory;

  /// Verifies PIN authorization if application lock is currently active.
  Future<bool> verifyWipeAuthorization(String enteredPin) async {
    final hasPin = await _securityRepo.hasPin();
    final isAppLockEnabled = await _securityRepo.isAppLockEnabled();
    if (!hasPin || !isAppLockEnabled) {
      return true; // No PIN configured or lock disabled
    }
    return _securityRepo.verifyPin(enteredPin);
  }

  /// Checks if PIN verification is currently required to perform a data wipe.
  Future<bool> isPinVerificationRequired() async {
    final hasPin = await _securityRepo.hasPin();
    final isAppLockEnabled = await _securityRepo.isAppLockEnabled();
    return hasPin && isAppLockEnabled;
  }

  /// Gets the expected PIN length if PIN verification is required.
  Future<int> getRequiredPinLength() async {
    return _securityRepo.getPinLength();
  }

  /// Executes atomic database truncation, secure storage wipe, and optional backup directory erasure.
  Future<WipeResult> executeFactoryReset({bool deleteBackups = false}) async {
    try {
      // 1. Flush SQLite write-ahead log (WAL) to main file
      try {
        await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      } catch (_) {}

      // 2. Disable foreign keys before opening transaction
      await _db.customStatement('PRAGMA foreign_keys = OFF;');

      int tablesCleared = 0;
      await _db.transaction(() async {
        for (final table in _db.allTables.toList().reversed) {
          await _db.customStatement('DELETE FROM "${table.actualTableName}";');
          tablesCleared++;
        }
      });

      // Re-enable foreign key constraints
      await _db.customStatement('PRAGMA foreign_keys = ON;');

      // 3. Reseed standard pristine agricultural budget taxonomy
      await _db.seedDefaultBudgetCategories();

      // 4. Wipe all encrypted keys and preferences from FlutterSecureStorage
      await _storage.deleteAll();

      // 5. Optionally remove local backup archive files
      int backupsDeleted = 0;
      if (deleteBackups) {
        final backupsDir = await _getBackupsDirectory();
        if (await backupsDir.exists()) {
          final files = backupsDir.listSync();
          for (final f in files) {
            if (f is File) {
              f.deleteSync();
              backupsDeleted++;
            }
          }
        }
      }

      return WipeResult(
        success: true,
        tablesCleared: tablesCleared,
        backupsDeleted: backupsDeleted,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return WipeResult(
        success: false,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  Future<Directory> _getBackupsDirectory() async {
    if (_customBackupsDir != null) return _customBackupsDir;
    final docsDir = _customDocsDir ?? await getApplicationDocumentsDirectory();
    return Directory(p.join(docsDir.path, 'backups'));
  }
}
