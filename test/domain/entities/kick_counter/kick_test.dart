@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';

import '../../../mocks/fake_data/kick_counter_fakes.dart';

void main() {
  group('[KickCounter] Kick Entity', () {
    test('should create Kick with all required fields', () {
      // Arrange
      final id = 'kick-123';
      final sessionId = 'session-456';
      final timestamp = DateTime(2024, 1, 1, 10, 30);
      const sequenceNumber = 5;
      const strength = MovementStrength.strong;

      // Act
      final kick = Kick(
        id: id,
        sessionId: sessionId,
        timestamp: timestamp,
        sequenceNumber: sequenceNumber,
        perceivedStrength: strength,
      );

      // Assert
      expect(kick.id, equals(id));
      expect(kick.sessionId, equals(sessionId));
      expect(kick.timestamp, equals(timestamp));
      expect(kick.sequenceNumber, equals(sequenceNumber));
      expect(kick.perceivedStrength, equals(strength));
    });

    test('should serialize MovementStrength enum correctly', () {
      // Arrange & Act
      final weakKick = FakeKick.simple(strength: MovementStrength.weak);
      final moderateKick = FakeKick.simple(strength: MovementStrength.moderate);
      final strongKick = FakeKick.simple(strength: MovementStrength.strong);

      // Assert
      expect(weakKick.perceivedStrength, equals(MovementStrength.weak));
      expect(moderateKick.perceivedStrength, equals(MovementStrength.moderate));
      expect(strongKick.perceivedStrength, equals(MovementStrength.strong));
    });

    test('should have correct displayName for each strength', () {
      // Assert
      expect(MovementStrength.weak.displayName, equals('Weak'));
      expect(MovementStrength.moderate.displayName, equals('Moderate'));
      expect(MovementStrength.strong.displayName, equals('Strong'));
    });

    test('should have correct name property for each strength', () {
      // Assert
      expect(MovementStrength.weak.name, equals('weak'));
      expect(MovementStrength.moderate.name, equals('moderate'));
      expect(MovementStrength.strong.name, equals('strong'));
    });

    test('should compare kicks correctly with == operator', () {
      // Arrange
      final kick1 = FakeKick.simple(
        id: 'kick-1',
        sequenceNumber: 1,
        strength: MovementStrength.weak,
      );
      final kick2 = FakeKick.simple(
        id: 'kick-1',
        sequenceNumber: 1,
        strength: MovementStrength.weak,
      );
      final kick3 = FakeKick.simple(
        id: 'kick-2',
        sequenceNumber: 2,
        strength: MovementStrength.strong,
      );

      // Assert
      expect(kick1, equals(kick2));
      expect(kick1, isNot(equals(kick3)));
    });
  });
}

