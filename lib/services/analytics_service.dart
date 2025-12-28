import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Privacy-respecting analytics service using Firebase Analytics.
///
/// Key privacy principles:
/// - User must opt-in (disabled by default)
/// - No personally identifiable information (PII)
/// - No financial data (amounts, balances, references)
/// - No device IDs or user IDs
/// - Only anonymous, aggregate event tracking
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;
  bool _isEnabled = false;

  static const String _enabledKey = 'analytics_enabled';

  /// Initialize Firebase and analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;

      // Load user preference
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? false;

      // Apply privacy settings
      await _applyPrivacySettings();

      _isInitialized = true;
      AppLogger.info('Analytics service initialized (enabled: $_isEnabled)');
    } catch (e) {
      AppLogger.error('Failed to initialize analytics', e);
      // App continues to work without analytics
      _isInitialized = true;
    }
  }

  /// Apply strict privacy settings to Firebase Analytics
  Future<void> _applyPrivacySettings() async {
    if (_analytics == null) return;

    // Enable/disable collection based on user preference
    await _analytics!.setAnalyticsCollectionEnabled(_isEnabled);

    // NEVER set user ID - anonymous only
    await _analytics!.setUserId(id: null);

    // Disable personalization ads
    await _analytics!.setUserProperty(
      name: 'allow_personalized_ads',
      value: 'false',
    );

    // Set privacy-focused user properties
    await _analytics!.setUserProperty(
      name: 'privacy_mode',
      value: 'enabled',
    );
  }

  /// Check if analytics is currently enabled
  bool get isEnabled => _isEnabled;

  /// Enable or disable analytics collection
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;

    // Persist preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    // Apply to Firebase
    if (_analytics != null) {
      await _analytics!.setAnalyticsCollectionEnabled(enabled);
    }

    AppLogger.info('Analytics ${enabled ? 'enabled' : 'disabled'} by user');

    // Track the preference change (if enabling)
    if (enabled) {
      await trackEvent('analytics_opted_in');
    }
  }

  /// Track a custom event (only if user has opted in)
  ///
  /// IMPORTANT: Never include PII or financial data in events or parameters!
  Future<void> trackEvent(String eventName, [Map<String, Object>? parameters]) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      // Sanitize parameters to ensure no PII leaks through
      final safeParams = _sanitizeParameters(parameters);

      await _analytics!.logEvent(
        name: eventName,
        parameters: safeParams,
      );

      AppLogger.debug('Analytics event: $eventName');
    } catch (e) {
      AppLogger.error('Failed to track event: $eventName', e);
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      AppLogger.debug('Analytics screen: $screenName');
    } catch (e) {
      AppLogger.error('Failed to track screen: $screenName', e);
    }
  }

  /// Sanitize parameters to remove any potential PII
  Map<String, Object>? _sanitizeParameters(Map<String, Object>? params) {
    if (params == null) return null;

    // List of keys that might contain PII - exclude them
    const sensitiveKeys = [
      'amount', 'balance', 'reference', 'phone', 'name',
      'email', 'id', 'user_id', 'device_id', 'transaction',
      'limit', 'interest', 'principal', 'due_date',
    ];

    final safeParams = <String, Object>{};

    for (final entry in params.entries) {
      final keyLower = entry.key.toLowerCase();

      // Skip sensitive keys
      if (sensitiveKeys.any((sensitive) => keyLower.contains(sensitive))) {
        continue;
      }

      // Skip numeric values that might be financial data
      if (entry.value is num && (entry.value as num) > 100) {
        continue;
      }

      safeParams[entry.key] = entry.value;
    }

    return safeParams.isEmpty ? null : safeParams;
  }

  // ============================================
  // SAFE PRE-DEFINED EVENTS (No PII)
  // ============================================

  /// Track app open
  Future<void> trackAppOpen() async {
    await trackEvent('app_opened');
  }

  /// Track screen navigation
  Future<void> trackNavigation(String destination) async {
    await trackScreenView(destination);
  }

  /// Track feature usage (generic, no specifics)
  Future<void> trackFeatureUsed(String feature) async {
    await trackEvent('feature_used', {'feature': feature});
  }

  /// Track badge earned (type only, no amounts)
  Future<void> trackBadgeEarned(String badgeType) async {
    await trackEvent('badge_earned', {'badge_type': badgeType});
  }

  /// Track SMS sync action (count only, no content)
  Future<void> trackSmsSync(int transactionCount) async {
    // Bucket the count to avoid fingerprinting
    final bucket = _bucketCount(transactionCount);
    await trackEvent('sms_synced', {'count_bucket': bucket});
  }

  /// Track settings changed (setting name only, not values)
  Future<void> trackSettingChanged(String settingName) async {
    await trackEvent('setting_changed', {'setting': settingName});
  }

  /// Track period filter changed
  Future<void> trackPeriodFilterChanged(String period) async {
    await trackEvent('period_filter_changed', {'period': period});
  }

  /// Track notification preference changed
  Future<void> trackNotificationPrefChanged(String notificationType, bool enabled) async {
    await trackEvent('notification_pref_changed', {
      'type': notificationType,
      'enabled': enabled.toString(),
    });
  }

  /// Track onboarding completed
  Future<void> trackOnboardingCompleted() async {
    await trackEvent('onboarding_completed');
  }

  /// Track permission granted
  Future<void> trackPermissionGranted(String permission) async {
    await trackEvent('permission_granted', {'permission': permission});
  }

  /// Bucket counts to prevent fingerprinting
  String _bucketCount(int count) {
    if (count == 0) return '0';
    if (count <= 10) return '1-10';
    if (count <= 50) return '11-50';
    if (count <= 100) return '51-100';
    if (count <= 500) return '101-500';
    return '500+';
  }
}

/// Global analytics instance
final analytics = AnalyticsService();
