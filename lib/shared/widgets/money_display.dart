import 'package:flutter/material.dart';
import '../../core/money/money.dart';
import '../../app/theme/app_theme_extension.dart';

enum MoneyDisplaySentiment { neutral, positive, negative }

/// Prominent outdoor display widget for financial sums.
class MoneyDisplay extends StatelessWidget {
  final Money money;
  final TextStyle? style;
  final MoneyDisplaySentiment sentiment;
  final bool showSign;

  const MoneyDisplay({
    super.key,
    required this.money,
    this.style,
    this.sentiment = MoneyDisplaySentiment.neutral,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    Color textColor;
    switch (sentiment) {
      case MoneyDisplaySentiment.positive:
        textColor = colors.cashIn;
        break;
      case MoneyDisplaySentiment.negative:
        textColor = colors.cashOut;
        break;
      case MoneyDisplaySentiment.neutral:
        textColor = theme.textTheme.displayMedium?.color ?? Colors.black;
        break;
    }

    final formattedText = money.format();
    final displayText = showSign && money.isPositive
        ? '+$formattedText'
        : formattedText;

    return Text(
      displayText,
      style: (style ?? theme.textTheme.titleLarge)?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
