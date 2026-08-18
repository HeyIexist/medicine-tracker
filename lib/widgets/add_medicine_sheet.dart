import 'package:flutter/material.dart';
import 'package:medicine_tracker/services/database_service.dart';

class AddMedicineSheet extends StatefulWidget {
  const AddMedicineSheet({super.key});

  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  final _nameController = TextEditingController();
  DateTime? _pickedDate;
  void _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    setState(() {
      _pickedDate = pickedDate;
    });
  }

  Future<void> addMedicineToDb() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _pickedDate == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            'Please enter a valid medicine name and its expiry date',
          ),
        ),
      );
      return;
    }
    final db = await DatabaseService.instance.database;
    await db.insert('medicines', {
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
      'expiryDate': _pickedDate!.toIso8601String(),
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Enter medicine name. (eg. Paracetamol)',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _pickedDate == null
                    ? 'Select expiry date'
                    : _pickedDate.toString().split(' ')[0],
              ),
              IconButton(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: addMedicineToDb,
                child: const Text('Save medicine'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
