import 'package:flutter/material.dart';
import 'package:medicine_tracker/services/database_service.dart';
import 'package:medicine_tracker/services/notification_service.dart';
import 'package:medicine_tracker/widgets/add_medicine_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> medicines = [];

  void _loadMedicines() async {
    final db = await DatabaseService.instance.database;
    final data = await db.query('medicines', orderBy: 'expiryDate ASC');
    setState(() {
      medicines = List<Map<String, dynamic>>.from(data);
    });
  }

  void _deleteMedicine(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void addMedicine() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => AddMedicineSheet(),
      isScrollControlled: true,
    );
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medicine Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: addMedicine,
        child: Icon(Icons.add),
      ),
      body: medicines.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No medicine added yet.'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Tap on'),
                      IconButton(onPressed: addMedicine, icon: Icon(Icons.add)),
                      Text('to add medicine.'),
                    ],
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                final expiryDate = DateTime.parse(med['expiryDate']);
                final daysLeft = expiryDate.difference(DateTime.now()).inDays;

                return Dismissible(
                  key: ValueKey(med['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    final removedMedicine = med;
                    final removedIndex = index;

                    setState(() => medicines.removeAt(index));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                          SnackBar(
                            persist: false,
                            content: Text('${removedMedicine['name']} removed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  medicines.insert(
                                    removedIndex,
                                    removedMedicine,
                                  );
                                });
                              },
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        )
                        .closed
                        .then((reason) {
                          // Only delete from DB if it wasn't undone

                          if (reason != SnackBarClosedReason.action) {
                            _deleteMedicine(removedMedicine['id']);
                            NotificationService.instance.cancelNotification(
                              removedMedicine['id'],
                            );
                          }
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(med['name']),
                        subtitle: Text(
                          daysLeft < 0
                              ? 'Expired ${-daysLeft} day(s) ago'
                              : daysLeft == 0
                              ? 'Expires today'
                              : 'Expires in $daysLeft day(s)',
                        ),
                        trailing: Icon(
                          Icons.circle,
                          size: 12,
                          color: daysLeft < 0
                              ? Colors.red
                              : daysLeft <= 7
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
