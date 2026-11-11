import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../authentication/presentation/providers/security_providers.dart';
import '../../domain/services/data_wipe_service.dart';

/// Provider exposing the [DataWipeService].
final dataWipeServiceProvider = Provider<DataWipeService>((ref) {
  final db = ref.watch(databaseProvider);
  final securityRepo = ref.watch(securityRepositoryProvider);
  return DataWipeService(db: db, securityRepository: securityRepo);
});

/// Provider checking whether PIN verification is required for data wipe.
final isPinRequiredForWipeProvider = FutureProvider<bool>((ref) async {
  final wipeService = ref.watch(dataWipeServiceProvider);
  return wipeService.isPinVerificationRequired();
});
