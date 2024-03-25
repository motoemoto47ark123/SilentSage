// Importing 'dart:convert' to enable JSON data conversion functionalities, which are essential for processing the API responses.
import 'dart:convert';
// Importing 'cronet_http' package to utilize Cronet for making efficient HTTP requests. Cronet is an open-source network stack from Google Chrome, offering improved performance.
import 'package:cronet_http/cronet_http.dart';
// Importing 'http' package to provide a high-level API for making HTTP requests. This package simplifies the process of sending network requests and processing responses.
import 'package:http/http.dart' as http;

// The GPTAPI class is designed to encapsulate all the functionalities required for interacting with the GPT API, including sending messages and managing session state.
class GPTAPI {
  // _apiEndpoint stores the URL of the GPT API endpoint. It is marked as a constant to ensure that the URL remains unchanged throughout the application lifecycle. The HTTPS protocol is used for secure communication.
  static const String _apiEndpoint =
      "https://gpt-proxy.motoemotovps.serv00.net/chat";
  // _chatId is a static variable that holds the unique identifier for the chat session. It is nullable to allow for the possibility of no session being active.
  static String? _chatId;

  // resetChatId is a static method that clears the current chat ID, effectively starting a new chat session by setting _chatId to null.
  static void resetChatId() {
    _chatId = null;
  }

  // setChatId is a static method that assigns a new value to _chatId. This method is useful for restoring a previous session state by setting the chat ID to a specific value.
  static void setChatId(String? chatId) {
    _chatId = chatId;
  }

  // The chatId getter method provides read-only access to the current chat ID, allowing other parts of the application to check the session state.
  static String? get chatId => _chatId;

  // sendMessage is an asynchronous method that sends a message to the GPT API and awaits the response. It returns a Future that resolves to the response text from the API.
  static Future<String> sendMessage(String message) async {
    // requestData is a map that holds the data to be sent in the API request. It includes the message text and an optional system prompt parameter.
    final Map<String, dynamic> requestData = {
      "message": message,
      "systemPrompt": "",
    };

    // If a chat ID is already set, it is included in the requestData to maintain the session context with the API.
    if (_chatId != null) {
      requestData["chatId"] = _chatId;
    }

    // Initializing the HTTP client. CronetEngine is used to create a Cronet-based HTTP client, offering enhanced performance through the use of the Cronet networking stack.
    final http.Client httpClient;
    final engine = CronetEngine.build(
      cacheMode: CacheMode.memory, // Configures the engine to use in-memory caching.
      cacheMaxSize: 2 * 1024 * 1024, // Sets the maximum cache size to 2MB.
      userAgent: 'SilentSage Agent', // Custom user agent string for identifying the client.
    );
    httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);

    try {
      // Sending a POST request to the GPT API endpoint with the requestData. The request includes a header specifying the content type as JSON.
      final http.Response response = await httpClient.post(
        Uri.parse(_apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      // Checking the response status code. If it is 200 (OK), the response body is decoded from JSON and processed.
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _chatId = responseData["chatId"]; // Updating the chat ID with the new value from the response.
        return responseData["response"]; // Returning the AI's response text.
      } else {
        // If the status code is not 200, an error message is returned indicating a non-successful status code.
        return "Error: Received a non-successful status code: ${response.statusCode}";
      }
    } catch (e) {
      // Catching and returning any errors encountered during the request. This ensures that the application can gracefully handle network or API failures.
      return "Error: $e";
    } finally {
      // Ensuring that the HTTP client is closed after the request is completed to free up resources and prevent memory leaks.
      httpClient.close();
    }
  }
}
