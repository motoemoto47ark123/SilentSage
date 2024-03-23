import 'dart:convert';
import 'package:http/http.dart' as http;

class GPTAPI {
  static const String _apiEndpoint = "http://gpt-proxy.motoemotovps.serv00.net/chat";
  static String? _chatId;

  static void resetChatId() {
    _chatId = null;
  }

  static String? get chatId => _chatId;

  /// Sends a message to the GPT API and returns the AI's response.
  static Future<String> sendMessage(String message) async {
    final Map<String, dynamic> requestData = {
      "message": message,
      "systemPrompt": "",
    };

    // If _chatId exists, add it to the request data
    if (_chatId != null) {
      requestData["chatId"] = _chatId;
    }

    try {
      final http.Response response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Update _chatId from the response for subsequent requests
        _chatId = responseData["chatId"];
        // Return only the text from the AI in the response
        return responseData["response"];
      } else {
        // Handle non-200 responses
        return "Error: Received a non-successful status code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
