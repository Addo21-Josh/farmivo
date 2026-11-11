import 'package:flutter/material.dart';

/// Animated visual indicator displaying entered PIN digits as secure filled dots (Milestone 9.1).
class PinDisplayDots extends StatefulWidget {
  final int totalDigits;
  final int enteredDigits;
  final bool hasError;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? errorColor;

  const PinDisplayDots({
    super.key,
    required this.totalDigits,
    required this.enteredDigits,
    this.hasError = false,
    this.activeColor,
    this.inactiveColor,
    this.errorColor,
  });

  @override
  State<PinDisplayDots> createState() => _PinDisplayDotsState();
}

class _PinDisplayDotsState extends State<PinDisplayDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void didUpdateWidget(covariant PinDisplayDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController
          .forward(from: 0.0)
          .then((_) => _shakeController.reverse());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active =
        widget.activeColor ?? const Color(0xFF1B6B2F); // Default Forest Green
    final inactive = widget.inactiveColor ?? theme.dividerColor;
    final error = widget.errorColor ?? Colors.red.shade700;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = widget.hasError ? _shakeAnimation.value : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.totalDigits, (index) {
          final isFilled = index < widget.enteredDigits;
          final dotColor = widget.hasError
              ? error
              : isFilled
              ? active
              : inactive;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: isFilled ? 18 : 16,
            height: isFilled ? 18 : 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? dotColor : Colors.transparent,
              border: Border.all(color: dotColor, width: 2.0),
              boxShadow: isFilled && !widget.hasError
                  ? [
                      BoxShadow(
                        color: active.withAlpha(80),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
