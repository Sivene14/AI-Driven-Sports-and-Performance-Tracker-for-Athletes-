import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://intervalic-trey-photometrically.ngrok-free.dev";

  static Future<Map<String, dynamic>> comparePerformance(Map<String, dynamic> athleteData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/compare"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(athleteData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to connect to backend: ${response.statusCode}");
    }
  }
}