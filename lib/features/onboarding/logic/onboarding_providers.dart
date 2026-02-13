import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/router/auth_notifier.dart';
import '../../../core/di/main_providers.dart';
import '../../../data/local/datasources/onboarding_local_datasource.dart';
import 'onboarding_notifier.dart';
import 'onboarding_service.dart';
import 'onboarding_state.dart';

// ----------------------------------------------------------------------------
// Onboarding Data Sources
// ----------------------------------------------------------------------------

/// Provider for SharedPreferences instance.
///
/// This is a FutureProvider because SharedPreferences.getInstance() is async.
/// Initialized during app startup and cached.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for the onboarding local data source.
///
/// Handles persistence of onboarding progress before authentication.
final onboardingLocalDataSourceProvider = FutureProvider<OnboardingLocalDataSource>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return OnboardingLocalDataSource(prefs);
});

// ----------------------------------------------------------------------------
// Onboarding State Management
// ----------------------------------------------------------------------------

/// Provider for the onboarding notifier.
///
/// Manages the entire onboarding flow state and business logic.
/// Use `ref.watch(onboardingNotifierProvider)` to access current state.
/// Use `ref.read(onboardingNotifierProvider.notifier)` to call methods.
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  // These providers need async initialization, so we handle the async case
  // by using AsyncValue's pattern. For now, we'll create a synchronous version
  // that initializes on first use.
  throw UnimplementedError(
    'Use onboardingNotifierProviderAsync instead, or ensure dependencies are pre-loaded',
  );
});

/// Async provider for the onboarding notifier.
///
/// Use this when you need to properly await all dependencies.
final onboardingNotifierProviderAsync =
    FutureProvider<OnboardingNotifier>((ref) async {
  final localDataSource = await ref.watch(onboardingLocalDataSourceProvider.future);
  final paymentService = ref.watch(paymentServiceProvider);
  final notificationService = ref.watch(notificationPermissionServiceProvider);
  final logger = ref.watch(loggingServiceProvider);
  final authNotifier = ref.watch(authNotifierProvider);

  return OnboardingNotifier(
    localDataSource: localDataSource,
    paymentService: paymentService,
    notificationService: notificationService,
    logger: logger,
    // Sync step changes with AuthNotifier for router redirects
    onStepChanged: (step) => authNotifier.updateSavedOnboardingStep(step),
  );
});

/// Provider for whether there is pending onboarding data.
///
/// Use this to check if user was in the middle of onboarding.
final hasPendingOnboardingProvider = FutureProvider<bool>((ref) async {
  final localDataSource = await ref.watch(onboardingLocalDataSourceProvider.future);
  return localDataSource.hasPendingOnboardingData();
});

/// Provider for the saved onboarding step.
///
/// Returns the step the user was on when they left onboarding.
final savedOnboardingStepProvider = FutureProvider<int>((ref) async {
  final localDataSource = await ref.watch(onboardingLocalDataSourceProvider.future);
  return localDataSource.getCurrentStep();
});

// ----------------------------------------------------------------------------
// Onboarding Service (Finalization)
// ----------------------------------------------------------------------------

/// Provider for the onboarding service.
///
/// Handles finalization of onboarding after authentication:
/// - Creates UserProfile entity
/// - Creates Pregnancy entity
/// - Links RevenueCat customer
/// - Marks onboarding as complete
///
/// Note: Background data pre-loading (maternity units) is handled by HomeScreen
/// on mount to avoid Riverpod ref lifecycle issues with async callbacks.
final onboardingServiceProvider = FutureProvider<OnboardingService>((ref) async {
  final createUserProfile = await ref.watch(createUserProfileUseCaseProvider.future);
  final createPregnancy = await ref.watch(createPregnancyUseCaseProvider.future);
  final paymentService = ref.watch(paymentServiceProvider);
  final authNotifier = ref.watch(authNotifierProvider);
  final logger = ref.watch(loggingServiceProvider);

  return OnboardingService(
    createUserProfile: createUserProfile,
    createPregnancy: createPregnancy,
    paymentService: paymentService,
    authNotifier: authNotifier,
    logger: logger,
    // No onComplete callback - HomeScreen handles data sync on mount
    // to avoid Riverpod ref lifecycle issues with async callbacks.
  );
});
