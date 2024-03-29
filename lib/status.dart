import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'main.dart';
import 'settings.dart';
import 'app_state.dart';
import 'actions.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Status Page'),
            backgroundColor: vm.isDarkMode ? Colors.black : Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Uptime 99%',
                  style: TextStyle(fontSize: 25, color: Colors.red),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.99,
                  backgroundColor: vm.isDarkMode ? Colors.grey : Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ],
            ),
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
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
              } else if (index == 2) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
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