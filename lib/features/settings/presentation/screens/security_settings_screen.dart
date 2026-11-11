import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../authentication/domain/models/auto_lock_timeout.dart';
import '../../../authentication/presentation/providers/security_providers.dart';
import '../../../authentication/presentation/widgets/numeric_keypad.dart';
import '../../../authentication/presentation/widgets/pin_display_dots.dart';

/// Screen allowing the farmer to configure App Lock, PIN creation/change,
/// biometric unlock, and auto-lock timeout duration (Milestone 9.1).
class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  void _showSetPinDialog(
    BuildContext context,
    WidgetRef ref, {
    bool isChanging = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PinSetupSheet(isChanging: isChanging),
    );
  }

  void _showTimeoutPicker(
    BuildContext context,
    WidgetRef ref,
    AutoLockTimeout current,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Auto-Lock Timeout'),
          content: RadioGroup<AutoLockTimeout>(
            groupValue: current,
            onChanged: (val) {
              if (val != null) {
                ref
                    .read(securitySettingsProvider.notifier)
                    .setAutoLockTimeout(val);
                Navigator.pop(ctx);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AutoLockTimeout.values.map((timeout) {
                return RadioListTile<AutoLockTimeout>(
                  title: Text(timeout.displayName),
                  value: timeout,
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
    final colors = context.appColors;
    final settingsAsync = ref.watch(securitySettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security & PIN Lock')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error loading security settings: $e')),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Security Status Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: settings.isAppLockEnabled
                      ? colors.healthGreenBg
                      : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settings.isAppLockEnabled
                        ? colors.healthGreen.withAlpha(80)
                        : theme.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      settings.isAppLockEnabled
                          ? Icons.verified_user_rounded
                          : Icons.lock_open_rounded,
                      size: 32,
                      color: settings.isAppLockEnabled
                          ? colors.healthGreen
                          : Colors.grey,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.isAppLockEnabled
                                ? 'Application Lock Active'
                                : 'Application Lock Disabled',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: settings.isAppLockEnabled
                                  ? colors.healthGreen
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.isAppLockEnabled
                                ? 'Financial records are guarded by ${settings.pinLength}-digit PIN'
                                      '${settings.isBiometricsEnabled ? ' and Biometrics' : ''}.'
                                : 'Anyone with physical access to your phone can view farm finances.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Toggle App Lock
              SwitchListTile(
                title: const Text(
                  'Require PIN to Open App',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Enforce authentication whenever Farmivo is launched or resumed',
                ),
                value: settings.isAppLockEnabled,
                activeThumbColor: colors.healthGreen,
                onChanged: (enabled) async {
                  if (enabled) {
                    if (!settings.hasPin) {
                      _showSetPinDialog(context, ref);
                    } else {
                      await ref
                          .read(securitySettingsProvider.notifier)
                          .setAppLockEnabled(true);
                    }
                  } else {
                    await ref
                        .read(securitySettingsProvider.notifier)
                        .setAppLockEnabled(false);
                  }
                },
              ),

              const Divider(),

              // PIN Management
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: Text(
                  settings.hasPin
                      ? 'Change Security PIN'
                      : 'Set Up Security PIN',
                ),
                subtitle: Text(
                  settings.hasPin
                      ? 'Update your current ${settings.pinLength}-digit passcode'
                      : 'Configure a passcode to secure confidential financials',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showSetPinDialog(
                  context,
                  ref,
                  isChanging: settings.hasPin,
                ),
              ),

              const Divider(),

              // Biometric Authentication
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint_rounded),
                title: const Text(
                  'Biometric Unlock',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  settings.isBiometricsAvailableOnDevice
                      ? 'Unlock using fingerprint scanner or Face ID'
                      : 'Biometric hardware unavailable on this device',
                ),
                value: settings.isBiometricsEnabled,
                activeThumbColor: colors.healthGreen,
                onChanged:
                    settings.isBiometricsAvailableOnDevice && settings.hasPin
                    ? (val) => ref
                          .read(securitySettingsProvider.notifier)
                          .setBiometricsEnabled(val)
                    : null,
              ),

              const Divider(),

              // Auto-Lock Timeout
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Auto-Lock Timeout'),
                subtitle: Text(settings.autoLockTimeout.displayName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                enabled: settings.isAppLockEnabled,
                onTap: () =>
                    _showTimeoutPicker(context, ref, settings.autoLockTimeout),
              ),

              const Divider(),
              const SizedBox(height: 12),

              // Lock Now Action
              if (settings.isAppLockEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Lock Farmivo Now'),
                    onPressed: () {
                      ref.read(appLockControllerProvider).lock();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Modal bottom sheet guiding the farmer through PIN entry and confirmation.
class _PinSetupSheet extends ConsumerStatefulWidget {
  final bool isChanging;

  const _PinSetupSheet({required this.isChanging});

  @override
  ConsumerState<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends ConsumerState<_PinSetupSheet> {
  int _step = 0; // 0 = enter pin, 1 = confirm pin
  String _firstPin = '';
  String _confirmPin = '';
  bool _hasError = false;
  String? _errorMessage;
  final int _pinLength = 4;

  void _onDigit(String d) {
    setState(() {
      _hasError = false;
      _errorMessage = null;

      if (_step == 0) {
        if (_firstPin.length < _pinLength) {
          _firstPin += d;
          if (_firstPin.length == _pinLength) {
            // Move to confirmation step after brief delay
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _step = 1);
            });
          }
        }
      } else {
        if (_confirmPin.length < _pinLength) {
          _confirmPin += d;
          if (_confirmPin.length == _pinLength) {
            _validateAndSave();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _hasError = false;
      _errorMessage = null;

      if (_step == 0) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Back up to step 0
          _step = 0;
          _firstPin = '';
        }
      }
    });
  }

  Future<void> _validateAndSave() async {
    if (_firstPin == _confirmPin) {
      await ref.read(securitySettingsProvider.notifier).savePin(_firstPin);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security PIN successfully configured!'),
          ),
        );
      }
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'PINs did not match. Please try again.';
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _step = 0;
            _firstPin = '';
            _confirmPin = '';
            _hasError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPin = _step == 0 ? _firstPin : _confirmPin;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            _step == 0
                ? (widget.isChanging
                      ? 'Enter New 4-Digit PIN'
                      : 'Create 4-Digit Security PIN')
                : 'Confirm Your 4-Digit PIN',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _step == 0
                ? 'Choose a memorable passcode to guard farm finances'
                : 'Re-enter the same 4 digits to confirm',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),

          PinDisplayDots(
            totalDigits: _pinLength,
            enteredDigits: currentPin.length,
            hasError: _hasError,
          ),

          SizedBox(
            height: 32,
            child: Center(
              child: _errorMessage != null
                  ? Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),

          NumericKeypad(
            onDigitPressed: _onDigit,
            onBackspacePressed: _onBackspace,
          ),
        ],
      ),
    );
  }
}
