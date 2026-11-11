import 'package:flutter/material.dart';

/// Outdoor-friendly high-contrast color tokens designed for high ambient sunlight.
class AppColors {
  AppColors._();

  // Primary Agriculture & Brand Tokens
  static const Color primaryGreen = Color(0xFF1B6B2F); // Deep forest green
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color primaryDark = Color(0xFF0F3E1A);

  // Surface and Backgrounds (High Contrast Light)
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color backgroundLight = Color(0xFFFFFFFF);

  // Surface and Backgrounds (Standard Dark)
  static const Color surfaceDark = Color(0xFF111417);
  static const Color backgroundDark = Color(0xFF0D0F11);

  // Surface and Backgrounds (Pure OLED Black)
  static const Color surfaceOled = Color(0xFF000000);
  static const Color backgroundOled = Color(0xFF000000);
  static const Color cardOled = Color(0xFF0A0A0A);
  static const Color cardBorderOled = Color(0xFF333333);

  // High-Contrast Text Tokens
  static const Color textPrimaryLight = Color(
    0xFF111827,
  ); // Very dark gray for glare
  static const Color textSecondaryLight = Color(0xFF374151);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Financial Health Badges
  static const Color healthGreen = Color(0xFF15803D); // Accessible Emerald
  static const Color healthGreenBg = Color(0xFFDCFCE7);
  static const Color healthYellow = Color(0xFFB45309); // Accessible Amber
  static const Color healthYellowBg = Color(0xFFFEF3C7);
  static const Color healthRed = Color(0xFFB91C1C); // Accessible Crimson
  static const Color healthRedBg = Color(0xFFFEE2E2);

  // Transaction Indicators
  static const Color cashIn = Color(0xFF16A34A);
  static const Color cashOut = Color(0xFFDC2626);
  static const Color creditPending = Color(0xFFD97706);
}
