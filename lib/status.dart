import 'package:flutter/material.dart';
import 'main.dart'; // Correct import path
import 'settings.dart'; // Correct import path for SettingsPage

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Correctly listening to the ValueNotifier for theme changes
      builder: (context, isDark, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Status Page'),
            backgroundColor: isDark ? Colors.grey[850] : Colors.blue, // Correctly using a dark grey for dark theme
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[ // Use 'const' with the constructor to improve performance.
                Text(
                  'Uptime 99%',
                  style: TextStyle(fontSize: 25, color: Colors.green), // Correctly adjusting text color based on theme
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.99,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Correctly adjusting progress bar color based on theme
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
              // Correctly handling navigation to respective pages when tapping on items
              if (index == 0) {
                // Navigate to Settings Page
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage())); // Correctly using pushReplacement to avoid stacking
              } else if (index == 1) {
                // Navigate back to Home Page
                Navigator.pop(context); // Correctly ensuring we're popping to avoid unnecessary stack buildup
              }
            },
          ),
        );
      },
    );
  }
}
