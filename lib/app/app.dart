import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../features/authentication/presentation/providers/security_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

/// Root application widget for Farm Project Manager (Farmivo).
class FarmivoApp extends ConsumerStatefulWidget {
  const FarmivoApp({super.key});

  @override
  ConsumerState<FarmivoApp> createState() => _FarmivoAppState();
}

class _FarmivoAppState extends ConsumerState<FarmivoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLockControllerProvider).initializeOnLaunch();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appLockControllerProvider).handleLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final preset = ref.watch(themePresetProvider);
    final darkTheme = ref.watch(currentDarkThemeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: darkTheme,
      themeMode: preset.themeMode,
      routerConfig: router,
    );
  }
}
