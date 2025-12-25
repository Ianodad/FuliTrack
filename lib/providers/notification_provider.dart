import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/services.dart';
import '../models/models.dart';

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});

/// Provider for notification preferences
final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

/// Notification preferences state
class NotificationPreferences {
  final bool dueDateReminders;
  final bool highInterestAlerts;
  final bool rewardNotifications;
  final bool weeklySummary;
  final int daysBeforeDueDate; // How many days before due date to notify

  const NotificationPreferences({
    this.dueDateReminders = true,
    this.highInterestAlerts = true,
    this.rewardNotifications = true,
    this.weeklySummary = false,
    this.daysBeforeDueDate = 1,
  });

  NotificationPreferences copyWith({
    bool? dueDateReminders,
    bool? highInterestAlerts,
    bool? rewardNotifications,
    bool? weeklySummary,
    int? daysBeforeDueDate,
  }) {
    return NotificationPreferences(
      dueDateReminders: dueDateReminders ?? this.dueDateReminders,
      highInterestAlerts: highInterestAlerts ?? this.highInterestAlerts,
      rewardNotifications: rewardNotifications ?? this.rewardNotifications,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      daysBeforeDueDate: daysBeforeDueDate ?? this.daysBeforeDueDate,
    );
  }
}

/// Notifier for notification preferences
class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(const NotificationPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    state = NotificationPreferences(
      dueDateReminders: prefs.getBool('notif_due_date') ?? true,
      highInterestAlerts: prefs.getBool('notif_high_interest') ?? true,
      rewardNotifications: prefs.getBool('notif_rewards') ?? true,
      weeklySummary: prefs.getBool('notif_weekly_summary') ?? false,
      daysBeforeDueDate: prefs.getInt('notif_days_before') ?? 1,
    );
  }

  Future<void> setDueDateReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_due_date', value);
    state = state.copyWith(dueDateReminders: value);
  }

  Future<void> setHighInterestAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_high_interest', value);
    state = state.copyWith(highInterestAlerts: value);
  }

  Future<void> setRewardNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_rewards', value);
    state = state.copyWith(rewardNotifications: value);
  }

  Future<void> setWeeklySummary(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_weekly_summary', value);
    state = state.copyWith(weeklySummary: value);
  }

  Future<void> setDaysBeforeDueDate(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_days_before', days);
    state = state.copyWith(daysBeforeDueDate: days);
  }
}

/// Helper to trigger notifications based on events
class NotificationHelper {
  final NotificationService _notificationService;
  final NotificationPreferences _preferences;

  NotificationHelper(this._notificationService, this._preferences);

  /// Check if a loan has high interest and trigger alert
  Future<void> checkHighInterest(FulizaEvent loan, FulizaEvent? interest) async {
    if (!_preferences.highInterestAlerts || interest == null) return;

    final interestRate = (interest.amount / loan.amount) * 100;

    // Alert if interest rate is above 5%
    if (interestRate >= 5.0) {
      await _notificationService.showHighInterestAlert(
        interestAmount: interest.amount,
        loanAmount: loan.amount,
        interestRate: interestRate,
      );
    }
  }

  /// Schedule due date reminder for a loan
  Future<void> scheduleDueDateReminder(FulizaEvent loan) async {
    if (!_preferences.dueDateReminders) return;
    if (loan.dueDate == null || loan.outstandingBalance == null) return;

    // Use a unique ID based on the loan reference
    final notificationId = loan.reference.hashCode.abs();

    await _notificationService.scheduleDueDateReminder(
      id: notificationId,
      dueDate: loan.dueDate!,
      outstandingAmount: loan.outstandingBalance!,
    );
  }

  /// Show reward notification
  Future<void> showReward(FulizaReward reward) async {
    if (!_preferences.rewardNotifications) return;

    await _notificationService.showRewardNotification(reward: reward);
  }

  /// Show weekly summary
  Future<void> showWeeklySummary(FulizaSummary summary) async {
    if (!_preferences.weeklySummary) return;

    await _notificationService.showSummaryNotification(
      period: 'Weekly',
      summary: summary,
    );
  }
}
