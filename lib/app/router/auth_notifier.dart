import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/di_graph.dart';
import '../../main.dart' show logger;

/// Supabase user metadata key for onboarding completion status.
const String _kOnboardingCompletedKey = 'onboarding_completed';

/// SharedPreferences key for saved onboarding step.
const String _kSavedOnboardingStepKey = 'onboarding_current_step';

/// SharedPreferences key for device onboarding completion.
/// This flag persists even after logout to indicate that this device
/// has been onboarded at least once.
const String _kDeviceOnboardedKey = 'device_onboarding_completed';

/// Notifies listeners when authentication state changes.
///
/// This is used by go_router's `refreshListenable` to trigger route
/// re-evaluation when the user logs in or out. Replaces the old
/// [AppAuthListener] that used imperative navigation.
///
/// Also tracks onboarding completion state stored in Supabase user metadata
/// and saved onboarding progress from SharedPreferences for partial completion.
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  bool _wasAuthenticated = false;
  bool _isCheckingOnboarding = false;
  int _savedOnboardingStep = 0;
  bool _onboardingStepLoaded = false;
  bool _deviceOnboarded = false;
  bool _deviceOnboardedLoaded = false;

  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() {
    _initialize();
  }

  void _initialize() {
    // Load saved onboarding step and device onboarded flag from SharedPreferences
    _loadSavedOnboardingStep();
    _loadDeviceOnboardedFlag();

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

      // Load onboarding status if authenticated
      if (_isAuthenticated) {
        _loadOnboardingStatus();
      }
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
          // Load onboarding status for new sign-in
          _loadOnboardingStatus();
          notifyListeners();
        } else if (event == AuthChangeEvent.signedOut) {
          logger.info('AuthNotifier: User signed out');
          _isAuthenticated = false;
          _hasCompletedOnboarding = false;
          notifyListeners();
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          logger.debug('AuthNotifier: Token refreshed');
          // Don't notify on token refresh - no navigation needed
        } else if (event == AuthChangeEvent.userUpdated) {
          // Reload onboarding status when user metadata is updated
          _loadOnboardingStatus();
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
            _hasCompletedOnboarding = false;
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
  /// Loaded from Supabase user metadata on sign-in.
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Whether onboarding status is currently being checked.
  bool get isCheckingOnboarding => _isCheckingOnboarding;

  /// The saved onboarding step from SharedPreferences.
  ///
  /// Returns the step the user was on when they left onboarding.
  /// Returns 0 if no saved step exists.
  int get savedOnboardingStep => _savedOnboardingStep;

  /// Whether the saved onboarding step has been loaded.
  bool get onboardingStepLoaded => _onboardingStepLoaded;

  /// Whether this device has completed onboarding at least once.
  ///
  /// This flag persists even after logout. When true, logged out users
  /// should be directed to the auth screen instead of onboarding.
  bool get deviceOnboarded => _deviceOnboarded;

  /// Whether the device onboarded flag has been loaded.
  bool get deviceOnboardedLoaded => _deviceOnboardedLoaded;

  /// Load saved onboarding step from SharedPreferences.
  ///
  /// This is called asynchronously during initialization.
  Future<void> _loadSavedOnboardingStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedOnboardingStep = prefs.getInt(_kSavedOnboardingStepKey) ?? 0;
      _onboardingStepLoaded = true;
      logger.debug('AuthNotifier: Saved onboarding step loaded - step: $_savedOnboardingStep');
      notifyListeners();
    } catch (e) {
      logger.warning('AuthNotifier: Failed to load saved onboarding step', error: e);
      _savedOnboardingStep = 0;
      _onboardingStepLoaded = true;
    }
  }

  /// Update the saved onboarding step.
  ///
  /// Called by OnboardingNotifier when the user navigates between steps.
  void updateSavedOnboardingStep(int step) {
    if (_savedOnboardingStep != step) {
      _savedOnboardingStep = step;
      logger.debug('AuthNotifier: Saved onboarding step updated - step: $step');
      // Don't notify listeners here - this is just for state tracking
      // The actual navigation is handled by OnboardingNotifier
    }
  }

  /// Clear the saved onboarding step.
  ///
  /// Called after onboarding is completed or when restarting onboarding.
  void clearSavedOnboardingStep() {
    _savedOnboardingStep = 0;
    logger.debug('AuthNotifier: Saved onboarding step cleared');
  }

  /// Load the device onboarded flag from SharedPreferences.
  Future<void> _loadDeviceOnboardedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceOnboarded = prefs.getBool(_kDeviceOnboardedKey) ?? false;
      _deviceOnboardedLoaded = true;
      logger.debug('AuthNotifier: Device onboarded flag loaded - onboarded: $_deviceOnboarded');
      notifyListeners();
    } catch (e) {
      logger.warning('AuthNotifier: Failed to load device onboarded flag', error: e);
      _deviceOnboarded = false;
      _deviceOnboardedLoaded = true;
    }
  }

  /// Mark this device as having completed onboarding.
  ///
  /// This flag persists even after logout. Once set, users who log out
  /// will be directed to the auth screen instead of onboarding.
  Future<void> markDeviceOnboarded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDeviceOnboardedKey, true);
      _deviceOnboarded = true;
      logger.info('AuthNotifier: Device marked as onboarded');
      notifyListeners();
    } catch (e) {
      logger.error('AuthNotifier: Failed to mark device as onboarded', error: e);
    }
  }

  /// Load onboarding completion status from Supabase user metadata.
  void _loadOnboardingStatus() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final metadata = user.userMetadata;
        _hasCompletedOnboarding = metadata?[_kOnboardingCompletedKey] == true;
        logger.debug('AuthNotifier: Onboarding status loaded - completed: $_hasCompletedOnboarding');
      }
    } catch (e) {
      logger.warning('AuthNotifier: Failed to load onboarding status', error: e);
      _hasCompletedOnboarding = false;
    }
  }

  /// Check onboarding status asynchronously and refresh from server.
  ///
  /// Use this when you need the most up-to-date status from the server.
  Future<bool> checkOnboardingStatus() async {
    if (!_isAuthenticated) return false;

    _isCheckingOnboarding = true;
    try {
      // Refresh user data from server
      final response = await Supabase.instance.client.auth.getUser();
      final user = response.user;
      if (user != null) {
        final metadata = user.userMetadata;
        _hasCompletedOnboarding = metadata?[_kOnboardingCompletedKey] == true;
        logger.debug('AuthNotifier: Onboarding status refreshed - completed: $_hasCompletedOnboarding');
        notifyListeners();
      }
      return _hasCompletedOnboarding;
    } catch (e) {
      logger.warning('AuthNotifier: Failed to check onboarding status', error: e);
      return _hasCompletedOnboarding;
    } finally {
      _isCheckingOnboarding = false;
    }
  }

  /// Mark onboarding as completed.
  ///
  /// Persists the completion status to Supabase user metadata.
  Future<void> completeOnboarding() async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {_kOnboardingCompletedKey: true}),
      );
      _hasCompletedOnboarding = true;
      logger.info('AuthNotifier: Onboarding marked as completed');
      notifyListeners();
    } catch (e) {
      logger.error('AuthNotifier: Failed to complete onboarding', error: e);
      rethrow;
    }
  }

  /// Check if a newly authenticated user has completed onboarding.
  ///
  /// Returns true if this is a NEW account (no onboarding metadata).
  /// Used in the "I already have an account" flow to detect new accounts
  /// that were accidentally created.
  bool isNewAccount() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return true;

      final metadata = user.userMetadata;
      // If metadata is null or doesn't have the onboarding key, it's new
      return metadata == null || !metadata.containsKey(_kOnboardingCompletedKey);
    } catch (e) {
      logger.warning('AuthNotifier: Failed to check if new account', error: e);
      return true;
    }
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
