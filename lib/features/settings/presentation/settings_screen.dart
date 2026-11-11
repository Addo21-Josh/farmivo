import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/theme_provider.dart';
import '../../authentication/presentation/providers/security_providers.dart';
import 'widgets/data_wipe_confirmation_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showThemeSelector(
    BuildContext context,
    WidgetRef ref,
    AppThemePreset current,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Theme Preset'),
          content: RadioGroup<AppThemePreset>(
            groupValue: current,
            onChanged: (val) {
              if (val != null) {
                ref.read(themePresetProvider.notifier).setThemePreset(val);
                Navigator.pop(ctx);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemePreset.values.map((preset) {
                return RadioListTile<AppThemePreset>(
                  title: Text(preset.label),
                  value: preset,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themePreset = ref.watch(themePresetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.landscape_outlined),
            title: const Text('My Farms & Landholdings'),
            subtitle: const Text(
              'Manage farm properties, tenure models, and GPS locations',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.farms),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Budget Categories & Taxonomy'),
            subtitle: const Text(
              'Standard agricultural taxonomy and custom categories',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.budgetCategories),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Visual Theme Preset'),
            subtitle: Text(themePreset.label),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showThemeSelector(context, ref, themePreset),
          ),
          const Divider(),
          Consumer(
            builder: (context, ref, _) {
              final securityAsync = ref.watch(securitySettingsProvider);
              final subtitle = securityAsync.maybeWhen(
                data: (s) => s.isAppLockEnabled
                    ? 'Active (${s.pinLength}-digit PIN${s.isBiometricsEnabled ? ' & Biometrics' : ''})'
                    : 'Disabled',
                orElse: () => 'Manage biometric unlock and fallback PIN',
              );

              return ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Security & PIN Lock'),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.securitySettings),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Local Database Backup'),
            subtitle: const Text('Export or restore offline encrypted backup'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.backup),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history_edu_outlined),
            title: const Text('Audit Trail & Forensic Logs'),
            subtitle: const Text(
              'Tamper-evident logs of financial adjustments and voids',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.auditLogs),
          ),
          const ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text('Default Currency'),
            subtitle: Text('Ghanaian Cedi (GHS)'),
          ),
          const Divider(),
          ListTile(
            key: const Key('settings_emergency_wipe_tile'),
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Emergency Data Wipe & Factory Reset',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Permanently erase all farms, financial records, audit logs, and PIN lock',
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.error,
            ),
            onTap: () => DataWipeConfirmationDialog.show(context),
          ),
        ],
      ),
    );
  }
}
