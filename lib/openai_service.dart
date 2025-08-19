import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';  // 🔑 from .env
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getAIAnswer(String prompt) async {
    if (_apiKey.isEmpty) {
      return '❌ Error: Missing API key. Did you create a .env file and add OPENAI_API_KEY=...?';
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 300,
        'temperature': 0.5,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      return '❌ Error: ${response.statusCode} - ${response.body}';
    }
  }
}