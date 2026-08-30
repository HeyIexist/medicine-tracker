import 'package:flutter/material.dart';
import 'package:medicine_tracker/services/database_service.dart';
import 'package:medicine_tracker/services/notification_service.dart';

class AddMedicineSheet extends StatefulWidget {
  const AddMedicineSheet({super.key});

  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  DateTime? _pickedDate;
  TimeOfDay? _reminderTime;
  String? _mealTiming;
  String? _dateOrTimeError;

  void _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    setState(() {
      _pickedDate = pickedDate;
      _dateOrTimeError = null;
    });
  }

  void _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    setState(() {
      _reminderTime = pickedTime;
      _dateOrTimeError = null;
    });
  }

  Future<void> addMedicineToDb() async {
    final isValid = _formKey.currentState!.validate();

    if (_pickedDate == null && _reminderTime == null) {
      setState(() {
        _dateOrTimeError =
            'Please set an expiry date, a reminder time, or both';
      });
      return;
    }

    if (!isValid) return;

    setState(() => _dateOrTimeError = null);
    _formKey.currentState!.save();
    final db = await DatabaseService.instance.database;
    final id = await db.insert('medicines', {
      'name': _name,
      'createdAt': DateTime.now().toIso8601String(),
      'expiryDate': _pickedDate?.toIso8601String(),
      'reminderTime': _reminderTime != null
          ? '${_reminderTime!.hour}:${_reminderTime!.minute}'
          : null,
      'mealTiming': _mealTiming,
    });

    if (_pickedDate != null) {
      NotificationService.instance.scheduleExpiryNotification(
        id: id,
        name: _name!,
        expiryDate: _pickedDate!,
      );
    }

    if (_reminderTime != null) {
      NotificationService.instance.scheduleDailyReminder(
        id: id,
        name: _name!,
        time: _reminderTime!,
        mealTiming: _mealTiming,
      );
    }

    if (mounted) Navigator.of(context).pop();
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter medicine name. (eg. Paracetamol)',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Name is required'
                    : null,
                onSaved: (value) => _name = value?.trim(),
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
              Row(
                children: [
                  Text(
                    _reminderTime == null
                        ? 'Select reminder time'
                        : _reminderTime!.format(context),
                  ),
                  IconButton(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                  ),
                ],
              ),
              if (_reminderTime != null) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _mealTiming,
                  decoration: const InputDecoration(
                    labelText: 'Meal timing (optional)',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'before',
                      child: Text('Before meal'),
                    ),
                    DropdownMenuItem(value: 'after', child: Text('After meal')),
                  ],
                  onChanged: (value) => setState(() => _mealTiming = value),
                ),
              ],
              if (_dateOrTimeError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _dateOrTimeError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
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
        ),
      ),
    );
  }
}
