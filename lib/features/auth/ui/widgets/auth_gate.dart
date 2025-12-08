import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/core/di/di_graph.dart';
import 'package:zeyra/features/auth/ui/auth_screen.dart';
import 'package:zeyra/features/dashboard/ui/screens/main_screen.dart';
import 'package:zeyra/main.dart' show logger;

/// A widget that checks the initial authentication state when the app starts.
/// 
/// This widget handles three scenarios:
/// 1. Supabase initialized + user has valid session → Navigate to MainScreen
/// 2. Supabase initialized + no session → Show AuthScreen
/// 3. Supabase failed to initialize → Show AuthScreen with error message
/// 
/// All subsequent dynamic navigation is handled by the global AppAuthListener.
/// TODO: Handle no network case.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if Supabase is available before trying to access session
    if (!DIGraph.isSupabaseAvailable) {
      logger.warning('AuthGate: Supabase not available, showing login screen');
      // Show auth screen but user won't be able to login until network is restored
      return const AuthScreen();
    }

    // Supabase is available, check if user has a valid session
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        logger.info('AuthGate: Valid session found, navigating to MainScreen');
        return const MainScreen();
      } else {
        logger.info('AuthGate: No session found, showing AuthScreen');
        return const AuthScreen();
      }
    } catch (e, stackTrace) {
      // If there's any error checking session, default to auth screen
      logger.error(
        'AuthGate: Error checking auth session',
        error: e,
        stackTrace: stackTrace,
      );
      return const AuthScreen();
    }
  }
} 