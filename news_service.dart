import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // Replace with your actual NewsAPI key
  static const String _apiKey = "9f91518055674cb8ad746f861ecacf79";

  static Future<List<dynamic>> fetchSportsNews() async {
    final url = Uri.parse(
      "https://newsapi.org/v2/top-headlines?category=sports&language=en&apiKey=$_apiKey"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["articles"] ?? [];
    } else {
      throw Exception("Failed to load sports news");
    }
  }
}