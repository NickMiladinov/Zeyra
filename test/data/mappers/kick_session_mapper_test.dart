@Tags(['kick_counter'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/local/daos/kick_counter_dao.dart';
import 'package:zeyra/data/mappers/kick_session_mapper.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';

void main() {
  group('[KickCounter] KickSessionMapper', () {
    // Helper functions for test
    String decryptStrength(String encrypted) =>
        encrypted.replaceFirst('encrypted_', '');

    test('should map KickSessionDto to KickSession domain entity', () {
      // Arrange
      final sessionDto = KickSessionDto(
        id: 'session-1',
        startTimeMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        endTimeMillis: DateTime(2024, 1, 1, 10, 30).millisecondsSinceEpoch,
        isActive: false,
        pausedAtMillis: null,
        totalPausedMillis: 5 * 60 * 1000, // 5 minutes
        pauseCount: 2,
        createdAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        updatedAtMillis: DateTime(2024, 1, 1, 10, 30).millisecondsSinceEpoch,
      );
      final kickDtos = <KickDto>[
        KickDto(
          id: 'kick-1',
          sessionId: 'session-1',
          timestampMillis: DateTime(2024, 1, 1, 10, 5).millisecondsSinceEpoch,
          sequenceNumber: 1,
          perceivedStrength: 'encrypted_moderate',
        ),
      ];
      final dtoWithKicks = KickSessionWithKicks(
        session: sessionDto,
        kicks: kickDtos,
      );

      // Act
      final domain = KickSessionMapper.toDomain(
        dtoWithKicks,
        decryptStrength,
      );

      // Assert
      expect(domain.id, equals('session-1'));
      expect(domain.startTime, equals(DateTime(2024, 1, 1, 10, 0)));
      expect(domain.endTime, equals(DateTime(2024, 1, 1, 10, 30)));
      expect(domain.isActive, isFalse);
      expect(domain.pausedAt, isNull);
      expect(domain.totalPausedDuration, equals(const Duration(minutes: 5)));
      expect(domain.pauseCount, equals(2));
      expect(domain.kicks.length, equals(1));
    });

    test('should convert totalPausedMillis to Duration correctly', () {
      // Arrange
      final sessionDto = KickSessionDto(
        id: 'session-1',
        startTimeMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        endTimeMillis: null,
        isActive: true,
        pausedAtMillis: null,
        totalPausedMillis: 3 * 60 * 1000 + 30 * 1000, // 3 min 30 sec
        pauseCount: 1,
        createdAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        updatedAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
      );
      final dtoWithKicks = KickSessionWithKicks(
        session: sessionDto,
        kicks: [],
      );

      // Act
      final domain = KickSessionMapper.toDomain(
        dtoWithKicks,
        decryptStrength,
      );

      // Assert
      expect(
        domain.totalPausedDuration,
        equals(const Duration(minutes: 3, seconds: 30)),
      );
    });

    test('should map Kick with decrypted strength', () {
      // Arrange
      final kickDto = KickDto(
        id: 'kick-1',
        sessionId: 'session-1',
        timestampMillis: DateTime(2024, 1, 1, 10, 5).millisecondsSinceEpoch,
        sequenceNumber: 1,
        perceivedStrength: 'encrypted_strong',
      );

      // Act
      final kick = KickSessionMapper.kickToDomain(kickDto, 'strong');

      // Assert
      expect(kick.id, equals('kick-1'));
      expect(kick.sessionId, equals('session-1'));
      expect(kick.timestamp, equals(DateTime(2024, 1, 1, 10, 5)));
      expect(kick.sequenceNumber, equals(1));
      expect(kick.perceivedStrength, equals(MovementStrength.strong));
    });

    test('should handle null pausedAt field', () {
      // Arrange
      final sessionDto = KickSessionDto(
        id: 'session-1',
        startTimeMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        endTimeMillis: null,
        isActive: true,
        pausedAtMillis: null, // Explicit null
        totalPausedMillis: 0,
        pauseCount: 0,
        createdAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        updatedAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
      );
      final dtoWithKicks = KickSessionWithKicks(
        session: sessionDto,
        kicks: [],
      );

      // Act
      final domain = KickSessionMapper.toDomain(
        dtoWithKicks,
        decryptStrength,
      );

      // Assert
      expect(domain.pausedAt, isNull);
      expect(domain.isPaused, isFalse);
    });

    test('should handle null endTime field', () {
      // Arrange
      final sessionDto = KickSessionDto(
        id: 'session-1',
        startTimeMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        endTimeMillis: null, // Active session
        isActive: true,
        pausedAtMillis: null,
        totalPausedMillis: 0,
        pauseCount: 0,
        createdAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
        updatedAtMillis: DateTime(2024, 1, 1, 10, 0).millisecondsSinceEpoch,
      );
      final dtoWithKicks = KickSessionWithKicks(
        session: sessionDto,
        kicks: [],
      );

      // Act
      final domain = KickSessionMapper.toDomain(
        dtoWithKicks,
        decryptStrength,
      );

      // Assert
      expect(domain.endTime, isNull);
      expect(domain.isActive, isTrue);
    });

    test('should parse weak strength correctly', () {
      // Arrange
      final kickDto = KickDto(
        id: 'kick-1',
        sessionId: 'session-1',
        timestampMillis: DateTime(2024, 1, 1, 10, 5).millisecondsSinceEpoch,
        sequenceNumber: 1,
        perceivedStrength: 'encrypted_weak',
      );

      // Act
      final kick = KickSessionMapper.kickToDomain(kickDto, 'weak');

      // Assert
      expect(kick.perceivedStrength, equals(MovementStrength.weak));
    });

    test('should parse moderate strength correctly', () {
      // Arrange
      final kickDto = KickDto(
        id: 'kick-1',
        sessionId: 'session-1',
        timestampMillis: DateTime(2024, 1, 1, 10, 5).millisecondsSinceEpoch,
        sequenceNumber: 1,
        perceivedStrength: 'encrypted_moderate',
      );

      // Act
      final kick = KickSessionMapper.kickToDomain(kickDto, 'moderate');

      // Assert
      expect(kick.perceivedStrength, equals(MovementStrength.moderate));
    });

    test('should convert MovementStrength to string correctly', () {
      // Assert
      expect(
        KickSessionMapper.movementStrengthToString(MovementStrength.weak),
        equals('weak'),
      );
      expect(
        KickSessionMapper.movementStrengthToString(MovementStrength.moderate),
        equals('moderate'),
      );
      expect(
        KickSessionMapper.movementStrengthToString(MovementStrength.strong),
        equals('strong'),
      );
    });
  });
}

