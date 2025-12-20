/// Aggregated summary of Fuliza usage for a period
class FulizaSummary {
  final double totalLoaned;
  final double totalInterest;
  final double totalRepaid;
  final double outstandingBalance;
  final int transactionCount;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  FulizaSummary({
    required this.totalLoaned,
    required this.totalInterest,
    required this.totalRepaid,
    required this.outstandingBalance,
    required this.transactionCount,
    this.periodStart,
    this.periodEnd,
  });

  /// Empty summary with zero values
  factory FulizaSummary.empty() {
    return FulizaSummary(
      totalLoaned: 0,
      totalInterest: 0,
      totalRepaid: 0,
      outstandingBalance: 0,
      transactionCount: 0,
    );
  }

  /// Average interest per loan transaction
  double get averageInterestPerLoan {
    if (transactionCount == 0) return 0;
    return totalInterest / transactionCount;
  }

  /// Interest rate (interest / principal)
  double get interestRate {
    if (totalLoaned == 0) return 0;
    return (totalInterest / totalLoaned) * 100;
  }

  /// Total cost (principal + interest)
  double get totalCost => totalLoaned + totalInterest;

  /// Net position (what you still owe)
  double get netPosition => totalLoaned + totalInterest - totalRepaid;

  @override
  String toString() {
    return 'FulizaSummary(loaned: $totalLoaned, interest: $totalInterest, repaid: $totalRepaid, outstanding: $outstandingBalance)';
  }
}

/// Filter options for dashboard
enum DateFilter {
  thisWeek,
  thisMonth,
  thisYear,
  custom,
  allTime,
}

/// Settings for user preferences
class AppSettings {
  final ComparisonTypePreference comparisonPreference;
  final bool showCharts;
  final bool enableNotifications;

  AppSettings({
    this.comparisonPreference = ComparisonTypePreference.combined,
    this.showCharts = true,
    this.enableNotifications = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'comparison_preference': comparisonPreference.name,
      'show_charts': showCharts ? 1 : 0,
      'enable_notifications': enableNotifications ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      comparisonPreference: ComparisonTypePreference.values.firstWhere(
        (e) => e.name == map['comparison_preference'],
        orElse: () => ComparisonTypePreference.combined,
      ),
      showCharts: map['show_charts'] == 1,
      enableNotifications: map['enable_notifications'] == 1,
    );
  }

  AppSettings copyWith({
    ComparisonTypePreference? comparisonPreference,
    bool? showCharts,
    bool? enableNotifications,
  }) {
    return AppSettings(
      comparisonPreference: comparisonPreference ?? this.comparisonPreference,
      showCharts: showCharts ?? this.showCharts,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}

enum ComparisonTypePreference {
  interestOnly,
  principalOnly,
  combined,
}
