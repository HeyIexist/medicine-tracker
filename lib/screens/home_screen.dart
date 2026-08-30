import 'package:flutter/material.dart';
import 'package:medicine_tracker/services/database_service.dart';
import 'package:medicine_tracker/widgets/add_medicine_sheet.dart';
import 'package:medicine_tracker/widgets/expiry_card.dart';
import 'package:medicine_tracker/services/notification_service.dart';
import 'package:medicine_tracker/widgets/reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> expiryMedicines = [];
  List<Map<String, dynamic>> reminderMedicines = [];

  void _loadExpiryMedicines() async {
    final db = await DatabaseService.instance.database;
    final data = await db.query(
      'medicines',
      where: 'expiryDate IS NOT NULL',
      orderBy: 'expiryDate ASC',
    );
    setState(() {
      expiryMedicines = List<Map<String, dynamic>>.from(data);
    });
  }

  void _loadReminderMedicines() async {
    final db = await DatabaseService.instance.database;
    final data = await db.query(
      'medicines',
      where: 'reminderTime IS NOT NULL',
      orderBy: 'reminderTime ASC',
    );
    setState(() {
      reminderMedicines = List<Map<String, dynamic>>.from(data);
    });
  }

  void addMedicine() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => AddMedicineSheet(),
      isScrollControlled: true,
    );
    _loadExpiryMedicines();
    _loadReminderMedicines();
  }

  void _clearExpiry(int id) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'medicines',
      {'expiryDate': null},
      where: 'id = ?',
      whereArgs: [id],
    );
    NotificationService.instance.cancelNotification(id + 10000);
    await _deleteIfEmpty(id);
  }

  void _clearReminder(int id) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'medicines',
      {'reminderTime': null, 'mealTiming': null},
      where: 'id = ?',
      whereArgs: [id],
    );
    NotificationService.instance.cancelNotification(id);
    await _deleteIfEmpty(id);
  }

  Future<void> _deleteIfEmpty(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('medicines', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final row = rows.first;
    if (row['expiryDate'] == null && row['reminderTime'] == null) {
      await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadExpiryMedicines();
    _loadReminderMedicines();
    // _checkPendingNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadExpiryMedicines();
      _loadReminderMedicines();
    }
  }

  int _selectedIndex = 0;
  Widget _buildExpiryTab() {
    if (expiryMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No medicine tracked for expiry yet.'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tap on'),
                IconButton(onPressed: addMedicine, icon: const Icon(Icons.add)),
                const Text('to add medicine.'),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: expiryMedicines.length,
      itemBuilder: (context, index) {
        final med = expiryMedicines[index];
        return ExpiryCard(
          medicine: med,
          index: index,
          onRemoved: (medicine, index) {
            setState(() => expiryMedicines.removeAt(index));
          },
          onUndo: (medicine, index) {
            setState(() => expiryMedicines.insert(index, medicine));
          },
          onDelete: (id) => _clearExpiry(id),
        );
      },
    );
  }

  Widget _buildReminderTab() {
    if (reminderMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No medicine reminders set yet.'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tap on'),
                IconButton(onPressed: addMedicine, icon: const Icon(Icons.add)),
                const Text('to add a reminder.'),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: reminderMedicines.length,
      itemBuilder: (context, index) {
        final med = reminderMedicines[index];
        return ReminderCard(
          medicine: med,
          index: index,
          onRemoved: (medicine, index) {
            setState(() => reminderMedicines.removeAt(index));
          },
          onUndo: (medicine, index) {
            setState(() => reminderMedicines.insert(index, medicine));
          },
          onDelete: (id) => _clearReminder(id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medicine Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: addMedicine,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_busy),
            label: 'Expiry',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Reminders'),
        ],
      ),
      body: _selectedIndex == 0 ? _buildExpiryTab() : _buildReminderTab(),
    );
  }
}
