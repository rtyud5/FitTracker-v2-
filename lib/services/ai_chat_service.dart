import 'dart:convert';

import 'package:http/http.dart' as http;

class AIChatService {
  AIChatService._();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static bool get isConfigured => _apiKey.trim().isNotEmpty;

  static Future<String> sendMessage(String text) async {
    if (!isConfigured) {
      return 'AI chat is not configured for this build. Add --dart-define=GEMINI_API_KEY=YOUR_KEY when running the app.';
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': text},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      return 'AI request failed (${response.statusCode}).';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['candidates']?[0]?['content']?['parts']?[0]?['text']?.toString() ??
        'The AI service returned no text.';
  }
}
