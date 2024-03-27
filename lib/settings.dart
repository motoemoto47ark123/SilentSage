import 'package:flutter/material.dart'; 
import 'main.dart'; 
import 'status.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, 
      builder: (context, isDark, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings Page'), 
            backgroundColor: isDark ? Colors.black : Colors.white, 
          ),
          body: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.brightness_3, size: 48), 
                    onPressed: () => isDarkMode.value = true, 
                    color: isDark ? Colors.yellow : Colors.grey,
                  ),
                  IconButton(
                    icon: Icon(Icons.brightness_7, size: 48), 
                    onPressed: () => isDarkMode.value = false, 
                    color: isDark ? Colors.grey : Colors.yellow,
                  ),
                ],
              ),
              Container(
                height: 2,
                color: isDark ? Colors.white : Colors.black, 
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Adjust your settings below', 
                    style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black), 
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.black : Colors.white, 
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyApp())); 
              } else if (index == 1) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StatusPage())); 
              }
            },
          ),
        );
      },
    );
  }
}
