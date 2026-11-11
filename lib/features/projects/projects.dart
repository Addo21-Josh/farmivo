/// Projects feature module.
library;

// Domain & Models
export 'domain/models/project_with_farm.dart';
export 'domain/repositories/project_repository.dart';
export 'domain/state_machine/project_state_machine.dart';

// Data Layer
export 'data/repositories/project_repository_impl.dart';

// Providers & State
export 'presentation/providers/project_providers.dart';
export 'presentation/providers/project_comparison_providers.dart';

// Presentation Screens & Widgets
export 'presentation/projects_screen.dart';
export 'presentation/project_comparison_screen.dart';
export 'presentation/create_project_screen.dart';
export 'presentation/project_details_screen.dart';
export 'presentation/widgets/project_card.dart';
export 'presentation/widgets/project_comparison_matrix_card.dart';
export 'presentation/widgets/project_stage_stepper.dart';
export 'presentation/widgets/project_status_transition_dialog.dart';
