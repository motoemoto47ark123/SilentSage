import 'package:flutter/material.dart'; // Importing Flutter Material Design package
import 'package:flutter_chat_ui/flutter_chat_ui.dart'; // Importing Flutter Chat UI package for chat UI components
import 'package:flutter_chat_types/flutter_chat_types.dart' as types; // Importing Flutter Chat Types with alias for message types
import 'gpt-api.dart'; // Importing custom GPT API handler
import 'settings.dart'; // Importing settings page
import 'status.dart'; // Importing status page

// Global notifier for theme mode (dark/light)
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

// Main entry point of the application
void main() => runApp(const MyApp());

// MyApp widget, the root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Builds the MaterialApp with theme based on isDarkMode
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: const MyHomePage(),
        );
      },
    );
  }
}

// Stateful widget for the home page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State class for MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  final types.User user = const types.User(id: 'user'); // User object for chat
  final List<types.Message> messages = []; // List to store chat messages
  int _selectedIndex = 0; // Index for bottom navigation bar
  Future<String>? _futureMessage; // Future for handling async message sending

  // Function to add a message to the chat
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

  // Function to send a message and handle AI response
  void _sendMessage(String text) {
    _addMessage(text);
    _futureMessage = GPTAPI.sendMessage(text);
    _futureMessage!.then((response) {
      _addMessage(response, isUserMessage: false);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    });
  }

  // Function to reset the chat
  void _resetChat() {
    setState(() {
      messages.clear();
      GPTAPI.resetChatId();
    });
  }

  // Function to handle bottom navigation bar item tap
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

  // Builds the UI for the home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
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
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white,
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
