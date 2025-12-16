import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/bump_photo_mapper.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo.dart';

void main() {
  group('BumpPhotoMapper', () {
    final now = DateTime(2024, 1, 15);

    group('toDomain', () {
      test('converts DTO to domain entity correctly', () {
        // Arrange
        final dto = BumpPhotoDto(
          id: 'test-id',
          pregnancyId: 'pregnancy-id',
          weekNumber: 20,
          filePath: '/path/to/photo.jpg',
          note: 'Test note',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = BumpPhotoMapper.toDomain(dto);

        // Assert
        expect(entity.id, dto.id);
        expect(entity.pregnancyId, dto.pregnancyId);
        expect(entity.weekNumber, dto.weekNumber);
        expect(entity.filePath, dto.filePath);
        expect(entity.note, dto.note);
        expect(entity.photoDate, now);
        expect(entity.createdAt, now);
        expect(entity.updatedAt, now);
      });

      test('handles null note', () {
        // Arrange
        final dto = BumpPhotoDto(
          id: 'test-id',
          pregnancyId: 'pregnancy-id',
          weekNumber: 20,
          filePath: '/path/to/photo.jpg',
          note: null,
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = BumpPhotoMapper.toDomain(dto);

        // Assert
        expect(entity.note, isNull);
      });

      test('converts timestamps correctly', () {
        // Arrange
        final photoDate = DateTime(2024, 3, 10, 14, 30);
        final createdAt = DateTime(2024, 3, 10, 14, 0);
        final updatedAt = DateTime(2024, 3, 10, 15, 0);

        final dto = BumpPhotoDto(
          id: 'test-id',
          pregnancyId: 'pregnancy-id',
          weekNumber: 20,
          filePath: '/path/to/photo.jpg',
          note: null,
          photoDateMillis: photoDate.millisecondsSinceEpoch,
          createdAtMillis: createdAt.millisecondsSinceEpoch,
          updatedAtMillis: updatedAt.millisecondsSinceEpoch,
        );

        // Act
        final entity = BumpPhotoMapper.toDomain(dto);

        // Assert
        expect(entity.photoDate.millisecondsSinceEpoch, photoDate.millisecondsSinceEpoch);
        expect(entity.createdAt.millisecondsSinceEpoch, createdAt.millisecondsSinceEpoch);
        expect(entity.updatedAt.millisecondsSinceEpoch, updatedAt.millisecondsSinceEpoch);
      });
    });

    group('toDto', () {
      test('converts domain entity to DTO correctly', () {
        // Arrange
        final entity = BumpPhoto(
          id: 'test-id',
          pregnancyId: 'pregnancy-id',
          weekNumber: 20,
          filePath: '/path/to/photo.jpg',
          note: 'Test note',
          photoDate: now,
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final dto = BumpPhotoMapper.toDto(entity);

        // Assert
        expect(dto.id, entity.id);
        expect(dto.pregnancyId, entity.pregnancyId);
        expect(dto.weekNumber, entity.weekNumber);
        expect(dto.filePath, entity.filePath);
        expect(dto.note, entity.note);
        expect(dto.photoDateMillis, now.millisecondsSinceEpoch);
        expect(dto.createdAtMillis, now.millisecondsSinceEpoch);
        expect(dto.updatedAtMillis, now.millisecondsSinceEpoch);
      });

      test('handles null note', () {
        // Arrange
        final entity = BumpPhoto(
          id: 'test-id',
          pregnancyId: 'pregnancy-id',
          weekNumber: 20,
          filePath: '/path/to/photo.jpg',
          photoDate: now,
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final dto = BumpPhotoMapper.toDto(entity);

        // Assert
        expect(dto.note, isNull);
      });
    });

    group('round-trip conversion', () {
      test('maintains data integrity through toDomain and toDto', () {
        // Arrange
        final originalDto = BumpPhotoDto(
          id: 'test-id',
          pregnancyId: 'pregnancy-id',
          weekNumber: 20,
          filePath: '/path/to/photo.jpg',
          note: 'Test note',
          photoDateMillis: now.millisecondsSinceEpoch,
          createdAtMillis: now.millisecondsSinceEpoch,
          updatedAtMillis: now.millisecondsSinceEpoch,
        );

        // Act
        final entity = BumpPhotoMapper.toDomain(originalDto);
        final roundTripDto = BumpPhotoMapper.toDto(entity);

        // Assert
        expect(roundTripDto.id, originalDto.id);
        expect(roundTripDto.pregnancyId, originalDto.pregnancyId);
        expect(roundTripDto.weekNumber, originalDto.weekNumber);
        expect(roundTripDto.filePath, originalDto.filePath);
        expect(roundTripDto.note, originalDto.note);
        expect(roundTripDto.photoDateMillis, originalDto.photoDateMillis);
      });
    });

    group('list conversions', () {
      test('toDomainList converts list correctly', () {
        // Arrange
        final dtoList = List.generate(
          3,
          (i) => BumpPhotoDto(
            id: 'id-$i',
            pregnancyId: 'pregnancy-id',
            weekNumber: i + 1,
            filePath: '/path/$i.jpg',
            note: null,
            photoDateMillis: now.millisecondsSinceEpoch,
            createdAtMillis: now.millisecondsSinceEpoch,
            updatedAtMillis: now.millisecondsSinceEpoch,
          ),
        );

        // Act
        final entityList = BumpPhotoMapper.toDomainList(dtoList);

        // Assert
        expect(entityList.length, 3);
        for (var i = 0; i < 3; i++) {
          expect(entityList[i].id, 'id-$i');
          expect(entityList[i].weekNumber, i + 1);
        }
      });

      test('toDtoList converts list correctly', () {
        // Arrange
        final entityList = List.generate(
          3,
          (i) => BumpPhoto(
            id: 'id-$i',
            pregnancyId: 'pregnancy-id',
            weekNumber: i + 1,
            filePath: '/path/$i.jpg',
            photoDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Act
        final dtoList = BumpPhotoMapper.toDtoList(entityList);

        // Assert
        expect(dtoList.length, 3);
        for (var i = 0; i < 3; i++) {
          expect(dtoList[i].id, 'id-$i');
          expect(dtoList[i].weekNumber, i + 1);
        }
      });
    });
  });
}
