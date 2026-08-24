import 'package:flutter/material.dart';
import 'package:medicine_tracker/widgets/medicine_info_dialogue.dart';

class ReminderCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final int index;
  final void Function(Map<String, dynamic> medicine, int index) onRemoved;
  final void Function(Map<String, dynamic> medicine, int index) onUndo;
  final void Function(int id) onDelete;

  const ReminderCard({
    super.key,
    required this.medicine,
    required this.index,
    required this.onRemoved,
    required this.onUndo,
    required this.onDelete,
  });

  String _formatTime(String reminderTime) {
    final parts = reminderTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  Color _getCardColor(String reminderTime) {
    final hour = int.parse(reminderTime.split(':')[0]);
    if (hour < 12) {
      return Colors.yellow.shade100;
    } else if (hour < 17) {
      return Colors.orange.shade100;
    } else {
      return Colors.blue.shade100;
    }
  }

  void _showMedicineInfoDialog(BuildContext context, String medicineName) {
    showDialog(
      context: context,
      builder: (ctx) => MedicineInfoDialog(medicineName: medicineName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderTime = medicine['reminderTime'] as String;
    final mealTiming = medicine['mealTiming'] as String?;

    return Dismissible(
      key: ValueKey(medicine['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onRemoved(medicine, index);
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger
            .showSnackBar(
              SnackBar(
                content: Text('${medicine['name']} reminder removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => onUndo(medicine, index),
                ),
                duration: const Duration(seconds: 3),
              ),
            )
            .closed
            .then((reason) {
              if (reason != SnackBarClosedReason.action) {
                onDelete(medicine['id']);
              }
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
          color: _getCardColor(reminderTime),
          child: ListTile(
            onTap: () => _showMedicineInfoDialog(context, medicine['name']),
            leading: const Icon(Icons.alarm),
            title: Text(medicine['name']),
            subtitle: Text(
              mealTiming == null
                  ? 'Take at ${_formatTime(reminderTime)}'
                  : 'Take at ${_formatTime(reminderTime)} (${mealTiming == 'before' ? 'before meal' : 'after meal'})',
            ),
          ),
        ),
      ),
    );
  }
}
