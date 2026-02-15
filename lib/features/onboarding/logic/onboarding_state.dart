import '../../../domain/entities/onboarding/onboarding_data.dart';

/// State for the onboarding flow.
///
/// Tracks current onboarding data, step, loading states, and errors.
class OnboardingState {
  /// The current onboarding data being collected.
  final OnboardingData data;

  /// Whether an async operation is in progress.
  final bool isLoading;

  /// Error message if an operation failed.
  final String? error;

  const OnboardingState({
    required this.data,
    this.isLoading = false,
    this.error,
  });

  /// Create initial state with empty onboarding data.
  factory OnboardingState.initial() =>
      OnboardingState(data: OnboardingData.empty());

  /// Current step index (0-2).
  int get currentStep => data.currentStep;

  /// Total number of onboarding steps.
  static const int totalSteps = 3;

  /// Progress percentage (0.0 - 1.0).
  double get progress => currentStep / (totalSteps - 1);

  /// Whether we're on the first step.
  bool get isFirstStep => currentStep == 0;

  /// Whether we're on the last step.
  bool get isLastStep => currentStep == totalSteps - 1;

  /// Create a copy with updated fields.
  OnboardingState copyWith({
    OnboardingData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => data.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() =>
      'OnboardingState(step: $currentStep, isLoading: $isLoading, error: $error)';
}
