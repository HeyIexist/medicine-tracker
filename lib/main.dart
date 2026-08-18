import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine_tracker/screens/home_screen.dart';
import 'package:medicine_tracker/services/database_service.dart';

final notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await notificationsPlugin.initialize(settings: initSettings);

  final androidImplementation = notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidImplementation?.requestNotificationsPermission();
  await showNotifications();
}

Future<void> showNotifications() async {
  final androidDetails = AndroidNotificationDetails(
    'test channel',
    'test notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  final details = NotificationDetails(android: androidDetails);
  notificationsPlugin.show(
    id: 0,
    title: 'Test notifications',
    body: 'if you see this notifications are working',
    notificationDetails: details,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  await _initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}
