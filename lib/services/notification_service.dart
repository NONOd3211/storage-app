import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
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
    final expirationDate = item.calculatedExpirationDate;
    if (expirationDate == null) return;

    final daysUntil = item.daysUntilExpiration ?? 0;
    if (daysUntil >= 30) return;

    // Schedule 7-day notification
    if (daysUntil >= 7) {
      await _scheduleNotification(
        item: item,
        daysBefore: 7,
        title: '保质期提醒',
        body: '${item.name} 还有7天就要过期了，请尽快使用！',
      );
    }

    // Schedule 1-day notification
    if (daysUntil >= 1) {
      await _scheduleNotification(
        item: item,
        daysBefore: 1,
        title: '保质期提醒',
        body: '${item.name} 还有1天就要过期了！',
      );
    }

    // Schedule expired notification
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
    await _notifications.cancel('${item.id}_7'.hashCode);
    await _notifications.cancel('${item.id}_1'.hashCode);
    await _notifications.cancel('${item.id}_0'.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
