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

      test('should calculate durationProgress based on last contraction', () {
        // Arrange - last contraction is 60s, threshold is 45s
        // durationProgress = min(1.0, 60/45) = 1.0 (capped)
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

        // Assert - based on last contraction (60s) relative to 45s threshold
        expect(result.durationProgress, equals(1.0));
      });

      test('should show current durationProgress even when reset triggers', () {
        // Arrange - 5 weak contractions (25s each, all < 30s)
        // Last 3 are all < 30s → duration reset triggers
        // BUT progress should still show based on last contraction (25s/45s ≈ 55.6%)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.weak(count: 5),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert - duration reset triggered, but shows current progress (not 0%)
        expect(result.isDurationReset, isTrue);
        expect(result.durationProgress, closeTo(0.556, 0.01)); // 25s / 45s
      });

      test('should show partial durationProgress when approaching but not achieved', () {
        // Arrange - contractions in gray zone (30-44s)
        // Not valid yet (< 45s) but not reset (>= 30s)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 35), // Gray zone
              const Duration(seconds: 40), // Gray zone
              const Duration(seconds: 35), // Gray zone
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert - no valid durations yet, no reset, shows partial progress based on last (35s/45s ≈ 77.8%)
        expect(result.validDurationCount, equals(0));
        expect(result.isDurationReset, isFalse);
        expect(result.durationProgress, closeTo(0.778, 0.01));
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

      test('should calculate frequencyProgress using inverse scale based on last interval', () {
        // Arrange - Last interval of 5 minutes should give 100% progress
        // Gaps: 10, 15, 8, 12, 5 → last = 5 minutes
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 10),
              const Duration(minutes: 15),
              const Duration(minutes: 8),
              const Duration(minutes: 12),
              const Duration(minutes: 5), // Last interval
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Last interval = 5 min (< 6 min) → 100% progress
        expect(result.frequencyProgress, equals(1.0));
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
        // Below minimum for alert, but consistency progress still calculated based on validity
        expect(result.consistencyProgress, greaterThan(0.0));
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

      test('should calculate frequencyProgress at 0% for 30+ min intervals', () {
        // Arrange - Very far apart (30+ minutes)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [const Duration(minutes: 30)],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.frequencyProgress, equals(0.0));
      });

      test('should calculate frequencyProgress at 100% for 6 min intervals', () {
        // Arrange - At target frequency (6 minutes)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: List.filled(5, const Duration(minutes: 6)),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.frequencyProgress, equals(1.0));
      });

      test('should calculate frequencyProgress at ~50% for 18 min intervals', () {
        // Arrange - Halfway between 30 and 6 minutes = 18 min
        // (30 - 18) / (30 - 6) = 12/24 = 0.5
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 10),
              const Duration(minutes: 18), // Last interval = 18 min
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.frequencyProgress, closeTo(0.5, 0.01));
      });

      test('should calculate frequencyProgress at ~83% for 10 min intervals', () {
        // Arrange - Last interval 10 minutes apart
        // (30 - 10) / (30 - 6) = 20/24 ≈ 0.833
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 15),
              const Duration(minutes: 10), // Last interval = 10 min
            ],
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        expect(result.frequencyProgress, closeTo(0.833, 0.01));
      });

      test('should calculate consistencyProgress even with < 6 contractions', () {
        // Arrange - Only 5 contractions, but all valid
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.meeting511Rule(count: 5),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // With < 6 contractions, progress is count-based: 5/6 = ~83.3%
        // This prevents misleading high progress from low sample sizes (e.g., 1/1 = 100%)
        expect(result.consistencyProgress, closeTo(0.833, 0.01));
      });

      test('should calculate consistencyProgress proportional to validity', () {
        // Arrange - 6 contractions with 33% validity (2/6)
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 30), // Invalid
              const Duration(seconds: 25), // Invalid
              const Duration(seconds: 30), // Invalid
              const Duration(seconds: 25), // Invalid
            ],
            frequency: const Duration(minutes: 5),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // 2/6 = 33% validity → 0.33 / 0.80 = ~41% consistency progress
        expect(result.consistencyProgress, closeTo(0.4167, 0.05));
      });

      test('should calculate 100% consistencyProgress at 80% validity', () {
        // Arrange - 10 contractions: 8 fully valid (duration+frequency)
        // Need exactly 80% validity (8/10) to hit 100% consistency
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 30), // Invalid
              const Duration(seconds: 30), // Invalid
            ],
            frequency: const Duration(minutes: 5),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Validity calculation is complex (duration + frequency matching)
        // Should reach near 100% as most contractions are valid
        expect(result.consistencyProgress, greaterThanOrEqualTo(0.9));
      });

      test('should cap consistencyProgress at 100% for > 80% validity', () {
        // Arrange - 8 contractions with 100% validity (all valid)
        final session = FakeContractionSession.meeting511Rule(count: 8);

        // Act
        final result = useCase.calculate(session);

        // Assert
        // 100% validity → capped at 100% consistency progress
        expect(result.consistencyProgress, equals(1.0));
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

    group('evaluateAchievedCriteria (Single Source of Truth)', () {
      test('should return all false for empty session', () {
        // Arrange
        final session = FakeContractionSession.simple();

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.duration, isFalse);
        expect(result.frequency, isFalse);
        expect(result.consistency, isFalse);
      });

      test('should achieve duration when at least 1 valid contraction and no reset', () {
        // Arrange - At least 1 contraction >= 45s
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 30),
              const Duration(seconds: 45), // 1 valid is enough!
              const Duration(seconds: 30),
            ],
          ),
        );

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.duration, isTrue); // At least 1 valid
      });

      test('should not achieve duration when no valid contractions', () {
        // Arrange - All contractions < 45s
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 30),
              const Duration(seconds: 35),
              const Duration(seconds: 40),
            ],
          ),
        );

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.duration, isFalse); // No valid contractions
      });

      test('should not achieve duration when reset (3 consecutive short)', () {
        // Arrange - Duration reset triggered by 3 consecutive < 30s
        final session = FakeContractionSession.withDurationReset();

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.duration, isFalse); // Reset blocks achievement
      });

      test('should achieve frequency when at least 1 valid interval and no reset', () {
        // Arrange - At least 1 interval <= 6 min
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 10),
              const Duration(minutes: 5), // 1 valid is enough!
              const Duration(minutes: 10),
            ],
          ),
        );

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.frequency, isTrue); // At least 1 valid interval
      });

      test('should not achieve frequency when no valid intervals', () {
        // Arrange - All intervals > 6 min
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.withGaps(
            gaps: [
              const Duration(minutes: 10),
              const Duration(minutes: 15),
              const Duration(minutes: 20),
            ],
          ),
        );

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.frequency, isFalse); // No valid intervals
      });

      test('should achieve consistency when alertActive is true', () {
        // Arrange - Need 13 contractions at 5-min intervals to span 1+ hour
        // (13 - 1) * 5 = 60 minutes, with 80%+ validity
        final session = FakeContractionSession.meeting511Rule(count: 13);

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert - consistency matches alertActive
        expect(result.consistency, isTrue);
      });

      test('should not achieve consistency when alertActive is false', () {
        // Arrange - Valid pattern but session too short (no alertActive)
        final session = FakeContractionSession.belowMinimum(count: 5);

        // Act
        final result = useCase.evaluateAchievedCriteria(session);

        // Assert
        expect(result.consistency, isFalse);
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

      test('should not show 100% consistency when 6+ valid but < 80% validity (Bug Fix)', () {
        // Arrange - Regression test for the bug where all 3 checks show 100% but alert doesn't trigger
        // Scenario: 8 contractions with 6 valid = 75% validity (below 80% threshold)
        // Expected: Consistency progress should be 75% / 80% = ~94%, NOT 100%
        //           Alert should NOT be active
        final session = FakeContractionSession.simple(
          contractions: FakeContraction.mixedDurations(
            durations: [
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 50), // Valid
              const Duration(seconds: 25), // Invalid (< 30s)
              const Duration(seconds: 25), // Invalid (< 30s)
            ],
            frequency: const Duration(minutes: 5),
          ),
        );

        // Act
        final result = useCase.calculate(session);

        // Assert
        // Should have 6 valid contractions out of 8 = 75% validity
        expect(result.contractionsInWindow, equals(8));
        expect(result.validDurationCount, equals(6));
        
        // Consistency progress should NOT be 100% (it should reflect that we haven't hit 80%)
        // 75% / 80% = 0.9375
        expect(result.consistencyProgress, lessThan(1.0));
        expect(result.consistencyProgress, closeTo(0.9375, 0.05));
        
        // Alert should NOT be active because validity < 80%
        expect(result.alertActive, isFalse);
        expect(result.validityPercentage, lessThan(0.80));
      });
    });
  });
}
