@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fake_data/kick_counter_fakes.dart';

void main() {
  group('[KickCounter] KickSession Entity', () {
    test('should calculate activeDuration correctly when not paused', () {
      // Arrange
      final startTime = DateTime(2024, 1, 1, 10, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30); // 30 minutes later
      final session = FakeKickSession.simple(
        startTime: startTime,
        endTime: endTime,
        totalPausedDuration: Duration.zero,
        pausedAt: null,
      );

      // Act
      final activeDuration = session.activeDuration;

      // Assert
      expect(activeDuration, equals(const Duration(minutes: 30)));
    });

    test('should calculate activeDuration excluding totalPausedDuration', () {
      // Arrange
      final startTime = DateTime(2024, 1, 1, 10, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30); // 30 minutes later
      final totalPaused = const Duration(minutes: 5);
      final session = FakeKickSession.simple(
        startTime: startTime,
        endTime: endTime,
        totalPausedDuration: totalPaused,
        pausedAt: null,
      );

      // Act
      final activeDuration = session.activeDuration;

      // Assert
      // Active = 30 min - 5 min pause = 25 min
      expect(activeDuration, equals(const Duration(minutes: 25)));
    });

    test('should calculate activeDuration excluding current pause when isPaused',
        () {
      // Arrange
      final startTime = DateTime(2024, 1, 1, 10, 0);
      final pausedAt = DateTime(2024, 1, 1, 10, 20); // Paused at 20 min
      final session = FakeKickSession.simple(
        startTime: startTime,
        endTime: null, // Still active
        pausedAt: pausedAt,
        totalPausedDuration: Duration.zero,
      );

      // Act
      final activeDuration = session.activeDuration;

      // Assert
      // Active duration should be approximately 20 minutes
      // (from start to pause, not including current pause)
      expect(activeDuration.inMinutes, lessThanOrEqualTo(20));
    });

    test('should return isPaused true when pausedAt is set', () {
      // Arrange
      final session = FakeKickSession.simple(
        pausedAt: DateTime(2024, 1, 1, 10, 15),
      );

      // Act & Assert
      expect(session.isPaused, isTrue);
    });

    test('should return isPaused false when pausedAt is null', () {
      // Arrange
      final session = FakeKickSession.simple(pausedAt: null);

      // Act & Assert
      expect(session.isPaused, isFalse);
    });

    test('should return kickCount matching kicks list length', () {
      // Arrange
      final kicks = FakeKick.batch(5);
      final session = FakeKickSession.simple(kicks: kicks);

      // Act & Assert
      expect(session.kickCount, equals(5));
      expect(session.kickCount, equals(kicks.length));
    });

    test('should calculate averageTimeBetweenKicks correctly', () {
      // Arrange
      final startTime = DateTime(2024, 1, 1, 10, 0);
      // 3 kicks at 0, 2, 4 minutes = avg 2 minutes between kicks
      final kicks = [
        FakeKick.simple(
          timestamp: startTime,
          sequenceNumber: 1,
        ),
        FakeKick.simple(
          timestamp: startTime.add(const Duration(minutes: 2)),
          sequenceNumber: 2,
        ),
        FakeKick.simple(
          timestamp: startTime.add(const Duration(minutes: 4)),
          sequenceNumber: 3,
        ),
      ];
      final session = FakeKickSession.simple(kicks: kicks);

      // Act
      final average = session.averageTimeBetweenKicks;

      // Assert
      expect(average, isNotNull);
      expect(average!.inMinutes, equals(2));
    });

    test('should return null averageTimeBetweenKicks with less than 2 kicks',
        () {
      // Arrange
      final session = FakeKickSession.simple(kicks: [FakeKick.simple()]);

      // Act
      final average = session.averageTimeBetweenKicks;

      // Assert
      expect(average, isNull);
    });

    test('should copyWith create new instance with updated fields', () {
      // Arrange
      final original = FakeKickSession.simple();
      final newEndTime = DateTime(2024, 1, 1, 11, 0);

      // Act
      final updated = original.copyWith(
        endTime: newEndTime,
        isActive: false,
      );

      // Assert
      expect(updated.id, equals(original.id));
      expect(updated.startTime, equals(original.startTime));
      expect(updated.endTime, equals(newEndTime));
      expect(updated.isActive, isFalse);
      expect(original.isActive, isTrue); // Original unchanged
    });

    test('should copyWith update note field', () {
      // Arrange
      final original = FakeKickSession.simple(note: 'Original note');
      const newNote = 'Updated note';

      // Act
      final updated = original.copyWith(note: newNote);

      // Assert
      expect(updated.note, equals(newNote));
      expect(original.note, equals('Original note')); // Original unchanged
    });

    test('should copyWith preserve note when not specified', () {
      // Arrange
      const note = 'Test note';
      final original = FakeKickSession.simple(note: note);

      // Act
      final updated = original.copyWith(isActive: false);

      // Assert
      expect(updated.note, equals(note));
    });

    test('should include note in equality comparison', () {
      // Arrange
      const note = 'Test note';
      final session1 = FakeKickSession.simple(id: 'id-1', note: note);
      final session2 = FakeKickSession.simple(id: 'id-1', note: note);
      final session3 = FakeKickSession.simple(id: 'id-1', note: 'Different note');
      final session4 = FakeKickSession.simple(id: 'id-1', note: null);

      // Assert
      expect(session1 == session2, isTrue); // Same note
      expect(session1 == session3, isFalse); // Different note
      expect(session1 == session4, isFalse); // Note vs no note
    });

    test('should include note in hashCode', () {
      // Arrange
      const note = 'Test note';
      final session1 = FakeKickSession.simple(id: 'id-1', note: note);
      final session2 = FakeKickSession.simple(id: 'id-1', note: note);
      final session3 = FakeKickSession.simple(id: 'id-1', note: 'Different');

      // Assert
      expect(session1.hashCode, equals(session2.hashCode));
      expect(session1.hashCode, isNot(equals(session3.hashCode)));
    });

    test('should include note in toString', () {
      // Arrange
      const note = 'Test note';
      final session = FakeKickSession.simple(note: note);

      // Act
      final string = session.toString();

      // Assert
      expect(string, contains('note: $note'));
    });
  });
}

