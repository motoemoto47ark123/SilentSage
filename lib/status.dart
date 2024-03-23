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
            backgroundColor: isDark ? Colors.black : Colors.white, // Using black for dark theme and white for light theme
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ // Removed 'const' to allow for dynamic color changes
                Text(
                  'Uptime 99%',
                  style: TextStyle(fontSize: 25, color: Colors.red), // Using red text color for both themes
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.99,
                  backgroundColor: isDark ? Colors.grey : Colors.white, // Adjusting background color based on theme
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red), // Using red for the progress bar in both themes
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // Adjusting bottom navigation bar background color based on theme
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home Page', // Renamed to Home Page
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
            currentIndex: 1, // Indicating that we are on the Status Page
            selectedItemColor: Colors.red, // Keep the selected item color consistent across themes
            unselectedItemColor: isDark ? Colors.white : Colors.black, // Adjust unselected item color based on theme
            onTap: (index) {
              // Correctly handling navigation to respective pages when tapping on items
              switch (index) {
                case 0:
                  // Navigate back to Home Page
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp())); // Correctly using pushReplacement to avoid stacking
                  break;
                case 2:
                  // Navigate to Settings Page
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage())); // Correctly using pushReplacement to avoid stacking
                  break;
              }
            },
          ),
        );
      },
    );
  }
}
