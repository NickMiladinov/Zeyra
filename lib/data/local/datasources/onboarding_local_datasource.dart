import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/onboarding/onboarding_data.dart';

/// Local data source for persisting onboarding data before authentication.
///
/// Uses SharedPreferences to store onboarding progress so it survives
/// app restarts. After successful authentication, this data is migrated
/// to UserProfile and Pregnancy entities, then cleared.
class OnboardingLocalDataSource {
  final SharedPreferences _prefs;

  // SharedPreferences keys
  static const String _keyCurrentStep = 'onboarding_current_step';

  OnboardingLocalDataSource(this._prefs);

  /// Save onboarding data to SharedPreferences.
  ///
  /// Minimal onboarding only persists the user's current step.
  Future<void> saveOnboardingData(OnboardingData data) async {
    await _prefs.setInt(_keyCurrentStep, data.currentStep);
  }

  /// Retrieve onboarding data from SharedPreferences.
  ///
  /// Returns null if no onboarding data exists.
  OnboardingData? getOnboardingData() {
    // Check if any onboarding data exists
    if (!_prefs.containsKey(_keyCurrentStep)) {
      return null;
    }

    return OnboardingData(currentStep: _prefs.getInt(_keyCurrentStep) ?? 0);
  }

  /// Check if there is pending onboarding data.
  bool hasPendingOnboardingData() {
    return _prefs.containsKey(_keyCurrentStep);
  }

  /// Get the current onboarding step.
  ///
  /// Returns 0 if no onboarding data exists.
  int getCurrentStep() {
    return _prefs.getInt(_keyCurrentStep) ?? 0;
  }

  /// Update just the current step.
  Future<void> updateCurrentStep(int step) async {
    await _prefs.setInt(_keyCurrentStep, step);
  }

  /// Clear all onboarding data from SharedPreferences.
  ///
  /// Called after successful onboarding finalization or when
  /// a new account is created via "I already have an account" flow.
  Future<void> clearOnboardingData() async {
    await _prefs.remove(_keyCurrentStep);
  }
}
