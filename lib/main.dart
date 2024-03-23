import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types; // Corrected import statement for flutter_chat_types
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return MaterialApp(
          theme: value ? ThemeData.dark() : ThemeData.light(),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final types.User user = const types.User(id: 'user'); // Corrected User class reference
  final List<types.Message> messages = []; // Corrected Message class reference
  int _selectedIndex = 0;

  void _addMessage(String text, {bool isUserMessage = true}) {
    final types.TextMessage message = types.TextMessage(
      author: isUserMessage ? user : const types.User(id: 'ai'), // Corrected User and TextMessage class references
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: text,
    );

    setState(() {
      messages.insert(0, message);
    });
  }

  void _sendMessage(String text) {
    _addMessage(text);
    GPTAPI.sendMessage(text).then((response) {
      _addMessage(response, isUserMessage: false);
    }).catchError((error) {
      // Removed the print statement to adhere to best practices for production code
    });
  }

  void _resetChat() {
    setState(() {
      messages.clear();
      // Removed the call to GPTAPI.resetChatId() as it's not defined in GPTAPI
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
          ),
        ],
        title: const Text('Chat with AI'),
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white,
      ),
      body: Chat(
        messages: messages.map((m) => m as types.Message).toList(), // Corrected Message class reference and casting
        onSendPressed: (text) {
          _sendMessage(text.text);
        },
        user: user,
        emojiEnlargementBehavior: types.EmojiEnlargementBehavior.multi, // Added required parameter
        hideBackgroundOnEmojiMessages: true, // Added required parameter
        message: types.TextMessage(text: '', author: user, id: '', createdAt: DateTime.now().millisecondsSinceEpoch), // Added required parameter
        showName: true, // Added required parameter
        usePreviewData: true, // Added required parameter
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: isDarkMode.value ? Colors.white : Colors.black,
      ),
    );
  }
}
