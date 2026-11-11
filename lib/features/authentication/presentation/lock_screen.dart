import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/security_providers.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/pin_display_dots.dart';

/// Fullscreen security lock screen guarding confidential agricultural financial records (Milestone 9.1).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  bool _hasError = false;
  String? _errorMessage;
  Timer? _lockoutTimer;
  int _remainingLockoutSeconds = 0;
  bool _hasAttemptedAutoBiometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLockoutStatus();
      _attemptBiometricsOnStart();
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _checkLockoutStatus() {
    final settings = ref.read(securitySettingsProvider).value;
    if (settings != null && settings.isLockedOut) {
      setState(() {
        _remainingLockoutSeconds = settings.remainingLockoutSeconds;
      });
      _startLockoutCountdown();
    }
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingLockoutSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingLockoutSeconds = 0;
          _errorMessage = null;
        });
        ref.read(securitySettingsProvider.notifier).refresh();
      } else {
        setState(() {
          _remainingLockoutSeconds--;
        });
      }
    });
  }

  Future<void> _attemptBiometricsOnStart() async {
    if (_hasAttemptedAutoBiometrics) return;
    _hasAttemptedAutoBiometrics = true;

    final settings = ref.read(securitySettingsProvider).value;
    if (settings != null &&
        settings.isBiometricsEnabled &&
        !settings.isLockedOut) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      await ref.read(appLockControllerProvider).authenticateWithBiometrics();
    }
  }

  void _onDigitPressed(String digit, int pinLength) {
    if (_remainingLockoutSeconds > 0) return;
    if (_enteredPin.length >= pinLength) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == pinLength) {
      _verifyPin();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    final notifier = ref.read(securitySettingsProvider.notifier);
    final isValid = await notifier.verifyPin(_enteredPin);

    if (!mounted) return;

    if (isValid) {
      // PIN matched! Unlock application.
      await ref.read(appLockControllerProvider).unlock();
    } else {
      // PIN incorrect.
      final settings = ref.read(securitySettingsProvider).value;
      setState(() {
        _hasError = true;
        if (settings != null && settings.isLockedOut) {
          _remainingLockoutSeconds = settings.remainingLockoutSeconds;
          _errorMessage =
              'Too many failed attempts. Locked for $_remainingLockoutSeconds seconds.';
          _startLockoutCountdown();
        } else {
          final attemptsLeft = 5 - (settings?.failedAttempts ?? 0);
          _errorMessage =
              'Incorrect PIN. ${attemptsLeft > 0 ? '$attemptsLeft attempts remaining.' : ''}';
        }
      });

      // Clear entered PIN after short delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _enteredPin = '';
          });
        }
      });
    }
  }

  Future<void> _onManualBiometricPressed() async {
    if (_remainingLockoutSeconds > 0) return;
    await ref.read(appLockControllerProvider).authenticateWithBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(securitySettingsProvider);

    return PopScope(
      canPop: false, // Disallow hardware back button dismissal
      child: Scaffold(
        body: SafeArea(
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Security error: $err')),
            data: (settings) {
              final pinLength = settings.pinLength > 0 ? settings.pinLength : 4;
              final isLockedOut = _remainingLockoutSeconds > 0;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Security Shield Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1B6B2F).withAlpha(20),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 48,
                          color: Color(0xFF1B6B2F),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title & Subtitle
                      Text(
                        'Farmivo Security Lock',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLockedOut
                            ? 'Locked for $_remainingLockoutSeconds seconds due to failed attempts'
                            : 'Enter your $pinLength-digit security PIN to unlock',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isLockedOut
                              ? Colors.red.shade700
                              : Colors.grey.shade600,
                          fontWeight: isLockedOut
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // PIN Indicator Dots
                      PinDisplayDots(
                        totalDigits: pinLength,
                        enteredDigits: _enteredPin.length,
                        hasError: _hasError,
                      ),

                      // Error message banner
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: _errorMessage != null
                              ? Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Numeric Keypad
                      NumericKeypad(
                        isEnabled: !isLockedOut,
                        showBiometricButton: settings.isBiometricsEnabled,
                        onDigitPressed: (digit) =>
                            _onDigitPressed(digit, pinLength),
                        onBackspacePressed: _onBackspacePressed,
                        onBiometricPressed: _onManualBiometricPressed,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
