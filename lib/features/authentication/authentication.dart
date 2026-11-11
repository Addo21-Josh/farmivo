/// Authentication & Security feature module (Milestone 9.1).
library;

// Domain Models
export 'domain/models/auto_lock_timeout.dart';
export 'domain/models/security_settings.dart';

// Services
export 'domain/services/pin_hasher.dart';
export 'domain/services/biometric_auth_service.dart';
export 'domain/services/security_repository.dart';

// Providers & State
export 'presentation/providers/security_providers.dart';

// Presentation Screens & Widgets
export 'presentation/lock_screen.dart';
export 'presentation/widgets/pin_display_dots.dart';
export 'presentation/widgets/numeric_keypad.dart';
