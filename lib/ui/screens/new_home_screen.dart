import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'new_dashboard_screen.dart';
import 'new_activity_screen.dart';
import 'new_rewards_screen.dart';
import 'new_settings_screen.dart';

/// Main home screen with bottom navigation
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    NewDashboardScreen(),
    NewActivityScreen(),
    NewRewardsScreen(),
    NewSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'HOME',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.history,
                  activeIcon: Icons.history,
                  label: 'HISTORY',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.emoji_events_outlined,
                  activeIcon: Icons.emoji_events,
                  label: 'BADGES',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'SETUP',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.teal50 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? AppTheme.primaryTeal : AppTheme.slate400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? AppTheme.primaryTeal : AppTheme.slate400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
