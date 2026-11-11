import 'package:flutter/material.dart';

/// Tactile on-screen numeric keypad for offline PIN entry (Milestone 9.1).
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometricButton;
  final bool isEnabled;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onBiometricPressed,
    this.showBiometricButton = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(context, ['1', '2', '3']),
          const SizedBox(height: 12),
          _buildRow(context, ['4', '5', '6']),
          const SizedBox(height: 12),
          _buildRow(context, ['7', '8', '9']),
          const SizedBox(height: 12),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeyButton(context, d)).toList(),
    );
  }

  Widget _buildKeyButton(BuildContext context, String digit) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => onDigitPressed(digit) : null,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled
                ? theme.colorScheme.surfaceContainerHighest.withAlpha(120)
                : theme.colorScheme.surfaceContainerHighest.withAlpha(40),
            border: Border.all(
              color: theme.dividerColor.withAlpha(60),
              width: 1,
            ),
          ),
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? theme.textTheme.titleLarge?.color
                  : theme.disabledColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Bottom Left: Biometric trigger or placeholder
        SizedBox(
          width: 72,
          height: 72,
          child: showBiometricButton && onBiometricPressed != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled ? onBiometricPressed : null,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withAlpha(25),
                      ),
                      child: Icon(
                        Icons.fingerprint_rounded,
                        size: 32,
                        color: isEnabled
                            ? theme.colorScheme.primary
                            : theme.disabledColor,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Bottom Center: 0
        _buildKeyButton(context, '0'),

        // Bottom Right: Backspace
        SizedBox(
          width: 72,
          height: 72,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onBackspacePressed : null,
              borderRadius: BorderRadius.circular(40),
              child: Container(
                alignment: Alignment.center,
                child: Icon(
                  Icons.backspace_outlined,
                  size: 26,
                  color: isEnabled
                      ? theme.textTheme.titleLarge?.color
                      : theme.disabledColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
