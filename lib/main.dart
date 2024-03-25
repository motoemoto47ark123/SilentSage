import 'package:flutter/material.dart'; // Importing Flutter Material Design package
import 'package:flutter_chat_ui/flutter_chat_ui.dart'; // Importing Flutter Chat UI package for chat UI components
import 'package:flutter_chat_types/flutter_chat_types.dart'
    as types; // Importing Flutter Chat Types with alias for message types
import 'gpt-api.dart'; // Importing custom GPT API handler
import 'settings.dart'; // Importing settings page
import 'status.dart'; // Importing status page

// Global notifier for theme mode (dark/light)
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

// Global variables to persist chat session across pages without saving to system memory
final List<types.Message> globalMessages = [];
String? globalChatId;

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
  late types.User user; // User object for chat
  int _selectedIndex = 0; // Index for bottom navigation bar
  Future<String>? _futureMessage; // Future for handling async message sending
  final TextEditingController _textController =
      TextEditingController(); // Custom text controller
  bool _isSendButtonVisible = false; // State to manage send button visibility

  @override
  void initState() {
    super.initState();
    user = const types.User(id: 'user');
    // Initialize chat ID from global variable
    GPTAPI.setChatId(globalChatId);
    _textController.addListener(_handleTextChange); // Listening to text changes
  }

  // Handling text changes for custom input
  void _handleTextChange() {
    final text = _textController.text;
    setState(() {
      _isSendButtonVisible =
          text.trim().isNotEmpty; // Update send button visibility based on text
    });
  }

  // Function to add a message to the chat
  void _addMessage(String text, {bool isUserMessage = true}) {
    final types.TextMessage message = types.TextMessage(
      author: isUserMessage ? user : const types.User(id: 'ai'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: text,
    );

    setState(() {
      globalMessages.insert(0, message);
    });
  }

  // Function to send a message and handle AI response
  void _sendMessage(types.PartialText message) {
    final text = message.text;
    _addMessage(text);
    _futureMessage = GPTAPI.sendMessage(text);
    setState(() {}); // Trigger UI update to show loading indicator
    _futureMessage!.then((response) {
      _addMessage(response, isUserMessage: false);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    }).whenComplete(
        () => setState(() {})); // Update UI after message is sent or failed
    _textController.clear(); // Clearing the text field after sending
  }

  // Function to reset the chat
  void _resetChat() {
    setState(() {
      globalMessages.clear();
    });
    GPTAPI.resetChatId();
    globalChatId = null;
    _textController.clear(); // Clearing the text field on chat reset
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _futureMessage,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Chat(
                    messages: globalMessages,
                    user: user,
                    onSendPressed: (message) => _sendMessage(
                        message), // Corrected to match the required signature
                    emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
                    hideBackgroundOnEmojiMessages: true,
                  );
                }
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
                  icon: Icon(Icons.send),
                  onPressed: _isSendButtonVisible
                      ? () => _sendMessage(
                          types.PartialText(text: _textController.text))
                      : null,
                ),
              ],
            ),
          ),
        ],
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
