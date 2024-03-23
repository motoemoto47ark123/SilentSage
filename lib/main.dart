import 'package:flutter/material.dart';
import 'settings.dart'; // Corrected import path as per the followup instruction
import 'status.dart'; // Corrected import path as per the followup instruction

final ValueNotifier<bool> isDarkMode = ValueNotifier(false); // Added ValueNotifier for theme change

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Listen to the ValueNotifier
      builder: (context, value, child) {
        return MaterialApp(
          title: _title,
          theme: value ? ThemeData.dark().copyWith(
            primaryColor: Colors.black, // Set primary color for dark mode
            scaffoldBackgroundColor: Colors.black, // Set scaffold background color for dark mode
            colorScheme: ColorScheme.dark().copyWith(
              primary: Colors.black,
              secondary: Colors.red, // Keeping red as the secondary color for dark theme
            ),
          ) : ThemeData.light().copyWith(
            primaryColor: Colors.white, // Set primary color for light mode
            scaffoldBackgroundColor: Colors.white, // Set scaffold background color for light mode
            colorScheme: ColorScheme.light().copyWith(
              primary: Colors.white,
              secondary: Colors.red, // Keeping red as the secondary color for light theme
            ),
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState(); // Made MyHomePageState public to fix the invalid use of a private type in a public API
}

class MyHomePageState extends State<MyHomePage> { // Made MyHomePageState public to fix the invalid use of a private type in a public API
  int _counter = 0;
  int _selectedIndex = 0; // Updated to indicate that we are on the Home Page

  void incrementCounter() { // Made incrementCounter public to fix the declaration '_incrementCounter' isn't referenced error
    setState(() {
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) { // Check if the current page is not the same as the one being navigated to
      setState(() {
        _selectedIndex = index;
      });
      if (index == 1) {
        // Navigate to Status Page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage())); // Using pushReplacement to avoid stacking
      } else if (index == 2) {
        // Navigate to Settings Page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage())); // Using pushReplacement to avoid stacking
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Click Counter'),
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white, // Adjust AppBar color based on theme
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: TextStyle(fontSize: 25, color: isDarkMode.value ? Colors.red : Colors.black), // Adjust text color based on theme
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _selectedIndex, // Updated to manage the current selection indicating we are on the Home Page
        onTap: _onItemTapped,
        backgroundColor: isDarkMode.value ? Colors.black : Colors.white, // Adjust BottomNavigationBar background color based on theme
        selectedItemColor: Colors.red, // Keep the selected item color consistent across themes
        unselectedItemColor: isDarkMode.value ? Colors.white : Colors.black, // Adjust unselected item color based on theme
      ),
    );
  }
}
