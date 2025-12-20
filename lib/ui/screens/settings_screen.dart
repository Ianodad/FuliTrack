import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';

/// Settings screen for app configuration and data management
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Display settings
          _SectionHeader(title: 'Display'),
          SwitchListTile(
            title: const Text('Show Charts'),
            subtitle: const Text('Display trend charts on dashboard'),
            value: settings.showCharts,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowCharts(value);
            },
          ),

          const Divider(),

          // Comparison settings
          _SectionHeader(title: 'Reward Comparison'),
          ListTile(
            title: const Text('Comparison Type'),
            subtitle: Text(_getComparisonLabel(settings.comparisonPreference)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComparisonPicker(context, ref),
          ),

          const Divider(),

          // Data management
          _SectionHeader(title: 'Data Management'),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync SMS'),
            subtitle: const Text('Import Fuliza transactions from SMS'),
            onTap: () => _syncSms(context, ref),
          ),
          FutureBuilder<_DataStats>(
            future: _getDataStats(ref),
            builder: (context, snapshot) {
              final stats = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Data Statistics'),
                subtitle: Text(
                  stats != null
                      ? '${stats.eventCount} transactions, ${stats.rewardCount} rewards'
                      : 'Loading...',
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete All Data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently remove all tracked data'),
            onTap: () => _confirmDeleteData(context, ref),
          ),

          const Divider(),

          // Privacy section
          _SectionHeader(title: 'Privacy'),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Your Data is Private'),
            subtitle: Text(
              'All data is stored locally on your device. '
              'Nothing is sent to any server.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.sms_outlined),
            title: Text('SMS Access'),
            subtitle: Text(
              'We only read M-PESA Fuliza messages to track your usage. '
              'Other SMS messages are ignored.',
            ),
          ),

          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('FuliTrack'),
            subtitle: Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Made in Kenya'),
            subtitle: const Text('Privacy-first Fuliza tracking'),
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getComparisonLabel(ComparisonTypePreference pref) {
    switch (pref) {
      case ComparisonTypePreference.interestOnly:
        return 'Interest Only';
      case ComparisonTypePreference.principalOnly:
        return 'Principal Only';
      case ComparisonTypePreference.combined:
        return 'Combined (Interest + Principal)';
    }
  }

  void _showComparisonPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Reward Comparison Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Interest Only'),
                subtitle: const Text('Compare only interest charged'),
                onTap: () {
                  ref.read(settingsProvider.notifier).setComparisonPreference(
                        ComparisonTypePreference.interestOnly,
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Principal Only'),
                subtitle: const Text('Compare only loan amounts'),
                onTap: () {
                  ref.read(settingsProvider.notifier).setComparisonPreference(
                        ComparisonTypePreference.principalOnly,
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Combined'),
                subtitle: const Text('Compare interest + principal'),
                onTap: () {
                  ref.read(settingsProvider.notifier).setComparisonPreference(
                        ComparisonTypePreference.combined,
                      );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _syncSms(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Syncing SMS...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final count = await ref.read(fulizaProvider.notifier).syncFromSms();

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(count > 0
                ? 'Synced $count Fuliza transactions'
                : 'No new transactions found'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<_DataStats> _getDataStats(WidgetRef ref) async {
    final db = ref.read(databaseServiceProvider);
    final events = await db.getAllEvents();
    final rewards = await db.getAllRewards();
    return _DataStats(eventCount: events.length, rewardCount: rewards.length);
  }

  void _confirmDeleteData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your tracked Fuliza transactions '
          'and earned rewards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(fulizaProvider.notifier).deleteAllData();
              await ref.read(rewardProvider.notifier).deleteAllRewards();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FuliTrack',
      applicationVersion: '1.0.0',
      applicationLegalese: ' 2024 FuliTrack\nMade with love in Kenya',
      children: [
        const SizedBox(height: 16),
        const Text(
          'FuliTrack helps you understand and reduce your Fuliza M-PESA usage '
          'by parsing SMS messages and providing insights into your borrowing habits.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '- Automatic SMS parsing\n'
          '- Weekly, monthly, yearly summaries\n'
          '- Interest trend charts\n'
          '- Savings rewards and badges\n'
          '- 100% offline and private',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _DataStats {
  final int eventCount;
  final int rewardCount;

  _DataStats({required this.eventCount, required this.rewardCount});
}
