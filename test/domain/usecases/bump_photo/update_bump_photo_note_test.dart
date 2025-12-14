import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/bump_photo/update_bump_photo_note.dart';

import '../../../mocks/mock_repositories.dart';
import '../../../mocks/fake_data/bump_photo_fakes.dart';

void main() {
  late MockBumpPhotoRepository mockRepository;
  late UpdateBumpPhotoNote useCase;

  setUp(() {
    mockRepository = MockBumpPhotoRepository();
    useCase = UpdateBumpPhotoNote(mockRepository);
  });

  group('UpdateBumpPhotoNote', () {
    const testPhotoId = 'photo-123';

    test('updates note successfully', () async {
      // Arrange
      const newNote = 'Updated note';
      final updatedPhoto = BumpPhotoFakes.bumpPhoto(
        id: testPhotoId,
        note: newNote,
      );

      when(() => mockRepository.updateNote(testPhotoId, newNote))
          .thenAnswer((_) async => updatedPhoto);

      // Act
      final result = await useCase(testPhotoId, newNote);

      // Assert
      expect(result.note, newNote);
      verify(() => mockRepository.updateNote(testPhotoId, newNote)).called(1);
    });

    test('clears note when null provided', () async {
      // Arrange
      final updatedPhoto = BumpPhotoFakes.bumpPhoto(
        id: testPhotoId,
        note: null,
      );

      when(() => mockRepository.updateNote(testPhotoId, null))
          .thenAnswer((_) async => updatedPhoto);

      // Act
      final result = await useCase(testPhotoId, null);

      // Assert
      expect(result.note, isNull);
      verify(() => mockRepository.updateNote(testPhotoId, null)).called(1);
    });

    test('handles empty string note', () async {
      // Arrange
      final updatedPhoto = BumpPhotoFakes.bumpPhoto(
        id: testPhotoId,
        note: '',
      );

      when(() => mockRepository.updateNote(testPhotoId, ''))
          .thenAnswer((_) async => updatedPhoto);

      // Act
      final result = await useCase(testPhotoId, '');

      // Assert
      expect(result.note, '');
    });

    test('handles repository errors', () async {
      // Arrange
      when(() => mockRepository.updateNote(testPhotoId, any()))
          .thenThrow(Exception('Update failed'));

      // Act & Assert
      expect(
        () => useCase(testPhotoId, 'New note'),
        throwsException,
      );
    });
  });
}
