import 'package:flutter/material.dart'; // Importing Flutter Material Design package.
import 'main.dart'; // Import for accessing the main application widget.
import 'status.dart'; // Import for navigating to the StatusPage widget.

// Defines a stateless widget for the settings page.
class SettingsPage extends StatelessWidget {
  // Constructor accepting a key for widget identification.
  const SettingsPage({Key? key}) : super(key: key);

  // Overriding the build method to design the UI of the settings page.
  @override
  Widget build(BuildContext context) {
    // Using ValueListenableBuilder to rebuild the widget when isDarkMode changes.
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Listening to changes in the theme mode.
      builder: (context, isDark, _) {
        // Scaffold provides the structure for the settings page.
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings Page'), // Title for the app bar.
            backgroundColor: isDark ? Colors.black : Colors.white, // Dynamic background color based on theme.
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Toggle Dark Mode', // Text displayed above the switch.
                  style: TextStyle(fontSize: 25, color: isDark ? Colors.red : Colors.red), // Text style with dynamic color.
                ),
                Switch(
                  value: isDark, // The current value of the switch.
                  onChanged: (value) {
                    isDarkMode.value = value; // Toggles the theme mode.
                  },
                  activeTrackColor: Colors.black.withOpacity(0.5), // Track color when the switch is active.
                  activeColor: Colors.black, // Color of the thumb when the switch is active.
                  materialTapTargetSize: MaterialTapTargetSize.padded, // Increases tap target size for accessibility.
                  thumbColor: isDark ? MaterialStateProperty.all(Colors.white) : MaterialStateProperty.all(Colors.black), // Dynamic thumb color.
                  trackColor: MaterialStateProperty.all(Colors.redAccent), // Track color for better visibility.
                  splashRadius: 28, // Radius of the ripple effect when the switch is toggled.
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // Dynamic background color based on theme.
            selectedItemColor: Colors.red, // Color for the selected item.
            unselectedItemColor: Colors.grey, // Color for the unselected items.
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat', // Label for the chat navigation item.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Status', // Label for the status navigation item.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings', // Label for the settings navigation item, indicating the current page.
              ),
            ],
            currentIndex: 2, // Index for the current navigation item.
            onTap: (index) {
              // Handles navigation based on the selected index.
              if (index == 0) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp())); // Navigates to the chat page.
              } else if (index == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage())); // Navigates to the status page.
              }
            },
          ),
        );
      },
    );
  }
}
