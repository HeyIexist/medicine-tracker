import 'package:flutter/material.dart';
import 'package:medicine_tracker/services/api_service.dart';

class MedicineInfoDialog extends StatelessWidget {
  final String medicineName;

  const MedicineInfoDialog({super.key, required this.medicineName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.instance.getMedicineUsage(medicineName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AlertDialog(
            title: Text(medicineName),
            content: const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return AlertDialog(
            title: Text(medicineName),
            content: const Text(
              'Failed to load medicine info. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final data = snapshot.data!;
        return AlertDialog(
          title: Text(medicineName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uses',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data['uses'] ?? ''),
                const SizedBox(height: 12),
                const Text(
                  'How It Works',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data['how_it_works'] ?? ''),
                const SizedBox(height: 12),
                const Text(
                  'Precautions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data['precautions'] ?? ''),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
