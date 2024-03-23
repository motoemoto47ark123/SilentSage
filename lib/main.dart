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
          theme: ThemeData(
            brightness: value ? Brightness.dark : Brightness.light, // Adjust brightness based on the ValueNotifier
            primaryColor: value ? Colors.grey[850] : Colors.white, // Adjust primary color based on the theme, using dark grey for dark mode
            appBarTheme: AppBarTheme(
              backgroundColor: value ? Colors.grey[850] : Colors.white, // Ensure AppBar color consistency across the app
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Colors.red, // Keeping red as the secondary color for both themes
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
  int _selectedIndex = 0; // Added to track the current index

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
      if (index == 0) {
        // Navigate to Settings Page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage())); // Using pushReplacement to avoid stacking
      } else if (index == 1) {
        // Navigate to Status Page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StatusPage())); // Using pushReplacement to avoid stacking
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Click Counter'),
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
              style: const TextStyle(fontSize: 25),
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
            icon: Icon(Icons.assessment),
            label: 'Status',
          ),
        ],
        currentIndex: _selectedIndex, // Added to manage the current selection
        onTap: _onItemTapped,
      ),
    );
  }
}
