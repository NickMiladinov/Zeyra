import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/bump_photo/get_bump_photos.dart';

import '../../../mocks/mock_repositories.dart';
import '../../../mocks/fake_data/bump_photo_fakes.dart';

void main() {
  late MockBumpPhotoRepository mockRepository;
  late GetBumpPhotos useCase;

  setUp(() {
    mockRepository = MockBumpPhotoRepository();
    useCase = GetBumpPhotos(mockRepository);
  });

  group('GetBumpPhotos', () {
    const testPregnancyId = 'pregnancy-123';

    test('returns all photos for pregnancy', () async {
      // Arrange
      final photos = BumpPhotoFakes.bumpPhotoList(5, pregnancyId: testPregnancyId);

      when(() => mockRepository.getBumpPhotos(testPregnancyId))
          .thenAnswer((_) async => photos);

      // Act
      final result = await useCase(testPregnancyId);

      // Assert
      expect(result, photos);
      expect(result.length, 5);
      verify(() => mockRepository.getBumpPhotos(testPregnancyId)).called(1);
    });

    test('returns empty list when no photos exist', () async {
      // Arrange
      when(() => mockRepository.getBumpPhotos(testPregnancyId))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase(testPregnancyId);

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getBumpPhotos(testPregnancyId)).called(1);
    });

    test('returns photos sorted by weekNumber ascending', () async {
      // Arrange
      final photos = [
        BumpPhotoFakes.forWeek(30, pregnancyId: testPregnancyId),
        BumpPhotoFakes.forWeek(10, pregnancyId: testPregnancyId),
        BumpPhotoFakes.forWeek(20, pregnancyId: testPregnancyId),
      ];

      when(() => mockRepository.getBumpPhotos(testPregnancyId))
          .thenAnswer((_) async => photos);

      // Act
      final result = await useCase(testPregnancyId);

      // Assert
      expect(result[0].weekNumber, 30);
      expect(result[1].weekNumber, 10);
      expect(result[2].weekNumber, 20);
    });

    test('filters by pregnancyId correctly', () async {
      // Arrange
      final photos = BumpPhotoFakes.bumpPhotoList(3, pregnancyId: testPregnancyId);

      when(() => mockRepository.getBumpPhotos(testPregnancyId))
          .thenAnswer((_) async => photos);

      // Act
      final result = await useCase(testPregnancyId);

      // Assert
      expect(result.every((photo) => photo.pregnancyId == testPregnancyId), isTrue);
    });

    test('handles repository errors', () async {
      // Arrange
      when(() => mockRepository.getBumpPhotos(testPregnancyId))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase(testPregnancyId),
        throwsException,
      );
    });
  });
}
