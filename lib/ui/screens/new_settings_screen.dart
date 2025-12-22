import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../providers/providers.dart';

/// Settings screen with preferences and data management
class NewSettingsScreen extends ConsumerWidget {
  const NewSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionHeader('PREFERENCES'),
              const SizedBox(height: 8),
              _buildPreferencesCard(context, ref),

              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader('DATA MANAGEMENT'),
              const SizedBox(height: 8),
              _buildDataManagementCard(context, ref),

              const SizedBox(height: 32),

              // App Info
              const Center(
                child: Column(
                  children: [
                    Text(
                      'FuliTrack v1.0.4 (MVP)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate400,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Offline & Privacy Centric',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.slate300,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.slate400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.slate100),
        ),
        child: Column(
          children: [
            _buildSettingItem(
              context,
              title: 'Default Period',
              value: 'Month',
              onTap: () => _showPeriodDialog(context),
              isFirst: true,
            ),
            const Divider(height: 1, color: AppTheme.slate50),
            _buildSettingItem(
              context,
              title: 'Compare Against',
              value: 'Month',
              onTap: () => _showCompareDialog(context),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.slate100),
        ),
        child: Column(
          children: [
            _buildActionItem(
              context,
              title: 'Re-scan SMS Messages',
              icon: Icons.refresh,
              color: AppTheme.primaryTeal,
              onTap: () => _rescanSms(context, ref),
              isFirst: true,
            ),
            const Divider(height: 1, color: AppTheme.slate50),
            _buildActionItem(
              context,
              title: 'Clear All Data',
              icon: Icons.info_outline,
              color: AppTheme.errorRed,
              onTap: () => _clearData(context, ref),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.slate700,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.slate400,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppTheme.slate400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Week', 'Month', 'Year'].map((period) {
            return RadioListTile<String>(
              title: Text(period),
              value: period,
              groupValue: 'Month',
              onChanged: (_) {
                Navigator.pop(context);
                // TODO: Save preference
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCompareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compare Against'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Week', 'Month', 'Year'].map((period) {
            return RadioListTile<String>(
              title: Text(period),
              value: period,
              groupValue: 'Month',
              onChanged: (_) {
                Navigator.pop(context);
                // TODO: Save preference
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _rescanSms(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-scan SMS Messages'),
        content: const Text(
          'This will re-read all M-PESA messages and update your Fuliza history. '
          'This may take a few moments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Re-scan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: Trigger SMS re-scan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Re-scanning SMS messages...')),
      );
    }
  }

  Future<void> _clearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your Fuliza tracking data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: Clear all data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared')),
      );
    }
  }
}
