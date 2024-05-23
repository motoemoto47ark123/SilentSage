import 'package:flutter/material.dart'; // This line imports the Material Design package from Flutter, providing UI components.
import 'package:flutter_chat_types/flutter_chat_types.dart' as types; // Imports the Flutter Chat Types package with an alias 'types' for easy reference to message types.
import 'package:flutter/services.dart'; // Imports Flutter's services library, which includes functionalities like clipboard access.
import 'gpt-api.dart'; // Imports a custom API handler for interacting with a GPT-based service.
import 'cohere-api.dart'; // Imports a custom Cohere API handler for chatbot interactions.
import 'settings.dart'; // Imports the settings page for the application, allowing users to adjust app preferences.
import 'status.dart'; // Imports the status page, likely used to display some form of user or application status.
import 'prodia-api.dart' as prodia; // Imports a custom Prodia API handler with an alias 'prodia', used for AI image generation.
import 'dart:async'; // Imports Dart's asynchronous library, which includes classes like Future and Stream for handling asynchronous operations.

// A global notifier that tracks the theme mode (dark or light) across the app.
final ValueNotifier<bool> isDarkMode = ValueNotifier(true);

// Global variables to maintain the chat session's state across different pages without persisting data to the device's memory.
final List<types.Message> globalMessages = []; // Holds the list of chat messages.
String? globalChatId; // Optionally stores a global chat identifier.
String? latestImageUrl; // Optionally stores the URL of the most recently generated image for easy access.

// Defines a class to manage the loading state and microphone access state across the app.
class LoadingState extends ChangeNotifier {
  bool _isLoading = false; // Tracks whether a loading indicator should be shown.
  bool _isMicOpen = false; // Tracks whether the microphone is in use.

  // Public getters to expose the private state variables.
  bool get isLoading => _isLoading;
  bool get isMicOpen => _isMicOpen;

  // Method to initiate loading state, ensuring the microphone is not already in use.
  void startLoading() {
    if (!_isMicOpen) {
      _isLoading = true;
      _isMicOpen = true;
      notifyListeners(); // Notifies listeners of state changes to update UI accordingly.
    }
  }

  // Method to stop the loading state and indicate the microphone is no longer in use.
  void stopLoading() {
    _isLoading = false;
    _isMicOpen = false;
    notifyListeners(); // Notifies listeners of state changes to update UI accordingly.
  }
}

// Instantiates the LoadingState class for global access.
final LoadingState loadingState = LoadingState();

// The main entry point of the Flutter application.
void main() => runApp(const MyApp());

// Defines the MyApp widget, which serves as the root of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor with an optional key parameter.

  // Builds the MaterialApp widget with a theme that toggles based on the isDarkMode value.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(), // Applies dark or light theme based on isDark value.
          home: const MyHomePage(), // Sets MyHomePage as the default route.
        );
      },
    );
  }
}

// Defines a stateful widget for the home page of the app.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); // Constructor with an optional key parameter.

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // Creates the mutable state for this widget.
}

// The state class associated with MyHomePage, containing the dynamic state of the home page.
class _MyHomePageState extends State<MyHomePage> {
  late types.User user; // Declares a User object for the chat, initialized in initState.
  int _selectedIndex = 0; // Tracks the currently selected index in the bottom navigation bar.
  final TextEditingController _textController = TextEditingController(); // Manages the text input field for chat messages.
  bool _isSendButtonVisible = false; // Controls the visibility of the send button based on text input.
  String _selectedService = 'gpt-3'; // Tracks the currently selected service (e.g., GPT-3, Cohere, or AI image generation).

  @override
  void initState() {
    super.initState();
    user = types.User(id: 'user'); // Initializes the user object with a unique identifier.
    // Sets the global chat ID for the session, allowing for continuity across app usage.
    GPTAPI.setChatId(globalChatId);
    _textController.addListener(_handleTextChange); // Adds a listener to handle changes in the text input field.
    loadingState.addListener(_handleLoadingStateChange); // Adds a listener to react to changes in the loading state.
  }

  @override
  void dispose() {
    loadingState.removeListener(_handleLoadingStateChange); // Removes the loading state listener upon widget disposal.
    super.dispose();
  }

  // Handles changes in the loading state, showing or hiding a loading dialog accordingly.
  void _handleLoadingStateChange() {
    if (loadingState.isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevents dialog dismissal on back press.
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(), // Displays a loading spinner.
                  SizedBox(height: 20), // Adds vertical spacing.
                  Text('Processing...'), // Displays a processing message.
                ],
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog'); // Dismisses the dialog when loading completes.
    }
  }

  // Handles text input changes, updating the send button's visibility based on the input's content.
  void _handleTextChange() {
    final text = _textController.text;
    setState(() {
      _isSendButtonVisible = text.trim().isNotEmpty; // Shows the send button only if there's non-whitespace text.
    });
  }

  // Adds a message to the chat, either from the user or as a response.
  void _addMessage(String text, {bool isUserMessage = true}) {
    final types.TextMessage message = types.TextMessage(
      author: isUserMessage ? user : types.User(id: 'ai'), // Sets the message author based on the message source.
      createdAt: DateTime.now().millisecondsSinceEpoch, // Sets the creation time to the current timestamp.
      id: DateTime.now().toString(), // Generates a unique ID based on the current time.
      text: text, // Sets the message text.
    );

    setState(() {
      globalMessages.insert(0, message); // Inserts the new message at the beginning of the chat log.
    });
  }

  // Sends a message and handles the response, either by displaying the AI's text response or generating an image.
  void _sendMessage(types.PartialText message) {
    final text = message.text;
    _addMessage(text); // Immediately displays the user's message in the chat.
    loadingState.startLoading(); // Initiates the loading state.
    if (_selectedService == 'gpt-3') {
      GPTAPI.sendMessage(text).then((response) {
        // Handles the plain text response from the AI.
        _addMessage(response, isUserMessage: false); // Adds the AI's response to the chat.
        loadingState.stopLoading(); // Stops the loading state once the AI responds.
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $error')), // Displays an error message if the send fails.
        );
        loadingState.stopLoading(); // Ensures the loading state is stopped even if an error occurs.
      });
    } else if (_selectedService == 'cohere') {
      CohereAPI.sendMessage(text).then((response) {
        // Handles the plain text response from the Cohere chatbot.
        _addMessage(response, isUserMessage: false); // Adds the Cohere's response to the chat.
        loadingState.stopLoading(); // Stops the loading state once the Cohere responds.
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $error')), // Displays an error message if the send fails.
        );
        loadingState.stopLoading(); // Ensures the loading state is stopped even if an error occurs.
      });
    } else if (_selectedService == 'ai_generation') {
      prodia.ProdiaAPI.generateImage(text).then((response) {
        // Handles the response from the image generation API.
        final types.ImageMessage imageMessage = types.ImageMessage(
          author: types.User(id: 'ai'), // Sets the AI as the author of the image message.
          createdAt: DateTime.now().millisecondsSinceEpoch, // Sets the creation time to the current timestamp.
          id: DateTime.now().toString(), // Generates a unique ID for the message.
          uri: response['imageUrl'], // Sets the image URL from the API response.
          width: 512, // Assumes a fixed width for the image.
          height: 512, // Assumes a fixed height for the image.
          name: 'AI Generated Image', // Provides a name for the image.
          size: response['fileSize'], // Sets the image size based on the API response, assuming 'fileSize' is provided.
        );
        latestImageUrl = response['imageUrl']; // Updates the latest image URL for clipboard access.
        setState(() {
          globalMessages.insert(0, imageMessage); // Adds the image message to the chat log.
        });
        loadingState.stopLoading(); // Stops the loading state once the image is generated.
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate image: $error')), // Displays an error message if image generation fails.
        );
        loadingState.stopLoading(); // Ensures the loading state is stopped even if an error occurs.
      });
    }
    _textController.clear(); // Clears the text input field after sending a message.
  }

  // Builds the UI for the home page, including the app bar, chat log, text input field, and bottom navigation bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'), // Sets the title of the app bar.
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh), // Displays a refresh icon.
            onPressed: _resetChat, // Resets the chat when the icon is pressed.
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedService, // Binds the selected service to the dropdown.
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'gpt-3', child: Text('GPT-3')), // Option for the GPT-3 service.
              DropdownMenuItem(value: 'cohere', child: Text('Cohere')), // Option for the Cohere chatbot service.
              DropdownMenuItem(value: 'ai_generation', child: Text('AI Generation')), // Option for the AI image generation service.
            ],
            onChanged: (value) {
              setState(() {
                _selectedService = value!; // Updates the selected service when a new option is chosen.
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              reverse: true, // Reverses the order of chat messages to start from the bottom.
              itemCount: globalMessages.length, // Sets the number of items in the list to the number of messages.
              itemBuilder: (context, index) {
                final message = globalMessages[index]; // Retrieves the message at the given index.
                if (message is types.TextMessage) {
                  return GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message.text)); // Copies the message text to the clipboard on long press.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text copied to clipboard')), // Notifies the user that the text has been copied.
                      );
                    },
                    child: _buildTextMessageBubble(message), // Builds a bubble for the text message.
                  );
                } else if (message is types.ImageMessage) {
                  return GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message.uri)); // Copies the image URL to the clipboard on long press.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image URL copied to clipboard')), // Notifies the user that the URL has been copied.
                      );
                    },
                    child: Image.network(message.uri), // Displays the image from the URL.
                  );
                } else {
                  return const SizedBox.shrink(); // Returns an empty widget for unsupported message types.
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // Adds padding around the text input field.
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController, // Binds the text controller to the text field.
                    decoration: InputDecoration(
                      hintText: "Type a message", // Displays a hint in the text field.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Sets a rounded border for the text field.
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send), // Displays a send icon.
                  onPressed: _isSendButtonVisible
                      ? () => _sendMessage(types.PartialText(text: _textController.text)) // Sends the message when the icon is pressed.
                      : null, // Disables the button when there's no text to send.
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white, // Sets the background color based on the theme mode.
        selectedItemColor: Colors.red, // Sets the color of the selected item.
        unselectedItemColor: Colors.grey, // Sets the color of unselected items.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // Displays a chat icon.
            label: 'Chat', // Sets the label for the chat item.
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment), // Displays an assessment icon.
            label: 'Status', // Sets the label for the status item.
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Displays a settings icon.
            label: 'Settings', // Sets the label for the settings item.
          ),
        ],
        currentIndex: _selectedIndex, // Binds the selected index to the bottom navigation bar.
        onTap: _onItemTapped, // Updates the selected index when an item is tapped.
      ),
    );
  }

  // Resets the chat by clearing the message log and resetting the chat ID.
  void _resetChat() {
    setState(() {
      globalMessages.clear(); // Clears the list of messages.
    });
    GPTAPI.resetChatId(); // Resets the global chat ID.
    globalChatId = null; // Clears the stored chat ID.
    _textController.clear(); // Clears the text input field.
  }

  // Handles taps on the bottom navigation bar items, updating the selected index and navigating accordingly.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Updates the selected index.
    });
    if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const StatusPage())); // Navigates to the Status page.
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SettingsPage())); // Navigates to the Settings page.
    }
  }

  // Builds a custom widget for displaying text messages with different background colors for user and AI messages.
  Widget _buildTextMessageBubble(types.TextMessage message) {
    bool isUserMessage = message.author.id == user.id; // Determines if the message is from the user.
    Color bubbleColor = isUserMessage ? Colors.red : Colors.blue; // Sets the bubble color based on the message source.
    TextAlign textAlign = isUserMessage ? TextAlign.right : TextAlign.left; // Aligns the text based on the message source.

    return Container(
      padding: const EdgeInsets.all(8), // Adds padding inside the bubble.
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal 8), // Adds margin around the bubble.
      decoration: BoxDecoration(
        color: bubbleColor, // Applies the determined background color.
        borderRadius: BorderRadius.circular(12), // Rounds the corners of the bubble.
      ),
      child: Text(
        message.text, // Displays the message text.
        style: const TextStyle(color: Colors.white), // Sets the text color to white for contrast.
        textAlign: textAlign, // Applies the determined text alignment.
      ),
    );
  }
}