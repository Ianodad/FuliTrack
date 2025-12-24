import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../../providers/providers.dart';

/// Rewards screen with premium design - Rewards Vault
class NewRewardsScreen extends ConsumerWidget {
  const NewRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardProvider).rewards;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'REWARDS VAULT',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.slate900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // Progress Card
              _buildProgressCard(),

              const SizedBox(height: 32),

              // Badges Section Header with Gradient
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GradientHeader(
                  title: 'Your Badges',
                  subtitle: 'Tap to view details',
                  icon: Icons.workspace_premium_rounded,
                ),
              ),

              const SizedBox(height: 16),

              // Badge Grid
              _buildBadgeGrid(rewards),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    const progress = 0.43; // 43% progress

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TappableCard(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.slate900,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glow effect
              Positioned(
                right: -24,
                bottom: -24,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.teal500.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Progress Ring
                    ProgressRing(
                      progress: progress,
                      size: 80,
                      strokeWidth: 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'DONE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate500,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MASTER MILESTONE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.teal400,
                                  letterSpacing: 2,
                                ),
                              ),
                              Icon(
                                Icons.bolt,
                                size: 16,
                                color: AppTheme.amber500,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'COST CUTTER II',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reduce Fuliza by 50% this month',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(List<dynamic> rewards) {
    final badges = [
      _BadgeData(
        label: 'Smart Start',
        icon: Icons.emoji_events_rounded,
        iconColor: AppTheme.bronzeColor,
        level: 'Bronze',
        earned: true,
        description: 'Started your journey to financial health.',
      ),
      _BadgeData(
        label: 'Cost Cutter',
        icon: Icons.trending_down_rounded,
        iconColor: AppTheme.teal500,
        level: 'Silver',
        earned: true,
        description: 'Reduced Fuliza interest by 25% in one month.',
      ),
      _BadgeData(
        label: 'Fuli Master',
        icon: Icons.emoji_events_rounded,
        iconColor: AppTheme.slate400,
        level: 'Gold',
        earned: false,
        description: 'Keep interest below Ksh 50 for 3 months.',
      ),
      _BadgeData(
        label: 'Zero Week',
        icon: Icons.local_fire_department_rounded,
        iconColor: AppTheme.orange500,
        level: 'Epic',
        earned: false,
        description: 'Zero Fuliza usage for 7 consecutive days.',
      ),
      _BadgeData(
        label: 'Debt Buster',
        icon: Icons.bolt_rounded,
        iconColor: AppTheme.emerald500,
        level: 'Pro',
        earned: true,
        description: 'Repaid over Ksh 5,000 this month.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
    return TappableCard(
      onTap: badge.earned ? () {
        // Could show badge details
      } : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: badge.earned ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppTheme.slate100),
            boxShadow: badge.earned
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: badge.earned ? AppTheme.teal50 : AppTheme.slate100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ColorFiltered(
                  colorFilter: badge.earned
                      ? const ColorFilter.mode(
                          Colors.transparent, BlendMode.multiply)
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
              const SizedBox(height: 16),

              // Label
              Text(
                badge.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.slate800,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badge.earned ? AppTheme.primaryTeal : AppTheme.slate200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.earned ? badge.level.toUpperCase() : 'LOCKED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: badge.earned ? Colors.white : AppTheme.slate500,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
