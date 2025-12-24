import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'new_dashboard_screen.dart';
import 'new_activity_screen.dart';
import 'new_rewards_screen.dart';
import 'new_settings_screen.dart';

/// Main home screen with premium floating bottom navigation
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
      backgroundColor: AppTheme.slate50,
      body: Stack(
        children: [
          // Main content area
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating Bottom Navigation
          Positioned(
            left: 32,
            right: 32,
            bottom: 32,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.slate900.withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter:
                      ColorFilter.mode(Colors.transparent, BlendMode.overlay),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.dashboard_rounded,
                          label: 'HUB',
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.history_rounded,
                          label: 'LOGS',
                        ),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.emoji_events_rounded,
                          label: 'BADGES',
                        ),
                        _buildNavItem(
                          index: 3,
                          icon: Icons.settings_rounded,
                          label: 'SETUP',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()..scale(isActive ? 1.1 : 1.0),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? AppTheme.teal400 : AppTheme.slate500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: isActive ? AppTheme.teal400 : AppTheme.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
