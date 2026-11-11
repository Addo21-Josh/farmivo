import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_theme.dart';

/// Available visual theme presets for Farmivo.
enum AppThemePreset { system, lightOutdoor, dark, oledHighContrast }

extension AppThemePresetX on AppThemePreset {
  String get label {
    switch (this) {
      case AppThemePreset.system:
        return 'System Default';
      case AppThemePreset.lightOutdoor:
        return 'Light (Outdoor High Contrast)';
      case AppThemePreset.dark:
        return 'Dark (Standard)';
      case AppThemePreset.oledHighContrast:
        return 'OLED High Contrast (Pure Black)';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreset.system:
        return ThemeMode.system;
      case AppThemePreset.lightOutdoor:
        return ThemeMode.light;
      case AppThemePreset.dark:
      case AppThemePreset.oledHighContrast:
        return ThemeMode.dark;
    }
  }
}

/// State notifier managing persisted theme preset selection.
class ThemePresetNotifier extends StateNotifier<AppThemePreset> {
  final FlutterSecureStorage _storage;
  static const String _storageKey = 'farmivo_theme_preset';

  ThemePresetNotifier({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(AppThemePreset.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved != null) {
        state = AppThemePreset.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AppThemePreset.system,
        );
      }
    } catch (_) {
      // Fallback gracefully on read errors
    }
  }

  Future<void> setThemePreset(AppThemePreset preset) async {
    state = preset;
    try {
      await _storage.write(key: _storageKey, value: preset.name);
    } catch (_) {}
  }
}

final themePresetProvider =
    StateNotifierProvider<ThemePresetNotifier, AppThemePreset>((ref) {
      return ThemePresetNotifier();
    });

/// Resolves the current dark theme depending on whether OLED mode is active.
final currentDarkThemeProvider = Provider<ThemeData>((ref) {
  final preset = ref.watch(themePresetProvider);
  return preset == AppThemePreset.oledHighContrast
      ? AppTheme.oledTheme
      : AppTheme.darkTheme;
});
