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
  static const String _keyFirstName = 'onboarding_first_name';
  static const String _keyDueDate = 'onboarding_due_date';
  static const String _keyStartDate = 'onboarding_start_date';
  static const String _keyDateOfBirth = 'onboarding_date_of_birth';
  static const String _keyNotificationsEnabled = 'onboarding_notifications_enabled';
  static const String _keyPurchaseCompleted = 'onboarding_purchase_completed';
  static const String _keyCurrentStep = 'onboarding_current_step';

  OnboardingLocalDataSource(this._prefs);

  /// Save onboarding data to SharedPreferences.
  ///
  /// Each field is saved individually to allow partial updates.
  Future<void> saveOnboardingData(OnboardingData data) async {
    if (data.firstName != null) {
      await _prefs.setString(_keyFirstName, data.firstName!);
    }
    if (data.dueDate != null) {
      await _prefs.setString(_keyDueDate, data.dueDate!.toIso8601String());
    }
    if (data.startDate != null) {
      await _prefs.setString(_keyStartDate, data.startDate!.toIso8601String());
    }
    if (data.dateOfBirth != null) {
      await _prefs.setString(_keyDateOfBirth, data.dateOfBirth!.toIso8601String());
    }
    await _prefs.setBool(_keyNotificationsEnabled, data.notificationsEnabled);
    await _prefs.setBool(_keyPurchaseCompleted, data.purchaseCompleted);
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

    return OnboardingData(
      firstName: _prefs.getString(_keyFirstName),
      dueDate: _parseDateTime(_prefs.getString(_keyDueDate)),
      startDate: _parseDateTime(_prefs.getString(_keyStartDate)),
      dateOfBirth: _parseDateTime(_prefs.getString(_keyDateOfBirth)),
      notificationsEnabled: _prefs.getBool(_keyNotificationsEnabled) ?? false,
      purchaseCompleted: _prefs.getBool(_keyPurchaseCompleted) ?? false,
      currentStep: _prefs.getInt(_keyCurrentStep) ?? 0,
    );
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
    await _prefs.remove(_keyFirstName);
    await _prefs.remove(_keyDueDate);
    await _prefs.remove(_keyStartDate);
    await _prefs.remove(_keyDateOfBirth);
    await _prefs.remove(_keyNotificationsEnabled);
    await _prefs.remove(_keyPurchaseCompleted);
    await _prefs.remove(_keyCurrentStep);
  }

  /// Parse ISO8601 date string to DateTime.
  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }
}
