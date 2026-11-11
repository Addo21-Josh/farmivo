/// Sales and commercial trade feature module.
library;

// Domain Models
export 'domain/models/sale_payment_status.dart';
export 'domain/models/sale_with_details.dart';
export 'domain/models/sales_summary.dart';

// Repository
export 'domain/repositories/sale_repository.dart';
export 'data/repositories/sale_repository_impl.dart';

// Presentation
export 'presentation/providers/sale_providers.dart';
export 'presentation/record_sale_screen.dart';
export 'presentation/add_sale_screen.dart';
export 'presentation/widgets/sale_tile.dart';
export 'presentation/widgets/sale_detail_sheet.dart';
export 'presentation/widgets/void_sale_dialog.dart';
