import 'package:flutter/material.dart'; // Importing Flutter Material Design package
import 'package:flutter_chat_types/flutter_chat_types.dart' as types; // Importing Flutter Chat Types with alias for message types
import 'package:flutter/services.dart'; // Importing services for clipboard
import 'gpt-api.dart'; // Importing custom GPT API handler
import 'settings.dart'; // Importing settings page
import 'status.dart'; // Importing status page
import 'prodia-api.dart' as prodia; // Importing custom Prodia API handler for AI image generation
import 'dart:async'; // Importing Dart async library for Timer

// Global notifier for theme mode (dark/light)
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

// Global variables to persist chat session across pages without saving to system memory
final List<types.Message> globalMessages = [];
String? globalChatId;
String? latestImageUrl; // Variable to store the latest image URL for clipboard copy

// Global loading state
class LoadingState extends ChangeNotifier {
  bool _isLoading = false;
  bool _isMicOpen = false;

  bool get isLoading => _isLoading;
  bool get isMicOpen => _isMicOpen;

  void startLoading() {
    if (!_isMicOpen) {
      _isLoading = true;
      _isMicOpen = true;
      notifyListeners();
    }
  }

  void stopLoading() {
    _isLoading = false;
    _isMicOpen = false;
    notifyListeners();
  }
}

final LoadingState loadingState = LoadingState();

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
  final TextEditingController _textController = TextEditingController(); // Custom text controller
  bool _isSendButtonVisible = false; // State to manage send button visibility
  String _selectedService = 'chatbot'; // State to manage selected service

  @override
  void initState() {
    super.initState();
    user = types.User(id: 'user'); // Removed const due to dynamic assignment
    // Initialize chat ID from global variable
    GPTAPI.setChatId(globalChatId);
    _textController.addListener(_handleTextChange); // Listening to text changes
    loadingState.addListener(_handleLoadingStateChange); // Listening to loading state changes
  }

  @override
  void dispose() {
    loadingState.removeListener(_handleLoadingStateChange); // Remove listener on dispose
    super.dispose();
  }

  // Handling loading state changes to show or hide loading overlay
  void _handleLoadingStateChange() {
    if (loadingState.isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Processing...'),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  // Handling text changes for custom input
  void _handleTextChange() {
    final text = _textController.text;
    setState(() {
      _isSendButtonVisible = text.trim().isNotEmpty; // Update send button visibility based on text
    });
  }

  // Function to add a message to the chat
  void _addMessage(String text, {bool isUserMessage = true}) {
    final types.TextMessage message = types.TextMessage(
      author: isUserMessage ? user : types.User(id: 'ai'), // Removed const due to dynamic assignment
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: text,
    );

    setState(() {
      globalMessages.insert(0, message);
    });
  }

  // Function to send a message and handle AI response or generate an image
  void _sendMessage(types.PartialText message) {
    final text = message.text;
    _addMessage(text); // Display user message in chat log immediately
    loadingState.startLoading(); // Start loading state
    if (_selectedService == 'chatbot') {
      GPTAPI.sendMessage(text).then((response) {
        // Directly add the plain text response as a message
        _addMessage(response, isUserMessage: false);
        loadingState.stopLoading(); // Stop loading state when AI responds
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $error')), // Removed const due to dynamic content
        );
        loadingState.stopLoading(); // Ensure loading state stops on error
      });
    } else if (_selectedService == 'ai_generation') {
      prodia.ProdiaAPI.generateImage(text).then((response) {
        // Display user message in chat log followed by the generated image
        final types.ImageMessage imageMessage = types.ImageMessage(
          author: types.User(id: 'ai'), // Removed const due to dynamic assignment
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: DateTime.now().toString(),
          uri: response['imageUrl'],
          width: 512,
          height: 512,
          name: 'AI Generated Image', // Added 'name' parameter as required
          size: response['fileSize'], // Added 'size' parameter as required, assuming 'fileSize' is provided in the response
        );
        latestImageUrl = response['imageUrl']; // Storing the latest image URL for clipboard copy
        setState(() {
          globalMessages.insert(0, imageMessage);
        });
        loadingState.stopLoading(); // Stop loading state when AI responds
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate image: $error')), // Removed const due to dynamic content
        );
        loadingState.stopLoading(); // Ensure loading state stops on error
      });
    }
    _textController.clear(); // Clearing the text field after sending
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
          DropdownButton<String>(
            value: _selectedService,
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'chatbot', child: Text('Chatbot')),
              DropdownMenuItem(value: 'ai_generation', child: Text('AI Generation')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedService = value!;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: globalMessages.length,
              itemBuilder: (context, index) {
                final message = globalMessages[index];
                if (message is types.TextMessage) {
                  return GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text copied to clipboard')),
                      );
                    },
                    child: _buildTextMessageBubble(message),
                  );
                } else if (message is types.ImageMessage) {
                  return GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message.uri));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image URL copied to clipboard')),
                      );
                    },
                    child: Image.network(message.uri),
                  );
                } else {
                  return const SizedBox.shrink(); // Return an empty widget for unsupported message types
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
                  icon: const Icon(Icons.send),
                  onPressed: _isSendButtonVisible
                      ? () => _sendMessage(types.PartialText(text: _textController.text))
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

  // Custom widget to build text message bubbles with different colors for user and AI
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