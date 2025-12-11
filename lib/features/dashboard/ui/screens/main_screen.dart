import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/features/baby/ui/screens/pregnancy_data_screen.dart';
import 'package:zeyra/features/dashboard/ui/screens/home_screen.dart';
import 'package:zeyra/features/developer/ui/screens/developer_menu_screen.dart';
import 'package:zeyra/features/tools/ui/screens/tools_screen.dart';
import 'package:zeyra/shared/providers/navigation_provider.dart';
import 'package:zeyra/shared/widgets/app_bottom_nav_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  static const String routeName = '/main';

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {

  // List of widgets to display in the body based on the current index
  List<Widget> get _screens => [
    const HomeScreen(), // Today (index 0)
    const _PlaceholderScreen(key: ValueKey('my-health'), title: 'My Health'), // My Health (index 1)
    const PregnancyDataScreen(key: ValueKey('baby')), // Baby (index 2)
    const ToolsScreen(key: ValueKey('tools')), // Tools (index 3)
    const _PlaceholderScreen(key: ValueKey('more'), title: 'More'), // More (index 4)
  ];

  void _onTabTapped(int index) {
    // Update the navigation provider instead of local state
    ref.read(navigationIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the navigation provider to react to tab changes from anywhere in the app
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      // Using IndexedStack to preserve the state of each screen when switching tabs
      body: IndexedStack(
        index: currentIndex,
        sizing: StackFit.expand,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
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
            
            // Developer menu for "More" tab in debug builds only
            if (title == 'More' && kDebugMode) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DeveloperMenuScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.developer_mode),
                label: const Text('Developer Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 