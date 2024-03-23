import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier(false); // Starts in light mode

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(), // Theme changes based on isDarkMode
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
    GPTAPI.sendMessage(text).then((response) {
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
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // AppBar color based on theme
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetChat,
              ),
            ],
            title: const Text('Chat with AI'),
          ),
          body: Container(
            color: isDark ? Colors.black : Colors.white, // Background color based on theme
            child: Chat(
              messages: messages,
              onSendPressed: (types.PartialText text) {
                _sendMessage(text.text);
              },
              user: user,
              emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
              hideBackgroundOnEmojiMessages: true,
              theme: ChatTheme(
                inputBackgroundColor: isDark ? Colors.black : Colors.white,
                inputTextColor: isDark ? Colors.white : Colors.black,
                backgroundColor: isDark ? Colors.black : Colors.white,
                primaryColor: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // BottomNavigationBar color based on theme
            selectedItemColor: Colors.red, // Keep the selected item color consistent across themes
            unselectedItemColor: isDark ? Colors.white : Colors.black, // Adjust unselected item color based on theme
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
      },
    );
  }
}
