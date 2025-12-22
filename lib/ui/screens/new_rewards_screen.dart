import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../providers/providers.dart';

/// Rewards screen with badges and progress
class NewRewardsScreen extends ConsumerWidget {
  const NewRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardProvider).rewards;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Rewards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
              ),

              // Progress Card
              _buildProgressCard(),

              const SizedBox(height: 24),

              // Badges Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your Badges',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Badge Grid
              _buildBadgeGrid(rewards),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.teal600, AppTheme.teal800],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress to Next Badge',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '43% Interest Reduction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.43,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.teal100),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep it up to unlock "Cost Cutter"',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(
              Icons.emoji_events,
              size: 128,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<dynamic> rewards) {
    // Mock badges matching React design
    final badges = [
      _BadgeData(
        label: 'Smart Start',
        icon: Icons.emoji_events,
        iconColor: AppTheme.bronzeColor,
        level: 'Bronze',
        earned: true,
        description: 'Started your journey to financial health.',
      ),
      _BadgeData(
        label: 'Cost Cutter',
        icon: Icons.trending_down,
        iconColor: AppTheme.slate400,
        level: 'Silver',
        earned: true,
        description: 'Reduced Fuliza interest by 25% in one month.',
      ),
      _BadgeData(
        label: 'Fuli Master',
        icon: Icons.emoji_events,
        iconColor: AppTheme.goldColor,
        level: 'Gold',
        earned: false,
        description: 'Keep interest below Ksh 50 for 3 months.',
      ),
      _BadgeData(
        label: 'Zero Week',
        icon: Icons.local_fire_department,
        iconColor: const Color(0xFFF97316),
        level: 'Epic',
        earned: false,
        description: 'Zero Fuliza usage for 7 consecutive days.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _BadgeCard(badge: badge);
        },
      ),
    );
  }
}

class _BadgeData {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String level;
  final bool earned;
  final String description;

  _BadgeData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.level,
    required this.earned,
    required this.description,
  });
}

class _BadgeCard extends StatelessWidget {
  final _BadgeData badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.earned ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: badge.earned ? AppTheme.slate50 : AppTheme.slate100,
                borderRadius: BorderRadius.circular(32),
                border: badge.earned
                    ? Border.all(color: AppTheme.teal50, width: 2)
                    : null,
              ),
              child: ColorFiltered(
                colorFilter: badge.earned
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                child: Icon(
                  badge.icon,
                  size: 32,
                  color: badge.iconColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Label
            Text(
              badge.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Level
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badge.earned ? AppTheme.teal100 : AppTheme.slate200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.earned ? badge.level : 'LOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badge.earned ? AppTheme.primaryTeal : AppTheme.slate500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
