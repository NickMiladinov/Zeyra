import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/di_graph.dart';
import '../../main.dart' show logger;

/// Notifies listeners when authentication state changes.
///
/// This is used by go_router's `refreshListenable` to trigger route
/// re-evaluation when the user logs in or out. Replaces the old
/// [AppAuthListener] that used imperative navigation.
///
/// Also tracks onboarding completion state for future use.
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  bool _wasAuthenticated = false;

  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() {
    _initialize();
  }

  void _initialize() {
    // Check if Supabase is available before accessing auth
    if (!DIGraph.isSupabaseAvailable) {
      logger.warning('AuthNotifier: Supabase not available');
      _isAuthenticated = false;
      return;
    }

    // Check initial state
    try {
      final session = Supabase.instance.client.auth.currentSession;
      _isAuthenticated = session != null;
      _wasAuthenticated = _isAuthenticated;
      logger.info('AuthNotifier: Initial auth state - authenticated: $_isAuthenticated');
    } catch (e) {
      logger.error('AuthNotifier: Error checking initial auth state', error: e);
      _isAuthenticated = false;
    }

    // Listen to Supabase auth state changes
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        final bool isNowAuthenticated = data.session != null;

        // Only navigate on actual state transitions, not token refreshes
        if (event == AuthChangeEvent.signedIn && !_wasAuthenticated) {
          logger.info('AuthNotifier: User signed in');
          _isAuthenticated = true;
          notifyListeners();
        } else if (event == AuthChangeEvent.signedOut) {
          logger.info('AuthNotifier: User signed out');
          _isAuthenticated = false;
          notifyListeners();
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          logger.debug('AuthNotifier: Token refreshed');
          // Don't notify on token refresh - no navigation needed
        }

        _wasAuthenticated = isNowAuthenticated;
      },
      onError: (error, stackTrace) {
        if (error is AuthException) {
          logger.warning(
            'AuthNotifier: Auth error (will retry automatically)',
            error: error,
          );

          // Sign out on permanent auth failures
          if (error.statusCode == '401' || error.statusCode == '403') {
            logger.error('AuthNotifier: Permanent auth failure, signing out');
            _isAuthenticated = false;
            notifyListeners();

            Supabase.instance.client.auth.signOut().catchError((e) {
              logger.error('AuthNotifier: Failed to sign out after auth failure', error: e);
            });
          }
        } else {
          logger.error('AuthNotifier: Unexpected error', error: error, stackTrace: stackTrace);
        }
      },
    );
  }

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _isAuthenticated;

  /// Whether the user has completed onboarding.
  ///
  /// TODO: Implement onboarding completion check.
  /// This should be loaded from user preferences or Supabase user metadata.
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Mark onboarding as completed.
  ///
  /// TODO: Persist this to user preferences or Supabase user metadata.
  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for the [AuthNotifier].
///
/// This provider should be kept alive for the lifetime of the app to ensure
/// auth state changes are always detected.
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});
