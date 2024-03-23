import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';
import 'package:widget_loading/widget_loading.dart'; // Added import for widget_loading

final ValueNotifier<bool> isDarkMode = ValueNotifier(true); // Always dark mode

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Always use dark theme
      home: const MyHomePage(),
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
  bool _isLoading = false; // Added loading state

  void _addMessage(String text, {bool isUserMessage = true, Color color = Colors.red}) {
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
    setState(() {
      _isLoading = true; // Start loading
    });
    _addMessage(text, color: Colors.red); // User messages in red
    GPTAPI.sendMessage(text).then((response) {
      _addMessage(response, isUserMessage: false, color: Colors.blue); // AI messages in blue
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    }).whenComplete(() {
      setState(() {
        _isLoading = false; // Stop loading
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
          ),
        ],
        title: const Text('Chat with AI'),
      ),
      body: Stack(
        children: [
          Chat(
            messages: messages,
            onSendPressed: (text) {
              _sendMessage(text.text);
            },
            user: user,
            emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
            hideBackgroundOnEmojiMessages: true,
          ),
          if (_isLoading) // Show loading icon when processing
            const Center(
              child: LoadingBouncingLine.circle(),
            ),
        ],
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
      ),
    );
  }
}
