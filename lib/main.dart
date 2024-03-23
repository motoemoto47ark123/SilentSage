import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier(true); // Always dark mode

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
  bool _isLoading = false;

  void _addMessage(String text, {bool isUserMessage = true}) {
    final types.TextMessage message = types.TextMessage(
      author: isUserMessage ? user : const types.User(id: 'ai'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: text,
      // Customizing message bubble colors
      metadata: {'color': isUserMessage ? 'red' : 'blue', 'textColor': 'white'},
    );

    setState(() {
      messages.insert(0, message);
    });
  }

  void _sendMessage(String text) {
    setState(() {
      _isLoading = true;
    });
    _addMessage(text); // User messages
    GPTAPI.sendMessage(text).then((response) {
      _addMessage(response, isUserMessage: false); // AI messages
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
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
              onSendPressed: (text) {
                _sendMessage(text.text);
              },
              user: user,
              emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
              hideBackgroundOnEmojiMessages: true,
              customMessageBuilder: (message) {
                // Custom message bubble colors
                if (message is types.TextMessage) {
                  final color = message.metadata?['color'] == 'red' ? Colors.red : Colors.blue;
                  final textColor = Colors.white;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: textColor),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // BottomNavigationBar color based on theme
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
