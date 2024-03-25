import 'package:flutter/material.dart'; // This line imports the Material Design library from Flutter, enabling the use of various UI components like Scaffold, AppBar, and Text widgets.
import 'main.dart'; // This import statement brings in the main.dart file, allowing for navigation to the MyApp widget which serves as the entry point of the application.
import 'settings.dart'; // This line imports the settings.dart file, making the SettingsPage widget accessible for navigation purposes.

// The StatusPage widget is defined below as a stateless widget, meaning its properties cannot change over time. It is used to display the application's status information.
class StatusPage extends StatelessWidget {
  // The constructor for StatusPage, which optionally accepts a Key object named 'key' for widget identification and management within the Flutter framework.
  const StatusPage({super.key});

  // The build method is overridden here to construct the UI of the StatusPage widget. It takes a BuildContext object as an argument, which holds the location of this widget within the widget tree.
  @override
  Widget build(BuildContext context) {
    // The ValueListenableBuilder widget is used here to listen for changes to the isDarkMode ValueNotifier defined in main.dart. It rebuilds its child widget whenever isDarkMode's value changes.
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Specifies the ValueNotifier object to listen to, in this case, isDarkMode.
      builder: (context, isDark, _) { // The builder function defines the widget to be rebuilt in response to value changes. It receives the current value of isDarkMode as 'isDark'.
        // The Scaffold widget provides a high-level structure for the StatusPage, including an AppBar at the top and a body section for content.
        return Scaffold(
          appBar: AppBar(
            title: const Text('Status Page'), // Sets the text displayed in the AppBar.
            backgroundColor: isDark ? Colors.black : Colors.white, // Dynamically sets the AppBar's background color based on the current theme mode (dark or light).
          ),
          body: Center(
            // The Center widget centers its child within itself.
            child: Column(
              // The Column widget arranges its children vertically.
              mainAxisAlignment: MainAxisAlignment.center, // Centers the Column's children along the main axis.
              children: <Widget>[
                const Text(
                  'Uptime 99%', // Displays a text indicating the uptime percentage.
                  style: TextStyle(fontSize: 25, color: Colors.red), // Sets the style of the text, including font size and color.
                ),
                const SizedBox(height: 10), // Provides vertical spacing between widgets.
                LinearProgressIndicator(
                  value: 0.99, // Sets the current value of the progress indicator to represent 99% uptime.
                  backgroundColor: isDark ? Colors.grey : Colors.white, // Dynamically sets the background color of the progress bar.
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red), // Sets the color of the progress indicator to red.
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // Dynamically sets the background color of the BottomNavigationBar.
            selectedItemColor: Colors.red, // Sets the color of the selected item in the BottomNavigationBar.
            unselectedItemColor: Colors.grey, // Sets the color of unselected items in the BottomNavigationBar.
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat), // Defines an icon for the chat item.
                label: 'Chat', // Sets the label for the chat item.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment), // Defines an icon for the status item.
                label: 'Status', // Sets the label for the status item.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings), // Defines an icon for the settings item.
                label: 'Settings', // Sets the label for the settings item.
              ),
            ],
            currentIndex: 1, // Sets the currently selected index to 1, corresponding to the Status item.
            onTap: (index) { // Defines a callback function to handle taps on the BottomNavigationBar items.
              // Conditional navigation based on the tapped item's index.
              if (index == 0) {
                // Navigates to the MyApp widget if the first item (Chat) is tapped.
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
              } else if (index == 2) {
                // Navigates to the SettingsPage widget if the third item (Settings) is tapped.
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              }
            },
          ),
        );
      },
    );
  }
}
