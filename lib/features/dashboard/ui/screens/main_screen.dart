import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/features/dashboard/ui/screens/home_screen.dart';
import 'package:zeyra/features/tools/ui/screens/tools_screen.dart';
import 'package:zeyra/shared/widgets/app_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const String routeName = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of widgets to display in the body based on the current index
  List<Widget> get _screens => [
    const HomeScreen(), // Today (index 0)
    const _PlaceholderScreen(key: ValueKey('my-health'), title: 'My Health'), // My Health (index 1)
    const _PlaceholderScreen(key: ValueKey('baby'), title: 'Baby'), // Baby (index 2)
    const ToolsScreen(key: ValueKey('tools')), // Tools (index 3)
    const _PlaceholderScreen(key: ValueKey('more'), title: 'More'), // More (index 4)
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using IndexedStack to preserve the state of each screen when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Placeholder screen for tabs that haven't been built yet
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTypography.displayMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Coming Soon',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 