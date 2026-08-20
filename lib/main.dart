import 'package:flutter/material.dart';
import 'package:medicine_tracker/screens/home_screen.dart';
import 'package:medicine_tracker/services/database_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:medicine_tracker/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  runApp(MyApp());
  await DatabaseService.instance.database;
  await NotificationService.instance.initNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}
