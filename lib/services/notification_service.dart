import 'package:flutter/material.dart';
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
    await requestPermission?.requestExactAlarmsPermission();
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
        id: id + 10000,
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

  Future<void> scheduleDailyReminder({
    required int id,
    required String name,
    required TimeOfDay time,
    String? mealTiming,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Medicine reminder alerts',
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    final mealText = mealTiming == 'before'
        ? ' (before meal)'
        : mealTiming == 'after'
        ? ' (after meal)'
        : '';
    await notificationPlugin.zonedSchedule(
      
      id: id,
      title: 'Time to take $name',
      body: 'Reminder to take your medicine $mealText',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      
    );
  }

  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id: id);
  }
}
