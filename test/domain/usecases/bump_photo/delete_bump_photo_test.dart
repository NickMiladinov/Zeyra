import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/bump_photo/delete_bump_photo.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late MockBumpPhotoRepository mockRepository;
  late DeleteBumpPhoto useCase;

  setUp(() {
    mockRepository = MockBumpPhotoRepository();
    useCase = DeleteBumpPhoto(mockRepository);
  });

  group('DeleteBumpPhoto', () {
    const testPhotoId = 'photo-123';

    test('deletes photo successfully', () async {
      // Arrange
      when(() => mockRepository.deleteBumpPhoto(testPhotoId))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testPhotoId);

      // Assert
      verify(() => mockRepository.deleteBumpPhoto(testPhotoId)).called(1);
    });

    test('calls repository with correct id', () async {
      // Arrange
      when(() => mockRepository.deleteBumpPhoto(testPhotoId))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testPhotoId);

      // Assert
      final captured = verify(() => mockRepository.deleteBumpPhoto(captureAny())).captured;
      expect(captured.single, testPhotoId);
    });

    test('handles non-existent photo gracefully', () async {
      // Arrange
      when(() => mockRepository.deleteBumpPhoto(testPhotoId))
          .thenAnswer((_) async => {}); // Repository does nothing

      // Act & Assert - should not throw
      await expectLater(
        useCase(testPhotoId),
        completes,
      );
    });

    test('handles repository errors', () async {
      // Arrange
      when(() => mockRepository.deleteBumpPhoto(testPhotoId))
          .thenThrow(Exception('Delete failed'));

      // Act & Assert
      expect(
        () => useCase(testPhotoId),
        throwsException,
      );
    });
  });
}
