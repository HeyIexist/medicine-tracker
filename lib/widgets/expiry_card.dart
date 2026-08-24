import 'package:flutter/material.dart';
import 'package:medicine_tracker/widgets/medicine_info_dialogue.dart';

class ExpiryCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final int index;
  final void Function(Map<String, dynamic> medicine, int index) onRemoved;
  final void Function(Map<String, dynamic> medicine, int index) onUndo;
  final void Function(int id) onDelete;

  const ExpiryCard({
    super.key,
    required this.medicine,
    required this.index,
    required this.onRemoved,
    required this.onUndo,
    required this.onDelete,
  });

  void _showMedicineInfoDialog(BuildContext context, String medicineName) {
    showDialog(
      context: context,
      builder: (ctx) => MedicineInfoDialog(medicineName: medicineName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiryDate = DateTime.parse(medicine['expiryDate']);
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;

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
                content: Text('${medicine['name']} removed'),
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
          color: daysLeft <= 0
              ? Colors.red.shade100
              : daysLeft <= 7
              ? Colors.orange.shade100
              : Colors.green.shade100,
          child: ListTile(
            onTap: () => _showMedicineInfoDialog(context, medicine['name']),
            title: Text(medicine['name']),
            subtitle: Text(
              daysLeft < 0
                  ? 'Expired ${-daysLeft} day(s) ago'
                  : daysLeft == 0
                  ? 'Expires today'
                  : 'Expires in $daysLeft day(s)',
            ),
          ),
        ),
      ),
    );
  }
}
