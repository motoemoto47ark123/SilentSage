import 'package:flutter/material.dart';
import 'main.dart'; // Correct import path
import 'status.dart'; // Correct import path for StatusPage

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Listen to the ValueNotifier for theme changes, specifying the type explicitly
      builder: (context, isDark, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings Page'),
            backgroundColor: isDark ? Colors.black : Colors.white, // Adjust AppBar color based on theme, using black for dark mode and white for light mode
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Toggle Dark Mode',
                  style: TextStyle(fontSize: 25, color: isDark ? Colors.red : Colors.red), // Adjust text color based on theme, using red for both modes
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    isDarkMode.value = value; // Update the entire app theme
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home Page', // Renamed to Home Page
                tooltip: 'Navigate to Main Page', // Added semantic labels for better accessibility
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Status',
                tooltip: 'Navigate to Status Page', // Added semantic labels for better accessibility
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
                tooltip: 'You are on the Settings Page', // Indicate current page
              ),
            ],
            currentIndex: 2, // Indicate that we are on the Settings Page
            onTap: (index) {
              // Handle navigation to respective pages when tapping on items
              switch (index) {
                case 0:
                  // Navigate to Main Page
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
                  break;
                case 1:
                  // Navigate to Status Page
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage()));
                  break;
              }
            },
            backgroundColor: isDark ? Colors.black : Colors.white, // Adjust BottomNavigationBar background color based on theme
            selectedItemColor: Colors.red, // Keep the selected item color consistent across themes
            unselectedItemColor: isDark ? Colors.white : Colors.black, // Adjust unselected item color based on theme
          ),
        );
      },
    );
  }
}
