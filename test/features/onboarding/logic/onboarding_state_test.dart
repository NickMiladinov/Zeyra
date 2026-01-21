@Tags(['onboarding'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/onboarding/onboarding_data.dart';
import 'package:zeyra/features/onboarding/logic/onboarding_state.dart';

void main() {
  group('[Onboarding] OnboardingState', () {
    // -------------------------------------------------------------------------
    // Initial State Tests
    // -------------------------------------------------------------------------
    group('Initial State', () {
      test('should create initial state with empty data', () {
        final state = OnboardingState.initial();

        expect(state.data.firstName, isNull);
        expect(state.data.dueDate, isNull);
        expect(state.data.currentStep, equals(0));
      });

      test('should have isLoading false initially', () {
        final state = OnboardingState.initial();

        expect(state.isLoading, isFalse);
      });

      test('should have null error initially', () {
        final state = OnboardingState.initial();

        expect(state.error, isNull);
      });

    });

    // -------------------------------------------------------------------------
    // Computed Properties Tests
    // -------------------------------------------------------------------------
    group('Computed Properties', () {
      test('should calculate progress correctly', () {
        // Step 0 of 11 = 0%
        final stateStep0 = OnboardingState(
          data: const OnboardingData(currentStep: 0),
        );
        expect(stateStep0.progress, equals(0.0));

        // Step 5 of 11 = 50%
        final stateStep5 = OnboardingState(
          data: const OnboardingData(currentStep: 5),
        );
        expect(stateStep5.progress, equals(0.5));

        // Step 10 of 11 = 100%
        final stateStep10 = OnboardingState(
          data: const OnboardingData(currentStep: 10),
        );
        expect(stateStep10.progress, equals(1.0));
      });

      test('should identify first step', () {
        final stateFirst = OnboardingState(
          data: const OnboardingData(currentStep: 0),
        );
        expect(stateFirst.isFirstStep, isTrue);

        final stateNotFirst = OnboardingState(
          data: const OnboardingData(currentStep: 1),
        );
        expect(stateNotFirst.isFirstStep, isFalse);
      });

      test('should identify last step', () {
        final stateLast = OnboardingState(
          data: const OnboardingData(currentStep: 10),
        );
        expect(stateLast.isLastStep, isTrue);

        final stateNotLast = OnboardingState(
          data: const OnboardingData(currentStep: 9),
        );
        expect(stateNotLast.isLastStep, isFalse);
      });

      test('should return totalSteps as 11', () {
        expect(OnboardingState.totalSteps, equals(11));
      });

      test('should return current step from data', () {
        final state = OnboardingState(
          data: const OnboardingData(currentStep: 7),
        );
        expect(state.currentStep, equals(7));
      });
    });

    // -------------------------------------------------------------------------
    // CopyWith Tests
    // -------------------------------------------------------------------------
    group('CopyWith', () {
      test('should update data field', () {
        final original = OnboardingState.initial();
        final newData = const OnboardingData(firstName: 'Jane');

        final updated = original.copyWith(data: newData);

        expect(updated.data.firstName, equals('Jane'));
        expect(original.data.firstName, isNull); // Original unchanged
      });

      test('should update isLoading', () {
        final original = OnboardingState.initial();

        final updated = original.copyWith(isLoading: true);

        expect(updated.isLoading, isTrue);
        expect(original.isLoading, isFalse); // Original unchanged
      });

      test('should update error', () {
        final original = OnboardingState.initial();

        final updated = original.copyWith(error: 'Test error');

        expect(updated.error, equals('Test error'));
        expect(original.error, isNull); // Original unchanged
      });

      test('should clear error with clearError flag', () {
        final stateWithError = OnboardingState(
          data: OnboardingData.empty(),
          error: 'Previous error',
        );

        final cleared = stateWithError.copyWith(clearError: true);

        expect(cleared.error, isNull);
      });

      test('should preserve unspecified fields', () {
        final original = OnboardingState(
          data: const OnboardingData(firstName: 'Jane', currentStep: 5),
          isLoading: true,
          error: 'Some error',
        );

        final updated = original.copyWith(isLoading: false);

        expect(updated.data.firstName, equals('Jane'));
        expect(updated.data.currentStep, equals(5));
        expect(updated.isLoading, isFalse);
        expect(updated.error, equals('Some error'));
      });
    });

    // -------------------------------------------------------------------------
    // Equality Tests
    // -------------------------------------------------------------------------
    group('Equality', () {
      test('should be equal when all fields match', () {
        final state1 = OnboardingState(
          data: const OnboardingData(firstName: 'Jane', currentStep: 5),
          isLoading: true,
          error: 'Error',
        );

        final state2 = OnboardingState(
          data: const OnboardingData(firstName: 'Jane', currentStep: 5),
          isLoading: true,
          error: 'Error',
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final state1 = OnboardingState(
          data: const OnboardingData(firstName: 'Jane'),
        );

        final state2 = OnboardingState(
          data: const OnboardingData(firstName: 'Sarah'),
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    // -------------------------------------------------------------------------
    // toString Tests
    // -------------------------------------------------------------------------
    group('toString', () {
      test('should include step in toString', () {
        final state = OnboardingState(
          data: const OnboardingData(currentStep: 5),
        );
        final string = state.toString();

        expect(string, contains('5'));
      });

      test('should include isLoading in toString', () {
        final state = OnboardingState(
          data: OnboardingData.empty(),
          isLoading: true,
        );
        final string = state.toString();

        expect(string, contains('isLoading: true'));
      });

      test('should include error in toString', () {
        final state = OnboardingState(
          data: OnboardingData.empty(),
          error: 'Test error',
        );
        final string = state.toString();

        expect(string, contains('Test error'));
      });
    });
  });
}
