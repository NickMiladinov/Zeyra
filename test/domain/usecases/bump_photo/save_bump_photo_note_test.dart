@Tags(['bump_photo'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo_constants.dart';
import 'package:zeyra/domain/exceptions/bump_photo_exception.dart';
import 'package:zeyra/domain/usecases/bump_photo/save_bump_photo_note.dart';

import '../../../mocks/mock_repositories.dart';
import '../../../mocks/fake_data/bump_photo_fakes.dart';

void main() {
  late MockBumpPhotoRepository mockRepository;
  late SaveBumpPhotoNote useCase;

  setUp(() {
    mockRepository = MockBumpPhotoRepository();
    useCase = SaveBumpPhotoNote(mockRepository);
  });

  group('SaveBumpPhotoNote', () {
    const testPregnancyId = 'pregnancy-123';

    test('saves note successfully for valid week', () async {
      // Arrange
      const weekNumber = 20;
      const note = 'Feeling great this week!';
      final expectedPhoto = BumpPhotoFakes.noteOnly(
        weekNumber,
        pregnancyId: testPregnancyId,
        note: note,
      );

      when(() => mockRepository.saveNoteOnly(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            note: note,
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: weekNumber,
        note: note,
      );

      // Assert
      expect(result, expectedPhoto);
      expect(result.note, note);
      verify(() => mockRepository.saveNoteOnly(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            note: note,
          )).called(1);
    });

    test('saves note with null value (clears note)', () async {
      // Arrange
      const weekNumber = 15;
      final expectedPhoto = BumpPhotoFakes.noteOnly(
        weekNumber,
        pregnancyId: testPregnancyId,
        note: null,
      );

      when(() => mockRepository.saveNoteOnly(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            note: null,
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: weekNumber,
        note: null,
      );

      // Assert
      expect(result.note, isNull);
      verify(() => mockRepository.saveNoteOnly(
            pregnancyId: testPregnancyId,
            weekNumber: weekNumber,
            note: null,
          )).called(1);
    });

    test('throws InvalidWeekException for week too low', () async {
      // Act & Assert
      expect(
        () => useCase(
          pregnancyId: testPregnancyId,
          weekNumber: 0,
          note: 'Some note',
        ),
        throwsA(isA<InvalidWeekException>()),
      );

      verifyNever(() => mockRepository.saveNoteOnly(
            pregnancyId: any(named: 'pregnancyId'),
            weekNumber: any(named: 'weekNumber'),
            note: any(named: 'note'),
          ));
    });

    test('throws InvalidWeekException for week too high', () async {
      // Act & Assert
      expect(
        () => useCase(
          pregnancyId: testPregnancyId,
          weekNumber: BumpPhotoConstants.maxWeek + 1,
          note: 'Some note',
        ),
        throwsA(isA<InvalidWeekException>()),
      );
    });

    test('saves note at minimum valid week', () async {
      // Arrange
      final expectedPhoto = BumpPhotoFakes.noteOnly(
        BumpPhotoConstants.minWeek,
        pregnancyId: testPregnancyId,
        note: 'Week 1 note',
      );

      when(() => mockRepository.saveNoteOnly(
            pregnancyId: testPregnancyId,
            weekNumber: BumpPhotoConstants.minWeek,
            note: 'Week 1 note',
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: BumpPhotoConstants.minWeek,
        note: 'Week 1 note',
      );

      // Assert
      expect(result.weekNumber, BumpPhotoConstants.minWeek);
    });

    test('saves note at maximum valid week', () async {
      // Arrange
      final expectedPhoto = BumpPhotoFakes.noteOnly(
        BumpPhotoConstants.maxWeek,
        pregnancyId: testPregnancyId,
        note: 'Week 42 note',
      );

      when(() => mockRepository.saveNoteOnly(
            pregnancyId: testPregnancyId,
            weekNumber: BumpPhotoConstants.maxWeek,
            note: 'Week 42 note',
          )).thenAnswer((_) async => expectedPhoto);

      // Act
      final result = await useCase(
        pregnancyId: testPregnancyId,
        weekNumber: BumpPhotoConstants.maxWeek,
        note: 'Week 42 note',
      );

      // Assert
      expect(result.weekNumber, BumpPhotoConstants.maxWeek);
    });

    test('does not call repository for invalid week', () async {
      // Act & Assert
      expect(
        () => useCase(
          pregnancyId: testPregnancyId,
          weekNumber: -5,
          note: 'Some note',
        ),
        throwsA(isA<InvalidWeekException>()),
      );

      verifyNever(() => mockRepository.saveNoteOnly(
            pregnancyId: any(named: 'pregnancyId'),
            weekNumber: any(named: 'weekNumber'),
            note: any(named: 'note'),
          ));
    });
  });
}
