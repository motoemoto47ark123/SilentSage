import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';

final ValueNotifier<bool> isDarkMode =
    ValueNotifier(false); // Updated to start in light mode

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(), // Toggle theme based on isDark
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final types.User user = const types.User(id: 'user');
  final List<types.Message> messages = [];
  int _selectedIndex = 0;
  Future<String>? _futureMessage;

  void _addMessage(String text, {bool isUserMessage = true}) {
    final types.TextMessage message = types.TextMessage(
      author: isUserMessage ? user : const types.User(id: 'ai'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: text,
    );

    setState(() {
      messages.insert(0, message);
    });
  }

  void _sendMessage(String text) {
    _addMessage(text); // User messages
    _futureMessage = GPTAPI.sendMessage(text);
    _futureMessage!.then((response) {
      _addMessage(response, isUserMessage: false); // AI messages
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    });
  }

  void _resetChat() {
    setState(() {
      messages.clear();
      GPTAPI.resetChatId(); // Correctly call resetChatId to clean the _chatId
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const StatusPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat, // Added reset chat functionality to AppBar
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _futureMessage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Chat(
              messages: messages,
              onSendPressed: (types.PartialText text) {
                _sendMessage(text.text);
              },
              user: user,
              emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
              hideBackgroundOnEmojiMessages: true,
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white, // Toggle BottomNavigationBar color based on isDarkMode
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
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
      ),
    );
  }
}
