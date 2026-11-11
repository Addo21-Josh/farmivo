import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Opens an asynchronous connection to the local SQLite database.
/// Runs in a background isolate to keep UI frame rates smooth (60/120fps).
LazyDatabase openConnection({String dbName = 'farmivo.sqlite'}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        // Enforce foreign keys and WAL mode on each connection in background isolate
        rawDb.execute('PRAGMA foreign_keys = ON;');
        rawDb.execute('PRAGMA journal_mode = WAL;');
        rawDb.execute('PRAGMA synchronous = NORMAL;');
      },
    );
  });
}
