import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/monitoring/logging_service.dart';
import '../../../core/services/notification_permission_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../data/local/datasources/onboarding_local_datasource.dart';
import '../../../domain/entities/onboarding/onboarding_data.dart';
import 'onboarding_state.dart';

/// Callback type for step change notifications.
///
/// Used to notify the router when the user navigates to a different step.
typedef OnStepChanged = void Function(int step);

/// Manages onboarding flow state and business logic.
///
/// Handles:
/// - Collecting user data (name, dates, preferences)
/// - Bidirectional due date / LMP calculation
/// - Persisting progress to SharedPreferences
/// - Processing payments via RevenueCat
/// - Finalizing onboarding after authentication
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingLocalDataSource _localDataSource;
  final PaymentService _paymentService;
  final NotificationPermissionService _notificationService;
  final LoggingService _logger;
  final OnStepChanged? _onStepChanged;

  OnboardingNotifier({
    required OnboardingLocalDataSource localDataSource,
    required PaymentService paymentService,
    required NotificationPermissionService notificationService,
    required LoggingService logger,
    OnStepChanged? onStepChanged,
  })  : _localDataSource = localDataSource,
        _paymentService = paymentService,
        _notificationService = notificationService,
        _logger = logger,
        _onStepChanged = onStepChanged,
        super(OnboardingState.initial()) {
    _loadSavedProgress();
  }

  /// Load any saved onboarding progress from local storage.
  void _loadSavedProgress() {
    try {
      final savedData = _localDataSource.getOnboardingData();
      if (savedData != null) {
        state = state.copyWith(data: savedData, clearError: true);
        _logger.info('Loaded saved onboarding progress at step ${savedData.currentStep}');
        // Sync with AuthNotifier for router
        _onStepChanged?.call(savedData.currentStep);
      }
    } catch (e) {
      _logger.warning('Failed to load saved onboarding progress', error: e);
    }
  }

  /// Save current progress to local storage.
  Future<void> _saveProgress() async {
    try {
      await _localDataSource.saveOnboardingData(state.data);
      // Notify listener of step change for router sync
      _onStepChanged?.call(state.currentStep);
    } catch (e) {
      _logger.warning('Failed to save onboarding progress', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Step Navigation
  // ---------------------------------------------------------------------------

  /// Move to the next step.
  Future<void> nextStep() async {
    if (state.currentStep >= OnboardingState.totalSteps - 1) return;

    final newData = state.data.copyWith(currentStep: state.currentStep + 1);
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug('Onboarding moved to step ${state.currentStep}');
  }

  /// Move to the previous step.
  Future<void> previousStep() async {
    if (state.currentStep <= 0) return;

    final newData = state.data.copyWith(currentStep: state.currentStep - 1);
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug('Onboarding moved back to step ${state.currentStep}');
  }

  /// Go to a specific step.
  Future<void> goToStep(int step) async {
    if (step < 0 || step >= OnboardingState.totalSteps) return;

    final newData = state.data.copyWith(currentStep: step);
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug('Onboarding jumped to step $step');
  }

  // ---------------------------------------------------------------------------
  // Data Updates
  // ---------------------------------------------------------------------------

  /// Update user's first name.
  Future<void> updateName(String name) async {
    final newData = state.data.copyWith(firstName: name.trim());
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug('Onboarding name updated');
  }

  /// Update due date and auto-calculate startDate (LMP).
  ///
  /// Uses standard 280-day pregnancy duration.
  Future<void> updateDueDate(DateTime dueDate) async {
    final startDate = OnboardingData.calculateLMPFromDueDate(dueDate);
    final newData = state.data.copyWith(
      dueDate: dueDate,
      startDate: startDate,
    );
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug(
      'Onboarding due date updated: $dueDate, calculated LMP: $startDate',
    );
  }

  /// Update LMP (startDate) and auto-calculate dueDate.
  ///
  /// Uses standard 280-day pregnancy duration.
  Future<void> updateLMP(DateTime lmp) async {
    final dueDate = OnboardingData.calculateDueDateFromLMP(lmp);
    final newData = state.data.copyWith(
      startDate: lmp,
      dueDate: dueDate,
    );
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug(
      'Onboarding LMP updated: $lmp, calculated due date: $dueDate',
    );
  }

  /// Update user's birth date.
  Future<void> updateBirthDate(DateTime birthDate) async {
    final newData = state.data.copyWith(dateOfBirth: birthDate);
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.debug('Onboarding birth date updated');
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  /// Request notification permission.
  ///
  /// Returns true if permission was granted.
  Future<bool> requestNotificationPermission() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final granted = await _notificationService.requestPermission();
      final newData = state.data.copyWith(notificationsEnabled: granted);
      state = state.copyWith(data: newData, isLoading: false);
      await _saveProgress();

      _logger.info('Notification permission ${granted ? 'granted' : 'denied'}');
      return granted;
    } catch (e, stackTrace) {
      _logger.error('Failed to request notification permission', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to request notification permission',
      );
      return false;
    }
  }

  /// Skip notification permission (mark as not enabled but continue).
  Future<void> skipNotificationPermission() async {
    final newData = state.data.copyWith(notificationsEnabled: false);
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.info('Notification permission skipped');
  }

  // ---------------------------------------------------------------------------
  // Payment
  // ---------------------------------------------------------------------------

  /// Mock purchase completion for testing/development.
  ///
  /// TODO: Remove this method when RevenueCat paywall is fully integrated.
  /// This allows testing the full onboarding flow without actual purchases.
  Future<void> mockPurchaseComplete() async {
    final newData = state.data.copyWith(purchaseCompleted: true);
    state = state.copyWith(data: newData, clearError: true);
    await _saveProgress();
    _logger.warning('MOCK: Purchase marked as complete (dev only)');
  }

  /// Get available subscription offerings.
  Future<Offerings?> getOfferings() async {
    try {
      return await _paymentService.getOfferings();
    } catch (e, stackTrace) {
      _logger.error('Failed to get offerings', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: 'Failed to load subscription options');
      return null;
    }
  }

  /// Purchase a subscription package.
  ///
  /// Returns true if purchase was successful.
  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final customerInfo = await _paymentService.purchase(package);
      final isPremium = _paymentService.hasZeyraEntitlementFromInfo(customerInfo);

      if (isPremium) {
        final newData = state.data.copyWith(purchaseCompleted: true);
        state = state.copyWith(data: newData, isLoading: false);
        await _saveProgress();
        _logger.info('Onboarding purchase completed successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Purchase completed but premium not activated',
        );
        return false;
      }
    } on PurchasesErrorCode catch (e) {
      _logger.warning('Purchase cancelled or failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: _getPurchaseErrorMessage(e),
      );
      return false;
    } catch (e, stackTrace) {
      _logger.error('Purchase failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Purchase failed. Please try again.',
      );
      return false;
    }
  }

  /// Restore previous purchases.
  ///
  /// Returns true if premium was restored.
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final customerInfo = await _paymentService.restore();
      final isPremium = _paymentService.hasZeyraEntitlementFromInfo(customerInfo);

      if (isPremium) {
        final newData = state.data.copyWith(purchaseCompleted: true);
        state = state.copyWith(data: newData, isLoading: false);
        await _saveProgress();
        _logger.info('Purchases restored successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No previous purchases found',
        );
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Restore failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to restore purchases. Please try again.',
      );
      return false;
    }
  }

  /// Get user-friendly error message for purchase errors.
  String _getPurchaseErrorMessage(PurchasesErrorCode errorCode) {
    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Purchase was cancelled';
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This product is not available for purchase';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device';
      default:
        return 'Purchase failed. Please try again.';
    }
  }

  // ---------------------------------------------------------------------------
  // Early Auth Flow
  // ---------------------------------------------------------------------------

  /// Clear all onboarding data and reset to initial state.
  ///
  /// Used when a new account is created via "I already have an account" flow.
  Future<void> clearAndRestart() async {
    await _localDataSource.clearOnboardingData();
    state = OnboardingState.initial();
    // Notify that step has been reset
    _onStepChanged?.call(0);
    _logger.info('Onboarding data cleared and reset');
  }

  // ---------------------------------------------------------------------------
  // Finalization
  // ---------------------------------------------------------------------------

  /// Get the current onboarding data.
  ///
  /// Used by the finalization service to create UserProfile and Pregnancy.
  OnboardingData get data => state.data;

  /// Check if all required data is present for finalization.
  bool get canFinalize => state.data.isComplete;

  /// Clear onboarding data after successful finalization.
  ///
  /// Called by the finalization service after creating entities.
  Future<void> clearAfterFinalization() async {
    await _localDataSource.clearOnboardingData();
    // Notify that step has been cleared
    _onStepChanged?.call(0);
    _logger.info('Onboarding data cleared after finalization');
  }
}
