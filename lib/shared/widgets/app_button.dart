import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outlined, destructive }

/// Outdoor-friendly interactive button guaranteeing >= 48dp minimum touch target.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.width = double.infinity,
    this.height = 50.0, // Meets >= 48dp target
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: theme.colorScheme.primary.withAlpha(120),
          ),
          child: const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(onPressed: onPressed, child: buttonContent),
        );
      case AppButtonVariant.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurface,
            ),
            child: buttonContent,
          ),
        );
      case AppButtonVariant.outlined:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(onPressed: onPressed, child: buttonContent),
        );
      case AppButtonVariant.destructive:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: buttonContent,
          ),
        );
    }
  }
}
