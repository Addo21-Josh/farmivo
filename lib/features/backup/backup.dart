/// Backup & Restore feature module (Milestone 9.2).
library;

// Domain Models
export 'domain/models/backup_metadata.dart';
export 'domain/models/backup_snapshot.dart';
export 'domain/models/backup_result.dart';

// Services
export 'domain/services/backup_archive_encoder.dart';
export 'domain/services/backup_restore_service.dart';

// Providers & State
export 'presentation/providers/backup_providers.dart';

// Presentation Screens
export 'presentation/backup_screen.dart';
