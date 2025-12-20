import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../theme/app_theme.dart';

/// Screen showing earned rewards and badges
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardState = ref.watch(rewardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
      ),
      body: rewardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge summary
                  _BadgeSummary(rewards: rewardState.rewards),

                  const SizedBox(height: 24),

                  // Streak info
                  if (rewardState.consecutiveImprovements > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StreakCard(
                        streak: rewardState.consecutiveImprovements,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Recent rewards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Recent Achievements',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (rewardState.rewards.isEmpty)
                    _EmptyRewardsState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rewardState.rewards.length,
                      itemBuilder: (context, index) {
                        return _RewardTile(reward: rewardState.rewards[index]);
                      },
                    ),

                  const SizedBox(height: 32),

                  // How rewards work
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'How Rewards Work',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _RewardInfoSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

/// Badge summary showing count of each reward type
class _BadgeSummary extends StatelessWidget {
  final List<FulizaReward> rewards;

  const _BadgeSummary({required this.rewards});

  @override
  Widget build(BuildContext context) {
    final counts = <RewardType, int>{};
    for (final type in RewardType.values) {
      counts[type] = rewards.where((r) => r.type == type).length;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Your Badges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BadgeIcon(
                emoji: '',
                label: 'Bronze',
                count: counts[RewardType.bronze] ?? 0,
                color: AppTheme.bronzeColor,
              ),
              _BadgeIcon(
                emoji: '',
                label: 'Silver',
                count: counts[RewardType.silver] ?? 0,
                color: AppTheme.silverColor,
              ),
              _BadgeIcon(
                emoji: '',
                label: 'Gold',
                count: counts[RewardType.gold] ?? 0,
                color: AppTheme.goldColor,
              ),
              _BadgeIcon(
                emoji: '',
                label: 'Zero',
                count: counts[RewardType.zeroFuliza] ?? 0,
                color: AppTheme.zeroFulizaColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _BadgeIcon({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Streak card showing consecutive improvements
class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.consistencyColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.consistencyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '',
                style: TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak Period Streak!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.consistencyColor,
                        ),
                  ),
                  Text(
                    'Keep reducing your Fuliza usage',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single reward tile
class _RewardTile extends StatelessWidget {
  final FulizaReward reward;

  const _RewardTile({required this.reward});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getRewardColor(reward.type);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            reward.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      title: Text(
        '${reward.displayName} Badge',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reward.description),
          const SizedBox(height: 4),
          Text(
            '${reward.period == RewardPeriod.weekly ? 'Week' : 'Month'} of ${FuliDateUtils.formatDate(reward.periodStart)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Color _getRewardColor(RewardType type) {
    switch (type) {
      case RewardType.bronze:
        return AppTheme.bronzeColor;
      case RewardType.silver:
        return AppTheme.silverColor;
      case RewardType.gold:
        return AppTheme.goldColor;
      case RewardType.zeroFuliza:
        return AppTheme.zeroFulizaColor;
      case RewardType.consistency:
        return AppTheme.consistencyColor;
    }
  }
}

/// Empty state for no rewards
class _EmptyRewardsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No rewards yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reduce your Fuliza usage to earn badges!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Information about how rewards work
class _RewardInfoSection extends StatelessWidget {
  const _RewardInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                emoji: '',
                title: 'Bronze Badge',
                description: 'Reduce Fuliza by 10% or more',
              ),
              const Divider(height: 24),
              _InfoRow(
                emoji: '',
                title: 'Silver Badge',
                description: 'Reduce Fuliza by 25% or more',
              ),
              const Divider(height: 24),
              _InfoRow(
                emoji: '',
                title: 'Gold Badge',
                description: 'Reduce Fuliza by 50% or more',
              ),
              const Divider(height: 24),
              _InfoRow(
                emoji: '',
                title: 'Zero Fuliza',
                description: 'No Fuliza usage in a period',
              ),
              const Divider(height: 24),
              _InfoRow(
                emoji: '',
                title: 'Consistency',
                description: '3 consecutive periods of improvement',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _InfoRow({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
