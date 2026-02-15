import 'package:flutter_riverpod/legacy.dart' show StateNotifier;

import '../../../core/monitoring/logging_service.dart';
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
/// - Persisting progress to SharedPreferences
/// - Finalizing onboarding after authentication
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingLocalDataSource _localDataSource;
  final LoggingService _logger;
  final OnStepChanged? _onStepChanged;

  OnboardingNotifier({
    required OnboardingLocalDataSource localDataSource,
    required LoggingService logger,
    OnStepChanged? onStepChanged,
  }) : _localDataSource = localDataSource,
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
        _logger.info(
          'Loaded saved onboarding progress at step ${savedData.currentStep}',
        );
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
