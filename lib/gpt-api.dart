import 'dart:convert';
import 'package:cronet_http/cronet_http.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';

class GPTAPI {
  static const String _apiEndpoint = "https://gpt-proxy.motoemotovps.serv00.net/chat";

  static void resetChatId(Store<AppState> store) {
    store.dispatch(ResetChatIdAction());
  }

  static void setChatId(Store<AppState> store, String? chatId) {
    store.dispatch(SetChatIdAction(chatId));
  }

  static String? getChatId(Store<AppState> store) {
    return store.state.chatId;
  }

  static Future<String> sendMessage(Store<AppState> store, String message) async {
    final Map<String, dynamic> requestData = {
      "message": message,
      "systemPrompt": "",
    };

    if (store.state.chatId != null) {
      requestData["chatId"] = store.state.chatId;
    }

    final http.Client httpClient;
    final engine = CronetEngine.build(
      cacheMode: CacheMode.memory,
      cacheMaxSize: 2 * 1024 * 1024,
      userAgent: 'SilentSage Agent',
    );
    httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);

    try {
      final http.Response response = await httpClient.post(
        Uri.parse(_apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        store.dispatch(SetChatIdAction(responseData["chatId"]));
        return responseData["response"];
      } else {
        return "Error: Received a non-successful status code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    } finally {
      httpClient.close();
    }
  }
}
