@Tags(['contraction_timer'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/contraction_mapper.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';

void main() {
  group('[ContractionTimer] ContractionMapper', () {
    final startTime = DateTime(2024, 1, 1, 10, 0);
    final endTime = DateTime(2024, 1, 1, 10, 1);
    final now = DateTime.now();

    group('toDomain', () {
      test('should map DTO to domain entity correctly', () {
        // Arrange
        final dto = ContractionDto(
          id: 'c1',
          sessionId: 's1',
          startTimeMillis: startTime.millisecondsSinceEpoch,
          endTimeMillis: endTime.millisecondsSinceEpoch,
          intensity: 1, // moderate = 1
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = ContractionMapper.toDomain(dto);

        // Assert
        expect(entity.id, equals('c1'));
        expect(entity.sessionId, equals('s1'));
        expect(entity.startTime, equals(startTime));
        expect(entity.endTime, equals(endTime));
        expect(entity.intensity, equals(ContractionIntensity.moderate));
      });

      test('should handle null endTime', () {
        // Arrange
        final dto = ContractionDto(
          id: 'c1',
          sessionId: 's1',
          startTimeMillis: startTime.millisecondsSinceEpoch,
          endTimeMillis: null,
          intensity: 1,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = ContractionMapper.toDomain(dto);

        // Assert
        expect(entity.endTime, isNull);
        expect(entity.isActive, isTrue);
      });

      test('should map mild intensity correctly', () {
        // Arrange
        final dto = ContractionDto(
          id: 'c1',
          sessionId: 's1',
          startTimeMillis: startTime.millisecondsSinceEpoch,
          endTimeMillis: endTime.millisecondsSinceEpoch,
          intensity: 0, // mild = 0
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = ContractionMapper.toDomain(dto);

        // Assert
        expect(entity.intensity, equals(ContractionIntensity.mild));
      });

      test('should map strong intensity correctly', () {
        // Arrange
        final dto = ContractionDto(
          id: 'c1',
          sessionId: 's1',
          startTimeMillis: startTime.millisecondsSinceEpoch,
          endTimeMillis: endTime.millisecondsSinceEpoch,
          intensity: 2, // strong = 2
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = ContractionMapper.toDomain(dto);

        // Assert
        expect(entity.intensity, equals(ContractionIntensity.strong));
      });
    });

    group('toDto', () {
      test('should map domain entity to DTO correctly', () {
        // Arrange
        final entity = Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: endTime,
          intensity: ContractionIntensity.moderate,
        );

        // Act
        final dto = ContractionMapper.toDto(entity);

        // Assert
        expect(dto.id, equals('c1'));
        expect(dto.sessionId, equals('s1'));
        expect(dto.startTimeMillis, equals(startTime.millisecondsSinceEpoch));
        expect(dto.endTimeMillis, equals(endTime.millisecondsSinceEpoch));
        expect(dto.intensity, equals(1)); // moderate = 1
      });

      test('should handle null endTime', () {
        // Arrange
        final entity = Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: null,
          intensity: ContractionIntensity.moderate,
        );

        // Act
        final dto = ContractionMapper.toDto(entity);

        // Assert
        expect(dto.endTimeMillis, isNull);
      });
    });

    group('Round-trip mapping', () {
      test('should be reversible (Domain -> DTO -> Domain)', () {
        // Arrange
        final originalEntity = Contraction(
          id: 'c1',
          sessionId: 's1',
          startTime: startTime,
          endTime: endTime,
          intensity: ContractionIntensity.moderate,
        );

        // Act
        final dto = ContractionMapper.toDto(originalEntity);
        final mappedEntity = ContractionMapper.toDomain(dto);

        // Assert
        expect(mappedEntity.id, equals(originalEntity.id));
        expect(mappedEntity.sessionId, equals(originalEntity.sessionId));
        expect(mappedEntity.startTime, equals(originalEntity.startTime));
        expect(mappedEntity.endTime, equals(originalEntity.endTime));
        expect(mappedEntity.intensity, equals(originalEntity.intensity));
      });
    });
  });
}
