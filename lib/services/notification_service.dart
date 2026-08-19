import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final instance = NotificationService._internal();
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initNotification() async {
    final androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final initSettings = InitializationSettings(android: androidSettings);

    await notificationPlugin.initialize(settings: initSettings);

    final requestPermission = notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await requestPermission?.requestNotificationsPermission();
  }

  Future<void> scheduleExpiryNotification({
    required int id,
    required String name,
    required DateTime expiryDate,
  }) async {
    final reminderDate = expiryDate.subtract(const Duration(days: 7));
    final now = DateTime.now();
    final androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      'Medicine Expiry Alerts',
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    final androidScheduleMode = AndroidScheduleMode.alarmClock;
    if (reminderDate.isAfter(now)) {
      await notificationPlugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
      );
    } else {
      await notificationPlugin.show(
        id: id,
        title: '$name expired',
        body: 'Expired medicine found',
        notificationDetails: notificationDetails,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id: id);
  }
}
