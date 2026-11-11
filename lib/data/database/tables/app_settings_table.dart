import 'package:drift/drift.dart';

/// Key-value persistent preferences and metadata store.
@DataClassName('AppSetting')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {settingKey};
}
