import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/auth/ui/auth_screen.dart';
import 'package:zeyra/features/dashboard/ui/screens/main_screen.dart';

/// A non-widget class to handle app-wide authentication state changes.
///
/// This listener is initialized once in `main.dart` to ensure it's active
/// throughout the app's lifecycle and can reliably handle navigation events
/// like sign-in and sign-out.
class AppAuthListener {
  final GlobalKey<NavigatorState> navigatorKey;

  AppAuthListener({required this.navigatorKey});

  /// Starts listening to the Supabase auth state stream.
  void init() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // Navigate on sign-in, useful for deep links or token refreshes from a signed-out state.
      if (event == AuthChangeEvent.signedIn) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
      // Navigate on sign-out. This is the crucial part for the logout button.
      else if (event == AuthChangeEvent.signedOut) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    });
  }
} 