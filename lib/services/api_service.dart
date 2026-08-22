import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._internal();

  static final instance = ApiService._internal();
  final baseURL = 'https://medicine-ai-backend.onrender.com';
  Future<Map<String, dynamic>> getMedicineUsage(String medicineName) async {
    final response = await http.get(Uri.parse('$baseURL/usage/$medicineName'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load medicine info');
    }
  }
}
