import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTest {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  static const String _lastLoginKey = 'last_login_date';

  static Future<void> initNotification() async {
    if (_isInitialized) return;
    
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation("Europe/Istanbul"));

      await _requestNotificationPermission();
      await _plugin.initialize(initializationSettings);
      
      _isInitialized = true;
    } catch (e) {
      print('Bildirim başlatma hatası: $e');
    }
  }

  static Future<void> _requestNotificationPermission() async {
    try {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } catch (e) {
      print('İzin alma hatası: $e');
    }
  }

  static Future<void> updateLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      
      await _plugin.cancelAll();
      
      await scheduleReminderNotification();
    } catch (e) {
      print('Son giriş güncelleme hatası: $e');
    }
  }

  static Future<void> scheduleReminderNotification() async {
    if (!_isInitialized) {
      await initNotification();
    }
    
    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));
      
      await _plugin.zonedSchedule(
        0,
        "HEYY!",
        "Lütfen, geri gel! Seni özledik. 🥺",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder Notifications',
            channelDescription: 'Kullanıcı uzun süre gelmezse hatırlatma',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'reminder_3_days',
      );
      
      print('Bildirim planlandı: ${scheduledDate.toString()}');
    } catch (e) {
      print('Bildirim zamanlama hatası: $e');
    }
  }

  static Future<bool> shouldShowReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginStr = prefs.getString(_lastLoginKey);
      
      if (lastLoginStr == null) return false;
      
      final lastLogin = DateTime.parse(lastLoginStr);
      final difference = DateTime.now().difference(lastLogin);
      
      return difference.inDays >= 3;
    } catch (e) {
      print('Hatırlatma kontrolü hatası: $e');
      return false;
    }
  }

  static Future<void> cancelReminder() async {
    try {
      await _plugin.cancel(0);
    } catch (e) {
      print('Bildirim iptal hatası: $e');
    }
  }
}