import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cronet_http/cronet_http.dart';

class CohereAPI {
  static const String apiUrl = "https://no-limts-ai-1.motoemotovps.xyz/generate";
  static const String sessionUrl = "https://no-limts-ai-1.motoemotovps.xyz/user_sessions";
  static const String userIdGenUrl = "https://no-limts-ai-1.motoemotovps.xyz/generate_user_id";

  static Future<Map<String, dynamic>> sendChatMessage(String message, {String? preamble}) async {
    if (message.isEmpty) {
      return {'error': 'Message cannot be empty'};
    }

    String? userId = await generateUserId();
    if (userId == null) {
      return {'error': 'Failed to generate user ID'};
    }

    Map<String, dynamic> chatHistory = await getUserSessions(userId);
    if (chatHistory.containsKey('error')) {
      return chatHistory;
    }

    List<Map<String, dynamic>> chatHistoryFormatted = chatHistory.containsKey('sessions') ? List<Map<String, dynamic>>.from(chatHistory['sessions']) : [];
    chatHistoryFormatted.add({"role": "USER", "message": message});

    if (preamble != null) {
      chatHistoryFormatted.add({"role": "SYSTEM", "message": preamble});
    }

    Map<String, dynamic> payload = {
      'user_id': userId,
      'message': message,
      'model': 'command-r-plus',
      'chat_history': chatHistoryFormatted,
      'connectors': []
    };

    final engine = CronetEngine.build();
    final http.Client httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);

    http.Response response;
    try {
      response = await httpClient.post(Uri.parse(apiUrl), body: jsonEncode(payload), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return {'error': 'Failed to send message: $e'};
    }

    if (response.statusCode == 200) {
      try {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['response'] != null) {
          return {'text': decodedResponse['response'], 'user_id': userId};
        } else {
          return {'error': 'Invalid response structure'};
        }
      } catch (e) {
        return {'error': 'Failed to decode response: $e'};
      }
    } else {
      return {'error': jsonDecode(response.body)};
    }
  }

  static Future<Map<String, dynamic>> getUserSessions(String userId) async {
    final engine = CronetEngine.build();
    final http.Client httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);

    http.Response response;
    try {
      response = await httpClient.get(Uri.parse("$sessionUrl/$userId"));
    } catch (e) {
      return {'error': 'Failed to retrieve user sessions: $e'};
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': jsonDecode(response.body)};
    }
  }

  static Future<String?> generateUserId() async {
    final engine = CronetEngine.build();
    final http.Client httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);

    http.Response response;
    try {
      response = await httpClient.get(Uri.parse(userIdGenUrl));
    } catch (e) {
      return null;
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user_id'];
    } else {
      return null;
    }
  }
}


