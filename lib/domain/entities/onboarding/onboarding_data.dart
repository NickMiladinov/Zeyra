/// Temporary entity for storing onboarding progress before authentication.
class OnboardingData {
  /// Current onboarding screen index (0-2).
  final int currentStep;

  const OnboardingData({this.currentStep = 0});

  /// Whether the minimal onboarding flow is complete.
  bool get isComplete => currentStep >= 2;

  /// Create a copy with updated fields.
  OnboardingData copyWith({int? currentStep}) {
    return OnboardingData(currentStep: currentStep ?? this.currentStep);
  }

  /// Create empty onboarding data.
  factory OnboardingData.empty() => const OnboardingData();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingData &&
          runtimeType == other.runtimeType &&
          currentStep == other.currentStep;

  @override
  int get hashCode => currentStep.hashCode;

  @override
  String toString() => 'OnboardingData(step: $currentStep)';
}
