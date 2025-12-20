import '../models/models.dart';
import '../utils/date_utils.dart';
import 'database_service.dart';

/// Service for aggregating Fuliza data
class AggregationService {
  final DatabaseService _db;

  AggregationService(this._db);

  /// Get weekly summary for current week
  Future<FulizaSummary> getCurrentWeekSummary() async {
    final now = DateTime.now();
    final start = FuliDateUtils.startOfWeek(now);
    final end = FuliDateUtils.endOfWeek(now);
    return _db.getSummary(start: start, end: end);
  }

  /// Get monthly summary for current month
  Future<FulizaSummary> getCurrentMonthSummary() async {
    final now = DateTime.now();
    final start = FuliDateUtils.startOfMonth(now);
    final end = FuliDateUtils.endOfMonth(now);
    return _db.getSummary(start: start, end: end);
  }

  /// Get yearly summary for current year
  Future<FulizaSummary> getCurrentYearSummary() async {
    final now = DateTime.now();
    final start = FuliDateUtils.startOfYear(now);
    final end = FuliDateUtils.endOfYear(now);
    return _db.getSummary(start: start, end: end);
  }

  /// Get summary for previous week
  Future<FulizaSummary> getPreviousWeekSummary() async {
    final (start, end) = FuliDateUtils.previousWeek(DateTime.now());
    return _db.getSummary(start: start, end: end);
  }

  /// Get summary for previous month
  Future<FulizaSummary> getPreviousMonthSummary() async {
    final (start, end) = FuliDateUtils.previousMonth(DateTime.now());
    return _db.getSummary(start: start, end: end);
  }

  /// Get summary for same week last year
  Future<FulizaSummary> getSameWeekLastYearSummary() async {
    final (start, end) = FuliDateUtils.sameWeekLastYear(DateTime.now());
    return _db.getSummary(start: start, end: end);
  }

  /// Get summary for same month last year
  Future<FulizaSummary> getSameMonthLastYearSummary() async {
    final (start, end) = FuliDateUtils.sameMonthLastYear(DateTime.now());
    return _db.getSummary(start: start, end: end);
  }

  /// Get all-time summary
  Future<FulizaSummary> getAllTimeSummary() async {
    return _db.getSummary();
  }

  /// Get monthly summaries for the last N months (for charts)
  Future<List<MonthlyData>> getMonthlyTrend({int months = 6}) async {
    final result = <MonthlyData>[];
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = FuliDateUtils.startOfMonth(month);
      final end = FuliDateUtils.endOfMonth(month);
      final summary = await _db.getSummary(start: start, end: end);

      result.add(MonthlyData(
        month: month,
        summary: summary,
        label: _getMonthLabel(month),
      ));
    }

    return result.reversed.toList();
  }

  /// Get weekly summaries for the last N weeks (for charts)
  Future<List<WeeklyData>> getWeeklyTrend({int weeks = 8}) async {
    final result = <WeeklyData>[];
    final now = DateTime.now();
    var currentWeekStart = FuliDateUtils.startOfWeek(now);

    for (int i = 0; i < weeks; i++) {
      final start = currentWeekStart.subtract(Duration(days: i * 7));
      final end = FuliDateUtils.endOfWeek(start);
      final summary = await _db.getSummary(start: start, end: end);

      result.add(WeeklyData(
        weekStart: start,
        summary: summary,
        label: 'W${FuliDateUtils.getIsoWeekNumber(start)}',
      ));
    }

    return result.reversed.toList();
  }

  String _getMonthLabel(DateTime month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month.month - 1];
  }

  /// Calculate comparison between two periods
  ComparisonResult comparePeriodicData({
    required FulizaSummary current,
    required FulizaSummary previous,
    required ComparisonTypePreference preference,
  }) {
    double currentValue;
    double previousValue;

    switch (preference) {
      case ComparisonTypePreference.interestOnly:
        currentValue = current.totalInterest;
        previousValue = previous.totalInterest;
        break;
      case ComparisonTypePreference.principalOnly:
        currentValue = current.totalLoaned;
        previousValue = previous.totalLoaned;
        break;
      case ComparisonTypePreference.combined:
        currentValue = current.totalLoaned + current.totalInterest;
        previousValue = previous.totalLoaned + previous.totalInterest;
        break;
    }

    double changePercentage = 0;
    if (previousValue != 0) {
      changePercentage = ((currentValue - previousValue) / previousValue) * 100;
    }

    return ComparisonResult(
      currentValue: currentValue,
      previousValue: previousValue,
      changePercentage: changePercentage,
      isImprovement: currentValue < previousValue,
    );
  }
}

/// Data class for monthly trend
class MonthlyData {
  final DateTime month;
  final FulizaSummary summary;
  final String label;

  MonthlyData({
    required this.month,
    required this.summary,
    required this.label,
  });
}

/// Data class for weekly trend
class WeeklyData {
  final DateTime weekStart;
  final FulizaSummary summary;
  final String label;

  WeeklyData({
    required this.weekStart,
    required this.summary,
    required this.label,
  });
}

/// Result of period comparison
class ComparisonResult {
  final double currentValue;
  final double previousValue;
  final double changePercentage;
  final bool isImprovement;

  ComparisonResult({
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.isImprovement,
  });

  double get difference => currentValue - previousValue;
}
