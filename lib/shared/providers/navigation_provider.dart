import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that manages the current bottom navigation tab index.
/// 
/// This allows navigation state to be shared across the entire app,
/// enabling deep-linked screens (e.g., kick counter history) to
/// navigate back to the main screen with the correct tab selected.
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Navigation service that handles tab switching and navigation to main screen.
/// 
/// Use this to navigate between tabs from anywhere in the app while
/// preserving the state of each tab through the IndexedStack in MainScreen.
class NavigationService {
  final BuildContext context;
  final WidgetRef ref;

  NavigationService(this.context, this.ref);

  /// Navigate to a specific tab in the main screen.
  /// 
  /// **Default Behavior:** Always pops back to MainScreen when on a detail screen,
  /// even if tapping the current tab. This provides consistent UX where tapping
  /// any tab from a detail screen returns you to the main tab view.
  /// 
  /// Example: From Kick Counter History (under Tools), tapping the Tools tab
  /// will return you to the main Tools screen, not stay on history.
  /// 
  /// [tabIndex] The index of the tab to navigate to (0-4):
  ///   - 0: Today
  ///   - 1: My Health
  ///   - 2: Baby
  ///   - 3: Tools
  ///   - 4: More
  void navigateToTab(int tabIndex) {
    // Update the tab index in the provider
    ref.read(navigationIndexProvider.notifier).state = tabIndex;

    // Always pop back to the main screen if we're on a detail screen
    // This ensures tapping any tab (including current) returns to main tab view
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Check if the current tab is the active tab.
  /// 
  /// Useful for determining if we should pop or just update the tab.
  bool isCurrentTab(int tabIndex) {
    return ref.read(navigationIndexProvider) == tabIndex;
  }
}
