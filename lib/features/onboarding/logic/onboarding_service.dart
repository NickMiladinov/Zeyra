import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router/auth_notifier.dart';
import '../../../core/monitoring/logging_service.dart';
import '../../../domain/entities/onboarding/onboarding_data.dart';
import '../../../domain/entities/pregnancy/pregnancy.dart';
import '../../../domain/entities/user_profile/gender.dart';
import '../../../domain/entities/user_profile/user_profile.dart';
import '../../../domain/usecases/pregnancy/create_pregnancy_usecase.dart';
import '../../../domain/usecases/user_profile/create_user_profile_usecase.dart';

/// Callback for triggering background tasks after onboarding completes.
///
/// Used to pre-load data (e.g., maternity units) without blocking the user.
typedef OnOnboardingComplete = Future<void> Function();

/// Service for finalizing onboarding after successful authentication.
///
/// Creates UserProfile and Pregnancy entities and marks onboarding complete.
class OnboardingService {
  final CreateUserProfileUseCase _createUserProfile;
  final CreatePregnancyUseCase _createPregnancy;
  final AuthNotifier _authNotifier;
  final LoggingService _logger;
  final OnOnboardingComplete? _onComplete;

  OnboardingService({
    required CreateUserProfileUseCase createUserProfile,
    required CreatePregnancyUseCase createPregnancy,
    required AuthNotifier authNotifier,
    required LoggingService logger,
    OnOnboardingComplete? onComplete,
  }) : _createUserProfile = createUserProfile,
       _createPregnancy = createPregnancy,
       _authNotifier = authNotifier,
       _logger = logger,
       _onComplete = onComplete;

  /// Finalize onboarding by creating user entities and marking complete.
  ///
  /// This should be called after:
  /// 1. User has completed all onboarding screens
  /// 2. User has completed OAuth authentication
  ///
  /// Returns true if finalization was successful.
  Future<bool> finalizeOnboarding(OnboardingData _) async {
    try {
      _logger.info('Starting onboarding finalization');

      // Get the authenticated user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _logger.error('Cannot finalize onboarding: No authenticated user');
        return false;
      }

      // 1. Create UserProfile
      final userProfile = await _createUserProfileEntity(user);
      _logger.info('Created user profile: ${userProfile.id}');

      // 2. Create Pregnancy
      final pregnancy = await _createPregnancyEntity(userProfile.id);
      _logger.info('Created pregnancy: ${pregnancy.id}');

      // 3. Mark onboarding as complete in Supabase metadata
      await _authNotifier.completeOnboarding();
      _logger.info('Onboarding marked as complete');

      // 4. Mark this device as onboarded (persists after logout)
      await _authNotifier.markDeviceOnboarded();
      _logger.info('Device marked as onboarded');

      // 5. Fire-and-forget: Trigger background data pre-loading
      // This runs async while the user transitions to the home screen,
      // so data is ready when they need it (e.g., Hospital Chooser).
      _triggerBackgroundTasks();

      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to finalize onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Trigger background tasks after successful onboarding.
  ///
  /// Runs async without blocking the user flow. Errors are logged
  /// but don't affect the user experience - data can be loaded later.
  void _triggerBackgroundTasks() {
    final onComplete = _onComplete;
    if (onComplete == null) return;

    // Fire and forget - don't await, don't block user
    Future(() async {
      try {
        _logger.info('Starting background data pre-loading');
        await onComplete();
        _logger.info('Background data pre-loading completed');
      } catch (e, stackTrace) {
        // Log but don't rethrow - this is non-critical background work
        _logger.warning(
          'Background data pre-loading failed (will retry later)',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Create UserProfile entity with safe defaults.
  Future<UserProfile> _createUserProfileEntity(User authUser) async {
    final fallbackBirthDate = DateTime.utc(1995, 1, 1);
    final firstName = _extractFirstName(authUser);

    // Use case generates ID and handles database path naming
    return await _createUserProfile.execute(
      authId: authUser.id,
      email: authUser.email ?? 'unknown@zeyra.app',
      firstName: firstName,
      lastName: '', // Not collected in onboarding, can be updated later
      dateOfBirth: fallbackBirthDate,
      gender: Gender
          .preferNotToSay, // Not collected in onboarding, can be updated later
      schemaVersion: 1,
    );
  }

  /// Create Pregnancy entity with a neutral baseline timeline.
  Future<Pregnancy> _createPregnancyEntity(String userId) async {
    final startDate = DateTime.now().toUtc();
    final dueDate = startDate.add(const Duration(days: 280));

    // Use case generates ID and handles validation
    return await _createPregnancy.execute(
      userId: userId,
      startDate: startDate,
      dueDate: dueDate,
    );
  }

  String _extractFirstName(User authUser) {
    final metadata = authUser.userMetadata ?? const {};

    final givenName = metadata['given_name'];
    if (givenName is String && givenName.trim().isNotEmpty) {
      return givenName.trim();
    }

    final fullName = metadata['full_name'] ?? metadata['name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim().split(' ').first;
    }

    final email = authUser.email;
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    return 'Mum';
  }
}
