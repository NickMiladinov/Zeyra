@Tags(['kick_counter'])
library;

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/local/daos/kick_counter_dao.dart';

void main() {
  group('KickSessionWithKicks', () {
    // Create base test data
    final tSession = KickSessionDto(
      id: 'session-1',
      startTimeMillis: 1000,
      isActive: true,
      totalPausedMillis: 0,
      pauseCount: 0,
      createdAtMillis: 1000,
      updatedAtMillis: 1000,
    );

    final tKick1 = KickDto(
      id: 'kick-1',
      sessionId: 'session-1',
      timestampMillis: 1100,
      sequenceNumber: 1,
      perceivedStrength: 'encrypted-strength',
    );

    final tKick2 = KickDto(
      id: 'kick-2',
      sessionId: 'session-1',
      timestampMillis: 1200,
      sequenceNumber: 2,
      perceivedStrength: 'encrypted-strength',
    );

    test('should support value equality', () {
      // Arrange
      final instance1 = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick1, tKick2],
      );

      final instance2 = KickSessionWithKicks(
        session: tSession.copyWith(), // Clone to ensure different reference
        kicks: [tKick1.copyWith(), tKick2.copyWith()], // Clone list items
      );

      // Assert
      expect(instance1, equals(instance2));
      expect(instance1.hashCode, equals(instance2.hashCode));
    });

    test('should differ when session differs', () {
      // Arrange
      final instance1 = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick1],
      );

      final instance2 = KickSessionWithKicks(
        session: tSession.copyWith(id: 'session-2'),
        kicks: [tKick1],
      );

      // Assert
      expect(instance1, isNot(equals(instance2)));
    });

    test('should differ when kicks list content differs', () {
      // Arrange
      final instance1 = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick1],
      );

      final instance2 = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick1, tKick2], // Extra kick
      );

      // Assert
      expect(instance1, isNot(equals(instance2)));
    });

    test('should differ when kicks list order differs', () {
      // Arrange
      final instance1 = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick1, tKick2],
      );

      final instance2 = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick2, tKick1], // Reversed order
      );

      // Assert
      expect(instance1, isNot(equals(instance2)));
    });

    test('should have correct toString output', () {
      final instance = KickSessionWithKicks(
        session: tSession,
        kicks: [tKick1, tKick2],
      );

      expect(
        instance.toString(),
        contains('session: session-1, kicks: 2'),
      );
    });
  });
}

