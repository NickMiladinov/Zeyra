@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/local/daos/contraction_timer_dao.dart';
import 'package:zeyra/data/mappers/contraction_session_mapper.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';

void main() {
  group('[ContractionTimer] ContractionSessionMapper', () {
    final startTime = DateTime(2024, 1, 1, 10, 0);
    final endTime = DateTime(2024, 1, 1, 11, 0);
    final now = DateTime.now();

    group('toDto', () {
      test('should map domain entity to session DTO', () {
        // Arrange
        final entity = ContractionSession(
          id: 's1',
          startTime: startTime,
          endTime: endTime,
          isActive: false,
          contractions: [],
          note: 'Test notes',
          achievedDuration: true,
          durationAchievedAt: startTime.add(const Duration(minutes: 30)),
          achievedFrequency: true,
          frequencyAchievedAt: startTime.add(const Duration(minutes: 30)),
          achievedConsistency: true,
          consistencyAchievedAt: startTime.add(const Duration(minutes: 30)),
        );

        // Act
        final dto = ContractionSessionMapper.toDto(entity);

        // Assert
        expect(dto.id, equals('s1'));
        expect(dto.startTimeMillis, equals(startTime.millisecondsSinceEpoch));
        expect(dto.endTimeMillis, equals(endTime.millisecondsSinceEpoch));
        expect(dto.isActive, isFalse);
        expect(dto.note, equals('Test notes'));
        expect(dto.achievedDuration, isTrue);
        expect(dto.achievedFrequency, isTrue);
        expect(dto.achievedConsistency, isTrue);
      });

      test('should handle null endTime', () {
        // Arrange
        final entity = ContractionSession(
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
        final dto = ContractionSessionMapper.toDto(entity);

        // Assert
        expect(dto.endTimeMillis, isNull);
        expect(dto.isActive, isTrue);
      });
    });

    group('toDomain', () {
      test('should map composite DTO to domain entity', () {
        // Arrange
        final sessionDto = ContractionSessionDto(
          id: 's1',
          startTimeMillis: startTime.millisecondsSinceEpoch,
          endTimeMillis: endTime.millisecondsSinceEpoch,
          isActive: false,
          note: 'Test notes',
          achievedDuration: true,
          durationAchievedAtMillis: startTime.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
          achievedFrequency: true,
          frequencyAchievedAtMillis: startTime.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
          achievedConsistency: true,
          consistencyAchievedAtMillis: startTime.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        final contractionDtos = [
          ContractionDto(
            id: 'c1',
            sessionId: 's1',
            startTimeMillis: startTime.millisecondsSinceEpoch,
            endTimeMillis: startTime.add(const Duration(seconds: 60)).millisecondsSinceEpoch,
            intensity: 1, // moderate
            createdAtMillis: now.millisecondsSinceEpoch,
            updatedAtMillis: now.millisecondsSinceEpoch,
          ),
        ];

        final composite = ContractionSessionWithContractions(
          session: sessionDto,
          contractions: contractionDtos,
        );

        // Act
        final entity = ContractionSessionMapper.toDomain(composite);

        // Assert
        expect(entity.id, equals('s1'));
        expect(entity.startTime, equals(startTime));
        expect(entity.endTime, equals(endTime));
        expect(entity.isActive, isFalse);
        expect(entity.note, equals('Test notes'));
        expect(entity.contractions, hasLength(1));
        expect(entity.contractions[0].intensity, equals(ContractionIntensity.moderate));
        expect(entity.achievedDuration, isTrue);
        expect(entity.achievedFrequency, isTrue);
        expect(entity.achievedConsistency, isTrue);
      });

      test('should handle empty contractions list', () {
        // Arrange
        final sessionDto = ContractionSessionDto(
          id: 's1',
          startTimeMillis: startTime.millisecondsSinceEpoch,
          endTimeMillis: null,
          isActive: true,
          note: null,
          achievedDuration: false,
          durationAchievedAtMillis: null,
          achievedFrequency: false,
          frequencyAchievedAtMillis: null,
          achievedConsistency: false,
          consistencyAchievedAtMillis: null,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        final composite = ContractionSessionWithContractions(
          session: sessionDto,
          contractions: [],
        );

        // Act
        final entity = ContractionSessionMapper.toDomain(composite);

        // Assert
        expect(entity.contractions, isEmpty);
        expect(entity.isActive, isTrue);
      });
    });
  });
}
