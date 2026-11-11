import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  /// Formats date for display: "12 Jul 2027"
  String toDisplayDate() {
    return DateFormat('d MMM y').format(this);
  }

  /// Formats date with time: "12 Jul 2027, 2:30 PM"
  String toDisplayDateTime() {
    return DateFormat('d MMM y, h:mm a').format(this);
  }

  /// Short date for compact tables: "12/07/27"
  String toShortDate() {
    return DateFormat('dd/MM/yy').format(this);
  }

  /// Formats month and year: "July 2027"
  String toMonthYear() {
    return DateFormat('MMMM y').format(this);
  }

  /// Whether this date represents the same calendar day as [other].
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
