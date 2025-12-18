@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';

void main() {
  group('[ContractionTimer] ContractionSession', () {
    final startTime = DateTime(2024, 1, 1, 10, 0);

    test('should create empty session', () {
      // Act
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Assert
      expect(session.id, equals('s1'));
      expect(session.startTime, equals(startTime));
      expect(session.endTime, isNull);
      expect(session.isActive, isTrue);
      expect(session.contractions, isEmpty);
      expect(session.note, isNull);
      expect(session.achievedDuration, isFalse);
      expect(session.achievedFrequency, isFalse);
      expect(session.achievedConsistency, isFalse);
    });

    test('should identify active session when is Active is true', () {
      // Arrange
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act & Assert
      expect(session.isActive, isTrue);
    });

    test('should identify completed session when isActive is false', () {
      // Arrange
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 1)),
        isActive: false,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act & Assert
      expect(session.isActive, isFalse);
    });

    test('should calculate total duration for active session', () {
      // Arrange
      final now = DateTime.now();
      final sessionStart = now.subtract(const Duration(minutes: 30));
      final session = ContractionSession(
        id: 's1',
        startTime: sessionStart,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final totalDuration = session.totalDuration;

      // Assert - Should be approximately 30 minutes (with small tolerance for test execution time)
      expect(totalDuration.inMinutes, greaterThanOrEqualTo(29));
      expect(totalDuration.inMinutes, lessThanOrEqualTo(31));
    });

    test('should calculate total duration for completed session', () {
      // Arrange
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 1)),
        isActive: false,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final totalDuration = session.totalDuration;

      // Assert
      expect(totalDuration, equals(const Duration(hours: 1)));
    });

    test('should return active contraction when one exists', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c2',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 5)),
          endTime: null,
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final activeContraction = session.activeContraction;

      // Assert
      expect(activeContraction, isNotNull);
      expect(activeContraction!.id, equals('c2'));
      expect(activeContraction.isActive, isTrue);
    });

    test('should return null when no active contraction exists', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final activeContraction = session.activeContraction;

      // Assert
      expect(activeContraction, isNull);
    });

    test('should return last completed contraction', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c2',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 5)),
          endTime: startTime.add(const Duration(minutes: 6)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c3',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 10)),
          endTime: null,
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final lastCompleted = session.lastCompletedContraction;

      // Assert
      expect(lastCompleted, isNotNull);
      expect(lastCompleted!.id, equals('c2'));
      expect(lastCompleted.isActive, isFalse);
    });

    test('should return null when no completed contractions exist', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: null,
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final lastCompleted = session.lastCompletedContraction;

      // Assert
      expect(lastCompleted, isNull);
    });

    test('should calculate average frequency between contractions', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c2',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 5)),
          endTime: startTime.add(const Duration(minutes: 5, seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c3',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 10)),
          endTime: startTime.add(const Duration(minutes: 10, seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final avgFrequency = session.averageFrequency;

      // Assert
      expect(avgFrequency, isNotNull);
      expect(avgFrequency!.inMinutes, equals(5));
    });

    test('should return null average frequency when less than 2 contractions', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final avgFrequency = session.averageFrequency;

      // Assert
      expect(avgFrequency, isNull);
    });

    test('should calculate average contraction duration', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c2',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 5)),
          endTime: startTime.add(const Duration(minutes: 5, seconds: 50)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c3',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 10)),
          endTime: startTime.add(const Duration(minutes: 10, seconds: 40)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final avgDuration = session.averageDuration;

      // Assert
      expect(avgDuration, isNotNull);
      expect(avgDuration!.inSeconds, equals(50));
    });

    test('should return null average duration when no completed contractions', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: null,
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final avgDuration = session.averageDuration;

      // Assert
      expect(avgDuration, isNull);
    });

    test('should find longest contraction', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 40)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c2',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 5)),
          endTime: startTime.add(const Duration(minutes: 5, seconds: 70)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c3',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 10)),
          endTime: startTime.add(const Duration(minutes: 10, seconds: 50)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final longestDuration = session.longestContraction;

      // Assert
      expect(longestDuration, isNotNull);
      expect(longestDuration!.inSeconds, equals(70));
    });

    test('should return null longest contraction when no completed contractions', () {
      // Arrange
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final longestDuration = session.longestContraction;

      // Assert
      expect(longestDuration, isNull);
    });

    test('should find closest frequency between contractions', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c2',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 5)),
          endTime: startTime.add(const Duration(minutes: 5, seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
        Contraction(
          id: 'c3',
          sessionId: 's1',
          startTime: startTime.add(const Duration(minutes: 8)),
          endTime: startTime.add(const Duration(minutes: 8, seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final closestFrequency = session.closestFrequency;

      // Assert
      expect(closestFrequency, isNotNull);
      expect(closestFrequency!.inMinutes, equals(3));
    });

    test('should return null closest frequency when less than 2 contractions', () {
      // Arrange
      final contractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
      ];

      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: contractions,
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final closestFrequency = session.closestFrequency;

      // Assert
      expect(closestFrequency, isNull);
    });

    test('should support copyWith for all fields', () {
      // Arrange
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      final newEndTime = startTime.add(const Duration(hours: 1));
      final newContractions = [
        Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 60)),
          intensity: ContractionIntensity.moderate,
        ),
      ];
      final achievedAt = DateTime(2024, 1, 1, 11, 0);

      // Act
      final copied = session.copyWith(
        id: 's2',
        startTime: startTime.add(const Duration(days: 1)),
        endTime: newEndTime,
        isActive: false,
        contractions: newContractions,
        note: 'Test notes',
        achievedDuration: true,
        durationAchievedAt: achievedAt,
        achievedFrequency: true,
        frequencyAchievedAt: achievedAt,
        achievedConsistency: true,
        consistencyAchievedAt: achievedAt,
      );

      // Assert
      expect(copied.id, equals('s2'));
      expect(copied.startTime, equals(startTime.add(const Duration(days: 1))));
      expect(copied.endTime, equals(newEndTime));
      expect(copied.isActive, isFalse);
      expect(copied.contractions, equals(newContractions));
      expect(copied.note, equals('Test notes'));
      expect(copied.achievedDuration, isTrue);
      expect(copied.durationAchievedAt, equals(achievedAt));
      expect(copied.achievedFrequency, isTrue);
      expect(copied.frequencyAchievedAt, equals(achievedAt));
      expect(copied.achievedConsistency, isTrue);
      expect(copied.consistencyAchievedAt, equals(achievedAt));
    });

    test('should maintain equality based on all fields', () {
      // Arrange
      final session1 = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      final session2 = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      final session3 = ContractionSession(
        id: 's2',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Assert
      expect(session1, equals(session2));
      expect(session1, isNot(equals(session3)));
    });

    test('should generate correct hashCode', () {
      // Arrange
      final session1 = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      final session2 = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: null,
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Assert
      expect(session1.hashCode, equals(session2.hashCode));
    });

    test('should generate toString with relevant information', () {
      // Arrange
      final session = ContractionSession(
        id: 's1',
        startTime: startTime,
        endTime: null,
        isActive: true,
        contractions: [],
        note: 'Test notes',
        achievedDuration: false,
        durationAchievedAt: null,
        achievedFrequency: false,
        frequencyAchievedAt: null,
        achievedConsistency: false,
        consistencyAchievedAt: null,
      );

      // Act
      final stringRep = session.toString();

      // Assert
      expect(stringRep, contains('s1'));
    });
  });
}
