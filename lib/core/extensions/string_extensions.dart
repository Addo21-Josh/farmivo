extension StringX on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts snake_case or SCREAMING_SNAKE to Title Case.
  String toTitleCase() {
    return split(RegExp(r'[_\s]+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');
  }
}
