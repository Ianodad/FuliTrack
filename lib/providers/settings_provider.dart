import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'database_provider.dart';

/// Notifier for app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  final DatabaseService _db;

  SettingsNotifier(this._db) : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _db.getAllSettings();

    state = AppSettings(
      comparisonPreference: _parseComparisonPreference(
        settings['comparison_preference'],
      ),
      showCharts: settings['show_charts'] != '0',
      enableNotifications: settings['enable_notifications'] == '1',
    );
  }

  ComparisonTypePreference _parseComparisonPreference(String? value) {
    if (value == null) return ComparisonTypePreference.combined;
    return ComparisonTypePreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ComparisonTypePreference.combined,
    );
  }

  Future<void> setComparisonPreference(ComparisonTypePreference pref) async {
    await _db.saveSetting('comparison_preference', pref.name);
    state = state.copyWith(comparisonPreference: pref);
  }

  Future<void> setShowCharts(bool value) async {
    await _db.saveSetting('show_charts', value ? '1' : '0');
    state = state.copyWith(showCharts: value);
  }

  Future<void> setEnableNotifications(bool value) async {
    await _db.saveSetting('enable_notifications', value ? '1' : '0');
    state = state.copyWith(enableNotifications: value);
  }
}

/// Provider for settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SettingsNotifier(db);
});
