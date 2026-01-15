@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/contraction_timer/rule_511_status.dart';

void main() {
  group('[ContractionTimer] Rule511Status', () {
    test('should create status with all fields', () {
      // Arrange
      final windowStart = DateTime(2024, 1, 1, 10, 0);

      // Act
      final status = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: windowStart,
      );

      // Assert
      expect(status.alertActive, isTrue);
      expect(status.contractionsInWindow, equals(8));
      expect(status.validDurationCount, equals(8));
      expect(status.validFrequencyCount, equals(7));
      expect(status.validityPercentage, equals(0.95));
      expect(status.durationProgress, equals(1.0));
      expect(status.frequencyProgress, equals(1.0));
      expect(status.consistencyProgress, equals(1.0));
      expect(status.isDurationReset, isFalse);
      expect(status.isFrequencyReset, isFalse);
      expect(status.isConsistencyReset, isFalse);
      expect(status.durationResetReason, isNull);
      expect(status.frequencyResetReason, isNull);
      expect(status.consistencyResetReason, isNull);
      expect(status.windowStartTime, equals(windowStart));
    });

    test('should create inactive alert status', () {
      // Act
      final status = Rule511Status(
        alertActive: false,
        contractionsInWindow: 3,
        validDurationCount: 2,
        validFrequencyCount: 1,
        validityPercentage: 0.5,
        durationProgress: 0.6,
        frequencyProgress: 0.4,
        consistencyProgress: 0.3,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: null,
      );

      // Assert
      expect(status.alertActive, isFalse);
      expect(status.contractionsInWindow, equals(3));
      expect(status.validityPercentage, equals(0.5));
    });

    test('should create status with reset flags', () {
      // Act
      final status = Rule511Status(
        alertActive: false,
        contractionsInWindow: 3,
        validDurationCount: 1,
        validFrequencyCount: 0,
        validityPercentage: 0.3,
        durationProgress: 0.3,
        frequencyProgress: 0.0,
        consistencyProgress: 0.0,
        isDurationReset: true,
        isFrequencyReset: false,
        isConsistencyReset: true,
        durationResetReason: 'Weak contractions',
        frequencyResetReason: null,
        consistencyResetReason: 'Pattern broken',
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      // Assert
      expect(status.isDurationReset, isTrue);
      expect(status.isFrequencyReset, isFalse);
      expect(status.isConsistencyReset, isTrue);
      expect(status.durationResetReason, equals('Weak contractions'));
      expect(status.frequencyResetReason, isNull);
      expect(status.consistencyResetReason, equals('Pattern broken'));
    });

    test('should create new status with different values', () {
      // Arrange
      final status1 = Rule511Status(
        alertActive: false,
        contractionsInWindow: 3,
        validDurationCount: 2,
        validFrequencyCount: 1,
        validityPercentage: 0.5,
        durationProgress: 0.5,
        frequencyProgress: 0.5,
        consistencyProgress: 0.5,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: null,
      );

      // Act
      final status2 = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: true,
        isFrequencyReset: true,
        isConsistencyReset: true,
        durationResetReason: 'Test reason',
        frequencyResetReason: 'Test reason',
        consistencyResetReason: 'Test reason',
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      // Assert - They should be different
      expect(status2.alertActive, isTrue);
      expect(status2.contractionsInWindow, equals(8));
      expect(status2.validDurationCount, equals(8));
      expect(status2.validFrequencyCount, equals(7));
      expect(status2.validityPercentage, equals(0.95));
      expect(status2.durationProgress, equals(1.0));
      expect(status2.frequencyProgress, equals(1.0));
      expect(status2.consistencyProgress, equals(1.0));
      expect(status2.isDurationReset, isTrue);
      expect(status2.isFrequencyReset, isTrue);
      expect(status2.isConsistencyReset, isTrue);
      expect(status2.durationResetReason, equals('Test reason'));
      expect(status2.frequencyResetReason, equals('Test reason'));
      expect(status2.consistencyResetReason, equals('Test reason'));
      expect(status2.windowStartTime, equals(DateTime(2024, 1, 1, 10, 0)));
      expect(status1, isNot(equals(status2)));
    });

    test('should maintain equality based on all fields', () {
      // Arrange
      final status1 = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      final status2 = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      final status3 = Rule511Status(
        alertActive: false,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      // Assert
      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('should generate correct hashCode', () {
      // Arrange
      final status1 = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      final status2 = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      // Assert
      expect(status1.hashCode, equals(status2.hashCode));
    });

    test('should generate toString with relevant information', () {
      // Arrange
      final status = Rule511Status(
        alertActive: true,
        contractionsInWindow: 8,
        validDurationCount: 8,
        validFrequencyCount: 7,
        validityPercentage: 0.95,
        durationProgress: 1.0,
        frequencyProgress: 1.0,
        consistencyProgress: 1.0,
        isDurationReset: false,
        isFrequencyReset: false,
        isConsistencyReset: false,
        durationResetReason: null,
        frequencyResetReason: null,
        consistencyResetReason: null,
        windowStartTime: DateTime(2024, 1, 1, 10, 0),
      );

      // Act
      final stringRep = status.toString();

      // Assert
      expect(stringRep, contains('true'));
      expect(stringRep, contains('8'));
      expect(stringRep, contains('95.0%')); // toString formats as percentage
    });
  });
}

