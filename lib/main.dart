import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types; // Corrected import statement for flutter_chat_types
import 'gpt-api.dart';
import 'settings.dart';
import 'status.dart';
import 'package:permission_handler/permission_handler.dart';

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
  State<MyHomePage> createState() => _MyHomePageState(); // Corrected visibility of _MyHomePageState
}

class _MyHomePageState extends State<MyHomePage> {
  final types.User user = const types.User(id: 'user'); // Corrected User class reference
  final List<types.Message> messages = []; // Corrected Message class reference
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.internet.request();
  }

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
    Permission.internet.status.then((status) {
      if (status.isGranted) {
        _addMessage(text);
        GPTAPI.sendMessage(text).then((response) {
          _addMessage(response, isUserMessage: false);
        }).catchError((error) {
          // Enhanced error handling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $error')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Internet permission not granted')),
        );
      }
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
        messages: messages, // Removed unnecessary cast
        onSendPressed: (text) {
          _sendMessage(text.text);
        },
        user: user,
        emojiEnlargementBehavior: EmojiEnlargementBehavior.multi, // Removed 'types.' prefix and corrected reference
        hideBackgroundOnEmojiMessages: true,
        // Removed 'message', 'showName', and 'usePreviewData' parameters as they are not defined in the current version of flutter_chat_ui
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
