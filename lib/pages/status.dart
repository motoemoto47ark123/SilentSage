import 'package:flutter/material.dart';
import '../../main.dart'; // Import main.dart to access isDarkMode ValueNotifier

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode, // Listen to the ValueNotifier for theme changes
      builder: (context, bool isDark, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Status Page'),
            backgroundColor: isDark ? Colors.black : Colors.blue, // Use isDark to determine the AppBar color, keeping blue for light theme as per original code
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Uptime 99%',
                  style: TextStyle(fontSize: 25, color: isDark ? Colors.red : Colors.green), // Adjust text color based on theme, red for dark, green for light
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.99,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.red : Colors.green), // Adjust progress bar color based on theme
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
            ],
            onTap: (index) {
              // Handle navigation to respective pages when tapping on items
              if (index == 0) {
                // Navigate to Settings Page
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              } else if (index == 1) {
                // Navigate back to Home Page
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
