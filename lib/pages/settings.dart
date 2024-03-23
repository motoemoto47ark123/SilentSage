import 'package:flutter/material.dart';
import '../../main.dart'; // Import main.dart to access isDarkMode ValueNotifier

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode, // Listen to the ValueNotifier for theme changes
      builder: (context, bool isDark, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings Page'),
            backgroundColor: isDark ? Colors.black : Colors.white, // Adjust AppBar color based on theme
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
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Main Page',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Status',
              ),
            ],
            onTap: (index) {
              // Handle navigation to respective pages when tapping on items
              if (index == 0) {
                // Navigate back to Home Page
                Navigator.pop(context);
              } else if (index == 1) {
                // Navigate to Status Page
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StatusPage()));
              }
            },
          ),
        );
      },
    );
  }
}
