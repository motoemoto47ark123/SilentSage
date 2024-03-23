import 'package:flutter/material.dart';
import '../../main.dart'; // Import main.dart to access isDarkMode ValueNotifier

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
            backgroundColor: isDark ? Colors.grey[850] : Theme.of(context).appBarTheme.backgroundColor, // Adjust AppBar color based on theme, using dark grey for dark mode
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Toggle Dark Mode',
                  style: TextStyle(fontSize: 25, color: isDark ? Colors.red : Colors.black), // Adjust text color based on theme
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    isDarkMode.value = value; // Update the entire app theme
                  },
                  semanticLabel: 'Toggle Dark Mode', // Added semantic label for accessibility
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Main Page',
                // Added semantic labels for better accessibility
                tooltip: 'Navigate to Main Page',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Status',
                // Added semantic labels for better accessibility
                tooltip: 'Navigate to Status Page',
              ),
            ],
            onTap: (index) {
              // Handle navigation to respective pages when tapping on items
              if (index == 0) {
                // Navigate back to Home Page
                if (!ModalRoute.of(context)!.isFirst) {
                  Navigator.pop(context);
                }
              } else if (index == 1) {
                // Navigate to Status Page
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage()));
              }
            },
          ),
        );
      },
    );
  }
}
