// Imports the 'dart:convert' package for converting the data to JSON format.
import 'dart:convert';
// Imports the 'http' package to enable making HTTP requests.
import 'package:http/http.dart' as http;

// Defines the GPTAPI class to manage interactions with the GPT API.
class GPTAPI {
  // Holds the URL of the GPT API endpoint as a constant string.
  static const String _apiEndpoint = "https://gpt-proxy.motoemotovps.serv00.net/chat"; // Updated to use HTTPS
  // Static variable to store the chat ID for maintaining the session state.
  static String? _chatId;

  // Method to clear the current chat ID, starting a new session.
  static void resetChatId() {
    _chatId = null;
  }

  // Getter method for retrieving the current chat ID.
  static String? get chatId => _chatId;

  // Asynchronously sends a message to the GPT API and retrieves the response.
  static Future<String> sendMessage(String message) async {
    // Initializes a map to hold the request data.
    final Map<String, dynamic> requestData = {
      "message": message, // The message to be sent to the API.
      "systemPrompt": "", // An optional system prompt parameter, left empty here.
    };

    // Checks if a chat ID exists and includes it in the request data if so.
    if (_chatId != null) {
      requestData["chatId"] = _chatId;
    }

    try {
      // Sends a POST request to the API endpoint with the request data.
      final http.Response response = await http.post(
        Uri.parse(_apiEndpoint), // Parses the API endpoint URL.
        headers: {'Content-Type': 'application/json'}, // Sets the content type header to application/json.
        body: jsonEncode(requestData), // Encodes the request data to JSON.
      );

      // Checks if the response status code is 200 (OK).
      if (response.statusCode == 200) {
        // Decodes the JSON response body.
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Updates the chat ID with the one provided in the response for future requests.
        _chatId = responseData["chatId"];
        // Returns the AI's response text.
        return responseData["response"];
      } else {
        // Returns an error message if the status code is not 200.
        return "Error: Received a non-successful status code: ${response.statusCode}";
      }
    } catch (e) {
      // Catches and returns any errors encountered during the request.
      return "Error: $e";
    }
  }
}
