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
                  activeTrackColor: Colors.black.withOpacity(0.5), // Adjust visibility in dark mode with slightly transparent black to follow the new instruction
                  activeColor: Colors.black, // Ensure the switch thumb is black when active for better visibility
                  materialTapTargetSize: MaterialTapTargetSize.padded, // Increase tap target size for better accessibility
                  thumbColor: isDark ? MaterialStateProperty.all(Colors.white) : MaterialStateProperty.all(Colors.black), // Ensure the thumb color is white when not toggled and black when toggled
                  trackColor: MaterialStateProperty.all(Colors.redAccent), // RedAccent track color for visibility
                  splashRadius: 28, // Increase splash radius for visual feedback
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, // Toggle BottomNavigationBar color based on isDarkMode
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
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
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
              } else if (index == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage()));
              }
            },
          ),
        );
      },
    );
  }
}


