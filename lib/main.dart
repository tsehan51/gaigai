import 'package:flutter/material.dart';
import 'package:gaigai/pages/home_screen.dart';
import 'package:gaigai/pages/safety_mode_screen.dart';
import 'package:gaigai/pages/emergency_screen.dart';
import 'package:gaigai/pages/saved_screen.dart';
import 'package:gaigai/pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'OpenSans',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int? _selectedIndex;

  final List<Widget> _screens = [
    const SafetyModeScreen(),
    const EmergencyScreen(),
    SavedScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: _selectedIndex == null,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _selectedIndex != null) {
        setState(() {
          _selectedIndex = null;
        });
      }
    },
    child: Scaffold(
      body: _selectedIndex == null ? const HomeScreen() : _screens[_selectedIndex!],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xffffffff),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Safety Mode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex ?? 0,
        selectedItemColor: _selectedIndex == null ? Colors.grey : Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    ),
  );
  }
} 