import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/app_logger.dart';

/// Pre-launch bootstrap initialization for database, isolates, and services.
Future<Widget> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLogger.init();
  AppLogger.info('Initializing Farmivo application bootstrap sequence...');

  // Wrap in Riverpod ProviderScope
  return ProviderScope(observers: [_AppProviderObserver()], child: builder());
}

class _AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Riverpod Provider ${provider.name ?? provider.runtimeType} failed',
      error,
      stackTrace,
    );
  }
}
