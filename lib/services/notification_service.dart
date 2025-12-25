import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/models.dart';
import '../utils/utils.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    AppLogger.d('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android doesn't need runtime permission for notifications
  }

  /// Schedule a due date reminder
  Future<void> scheduleDueDateReminder({
    required int id,
    required DateTime dueDate,
    required double outstandingAmount,
  }) async {
    if (!_initialized) await initialize();

    // Schedule notification 1 day before due date at 10 AM
    final scheduledDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 1,
      10,
      0,
    );

    // Don't schedule if the date has passed
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'due_date_reminders',
      'Due Date Reminders',
      channelDescription: 'Reminders for upcoming Fuliza due dates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF14B8A6), // Teal color
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '⏰ Fuliza Payment Due Tomorrow',
      'You have Ksh ${outstandingAmount.toStringAsFixed(2)} due on ${_formatDate(dueDate)}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'due_date_$id',
    );
  }

  /// Show immediate high interest alert
  Future<void> showHighInterestAlert({
    required double interestAmount,
    required double loanAmount,
    required double interestRate,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'high_interest_alerts',
      'High Interest Alerts',
      channelDescription: 'Alerts for high interest charges on Fuliza loans',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF59E0B), // Amber color for warning
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⚠️ High Interest Charge Detected',
      'Interest of Ksh ${interestAmount.toStringAsFixed(2)} (${interestRate.toStringAsFixed(1)}%) charged on Ksh ${loanAmount.toStringAsFixed(2)} loan',
      details,
      payload: 'high_interest',
    );
  }

  /// Show achievement reward notification
  Future<void> showRewardNotification({
    required FulizaReward reward,
  }) async {
    if (!_initialized) await initialize();

    final emoji = _getRewardEmoji(reward.type);
    final title = _getRewardTitle(reward.type);
    final message = _getRewardMessage(reward);

    const androidDetails = AndroidNotificationDetails(
      'rewards',
      'Achievement Rewards',
      channelDescription: 'Notifications for earned achievement badges',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF10B981), // Green color for achievement
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '$emoji $title',
      message,
      details,
      payload: 'reward_${reward.type.name}',
    );
  }

  /// Show daily/weekly summary notification
  Future<void> showSummaryNotification({
    required String period,
    required FulizaSummary summary,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'summaries',
      'Usage Summaries',
      channelDescription: 'Daily/weekly Fuliza usage summaries',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF14B8A6),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final message = '''
Loaned: Ksh ${summary.totalLoaned.toStringAsFixed(2)}
Interest: Ksh ${summary.totalInterest.toStringAsFixed(2)}
Outstanding: Ksh ${summary.outstandingBalance.toStringAsFixed(2)}
''';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '📊 Your $period Fuliza Summary',
      message,
      details,
      payload: 'summary_$period',
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Helper methods

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getRewardEmoji(RewardType type) {
    switch (type) {
      case RewardType.bronze:
        return '🥉';
      case RewardType.silver:
        return '🥈';
      case RewardType.gold:
        return '🥇';
      case RewardType.zeroFuliza:
        return '🎯';
      case RewardType.consistency:
        return '🔥';
    }
  }

  String _getRewardTitle(RewardType type) {
    switch (type) {
      case RewardType.bronze:
        return 'Bronze Achievement Unlocked!';
      case RewardType.silver:
        return 'Silver Achievement Unlocked!';
      case RewardType.gold:
        return 'Gold Achievement Unlocked!';
      case RewardType.zeroFuliza:
        return 'Zero Fuliza Achievement!';
      case RewardType.consistency:
        return 'Consistency Streak!';
    }
  }

  String _getRewardMessage(FulizaReward reward) {
    if (reward.type == RewardType.zeroFuliza) {
      return 'Congratulations! You had zero Fuliza usage this ${reward.period.name}!';
    } else if (reward.type == RewardType.consistency) {
      return 'Great job! You\'ve been consistently reducing your Fuliza usage!';
    } else {
      final reduction = reward.reductionPercentage;
      return 'You reduced your Fuliza usage by ${reduction.toStringAsFixed(1)}% this ${reward.period.name}!';
    }
  }
}
