import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

/// State class for analytics preferences
class AnalyticsState {
  final bool isEnabled;
  final bool isInitialized;

  const AnalyticsState({
    this.isEnabled = false,
    this.isInitialized = false,
  });

  AnalyticsState copyWith({
    bool? isEnabled,
    bool? isInitialized,
  }) {
    return AnalyticsState(
      isEnabled: isEnabled ?? this.isEnabled,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Notifier for analytics state management
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await analytics.initialize();
    state = state.copyWith(
      isEnabled: analytics.isEnabled,
      isInitialized: true,
    );
  }

  /// Enable or disable analytics
  Future<void> setEnabled(bool enabled) async {
    await analytics.setEnabled(enabled);
    state = state.copyWith(isEnabled: enabled);
  }

  /// Track app opened
  void trackAppOpen() {
    analytics.trackAppOpen();
  }

  /// Track screen view
  void trackScreen(String screenName) {
    analytics.trackNavigation(screenName);
  }

  /// Track feature usage
  void trackFeature(String feature) {
    analytics.trackFeatureUsed(feature);
  }

  /// Track badge earned
  void trackBadge(String badgeType) {
    analytics.trackBadgeEarned(badgeType);
  }

  /// Track SMS sync
  void trackSync(int count) {
    analytics.trackSmsSync(count);
  }

  /// Track setting changed
  void trackSetting(String setting) {
    analytics.trackSettingChanged(setting);
  }

  /// Track period filter changed
  void trackPeriodFilter(String period) {
    analytics.trackPeriodFilterChanged(period);
  }

  /// Track notification preference changed
  void trackNotificationPref(String type, bool enabled) {
    analytics.trackNotificationPrefChanged(type, enabled);
  }

  /// Track onboarding completed
  void trackOnboarding() {
    analytics.trackOnboardingCompleted();
  }

  /// Track permission granted
  void trackPermission(String permission) {
    analytics.trackPermissionGranted(permission);
  }
}

/// Provider for analytics state
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
