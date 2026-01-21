/// Temporary entity for storing onboarding data before authentication.
///
/// This entity is stored in SharedPreferences during the onboarding flow
/// and persisted to UserProfile and Pregnancy entities after successful
/// authentication.
class OnboardingData {
  /// User's first name
  final String? firstName;

  /// Expected due date (EDD) - calculated if LMP provided
  final DateTime? dueDate;

  /// Last Menstrual Period (LMP) / start date - calculated if dueDate provided
  final DateTime? startDate;

  /// User's date of birth
  final DateTime? dateOfBirth;

  /// Whether notification permission was granted
  final bool notificationsEnabled;

  /// Whether RevenueCat purchase was completed
  final bool purchaseCompleted;

  /// Current onboarding screen index (0-10)
  final int currentStep;

  /// Standard pregnancy duration in days (40 weeks)
  static const int pregnancyDurationDays = 280;

  const OnboardingData({
    this.firstName,
    this.dueDate,
    this.startDate,
    this.dateOfBirth,
    this.notificationsEnabled = false,
    this.purchaseCompleted = false,
    this.currentStep = 0,
  });

  /// Calculate due date from LMP (startDate + 280 days)
  ///
  /// Standard Naegele's rule: EDD = LMP + 280 days
  static DateTime calculateDueDateFromLMP(DateTime lmp) {
    return lmp.add(const Duration(days: pregnancyDurationDays));
  }

  /// Calculate LMP from due date (dueDate - 280 days)
  static DateTime calculateLMPFromDueDate(DateTime dueDate) {
    return dueDate.subtract(const Duration(days: pregnancyDurationDays));
  }

  /// Get current gestational week based on startDate
  ///
  /// Returns 0 if startDate is null or in the future.
  int get gestationalWeek {
    if (startDate == null) return 0;
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return 0;
    return now.difference(startDate!).inDays ~/ 7;
  }

  /// Get gestational days within current week (0-6)
  int get gestationalDaysInWeek {
    if (startDate == null) return 0;
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return 0;
    return now.difference(startDate!).inDays % 7;
  }

  /// Get formatted gestational age (e.g., "24w 3d")
  String get gestationalAgeFormatted {
    return '${gestationalWeek}w ${gestationalDaysInWeek}d';
  }

  /// Check if onboarding has all required data for finalization
  bool get isComplete {
    return firstName != null &&
        firstName!.isNotEmpty &&
        dueDate != null &&
        startDate != null &&
        dateOfBirth != null &&
        purchaseCompleted;
  }

  /// Create a copy with updated fields
  OnboardingData copyWith({
    String? firstName,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? dateOfBirth,
    bool? notificationsEnabled,
    bool? purchaseCompleted,
    int? currentStep,
  }) {
    return OnboardingData(
      firstName: firstName ?? this.firstName,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      purchaseCompleted: purchaseCompleted ?? this.purchaseCompleted,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Create empty onboarding data
  factory OnboardingData.empty() => const OnboardingData();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingData &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          dueDate == other.dueDate &&
          startDate == other.startDate &&
          dateOfBirth == other.dateOfBirth &&
          notificationsEnabled == other.notificationsEnabled &&
          purchaseCompleted == other.purchaseCompleted &&
          currentStep == other.currentStep;

  @override
  int get hashCode =>
      firstName.hashCode ^
      dueDate.hashCode ^
      startDate.hashCode ^
      dateOfBirth.hashCode ^
      notificationsEnabled.hashCode ^
      purchaseCompleted.hashCode ^
      currentStep.hashCode;

  @override
  String toString() =>
      'OnboardingData(firstName: $firstName, gestationalAge: $gestationalAgeFormatted, step: $currentStep)';
}
