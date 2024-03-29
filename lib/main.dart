import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter/services.dart';
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';
import 'prodia-api.dart' as prodia;
import 'dart:async';
import 'app_state.dart';
import 'reducers.dart';
import 'actions.dart';

void main() {
  final store = Store<AppState>(appReducer, initialState: AppState.initial());
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({Key? key, required this.store}) : super(key: key); // Updated to use Key? key instead of super.key

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, ThemeMode>(
        converter: (store) => store.state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        builder: (context, themeMode) => MaterialApp(
          home: const MyHomePage(),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode, // Directly using the themeMode from StoreConnector
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key); // Updated to use Key? key instead of super.key

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late types.User user;
  final TextEditingController _textController = TextEditingController();
  String? globalChatId;

  @override
  void initState() {
    super.initState();
    user = types.User(id: 'user');
    _textController.addListener(_handleTextChange);
    globalChatId = "some_chat_id"; // Assuming a default or fetched chat ID
    StoreProvider.of<AppState>(context, listen: false).dispatch(SetChatIdAction(globalChatId));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final text = _textController.text;
    final isVisible = text.isNotEmpty;
    StoreProvider.of<AppState>(context, listen: false).dispatch(UpdateSendButtonVisibilityAction(isVisible));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) => Scaffold(
        appBar: AppBar(title: const Text('Chat App')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: vm.messages.length,
                itemBuilder: (context, index) {
                  final message = vm.messages[index];
                  return message is types.TextMessage ? _buildTextMessageBubble(message) : const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: vm.isSendButtonVisible
                        ? () => _sendMessage(types.PartialText(text: _textController.text))
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: vm.isDarkMode ? Colors.black : Colors.white,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Status'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
          currentIndex: vm.selectedIndex,
          onTap: (index) => StoreProvider.of<AppState>(context, listen: false).dispatch(UpdateSelectedIndexAction(index)),
        ),
      ),
    );
  }

  void _sendMessage(types.PartialText message) {
    // Implementation for sending a message
  }

  Widget _buildTextMessageBubble(types.TextMessage message) {
    bool isUserMessage = message.author.id == user.id;
    Color bubbleColor = isUserMessage ? Colors.red : Colors.blue;
    TextAlign textAlign = isUserMessage ? TextAlign.right : TextAlign.left;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

class _ViewModel {
  final List<types.Message> messages;
  final bool isDarkMode;
  final bool isSendButtonVisible;
  final int selectedIndex;

  _ViewModel({
    required this.messages,
    required this.isDarkMode,
    required this.isSendButtonVisible,
    required this.selectedIndex,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      messages: store.state.messages,
      isDarkMode: store.state.isDarkMode,
      isSendButtonVisible: store.state.isSendButtonVisible,
      selectedIndex: store.state.selectedIndex,
    );
  }
}
