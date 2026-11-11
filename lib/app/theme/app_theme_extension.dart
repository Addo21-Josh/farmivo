import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic ThemeExtension providing specialized agricultural and financial tokens.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color healthGreen;
  final Color healthGreenBg;
  final Color healthYellow;
  final Color healthYellowBg;
  final Color healthRed;
  final Color healthRedBg;

  final Color cashIn;
  final Color cashInBg;
  final Color cashOut;
  final Color cashOutBg;
  final Color creditPending;
  final Color creditPendingBg;

  final Color cardBorder;
  final Color inputBorder;
  final Color subtleSurface;

  const AppThemeExtension({
    required this.healthGreen,
    required this.healthGreenBg,
    required this.healthYellow,
    required this.healthYellowBg,
    required this.healthRed,
    required this.healthRedBg,
    required this.cashIn,
    required this.cashInBg,
    required this.cashOut,
    required this.cashOutBg,
    required this.creditPending,
    required this.creditPendingBg,
    required this.cardBorder,
    required this.inputBorder,
    required this.subtleSurface,
  });

  /// Light theme tokens (high outdoor contrast).
  static const light = AppThemeExtension(
    healthGreen: AppColors.healthGreen,
    healthGreenBg: AppColors.healthGreenBg,
    healthYellow: AppColors.healthYellow,
    healthYellowBg: AppColors.healthYellowBg,
    healthRed: AppColors.healthRed,
    healthRedBg: AppColors.healthRedBg,
    cashIn: AppColors.cashIn,
    cashInBg: Color(0xFFDCFCE7),
    cashOut: AppColors.cashOut,
    cashOutBg: Color(0xFFFEE2E2),
    creditPending: AppColors.creditPending,
    creditPendingBg: Color(0xFFFEF3C7),
    cardBorder: Color(0xFFD1D5DB),
    inputBorder: Color(0xFF9CA3AF),
    subtleSurface: Color(0xFFF3F4F6),
  );

  /// Dark theme tokens.
  static const dark = AppThemeExtension(
    healthGreen: Color(0xFF4ADE80),
    healthGreenBg: Color(0xFF064E3B),
    healthYellow: Color(0xFFFBBF24),
    healthYellowBg: Color(0xFF78350F),
    healthRed: Color(0xFFF87171),
    healthRedBg: Color(0xFF7F1D1D),
    cashIn: Color(0xFF4ADE80),
    cashInBg: Color(0xFF064E3B),
    cashOut: Color(0xFFF87171),
    cashOutBg: Color(0xFF7F1D1D),
    creditPending: Color(0xFFFBBF24),
    creditPendingBg: Color(0xFF78350F),
    cardBorder: Color(0xFF374151),
    inputBorder: Color(0xFF4B5563),
    subtleSurface: Color(0xFF1F2937),
  );

  /// Pure OLED Black High-Contrast theme tokens.
  static const oled = AppThemeExtension(
    healthGreen: Color(0xFF4ADE80),
    healthGreenBg: Color(0xFF064E3B),
    healthYellow: Color(0xFFFBBF24),
    healthYellowBg: Color(0xFF78350F),
    healthRed: Color(0xFFF87171),
    healthRedBg: Color(0xFF7F1D1D),
    cashIn: Color(0xFF4ADE80),
    cashInBg: Color(0xFF064E3B),
    cashOut: Color(0xFFF87171),
    cashOutBg: Color(0xFF7F1D1D),
    creditPending: Color(0xFFFBBF24),
    creditPendingBg: Color(0xFF78350F),
    cardBorder: AppColors.cardBorderOled,
    inputBorder: Color(0xFF555555),
    subtleSurface: Color(0xFF111111),
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? healthGreen,
    Color? healthGreenBg,
    Color? healthYellow,
    Color? healthYellowBg,
    Color? healthRed,
    Color? healthRedBg,
    Color? cashIn,
    Color? cashInBg,
    Color? cashOut,
    Color? cashOutBg,
    Color? creditPending,
    Color? creditPendingBg,
    Color? cardBorder,
    Color? inputBorder,
    Color? subtleSurface,
  }) {
    return AppThemeExtension(
      healthGreen: healthGreen ?? this.healthGreen,
      healthGreenBg: healthGreenBg ?? this.healthGreenBg,
      healthYellow: healthYellow ?? this.healthYellow,
      healthYellowBg: healthYellowBg ?? this.healthYellowBg,
      healthRed: healthRed ?? this.healthRed,
      healthRedBg: healthRedBg ?? this.healthRedBg,
      cashIn: cashIn ?? this.cashIn,
      cashInBg: cashInBg ?? this.cashInBg,
      cashOut: cashOut ?? this.cashOut,
      cashOutBg: cashOutBg ?? this.cashOutBg,
      creditPending: creditPending ?? this.creditPending,
      creditPendingBg: creditPendingBg ?? this.creditPendingBg,
      cardBorder: cardBorder ?? this.cardBorder,
      inputBorder: inputBorder ?? this.inputBorder,
      subtleSurface: subtleSurface ?? this.subtleSurface,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      healthGreen: Color.lerp(healthGreen, other.healthGreen, t)!,
      healthGreenBg: Color.lerp(healthGreenBg, other.healthGreenBg, t)!,
      healthYellow: Color.lerp(healthYellow, other.healthYellow, t)!,
      healthYellowBg: Color.lerp(healthYellowBg, other.healthYellowBg, t)!,
      healthRed: Color.lerp(healthRed, other.healthRed, t)!,
      healthRedBg: Color.lerp(healthRedBg, other.healthRedBg, t)!,
      cashIn: Color.lerp(cashIn, other.cashIn, t)!,
      cashInBg: Color.lerp(cashInBg, other.cashInBg, t)!,
      cashOut: Color.lerp(cashOut, other.cashOut, t)!,
      cashOutBg: Color.lerp(cashOutBg, other.cashOutBg, t)!,
      creditPending: Color.lerp(creditPending, other.creditPending, t)!,
      creditPendingBg: Color.lerp(creditPendingBg, other.creditPendingBg, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
    );
  }
}

extension AppThemeExtensionX on BuildContext {
  /// Convenient accessor for agricultural & financial design tokens.
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
}
