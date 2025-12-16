import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/auth/ui/auth_screen.dart';
import 'package:zeyra/features/dashboard/ui/screens/main_screen.dart';
import 'package:zeyra/main.dart' show logger;

/// A non-widget class to handle app-wide authentication state changes.
///
/// This listener is initialized once during app startup to ensure it's active
/// throughout the app's lifecycle and can reliably handle navigation events
/// like sign-in and sign-out.
/// 
/// **Initialization:** This service is initialized in `DIGraph.initialize()` during app startup.
class AppAuthListener {
  final GlobalKey<NavigatorState> navigatorKey;
  
  /// Tracks whether the user was previously authenticated.
  /// Used to differentiate between initial sign-in and token refresh events.
  bool _wasAuthenticated = false;

  AppAuthListener({required this.navigatorKey});

  /// Starts listening to the Supabase auth state stream.
  /// 
  /// Handles auth state changes and token refresh errors gracefully.
  /// Token refresh failures (e.g., 500 errors from server) are logged but
  /// don't crash the app, as Supabase will retry automatically.
  /// 
  /// **Important:** Only navigates on actual state transitions (signed-out → signed-in
  /// or signed-in → signed-out), NOT on token refreshes which also fire signedIn events.
  void init() {
    // Check initial auth state
    _wasAuthenticated = Supabase.instance.client.auth.currentSession != null;
    
    // Listen to auth state changes with error handling
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        final bool isNowAuthenticated = data.session != null;

        // Navigate on sign-in ONLY if transitioning from signed-out to signed-in
        // This prevents recreating MainScreen on token refreshes
        if (event == AuthChangeEvent.signedIn && !_wasAuthenticated) {
          logger.info('Auth state changed: signed in (was signed out)');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
        // Navigate on sign-out. This is the crucial part for the logout button.
        else if (event == AuthChangeEvent.signedOut) {
          logger.info('Auth state changed: signed out');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
          );
        }
        // Log token refresh events for debugging
        else if (event == AuthChangeEvent.tokenRefreshed) {
          logger.debug('Auth token refreshed successfully');
        }
        // Log other signedIn events (likely token refresh related)
        else if (event == AuthChangeEvent.signedIn && _wasAuthenticated) {
          logger.debug('Auth signedIn event (already authenticated, likely token refresh)');
        }
        
        // Update tracked state
        _wasAuthenticated = isNowAuthenticated;
      },
      // Handle token refresh errors gracefully
      onError: (error, stackTrace) {
        // Check if this is a retryable fetch error (e.g., 500 server errors)
        if (error is AuthException) {
          // Log as warning since token refresh is automatic and will retry
          logger.warning(
            'Auth token refresh failed (will retry automatically)',
            error: error,
            data: {
              'error_type': error.runtimeType.toString(),
              'message': error.message,
              'status_code': error.statusCode,
            },
          );
          
          // If it's a permanent auth failure (401, 403), sign out the user
          if (error.statusCode != null && 
              (error.statusCode == '401' || error.statusCode == '403')) {
            logger.error(
              'Auth token permanently invalid, signing out user',
              error: error,
              stackTrace: stackTrace,
            );
            
            // Sign out the user (this will trigger the signedOut event above)
            Supabase.instance.client.auth.signOut().catchError((e) {
              logger.error('Failed to sign out after auth failure', error: e);
            });
          }
        } else {
          // Unknown error type, log as error but don't crash
          logger.error(
            'Unexpected auth state change error',
            error: error,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }
}
