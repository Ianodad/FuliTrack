import 'package:intl/intl.dart';

/// Utility functions for date manipulation
class FuliDateUtils {
  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final diff = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final diff = 7 - date.weekday;
    return DateTime(date.year, date.month, date.day + diff, 23, 59, 59);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  /// Get ISO week number
  static int getIsoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final weekday = date.weekday;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  /// Get weekly period key (e.g., "2024-W18")
  static String getWeeklyKey(DateTime date) {
    final weekNumber = getIsoWeekNumber(date);
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Get monthly period key (e.g., "2024-05")
  static String getMonthlyKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  /// Get yearly period key (e.g., "2024")
  static String getYearlyKey(DateTime date) {
    return date.year.toString();
  }

  /// Get previous week's date range
  static (DateTime, DateTime) previousWeek(DateTime date) {
    final currentStart = startOfWeek(date);
    final prevStart = currentStart.subtract(const Duration(days: 7));
    final prevEnd = prevStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return (prevStart, prevEnd);
  }

  /// Get previous month's date range
  static (DateTime, DateTime) previousMonth(DateTime date) {
    final prevMonth = DateTime(date.year, date.month - 1, 1);
    return (startOfMonth(prevMonth), endOfMonth(prevMonth));
  }

  /// Get same week last year
  static (DateTime, DateTime) sameWeekLastYear(DateTime date) {
    final weekNum = getIsoWeekNumber(date);
    final lastYear = date.year - 1;
    // Find the first day of that week number in last year
    // January 4th is always in week 1
    final jan4 = DateTime(lastYear, 1, 4);
    final startOfWeek1 = FuliDateUtils.startOfWeek(jan4);
    final targetWeekStart = startOfWeek1.add(Duration(days: (weekNum - 1) * 7));
    return (targetWeekStart, endOfWeek(targetWeekStart));
  }

  /// Get same month last year
  static (DateTime, DateTime) sameMonthLastYear(DateTime date) {
    final lastYear = DateTime(date.year - 1, date.month, 1);
    return (startOfMonth(lastYear), endOfMonth(lastYear));
  }

  /// Format date as readable string
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date range as readable string
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('dd').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  /// Get relative time description
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
