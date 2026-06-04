import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> scheduleAllDailyReminders() async {
    await cancelAll();

    await scheduleDailyMoodReminder();
    await schedulePlanReminder();
    await scheduleEndDayReminder();
  }

  static Future<void> scheduleDailyMoodReminder() async {
    await _scheduleDailyNotification(
      id: 1,
      hour: 10,
      minute: 0,
      title: "Bugün nasıl hissediyorsun?",
      body: "Modunu kontrol ederek sana özel önerileri keşfet.",
    );
  }

  static Future<void> schedulePlanReminder() async {
    await _scheduleDailyNotification(
      id: 2,
      hour: 18,
      minute: 0,
      title: "Planını kontrol et",
      body: "Bugünkü planında tamamlanmamış öneriler olabilir.",
    );
  }

  static Future<void> scheduleEndDayReminder() async {
    await _scheduleDailyNotification(
      id: 3,
      hour: 21,
      minute: 0,
      title: "Gün sonu değerlendirmesi",
      body: "Bugünün nasıl geçtiğini kaydetmeyi unutma.",
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Günlük Hatırlatmalar',
          channelDescription: 'Mood, plan ve gün sonu hatırlatmaları',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}