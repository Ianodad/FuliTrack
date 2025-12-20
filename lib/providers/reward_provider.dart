import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'database_provider.dart';

/// State for rewards
class RewardState {
  final List<FulizaReward> rewards;
  final bool isLoading;
  final String? error;
  final int consecutiveImprovements;

  RewardState({
    this.rewards = const [],
    this.isLoading = false,
    this.error,
    this.consecutiveImprovements = 0,
  });

  RewardState copyWith({
    List<FulizaReward>? rewards,
    bool? isLoading,
    String? error,
    int? consecutiveImprovements,
  }) {
    return RewardState(
      rewards: rewards ?? this.rewards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      consecutiveImprovements: consecutiveImprovements ?? this.consecutiveImprovements,
    );
  }
}

/// Notifier for managing rewards
class RewardNotifier extends StateNotifier<RewardState> {
  final DatabaseService _db;

  RewardNotifier(this._db) : super(RewardState()) {
    loadRewards();
  }

  /// Load rewards from database
  Future<void> loadRewards() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rewards = await _db.getAllRewards();
      final consecutive = _calculateConsecutiveImprovements(rewards);

      state = state.copyWith(
        rewards: rewards,
        isLoading: false,
        consecutiveImprovements: consecutive,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load rewards: $e',
      );
    }
  }

  /// Evaluate and potentially award a reward for a period
  Future<FulizaReward?> evaluateReward({
    required double previous,
    required double current,
    required DateTime periodStart,
    required RewardPeriod period,
    required ComparisonType comparisonType,
  }) async {
    final reward = _evaluateRewardLogic(
      previous: previous,
      current: current,
      periodStart: periodStart,
      period: period,
      comparisonType: comparisonType,
    );

    if (reward != null) {
      await _db.insertReward(reward);
      await loadRewards();
    }

    return reward;
  }

  /// Core reward evaluation logic
  FulizaReward? _evaluateRewardLogic({
    required double previous,
    required double current,
    required DateTime periodStart,
    required RewardPeriod period,
    required ComparisonType comparisonType,
  }) {
    // Zero Fuliza achievement
    if (current == 0) {
      return FulizaReward(
        type: RewardType.zeroFuliza,
        period: period,
        periodStart: periodStart,
        awardedAt: DateTime.now(),
        previousValue: previous,
        currentValue: current,
        comparisonType: comparisonType,
      );
    }

    // Can't calculate reduction if previous was zero
    if (previous == 0) return null;

    final reduction = (previous - current) / previous;

    RewardType? type;
    if (reduction >= 0.5) {
      type = RewardType.gold;
    } else if (reduction >= 0.25) {
      type = RewardType.silver;
    } else if (reduction >= 0.1) {
      type = RewardType.bronze;
    }

    if (type != null) {
      return FulizaReward(
        type: type,
        period: period,
        periodStart: periodStart,
        awardedAt: DateTime.now(),
        previousValue: previous,
        currentValue: current,
        comparisonType: comparisonType,
      );
    }

    return null;
  }

  /// Check for consistency reward (3 consecutive improvements)
  Future<FulizaReward?> checkConsistencyReward({
    required DateTime periodStart,
    required RewardPeriod period,
    required ComparisonType comparisonType,
  }) async {
    // Get recent rewards
    final recentRewards = await _db.getRecentRewards(limit: 3);

    if (recentRewards.length >= 3) {
      // Check if last 3 are all improvements (not zeroFuliza which is special)
      final allImprovements = recentRewards.take(3).every((r) =>
          r.type == RewardType.bronze ||
          r.type == RewardType.silver ||
          r.type == RewardType.gold);

      if (allImprovements) {
        // Check we haven't already awarded consistency for this period
        final hasConsistency = recentRewards.any(
          (r) => r.type == RewardType.consistency,
        );

        if (!hasConsistency) {
          final reward = FulizaReward(
            type: RewardType.consistency,
            period: period,
            periodStart: periodStart,
            awardedAt: DateTime.now(),
            previousValue: 0,
            currentValue: 0,
            comparisonType: comparisonType,
          );

          await _db.insertReward(reward);
          await loadRewards();
          return reward;
        }
      }
    }

    return null;
  }

  /// Calculate consecutive improvements
  int _calculateConsecutiveImprovements(List<FulizaReward> rewards) {
    int count = 0;
    for (final reward in rewards) {
      if (reward.type == RewardType.bronze ||
          reward.type == RewardType.silver ||
          reward.type == RewardType.gold ||
          reward.type == RewardType.zeroFuliza) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Get rewards by type
  List<FulizaReward> getRewardsByType(RewardType type) {
    return state.rewards.where((r) => r.type == type).toList();
  }

  /// Get reward count by type
  Map<RewardType, int> getRewardCounts() {
    final counts = <RewardType, int>{};
    for (final type in RewardType.values) {
      counts[type] = state.rewards.where((r) => r.type == type).length;
    }
    return counts;
  }

  /// Delete all rewards
  Future<void> deleteAllRewards() async {
    await _db.deleteAllRewards();
    state = RewardState();
  }
}

/// Provider for reward state
final rewardProvider = StateNotifierProvider<RewardNotifier, RewardState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return RewardNotifier(db);
});

/// Provider for recent rewards only
final recentRewardsProvider = Provider<List<FulizaReward>>((ref) {
  final rewards = ref.watch(rewardProvider).rewards;
  return rewards.take(5).toList();
});

/// Provider for reward counts
final rewardCountsProvider = Provider<Map<RewardType, int>>((ref) {
  final rewards = ref.watch(rewardProvider).rewards;
  final counts = <RewardType, int>{};
  for (final type in RewardType.values) {
    counts[type] = rewards.where((r) => r.type == type).length;
  }
  return counts;
});
