import 'package:flutter/material.dart'; 
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'main.dart'; 
import 'status.dart'; 
import 'app_state.dart';
import 'actions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings Page'), 
            backgroundColor: vm.isDarkMode ? Colors.black : Colors.white, 
          ),
          body: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.brightness_3, size: 48), 
                    onPressed: () => StoreProvider.of<AppState>(context).dispatch(UpdateThemeAction(true)), 
                    color: vm.isDarkMode ? Colors.yellow : Colors.grey,
                  ),
                  IconButton(
                    icon: Icon(Icons.brightness_7, size: 48), 
                    onPressed: () => StoreProvider.of<AppState>(context).dispatch(UpdateThemeAction(false)), 
                    color: vm.isDarkMode ? Colors.grey : Colors.yellow,
                  ),
                ],
              ),
              Container(
                height: 2,
                color: vm.isDarkMode ? Colors.white : Colors.black, 
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Adjust your settings below', 
                    style: TextStyle(
                        fontSize: 20,
                        color: vm.isDarkMode ? Colors.white : Colors.black), 
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: vm.isDarkMode ? Colors.black : Colors.white, 
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

class _ViewModel {
  final bool isDarkMode;

  _ViewModel({
    required this.isDarkMode,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isDarkMode: store.state.isDarkMode,
    );
  }
}
