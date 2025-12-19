import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationTest {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);
  }

  static Future<void> showNotificationSingle() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'single_notification_channel_id',
          'single_notification_channel_name',
          channelDescription: "This is single notification testing",
          importance: Importance.max,
          priority: Priority.high,
        );
    await _plugin.zonedSchedule(
      0,
      "Bizi Sevdiniz mi⁉️",
      "O zaman bizi kullanmaya devam edin❤️❤️",
      tz.TZDateTime.now(tz.local).add(const Duration(days: 3)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          channelDescription: 'Kullanıcı uzun süre gelmezse hatırlatma',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
