import 'dart:convert';
import 'package:http/http.dart' as http;

class CohereAPI {
  static const String apiUrl = "https://no-limts-ai-1.motoemotovps.xyz/generate";
  static const String sessionUrl = "https://no-limts-ai-1.motoemotovps.xyz/user_sessions";
  static const String userIdGenUrl = "https://no-limts-ai-1.motoemotovps.xyz/generate_user_id";

  static Future<Map<String, dynamic>> generateText(String userId, String message, {String model = 'command-r-plus', String preamble = '', List<String>? connectors}) async {
    connectors ??= [];

    Map<String, dynamic> chatHistory = await getUserSessions(userId);
    List<Map<String, dynamic>> chatHistoryFormatted = chatHistory.containsKey('sessions') ? List<Map<String, dynamic>>.from(chatHistory['sessions']) : [];

    chatHistoryFormatted.add({"role": "USER", "message": message});
    if (preamble.isNotEmpty) {
      chatHistoryFormatted.add({"role": "SYSTEM", "message": preamble});
    }

    Map<String, dynamic> payload = {
      'user_id': userId,
      'message': message,
      'model': model,
      'chat_history': chatHistoryFormatted,
      'connectors': connectors
    };

    http.Response response = await http.post(Uri.parse(apiUrl), body: jsonEncode(payload), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> getUserSessions(String userId) async {
    http.Response response = await http.get(Uri.parse("$sessionUrl/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)};
    }
  }

  static Future<String?> generateUserId() async {
    http.Response response = await http.get(Uri.parse(userIdGenUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user_id'];
    } else {
      return null;
    }
  }
}

