import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/item.dart';
import '../main.dart';
import 'settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  late SettingsService _settingsService;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    // Use global settingsService instance
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
    if (!_settingsService.notificationEnabled) return;

    final expirationDate = item.calculatedExpirationDate;
    if (expirationDate == null) return;

    final daysUntil = item.daysUntilExpiration ?? 0;
    final warningDays = _settingsService.warningDays;
    final urgentDays = _settingsService.urgentDays;

    // 如果剩余天数大于警告阈值，不发送通知
    if (daysUntil > warningDays) return;

    // 即将过期提醒（剩余天数 = warningDays 时提醒）
    if (daysUntil == warningDays) {
      await _scheduleNotification(
        item: item,
        daysBefore: warningDays,
        title: '即将过期提醒',
        body: '${item.name} 还有$warningDays天就要过期了，请尽快使用！',
      );
    }

    // 紧急提醒（剩余天数 = urgentDays 时提醒）
    if (daysUntil == urgentDays) {
      await _scheduleNotification(
        item: item,
        daysBefore: urgentDays,
        title: '紧急提醒',
        body: '${item.name} 还有$urgentDays天就要过期了，请尽快使用！',
      );
    }

    // 明天过期提醒（1天时提醒）
    if (daysUntil == 1) {
      await _scheduleNotification(
        item: item,
        daysBefore: 1,
        title: '紧急提醒',
        body: '${item.name} 还有1天就要过期了！',
      );
    }

    // 已过期提醒
    if (daysUntil < 0) {
      await _scheduleNotification(
        item: item,
        daysBefore: 0,
        title: '物品已过期',
        body: '${item.name} 已经过期，请及时处理！',
      );
    }
  }

  Future<void> _scheduleNotification({
    required Item item,
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
      '${item.id}_$daysBefore'.hashCode,
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
    // 取消所有可能的通知
    for (int i = 0; i <= 30; i++) {
      await _notifications.cancel('${item.id}_$i'.hashCode);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
