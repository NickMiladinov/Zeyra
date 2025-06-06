import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // Ensures all items are visible and have labels
      selectedItemColor: Theme.of(context).colorScheme.primary, // Use colorScheme for modern themes
      unselectedItemColor: Colors.grey[700],
      // Visual density can make tap targets larger without increasing icon size too much
      // visualDensity: VisualDensity.comfortable, 
      // Increase icon size slightly for better tapability and modern look
      iconSize: 26.0,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Go to Home', // Accessibility: Tooltip for items
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_copy_outlined), // Using a slightly different icon for outline
          activeIcon: Icon(Icons.folder_copy),
          label: 'Files',
          tooltip: 'Go to My Files', // Accessibility: Tooltip for items
        ),
        // Example for future items:
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.person_outline),
        //   activeIcon: Icon(Icons.person),
        //   label: 'Profile',
        //   tooltip: 'Go to Profile',
        // ),
      ],
    );
  }
} 