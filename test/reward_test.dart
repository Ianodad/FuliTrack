import 'package:flutter_test/flutter_test.dart';
import 'package:fulitrack/models/models.dart';

void main() {
  group('Reward Evaluation Logic', () {
    FulizaReward? evaluateReward({
      required double previous,
      required double current,
      required DateTime periodStart,
      required RewardPeriod period,
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
          comparisonType: ComparisonType.combined,
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
          comparisonType: ComparisonType.combined,
        );
      }

      return null;
    }

    test('should return zeroFuliza when current is 0', () {
      final reward = evaluateReward(
        previous: 1000,
        current: 0,
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNotNull);
      expect(reward!.type, equals(RewardType.zeroFuliza));
    });

    test('should return gold for 50%+ reduction', () {
      final reward = evaluateReward(
        previous: 1000,
        current: 400, // 60% reduction
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNotNull);
      expect(reward!.type, equals(RewardType.gold));
    });

    test('should return silver for 25-49% reduction', () {
      final reward = evaluateReward(
        previous: 1000,
        current: 700, // 30% reduction
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNotNull);
      expect(reward!.type, equals(RewardType.silver));
    });

    test('should return bronze for 10-24% reduction', () {
      final reward = evaluateReward(
        previous: 1000,
        current: 850, // 15% reduction
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNotNull);
      expect(reward!.type, equals(RewardType.bronze));
    });

    test('should return null for less than 10% reduction', () {
      final reward = evaluateReward(
        previous: 1000,
        current: 950, // 5% reduction
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNull);
    });

    test('should return null for increase in usage', () {
      final reward = evaluateReward(
        previous: 1000,
        current: 1500, // 50% increase
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNull);
    });

    test('should return null when previous is 0', () {
      final reward = evaluateReward(
        previous: 0,
        current: 500,
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNull);
    });

    test('should return zeroFuliza when both are 0', () {
      final reward = evaluateReward(
        previous: 0,
        current: 0,
        periodStart: DateTime(2024, 5, 1),
        period: RewardPeriod.monthly,
      );

      expect(reward, isNotNull);
      expect(reward!.type, equals(RewardType.zeroFuliza));
    });
  });

  group('FulizaReward', () {
    test('should calculate correct reduction percentage', () {
      final reward = FulizaReward(
        type: RewardType.gold,
        period: RewardPeriod.monthly,
        periodStart: DateTime(2024, 5, 1),
        awardedAt: DateTime.now(),
        previousValue: 1000,
        currentValue: 400,
        comparisonType: ComparisonType.combined,
      );

      expect(reward.reductionPercentage, equals(60));
    });

    test('should return correct display name', () {
      expect(
        FulizaReward(
          type: RewardType.gold,
          period: RewardPeriod.monthly,
          periodStart: DateTime(2024, 5, 1),
          awardedAt: DateTime.now(),
          previousValue: 0,
          currentValue: 0,
          comparisonType: ComparisonType.combined,
        ).displayName,
        equals('Gold'),
      );

      expect(
        FulizaReward(
          type: RewardType.zeroFuliza,
          period: RewardPeriod.monthly,
          periodStart: DateTime(2024, 5, 1),
          awardedAt: DateTime.now(),
          previousValue: 0,
          currentValue: 0,
          comparisonType: ComparisonType.combined,
        ).displayName,
        equals('Zero Fuliza'),
      );
    });
  });

  group('FulizaSummary', () {
    test('should calculate correct average interest per loan', () {
      final summary = FulizaSummary(
        totalLoaned: 1000,
        totalInterest: 100,
        totalRepaid: 500,
        outstandingBalance: 600,
        transactionCount: 5,
      );

      expect(summary.averageInterestPerLoan, equals(20));
    });

    test('should calculate correct interest rate', () {
      final summary = FulizaSummary(
        totalLoaned: 1000,
        totalInterest: 50,
        totalRepaid: 500,
        outstandingBalance: 550,
        transactionCount: 5,
      );

      expect(summary.interestRate, equals(5));
    });

    test('should return 0 for empty summary', () {
      final summary = FulizaSummary.empty();

      expect(summary.totalLoaned, equals(0));
      expect(summary.totalInterest, equals(0));
      expect(summary.averageInterestPerLoan, equals(0));
      expect(summary.interestRate, equals(0));
    });
  });
}
