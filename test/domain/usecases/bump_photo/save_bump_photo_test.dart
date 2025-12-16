import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo_constants.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';
import 'package:zeyra/domain/usecases/bump_photo/save_bump_photo.dart';

import '../../../mocks/mock_repositories.dart';
import '../../../mocks/fake_data/bump_photo_fakes.dart';

void main() {
  late MockBumpPhotoRepository mockRepository;
  late SaveBumpPhoto useCase;

  setUp(() {
    mockRepository = MockBumpPhotoRepository();
    useCase = SaveBumpPhoto(mockRepository);
  });

  group('SaveBumpPhoto', () {
    final testImageBytes = List<int>.filled(100, 0);
    const testPregnancyId = 'pregnancy-123';

    test('saves photo successfully for valid week', () async {
      // Arrange
      const weekNumber = 20;
      final expectedPhoto = BumpPhotoFakes.forWeek(weekNumber, pregnancyId: testPregnancyId);

      when(() => mockRepository.saveBumpPhoto(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            imageBytes: testImageBytes,
            note: null,
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: weekNumber,
        imageBytes: testImageBytes,
      );

      // Assert
      expect(result, expectedPhoto);
      verify(() => mockRepository.saveBumpPhoto(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            imageBytes: testImageBytes,
            note: null,
          )).called(1);
    });

    test('saves photo with note', () async {
      // Arrange
      const weekNumber = 25;
      const note = 'Feeling great this week!';
      final expectedPhoto = BumpPhotoFakes.forWeek(
        weekNumber,
        pregnancyId: testPregnancyId,
        note: note,
      );

      when(() => mockRepository.saveBumpPhoto(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            imageBytes: testImageBytes,
            note: note,
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: weekNumber,
        imageBytes: testImageBytes,
        note: note,
      );

      // Assert
      expect(result.note, note);
    });

    test('throws InvalidWeekException for week too low', () async {
      // Act & Assert
      expect(
        () => useCase(
          pregnancyId: testPregnancyId,
          weekNumber: 0,
          imageBytes: testImageBytes,
        ),
        throwsA(isA<InvalidWeekException>()),
      );

      verifyNever(() => mockRepository.saveBumpPhoto(
            pregnancyId: any(named: 'pregnancyId'),
            weekNumber: any(named: 'weekNumber'),
            imageBytes: any(named: 'imageBytes'),
          ));
    });

    test('throws InvalidWeekException for week too high', () async {
      // Act & Assert
      expect(
        () => useCase(
          pregnancyId: testPregnancyId,
          weekNumber: BumpPhotoConstants.maxWeek + 1,
          imageBytes: testImageBytes,
        ),
        throwsA(isA<InvalidWeekException>()),
      );
    });

    test('throws InvalidWeekException for negative week', () async {
      // Act & Assert
      expect(
        () => useCase(
          pregnancyId: testPregnancyId,
          weekNumber: -5,
          imageBytes: testImageBytes,
        ),
        throwsA(isA<InvalidWeekException>()),
      );
    });

    test('saves photo at minimum valid week', () async {
      // Arrange
      final expectedPhoto = BumpPhotoFakes.forWeek(
        BumpPhotoConstants.minWeek,
        pregnancyId: testPregnancyId,
      );

      when(() => mockRepository.saveBumpPhoto(
            pregnancyId: testPregnancyId,
            weekNumber: BumpPhotoConstants.minWeek,
            imageBytes: testImageBytes,
            note: null,
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: BumpPhotoConstants.minWeek,
        imageBytes: testImageBytes,
      );

      // Assert
      expect(result.weekNumber, BumpPhotoConstants.minWeek);
    });

    test('saves photo at maximum valid week', () async {
      // Arrange
      final expectedPhoto = BumpPhotoFakes.forWeek(
        BumpPhotoConstants.maxWeek,
        pregnancyId: testPregnancyId,
      );

      when(() => mockRepository.saveBumpPhoto(
            pregnancyId: testPregnancyId,
            weekNumber: BumpPhotoConstants.maxWeek,
            imageBytes: testImageBytes,
            note: null,
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: BumpPhotoConstants.maxWeek,
        imageBytes: testImageBytes,
      );

      // Assert
      expect(result.weekNumber, BumpPhotoConstants.maxWeek);
    });
  });
}
