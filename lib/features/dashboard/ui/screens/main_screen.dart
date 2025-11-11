import 'package:flutter/material.dart';
import 'package:zeyra/features/dashboard/ui/screens/home_screen.dart';
import 'package:zeyra/features/dashboard/ui/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const String routeName = '/main'; // Optional: for named routing if you use it

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of widgets to display in the body based on the current index
  final List<Widget> _screens = [
    const HomeScreen(),
    // Add more screens here if you expand your BottomNavBar
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each screen in _screens is expected to have its own Scaffold and AppBar if needed.
      // Using IndexedStack to preserve the state of each screen when switching tabs.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
} 