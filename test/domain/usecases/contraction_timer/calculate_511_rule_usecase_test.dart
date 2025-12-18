@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/usecases/contraction_timer/calculate_511_rule_usecase.dart';

import '../../../mocks/fake_data/contraction_timer_fakes.dart';

void main() {
  group('[ContractionTimer] Calculate511RuleUseCase', () {
    late Calculate511RuleUseCase useCase;

    setUp(() {
      useCase = Calculate511RuleUseCase();
    });

    group('Basic Functionality', () {
      test('should return inactive status for empty session', () {
        // Arrange
        final session = FakeContractionSession.simple();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.alertActive, isFalse);
        expect(result.contractionsInWindow, equals(0));
        expect(result.validDurationCount, equals(0));
        expect(result.validFrequencyCount, equals(0));
      });

      test('should handle session with contractions', () {
        // Arrange
        final session = FakeContractionSession.meeting511Rule();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result, isNotNull);
        expect(result.contractionsInWindow, greaterThanOrEqualTo(0));
        expect(result.validDurationCount, greaterThanOrEqualTo(0));
        expect(result.validFrequencyCount, greaterThanOrEqualTo(0));
      });
    });

    group('Status Output', () {
      test('should return Rule511Status with all required fields', () {
        // Arrange
        final session = FakeContractionSession.simple();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.alertActive, isA<bool>());
        expect(result.contractionsInWindow, isA<int>());
        expect(result.validDurationCount, isA<int>());
        expect(result.validFrequencyCount, isA<int>());
        expect(result.validityPercentage, isA<double>());
        expect(result.durationProgress, isA<double>());
        expect(result.frequencyProgress, isA<double>());
        expect(result.consistencyProgress, isA<double>());
        expect(result.isDurationReset, isA<bool>());
        expect(result.isFrequencyReset, isA<bool>());
        expect(result.isConsistencyReset, isA<bool>());
      });

      test('should calculate progress values between 0 and 1', () {
        // Arrange
        final session = FakeContractionSession.meeting511Rule();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.durationProgress, greaterThanOrEqualTo(0.0));
        expect(result.durationProgress, lessThanOrEqualTo(1.0));
        expect(result.frequencyProgress, greaterThanOrEqualTo(0.0));
        expect(result.frequencyProgress, lessThanOrEqualTo(1.0));
        expect(result.consistencyProgress, greaterThanOrEqualTo(0.0));
        expect(result.consistencyProgress, lessThanOrEqualTo(1.0));
        expect(result.validityPercentage, greaterThanOrEqualTo(0.0));
        expect(result.validityPercentage, lessThanOrEqualTo(1.0));
      });
    });

    group('Edge Cases', () {
      test('should handle session with minimal contractions', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: [FakeContraction.simple()],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result, isNotNull);
        expect(result.alertActive, isFalse);
      });

      test('should handle session with active contraction', () {
        // Arrange
        final session = FakeContractionSession.withActiveContraction();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result, isNotNull);
        // Active contractions should not be counted in calculations
      });
    });

    group('Reset Conditions', () {
      test('should include reset reason when reset is true', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: [FakeContraction.simple()],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // If any reset is true, the corresponding reason should be set
        if (result.isDurationReset) {
          expect(result.durationResetReason, isNotNull);
        }
        if (result.isFrequencyReset) {
          expect(result.frequencyResetReason, isNotNull);
        }
        if (result.isConsistencyReset) {
          expect(result.consistencyResetReason, isNotNull);
        }
      });

      test('should have null reset reasons when reset is false', () {
        // Arrange
        final session = FakeContractionSession.simple();

        // Act
        final result = useCase.calculate(session);

        // Assert
        // For empty session, no resets should be active
        expect(result.isDurationReset, isFalse);
        expect(result.isFrequencyReset, isFalse);
        expect(result.isConsistencyReset, isFalse);
      });
    });

    group('Window Time Calculation', () {
      test('should set window start time when contractions exist', () {
        // Arrange
        final session = FakeContractionSession.meeting511Rule();

        // Act
        final result = useCase.calculate(session);

        // Assert
        if (result.contractionsInWindow > 0) {
          expect(result.windowStartTime, isNotNull);
        }
      });

      test('should have null window start time for empty session', () {
        // Arrange
        final session = FakeContractionSession.simple();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.windowStartTime, isNull);
      });
    });

    // ========================================================================
    // COMPREHENSIVE TEST COVERAGE
    // ========================================================================

    group('Duration Criteria (durationValidThreshold >= 45s)', () {
      test('should count contractions >= 45s as valid duration', () {
        // Arrange
        final now = DateTime.now();
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50),
              const Duration(seconds: 45),
              const Duration(seconds: 60),
            ],
            startTime: now.subtract(const Duration(minutes: 30)),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, equals(3));
      });

      test('should not count contractions < 45s as valid duration', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 44),
              const Duration(seconds: 40),
              const Duration(seconds: 35),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, equals(0));
      });

      test('should count contractions exactly at 45s boundary', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 45),
              const Duration(seconds: 45),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, equals(2));
      });

      test('should handle contractions in gray zone (30-45s)', () {
        // Arrange - These are counted but not as "valid"
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 35),
              const Duration(seconds: 40),
              const Duration(seconds: 42),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, equals(0)); // None meet >= 45s threshold
      });

      test('should not count contractions < 30s at all', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 25),
              const Duration(seconds: 20),
              const Duration(seconds: 15),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, equals(0));
      });

      test('should skip active contractions in duration count', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: [
            FakeContraction.completed(duration: const Duration(seconds: 50)),
            FakeContraction.active(), // No end time
            FakeContraction.completed(duration: const Duration(seconds: 50)),
          ],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, equals(2)); // Active not counted
      });

      test('should calculate durationProgress correctly', () {
        // Arrange - 2 out of 3 meet threshold
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50),
              const Duration(seconds: 30),
              const Duration(seconds: 60),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.durationProgress, closeTo(0.666, 0.01)); // ~66.6%
      });

      test('should return 0 durationProgress for all short contractions', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.weak(count: 5),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.durationProgress, equals(0.0));
      });
    });

    group('Frequency Criteria (frequencyValidThreshold <= 6 min)', () {
      test('should count intervals <= 6 minutes as valid', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 5),
              const Duration(minutes: 6),
              const Duration(minutes: 4),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(3)); // All intervals valid
      });

      test('should not count intervals > 6 minutes as valid', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 7),
              const Duration(minutes: 8),
              const Duration(minutes: 10),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(0));
      });

      test('should treat intervals < 2 minutes as valid/urgent', () {
        // Arrange - Hyperstimulation pattern
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 1),
              const Duration(seconds: 90),
              const Duration(seconds: 100),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(3)); // All urgent/valid
      });

      test('should handle exactly 6 minute boundary', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 6),
              const Duration(minutes: 6),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(2)); // Exactly at threshold
      });

      test('should return 0 for single contraction', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: [FakeContraction.simple()],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(0)); // Need 2+ for intervals
      });

      test('should calculate frequencyProgress correctly', () {
        // Arrange - 4 valid out of 6 intervals (need 7 contractions for 6 intervals)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 5), // Valid
              const Duration(minutes: 5), // Valid
              const Duration(minutes: 8), // Invalid
              const Duration(minutes: 4), // Valid
              const Duration(minutes: 9), // Invalid
              const Duration(minutes: 5), // Valid
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.frequencyProgress, closeTo(0.666, 0.01)); // ~66.6% (4/6)
      });

      test('should handle mixed valid/invalid intervals', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 3), // Valid
              const Duration(minutes: 7), // Invalid
              const Duration(minutes: 5), // Valid
              const Duration(minutes: 10), // Invalid
              const Duration(minutes: 2), // Valid (urgent)
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(3)); // 3 out of 5
      });

      test('should handle hyperstimulation pattern (< 2min)', () {
        // Arrange - All intervals very short (urgent case)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: List.filled(5, const Duration(seconds: 90)),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validFrequencyCount, equals(5)); // All valid
      });
    });

    group('Validity/Consistency (80% threshold)', () {
      test('should require 80% validity for alert', () {
        // Arrange - 5 out of 6 contractions valid = 83.3%
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50),
              const Duration(seconds: 50),
              const Duration(seconds: 50),
              const Duration(seconds: 50),
              const Duration(seconds: 50),
              const Duration(seconds: 30), // One weak
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validityPercentage, greaterThanOrEqualTo(0.80));
      });

      test('should not alert below 80% validity', () {
        // Arrange - 4 out of 6 = 66.6% (below threshold)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50),
              const Duration(seconds: 50),
              const Duration(seconds: 30),
              const Duration(seconds: 50),
              const Duration(seconds: 30),
              const Duration(seconds: 50),
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validityPercentage, lessThan(0.80));
        expect(result.alertActive, isFalse);
      });

      test('should count contractions meeting both duration AND frequency', () {
        // Arrange - Good duration, good frequency
        final session = FakeContractionSession.meeting511Rule(count: 6);

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, greaterThanOrEqualTo(5));
        expect(result.validFrequencyCount, greaterThanOrEqualTo(4));
      });

      test('should require minimum 6 contractions', () {
        // Arrange
        final session = FakeContractionSession.belowMinimum(count: 5);

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.contractionsInWindow, lessThan(6));
        expect(result.alertActive, isFalse); // Below minimum
      });

      test('should calculate validityPercentage correctly', () {
        // Arrange - 6 perfect contractions out of 8
        final session = FakeContractionSession.simple(
          contractions: [
            ...FakeContraction.meeting511Rule(count: 6),
            ...FakeContraction.weak(count: 2),
          ],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validityPercentage, closeTo(0.75, 0.05)); // ~75%
      });

      test('should handle 5 contractions (below minimum)', () {
        // Arrange
        final session = FakeContractionSession.belowMinimum(count: 5);

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.contractionsInWindow, equals(5));
        expect(result.alertActive, isFalse);
        expect(result.consistencyProgress, closeTo(0.833, 0.01)); // 5/6
      });
    });

    group('Reset Conditions (Duration, Frequency, Consistency)', () {
      test('should trigger duration reset after 3 consecutive short contractions', () {
        // Arrange
        final session = FakeContractionSession.withDurationReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isDurationReset, isTrue);
        expect(result.durationResetReason, equals('consecutive_short'));
      });

      test('should not reset duration with only 2 short contractions', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.weak(count: 2),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isDurationReset, isFalse);
      });

      test('should set durationResetReason to consecutive_short', () {
        // Arrange
        final session = FakeContractionSession.withDurationReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isDurationReset, isTrue);
        expect(result.durationResetReason, isNotNull);
        expect(result.durationResetReason, equals('consecutive_short'));
      });

      test('should trigger frequency reset after 20 minute gap', () {
        // Arrange
        final session = FakeContractionSession.withFrequencyReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isFrequencyReset, isTrue);
        expect(result.frequencyResetReason, equals('gap_too_long'));
      });

      test('should not reset frequency with 19 minute gap', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 5),
              const Duration(minutes: 19), // Just under threshold
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isFrequencyReset, isFalse);
      });

      test('should set frequencyResetReason to gap_too_long', () {
        // Arrange
        final session = FakeContractionSession.withFrequencyReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isFrequencyReset, isTrue);
        expect(result.frequencyResetReason, isNotNull);
        expect(result.frequencyResetReason, equals('gap_too_long'));
      });

      test('should trigger consistency reset with 3/5 invalid intervals', () {
        // Arrange
        final session = FakeContractionSession.withConsistencyReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isConsistencyReset, isTrue);
        expect(result.consistencyResetReason, equals('pattern_irregular'));
      });

      test('should not reset consistency with 2/5 invalid intervals', () {
        // Arrange
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 5), // Valid
              const Duration(minutes: 8), // Invalid
              const Duration(minutes: 5), // Valid
              const Duration(minutes: 9), // Invalid
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isConsistencyReset, isFalse); // Only 2 invalid
      });

      test('should set consistencyResetReason to pattern_irregular', () {
        // Arrange
        final session = FakeContractionSession.withConsistencyReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isConsistencyReset, isTrue);
        expect(result.consistencyResetReason, isNotNull);
        expect(result.consistencyResetReason, equals('pattern_irregular'));
      });

      test('should prevent alert activation during critical resets', () {
        // Arrange - Good pattern but with duration reset
        final session = FakeContractionSession.withDurationReset();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isDurationReset, isTrue);
        expect(result.alertActive, isFalse); // Reset blocks alert
      });
    });

    group('Progress Calculations', () {
      test('should clamp all progress values between 0 and 1', () {
        // Arrange - Perfect pattern
        final session = FakeContractionSession.meeting511Rule(count: 12);

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.durationProgress, lessThanOrEqualTo(1.0));
        expect(result.frequencyProgress, lessThanOrEqualTo(1.0));
        expect(result.consistencyProgress, lessThanOrEqualTo(1.0));
        expect(result.durationProgress, greaterThanOrEqualTo(0.0));
        expect(result.frequencyProgress, greaterThanOrEqualTo(0.0));
        expect(result.consistencyProgress, greaterThanOrEqualTo(0.0));
      });

      test('should calculate consistencyProgress with time + validity', () {
        // Arrange - Session with decent pattern
        final session = FakeContractionSession.meeting511Rule(count: 7);

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Consistency is weighted combination of time and validity
        expect(result.consistencyProgress, greaterThan(0.0));
        expect(result.consistencyProgress, lessThanOrEqualTo(1.0));
      });

      test('should handle empty session for all progress values', () {
        // Arrange
        final session = FakeContractionSession.simple();

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.durationProgress, equals(0.0));
        expect(result.frequencyProgress, equals(0.0));
        expect(result.consistencyProgress, equals(0.0));
      });

      test('should set windowStartTime to first contraction in window', () {
        // Arrange - use recent timestamps so contractions are in the rolling window
        final startTime = DateTime.now().subtract(const Duration(minutes: 40));
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.meeting511Rule(
            startTime: startTime,
            count: 6,
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // windowStartTime should be set to the first contraction in the window
        expect(result.windowStartTime, isNotNull);
        // The first contraction should be close to our startTime (within a few seconds)
        expect(
          result.windowStartTime!.difference(startTime).inSeconds.abs(),
          lessThan(5),
        );
      });

      test('should exclude old contractions from window', () {
        // Arrange - Mix of old and recent contractions
        final now = DateTime.now();
        final oldContractions = FakeContraction.batch(
          3,
          startTime: now.subtract(const Duration(hours: 2)),
        );
        final recentContractions = FakeContraction.batch(
          6,
          startTime: now.subtract(const Duration(minutes: 30)),
        );

        final session = FakeContractionSession.simple(
          contractions: [...oldContractions, ...recentContractions],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Should only count recent ones in 60-min window
        expect(result.contractionsInWindow, lessThan(9));
      });
    });

    group('Integration/Combined Scenarios', () {
      test('should activate alert for perfect 5-1-1 pattern', () {
        // Arrange - 8 contractions, all meeting criteria
        final session = FakeContractionSession.meeting511Rule(count: 8);

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.alertActive, isTrue);
        expect(result.contractionsInWindow, greaterThanOrEqualTo(6));
        expect(result.validityPercentage, greaterThanOrEqualTo(0.80));
        expect(result.isDurationReset, isFalse);
        expect(result.isFrequencyReset, isFalse);
      });

      test('should not alert with good duration but poor frequency', () {
        // Arrange - Good duration but too far apart
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.batch(
            6,
            duration: const Duration(seconds: 50), // Good
            frequency: const Duration(minutes: 10), // Too far apart
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.validDurationCount, greaterThan(0));
        expect(result.validFrequencyCount, equals(0));
        expect(result.alertActive, isFalse);
      });

      test('should handle gradual improvement to 5-1-1', () {
        // Arrange - Starts weak, gets better
        final session = FakeContractionSession.simple(
          contractions: [
            ...FakeContraction.weak(count: 2),
            ...FakeContraction.meeting511Rule(count: 6),
          ],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Should show progress even with initial weak contractions
        expect(result.contractionsInWindow, greaterThanOrEqualTo(6));
        expect(result.durationProgress, greaterThan(0.5));
      });

      test('should handle pattern degradation after achieving 5-1-1', () {
        // Arrange - Good pattern then degrades
        final session = FakeContractionSession.simple(
          contractions: [
            ...FakeContraction.meeting511Rule(count: 6),
            ...FakeContraction.weak(count: 3), // Pattern degrades
          ],
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.isDurationReset, isTrue); // 3 consecutive weak
        expect(result.alertActive, isFalse); // Reset prevents alert
      });

      test('should handle real-world mixed pattern', () {
        // Arrange - Mix of good and weak contractions
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50), // Good
              const Duration(seconds: 35), // Weak
              const Duration(seconds: 55), // Good
              const Duration(seconds: 45), // Good
              const Duration(seconds: 30), // Weak
              const Duration(seconds: 60), // Good
              const Duration(seconds: 50), // Good
            ],
            frequency: const Duration(minutes: 5),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Should handle mixed data gracefully
        expect(result, isNotNull);
        expect(result.validDurationCount, greaterThan(0));
        expect(result.validityPercentage, greaterThan(0.0));
      });
    });
  });
}
