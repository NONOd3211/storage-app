import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/item.dart';
import 'settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  SettingsService? _settingsService;
  static const String _warningKey = 'warning';
  static const String _urgentKey = 'urgent';
  static const String _oneDayKey = 'one_day';
  static const String _dueKey = 'due';

  Future<void> initialize({SettingsService? settingsService}) async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    // Use provided settingsService or global instance
    _settingsService = settingsService;
  }

  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleNotification(Item item) async {
    // 检查通知是否启用
    if (_settingsService == null || !_settingsService!.notificationEnabled) return;

    final expirationDate = item.calculatedExpirationDate;
    if (expirationDate == null) return;

    final warningDays = _settingsService!.warningDays;
    final urgentDays = _settingsService!.urgentDays;

    await cancelNotifications(item);

    final reminders = <_Reminder>[
      _Reminder(
        key: _warningKey,
        enabled: _settingsService!.warningReminderEnabled,
        daysBefore: warningDays,
        title: '即将过期提醒',
        body: '${item.name} 还有$warningDays天就要过期了，请尽快使用！',
      ),
      _Reminder(
        key: _urgentKey,
        enabled: _settingsService!.urgentReminderEnabled,
        daysBefore: urgentDays,
        title: '紧急提醒',
        body: '${item.name} 还有$urgentDays天就要过期了，请尽快使用！',
      ),
      _Reminder(
        key: _oneDayKey,
        enabled: _settingsService!.oneDayReminderEnabled,
        daysBefore: 1,
        title: '紧急提醒',
        body: '${item.name} 还有1天就要过期了！',
      ),
      _Reminder(
        key: _dueKey,
        enabled: _settingsService!.dueDayReminderEnabled,
        daysBefore: 0,
        title: '到期提醒',
        body: '${item.name} 今天到期，请及时处理！',
      ),
    ];

    final deduped = <int, _Reminder>{};
    for (final reminder in reminders) {
      if (!reminder.enabled) continue;
      deduped[reminder.daysBefore] = reminder;
    }

    for (final reminder in deduped.values) {
      await _scheduleNotification(
        item: item,
        key: reminder.key,
        daysBefore: reminder.daysBefore,
        title: reminder.title,
        body: reminder.body,
      );
    }
  }

  Future<void> _scheduleNotification({
    required Item item,
    required String key,
    required int daysBefore,
    required String title,
    required String body,
  }) async {
    final expirationDate = item.calculatedExpirationDate;
    if (expirationDate == null) return;

    final notificationDate = daysBefore > 0
        ? expirationDate.subtract(Duration(days: daysBefore))
        : expirationDate;

    // Set to 9 AM
    final scheduledDate = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'expiration_channel',
      '保质期提醒',
      channelDescription: '物品保质期提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      '${item.id}_$key'.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotifications(Item item) async {
    const keys = [_warningKey, _urgentKey, _oneDayKey, _dueKey];
    for (final key in keys) {
      await _notifications.cancel('${item.id}_$key'.hashCode);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

class _Reminder {
  final String key;
  final bool enabled;
  final int daysBefore;
  final String title;
  final String body;

  const _Reminder({
    required this.key,
    required this.enabled,
    required this.daysBefore,
    required this.title,
    required this.body,
  });
}
