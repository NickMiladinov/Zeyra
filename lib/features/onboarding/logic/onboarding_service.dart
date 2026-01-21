import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router/auth_notifier.dart';
import '../../../core/monitoring/logging_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../domain/entities/onboarding/onboarding_data.dart';
import '../../../domain/entities/pregnancy/pregnancy.dart';
import '../../../domain/entities/user_profile/gender.dart';
import '../../../domain/entities/user_profile/user_profile.dart';
import '../../../domain/usecases/pregnancy/create_pregnancy_usecase.dart';
import '../../../domain/usecases/user_profile/create_user_profile_usecase.dart';

/// Service for finalizing onboarding after successful authentication.
///
/// Creates UserProfile and Pregnancy entities from onboarding data,
/// links RevenueCat customer to auth user, and marks onboarding as complete.
class OnboardingService {
  final CreateUserProfileUseCase _createUserProfile;
  final CreatePregnancyUseCase _createPregnancy;
  final PaymentService _paymentService;
  final AuthNotifier _authNotifier;
  final LoggingService _logger;

  OnboardingService({
    required CreateUserProfileUseCase createUserProfile,
    required CreatePregnancyUseCase createPregnancy,
    required PaymentService paymentService,
    required AuthNotifier authNotifier,
    required LoggingService logger,
  })  : _createUserProfile = createUserProfile,
        _createPregnancy = createPregnancy,
        _paymentService = paymentService,
        _authNotifier = authNotifier,
        _logger = logger;

  /// Finalize onboarding by creating user entities and marking complete.
  ///
  /// This should be called after:
  /// 1. User has completed all onboarding screens
  /// 2. User has completed OAuth authentication
  /// 3. User has active premium subscription
  ///
  /// Returns true if finalization was successful.
  Future<bool> finalizeOnboarding(OnboardingData data) async {
    try {
      _logger.info('Starting onboarding finalization');

      // Get the authenticated user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _logger.error('Cannot finalize onboarding: No authenticated user');
        return false;
      }

      // Validate required data
      if (!_validateData(data)) {
        _logger.error('Cannot finalize onboarding: Missing required data');
        return false;
      }

      // 1. Link RevenueCat customer to auth user
      await _linkPaymentAccount(user.id);

      // 2. Create UserProfile
      final userProfile = await _createUserProfileEntity(user, data);
      _logger.info('Created user profile: ${userProfile.id}');

      // 3. Create Pregnancy
      final pregnancy = await _createPregnancyEntity(userProfile.id, data);
      _logger.info('Created pregnancy: ${pregnancy.id}');

      // 4. Mark onboarding as complete in Supabase metadata
      await _authNotifier.completeOnboarding();
      _logger.info('Onboarding marked as complete');

      // 5. Mark this device as onboarded (persists after logout)
      await _authNotifier.markDeviceOnboarded();
      _logger.info('Device marked as onboarded');

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

  /// Validate that all required data is present.
  bool _validateData(OnboardingData data) {
    if (data.firstName == null || data.firstName!.isEmpty) {
      _logger.warning('Onboarding validation failed: Missing firstName');
      return false;
    }
    if (data.dueDate == null) {
      _logger.warning('Onboarding validation failed: Missing dueDate');
      return false;
    }
    if (data.startDate == null) {
      _logger.warning('Onboarding validation failed: Missing startDate');
      return false;
    }
    if (data.dateOfBirth == null) {
      _logger.warning('Onboarding validation failed: Missing dateOfBirth');
      return false;
    }
    if (!data.purchaseCompleted) {
      _logger.warning('Onboarding validation failed: Purchase not completed');
      return false;
    }
    return true;
  }

  /// Link RevenueCat customer to the authenticated user.
  Future<void> _linkPaymentAccount(String authId) async {
    try {
      await _paymentService.linkToAuthUser(authId);
      _logger.debug('Linked RevenueCat customer to auth user');
    } catch (e) {
      _logger.warning('Failed to link RevenueCat customer: $e');
      // Don't fail finalization for this - purchase is already complete
    }
  }

  /// Create UserProfile entity from onboarding data.
  Future<UserProfile> _createUserProfileEntity(
    User authUser,
    OnboardingData data,
  ) async {
    // Use case generates ID and handles database path naming
    return await _createUserProfile.execute(
      authId: authUser.id,
      email: authUser.email ?? '',
      firstName: data.firstName!,
      lastName: '', // Not collected in onboarding, can be updated later
      dateOfBirth: data.dateOfBirth!,
      gender: Gender.preferNotToSay, // Not collected in onboarding, can be updated later
      schemaVersion: 1,
    );
  }

  /// Create Pregnancy entity from onboarding data.
  Future<Pregnancy> _createPregnancyEntity(
    String userId,
    OnboardingData data,
  ) async {
    // Use case generates ID and handles validation
    return await _createPregnancy.execute(
      userId: userId,
      startDate: data.startDate!,
      dueDate: data.dueDate!,
    );
  }
}
