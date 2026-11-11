import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_guards.dart';
import '../../../../app/router/routes.dart';
import '../../../authentication/presentation/providers/security_providers.dart';
import '../providers/wipe_providers.dart';

/// Modal dialog enforcing multi-step confirmation and PIN verification
/// before performing an emergency data wipe and factory reset (Milestone 9.4).
class DataWipeConfirmationDialog extends ConsumerStatefulWidget {
  const DataWipeConfirmationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DataWipeConfirmationDialog(),
    );
  }

  @override
  ConsumerState<DataWipeConfirmationDialog> createState() =>
      _DataWipeConfirmationDialogState();
}

class _DataWipeConfirmationDialogState
    extends ConsumerState<DataWipeConfirmationDialog> {
  final TextEditingController _challengeController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _deleteBackups = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _challengeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  bool _canSubmit(bool isPinRequired) {
    if (_challengeController.text.trim().toUpperCase() != 'RESET') {
      return false;
    }
    if (isPinRequired && _pinController.text.trim().isEmpty) {
      return false;
    }
    return !_isLoading;
  }

  Future<void> _handleWipe(bool isPinRequired) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final wipeService = ref.read(dataWipeServiceProvider);

    // 1. Verify PIN if required
    if (isPinRequired) {
      final isAuthorized = await wipeService.verifyWipeAuthorization(
        _pinController.text.trim(),
      );
      if (!isAuthorized) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Incorrect security PIN. Factory reset cancelled.';
        });
        return;
      }
    }

    // 2. Execute factory reset
    final result = await wipeService.executeFactoryReset(
      deleteBackups: _deleteBackups,
    );

    if (!mounted) return;

    if (result.success) {
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);
      GoRouter? router;
      try {
        router = GoRouter.of(context);
      } catch (_) {}

      // 3. Reset application runtime state and route guards
      ref.read(authLockProvider.notifier).state = false;
      await ref.read(onboardingCompletedProvider.notifier).resetOnboarding();
      ref.read(securitySettingsProvider.notifier).refresh();

      if (!mounted) return;

      nav.pop(true);

      // 4. Navigate cleanly to onboarding screen
      router?.go(AppRoutes.onboarding);

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Factory reset complete. All device data and credentials cleared.',
          ),
          backgroundColor: Color(0xFF1B6B2F),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.errorMessage ?? 'Failed to execute factory reset.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPinRequiredAsync = ref.watch(isPinRequiredForWipeProvider);

    return isPinRequiredAsync.when(
      loading: () => const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load security requirements: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Close'),
          ),
        ],
      ),
      data: (isPinRequired) {
        final canSubmit = _canSubmit(isPinRequired);

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Emergency Factory Reset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Danger Warning Banner
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DANGER: This action cannot be undone. All data will be permanently wiped.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'The following will be completely erased from this device:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _buildBulletPoint('All farms, projects, budgets, and crops'),
                _buildBulletPoint(
                  'All recorded expenses, commercial sales & payments',
                ),
                _buildBulletPoint('All immutable forensic audit trail logs'),
                _buildBulletPoint(
                  'All security PINs and biometric authentication keys',
                ),
                const SizedBox(height: 12),

                // Option to delete backup archives
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Also delete offline backup files (.farmivo)',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _deleteBackups,
                  onChanged: _isLoading
                      ? null
                      : (val) => setState(() => _deleteBackups = val ?? false),
                ),
                const SizedBox(height: 12),

                // PIN Input (if enabled)
                if (isPinRequired) ...[
                  const Text(
                    'Enter Security PIN to authorize:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    key: const Key('wipe_pin_input'),
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter PIN',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                ],

                // Challenge Input
                const Text(
                  'Type RESET to confirm deletion:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('wipe_challenge_input'),
                  controller: _challengeController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'RESET',
                    prefixIcon: const Icon(Icons.keyboard_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Erasing all data & restoring factory defaults...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              key: const Key('wipe_confirm_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: canSubmit ? () => _handleWipe(isPinRequired) : null,
              child: const Text('Erase All Data Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
