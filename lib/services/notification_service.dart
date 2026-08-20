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
    final reminderDate = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day - 7,
      9,
      0,
    );
    final now = DateTime.now();
    final androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      'Medicine Expiry Alerts',
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    final androidScheduleMode = AndroidScheduleMode.alarmClock;
    if (reminderDate.isAfter(now)) {
      final expiresIn = expiryDate.difference(now).inDays;
      await notificationPlugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        title: '$name expires soon',
        body: 'Expires in $expiresIn days',
      );
    } else {
      final alreadyExpired = expiryDate.isBefore(now);
      final daysLeft = expiryDate.difference(now).inDays;
      await notificationPlugin.show(
        id: id,
        title: alreadyExpired ? '$name expired' : '$name expires soon',
        body: alreadyExpired
            ? 'Expired medicine found'
            : 'Expires in $daysLeft days',
        notificationDetails: notificationDetails,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id: id);
  }
}
