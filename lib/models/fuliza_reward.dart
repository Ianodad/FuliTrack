/// Types of rewards that can be earned
enum RewardType {
  bronze,     // 10% reduction
  silver,     // 25% reduction
  gold,       // 50%+ reduction
  zeroFuliza, // No Fuliza usage in period
  consistency, // 3 consecutive improvements
}

/// Comparison type for reward evaluation
enum ComparisonType {
  interestOnly,
  principalOnly,
  combined,
}

/// Period type for reward evaluation
enum RewardPeriod {
  weekly,
  monthly,
}

/// Represents an earned reward for financial discipline
class FulizaReward {
  final int? id;
  final RewardType type;
  final RewardPeriod period;
  final DateTime periodStart;
  final DateTime awardedAt;
  final double previousValue;
  final double currentValue;
  final ComparisonType comparisonType;

  FulizaReward({
    this.id,
    required this.type,
    required this.period,
    required this.periodStart,
    required this.awardedAt,
    required this.previousValue,
    required this.currentValue,
    required this.comparisonType,
  });

  /// Calculate the reduction percentage
  double get reductionPercentage {
    if (previousValue == 0) return 0;
    return ((previousValue - currentValue) / previousValue) * 100;
  }

  /// Get display name for the reward type
  String get displayName {
    switch (type) {
      case RewardType.bronze:
        return 'Bronze';
      case RewardType.silver:
        return 'Silver';
      case RewardType.gold:
        return 'Gold';
      case RewardType.zeroFuliza:
        return 'Zero Fuliza';
      case RewardType.consistency:
        return 'Consistency';
    }
  }

  /// Get emoji for the reward type
  String get emoji {
    switch (type) {
      case RewardType.bronze:
        return '';
      case RewardType.silver:
        return '';
      case RewardType.gold:
        return '';
      case RewardType.zeroFuliza:
        return '';
      case RewardType.consistency:
        return '';
    }
  }

  /// Get description message for the reward
  String get description {
    final periodLabel = period == RewardPeriod.weekly ? 'week' : 'month';

    switch (type) {
      case RewardType.zeroFuliza:
        return 'Zero Fuliza usage this $periodLabel - keep it up!';
      case RewardType.gold:
        return 'You reduced Fuliza by ${reductionPercentage.toStringAsFixed(0)}% compared to last $periodLabel!';
      case RewardType.silver:
        return 'Great progress! ${reductionPercentage.toStringAsFixed(0)}% reduction this $periodLabel';
      case RewardType.bronze:
        return 'Good start! ${reductionPercentage.toStringAsFixed(0)}% reduction this $periodLabel';
      case RewardType.consistency:
        return '3 consecutive periods of improvement!';
    }
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'period': period.name,
      'period_start': periodStart.millisecondsSinceEpoch,
      'awarded_at': awardedAt.millisecondsSinceEpoch,
      'previous_value': previousValue,
      'current_value': currentValue,
      'comparison_type': comparisonType.name,
    };
  }

  /// Create from database Map
  factory FulizaReward.fromMap(Map<String, dynamic> map) {
    return FulizaReward(
      id: map['id'] as int?,
      type: RewardType.values.firstWhere((e) => e.name == map['type']),
      period: RewardPeriod.values.firstWhere((e) => e.name == map['period']),
      periodStart: DateTime.fromMillisecondsSinceEpoch(map['period_start'] as int),
      awardedAt: DateTime.fromMillisecondsSinceEpoch(map['awarded_at'] as int),
      previousValue: (map['previous_value'] as num).toDouble(),
      currentValue: (map['current_value'] as num).toDouble(),
      comparisonType: ComparisonType.values.firstWhere(
        (e) => e.name == map['comparison_type'],
        orElse: () => ComparisonType.combined,
      ),
    );
  }

  FulizaReward copyWith({
    int? id,
    RewardType? type,
    RewardPeriod? period,
    DateTime? periodStart,
    DateTime? awardedAt,
    double? previousValue,
    double? currentValue,
    ComparisonType? comparisonType,
  }) {
    return FulizaReward(
      id: id ?? this.id,
      type: type ?? this.type,
      period: period ?? this.period,
      periodStart: periodStart ?? this.periodStart,
      awardedAt: awardedAt ?? this.awardedAt,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      comparisonType: comparisonType ?? this.comparisonType,
    );
  }

  @override
  String toString() {
    return 'FulizaReward(type: $type, period: $period, reduction: ${reductionPercentage.toStringAsFixed(1)}%)';
  }
}
