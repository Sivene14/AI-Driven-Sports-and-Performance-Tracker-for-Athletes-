import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  final String apiKey;

  OpenRouterService(this.apiKey);

  Future<String> askOpenRouter(String prompt) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "openai/gpt-3.5-turbo", // safer free-tier model
        "messages": [
          {
            "role": "system",
            "content":
                "You are a sports assistant. Only answer questions related to sports, athletes, training, fitness, or performance. If the query is unrelated to sports, politely refuse."
          },
          {"role": "user", "content": prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("OpenRouter error: ${response.body}");
    }
  }
}
