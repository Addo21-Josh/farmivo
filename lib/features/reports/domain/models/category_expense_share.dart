import 'package:flutter/material.dart';
import '../../../../core/money/money.dart';

/// Represents a single budget/expense category's share of overall expenditures.
class CategoryExpenseShare {
  final String categoryId;
  final String categoryName;
  final Money totalSpent;
  final double percentage;
  final Color color;

  const CategoryExpenseShare({
    required this.categoryId,
    required this.categoryName,
    required this.totalSpent,
    required this.percentage,
    required this.color,
  });

  /// Distinct theme-calibrated color palette for category distribution.
  static const List<Color> palette = [
    Color(0xFF2E7D32), // Forest Green
    Color(0xFF1E88E5), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFF64748B), // Slate
  ];

  static Color resolveColor(int index) {
    return palette[index % palette.length];
  }
}
