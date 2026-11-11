/// Payments and installment collection module.
library;

// Domain Models
export 'domain/models/payment_with_details.dart';

// Repository
export 'domain/repositories/payment_repository.dart';
export 'data/repositories/payment_repository_impl.dart';

// Presentation
export 'presentation/providers/payment_providers.dart';
export 'presentation/record_payment_screen.dart';
export 'presentation/add_payment_screen.dart';
export 'presentation/widgets/payment_tile.dart';
export 'presentation/widgets/record_payment_sheet.dart';
export 'presentation/widgets/void_payment_dialog.dart';
