import 'package:flutter/material.dart'; // This line imports the Material Design package from Flutter, providing access to a wide range of pre-designed UI components.
import 'main.dart'; // This import statement makes the main application widget accessible in this file, allowing for navigation and widget interaction.
import 'status.dart'; // By importing 'status.dart', we gain the ability to navigate to the StatusPage widget, enhancing the app's navigational capabilities.

// The SettingsPage widget is defined here as a stateless widget, meaning its properties can't change over time. It's responsible for displaying the settings page of the app.
class SettingsPage extends StatelessWidget {
  // The constructor for SettingsPage, which optionally accepts a key used to control the framework's widget replacement and retrieval process.
  const SettingsPage({super.key});

  // This method builds the UI of the settings page. It overrides the StatelessWidget's build method to define custom UI elements and layout for this page.
  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder is used here to listen for changes to isDarkMode. When isDarkMode changes, it triggers a rebuild of the widget tree within its builder, ensuring the UI reflects the current theme mode.
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // This specifies the ValueListenable to listen to, in this case, the isDarkMode boolean.
      builder: (context, isDark, _) {
        // The builder method returns a Scaffold widget, providing the basic visual layout structure of the settings page, including an AppBar and a Body.
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings Page'), // Sets the text displayed in the AppBar at the top of the settings page.
            backgroundColor: isDark
                ? Colors.black
                : Colors.white, // Dynamically changes the AppBar's background color based on the current theme mode (dark or light).
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Toggle Dark Mode', // This Text widget displays instructions for the switch below it, guiding users on its purpose.
                  style: TextStyle(
                      fontSize: 25,
                      color: isDark
                          ? Colors.red
                          : Colors.red), // Defines the style of the text, including its size and color. Note: The color does not change dynamically here.
                ),
                Switch(
                  value: isDark, // The current position of the switch is determined by the isDark variable, reflecting the current theme mode.
                  onChanged: (value) {
                    isDarkMode.value = value; // This updates the isDarkMode ValueNotifier, effectively toggling the theme mode when the switch is flipped.
                  },
                  activeTrackColor: Colors.black.withOpacity(
                      0.5), // Specifies the color of the switch's track when it is in the "on" position, with a slight transparency.
                  activeColor: Colors
                      .black, // Sets the color of the thumb (the part of the switch that moves) when the switch is "on".
                  materialTapTargetSize: MaterialTapTargetSize
                      .padded, // Increases the tap target size to make the switch more accessible.
                  thumbColor: isDark
                      ? MaterialStateProperty.all(Colors.white)
                      : MaterialStateProperty.all(
                          Colors.black), // Dynamically changes the thumb color based on the current theme mode.
                  trackColor: MaterialStateProperty.all(
                      Colors.redAccent), // Sets the track color of the switch for better visibility, regardless of the theme mode.
                  splashRadius:
                      28, // Defines the radius of the ripple effect produced when the switch is toggled, enhancing the visual feedback.
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark
                ? Colors.black
                : Colors.white, // Dynamically changes the background color of the BottomNavigationBar based on the current theme mode.
            selectedItemColor: Colors.red, // Sets the color of the selected navigation item, making it stand out.
            unselectedItemColor: Colors.grey, // Defines the color of unselected navigation items for visual distinction.
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat', // Label for the chat navigation item, guiding users to the chat feature.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Status', // Label for the status navigation item, guiding users to the status feature.
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label:
                    'Settings', // Indicates the current page as the settings page through the label of this navigation item.
              ),
            ],
            currentIndex: 2, // Sets the currently selected item in the BottomNavigationBar to the settings page, providing visual feedback to the user.
            onTap: (index) {
              // This function handles navigation when a BottomNavigationBarItem is tapped, using the index of the tapped item to determine the destination.
              if (index == 0) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MyApp())); // Navigates to the chat page when the first item is tapped.
              } else if (index == 1) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StatusPage())); // Navigates to the status page when the second item is tapped.
              }
            },
          ),
        );
      },
    );
  }
}
