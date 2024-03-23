import 'package:flutter/material.dart'; // Importing Flutter Material Design package.
import 'main.dart'; // Import for the main application entry point.
import 'settings.dart'; // Import for the SettingsPage widget.

// Defining a StatelessWidget for the Status Page.
class StatusPage extends StatelessWidget {
  // Constructor accepting a key for widget identification.
  const StatusPage({Key? key}) : super(key: key);

  // Overriding the build method to define the UI of the StatusPage.
  @override
  Widget build(BuildContext context) {
    // Using ValueListenableBuilder to rebuild the widget when isDarkMode changes.
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Listening to the isDarkMode ValueNotifier.
      builder: (context, isDark, _) { // Builder function to rebuild UI based on isDark value.
        // Scaffold provides the structure for the page.
        return Scaffold(
          appBar: AppBar( // AppBar to display at the top of the page.
            title: const Text('Status Page'), // Title for the AppBar.
            backgroundColor: isDark ? Colors.black : Colors.white, // Conditional background color based on theme.
          ),
          body: Center( // Center widget to center the body content.
            child: Column( // Column widget to layout widgets vertically.
              mainAxisAlignment: MainAxisAlignment.center, // Aligning children to the center of the main axis.
              children: <Widget>[ // List of widgets inside the Column.
                Text( // Text widget to display uptime percentage.
                  'Uptime 99%',
                  style: TextStyle(fontSize: 25, color: Colors.red), // Styling for the text.
                ),
                SizedBox(height: 10), // SizedBox for spacing between widgets.
                LinearProgressIndicator( // LinearProgressIndicator to show progress.
                  value: 0.99, // Value representing the progress.
                  backgroundColor: isDark ? Colors.grey : Colors.white, // Conditional background color.
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Red color for the progress indicator.
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar( // BottomNavigationBar for navigation.
            backgroundColor: isDark ? Colors.black : Colors.white, // Conditional background color.
            selectedItemColor: Colors.red, // Color for the selected item.
            unselectedItemColor: Colors.grey, // Color for the unselected items.
            items: const <BottomNavigationBarItem>[ // List of navigation items.
              BottomNavigationBarItem(
                icon: Icon(Icons.chat), // Icon for chat.
                label: 'Chat', // Label for chat.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment), // Icon for status.
                label: 'Status', // Label for status.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings), // Icon for settings.
                label: 'Settings', // Label for settings.
              ),
            ],
            currentIndex: 1, // Current selected index indicating the Status Page.
            onTap: (index) { // Function to handle item taps.
              // Conditional navigation based on tapped index.
              if (index == 0) {
                // Navigating to the MyApp page if chat is tapped.
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
              } else if (index == 2) {
                // Navigating to the SettingsPage if settings is tapped.
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              }
            },
          ),
        );
      },
    );
  }
}
