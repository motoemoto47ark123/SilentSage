import 'package:flutter/material.dart';
import 'pages/settings.dart'; // Assuming settings.dart is in the lib/pages directory
import 'pages/status.dart'; // Assuming status.dart is in the lib/pages directory

final ValueNotifier<bool> isDarkMode = ValueNotifier(false); // Added ValueNotifier for theme change

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode, // Listen to the ValueNotifier
      builder: (context, value, child) {
        return MaterialApp(
          title: _title,
          theme: ThemeData(
            brightness: value ? Brightness.dark : Brightness.light, // Adjust brightness based on the ValueNotifier
            primaryColor: value ? Colors.black : Colors.white, // Adjust primary color based on the theme
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
        onTap: (index) {
          // Handle navigation to respective pages when tapping on items
          if (index == 0) {
            // Navigate to Settings Page
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          } else if (index == 1) {
            // Navigate to Status Page
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StatusPage()));
          }
        },
      ),
    );
  }
}
