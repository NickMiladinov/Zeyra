@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/hospital/manage_shortlist_usecase.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  late MockHospitalShortlistRepository mockRepository;
  late ManageShortlistUseCase useCase;

  setUp(() {
    mockRepository = MockHospitalShortlistRepository();
    useCase = ManageShortlistUseCase(repository: mockRepository);
  });

  group('[HospitalChooser] ManageShortlistUseCase - getShortlist', () {
    test('should return shortlist from repository', () async {
      // Arrange
      final shortlist = FakeShortlistWithUnit.batch(3);
      when(() => mockRepository.getShortlistWithUnits())
          .thenAnswer((_) async => shortlist);

      // Act
      final result = await useCase.getShortlist();

      // Assert
      expect(result, equals(shortlist));
      expect(result.length, 3);
      verify(() => mockRepository.getShortlistWithUnits()).called(1);
    });

    test('should return empty list when shortlist empty', () async {
      // Arrange
      when(() => mockRepository.getShortlistWithUnits())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.getShortlist();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getShortlistWithUnits())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.getShortlist(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('[HospitalChooser] ManageShortlistUseCase - isShortlisted', () {
    test('should return true when unit in shortlist', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => true);

      // Act
      final result = await useCase.isShortlisted('unit-1');

      // Assert
      expect(result, isTrue);
      verify(() => mockRepository.isShortlisted('unit-1')).called(1);
    });

    test('should return false when unit not in shortlist', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => false);

      // Act
      final result = await useCase.isShortlisted('unit-1');

      // Assert
      expect(result, isFalse);
    });
  });

  group('[HospitalChooser] ManageShortlistUseCase - addToShortlist', () {
    test('should add unit to shortlist', () async {
      // Arrange
      final shortlistEntry = FakeHospitalShortlist.simple(maternityUnitId: 'unit-1');
      when(() => mockRepository.addToShortlist('unit-1', notes: null))
          .thenAnswer((_) async => shortlistEntry);

      // Act
      final result = await useCase.addToShortlist('unit-1');

      // Assert
      expect(result, equals(shortlistEntry));
      verify(() => mockRepository.addToShortlist('unit-1', notes: null)).called(1);
    });

    test('should add unit with notes', () async {
      // Arrange
      final shortlistEntry = FakeHospitalShortlist.withNotes(
        notes: 'Great hospital',
        maternityUnitId: 'unit-1',
      );
      when(() => mockRepository.addToShortlist('unit-1', notes: 'Great hospital'))
          .thenAnswer((_) async => shortlistEntry);

      // Act
      final result = await useCase.addToShortlist('unit-1', notes: 'Great hospital');

      // Assert
      expect(result.notes, 'Great hospital');
      verify(() => mockRepository.addToShortlist('unit-1', notes: 'Great hospital')).called(1);
    });

    test('should return created shortlist entry', () async {
      // Arrange
      final shortlistEntry = FakeHospitalShortlist.simple(
        id: 'new-id',
        maternityUnitId: 'unit-1',
      );
      when(() => mockRepository.addToShortlist('unit-1', notes: null))
          .thenAnswer((_) async => shortlistEntry);

      // Act
      final result = await useCase.addToShortlist('unit-1');

      // Assert
      expect(result.id, 'new-id');
      expect(result.maternityUnitId, 'unit-1');
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.addToShortlist(any(), notes: any(named: 'notes')))
          .thenThrow(Exception('Already in shortlist'));

      // Act & Assert
      expect(
        () => useCase.addToShortlist('unit-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('[HospitalChooser] ManageShortlistUseCase - removeFromShortlist', () {
    test('should remove unit from shortlist', () async {
      // Arrange
      when(() => mockRepository.removeByMaternityUnitId('unit-1'))
          .thenAnswer((_) async {});

      // Act
      await useCase.removeFromShortlist('unit-1');

      // Assert
      verify(() => mockRepository.removeByMaternityUnitId('unit-1')).called(1);
    });

    test('should complete without error when unit not in shortlist', () async {
      // Arrange
      when(() => mockRepository.removeByMaternityUnitId('non-existent'))
          .thenAnswer((_) async {});

      // Act & Assert - should not throw
      await expectLater(
        useCase.removeFromShortlist('non-existent'),
        completes,
      );
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.removeByMaternityUnitId(any()))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.removeFromShortlist('unit-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('[HospitalChooser] ManageShortlistUseCase - toggleShortlist', () {
    test('should add and return true when not shortlisted', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => false);
      when(() => mockRepository.addToShortlist('unit-1', notes: null))
          .thenAnswer((_) async => FakeHospitalShortlist.simple(maternityUnitId: 'unit-1'));

      // Act
      final result = await useCase.toggleShortlist('unit-1');

      // Assert
      expect(result, isTrue);
      verify(() => mockRepository.isShortlisted('unit-1')).called(1);
      verify(() => mockRepository.addToShortlist('unit-1', notes: null)).called(1);
    });

    test('should remove and return false when shortlisted', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => true);
      when(() => mockRepository.removeByMaternityUnitId('unit-1'))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase.toggleShortlist('unit-1');

      // Assert
      expect(result, isFalse);
      verify(() => mockRepository.isShortlisted('unit-1')).called(1);
      verify(() => mockRepository.removeByMaternityUnitId('unit-1')).called(1);
    });

    test('should call isShortlisted first', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => false);
      when(() => mockRepository.addToShortlist('unit-1', notes: null))
          .thenAnswer((_) async => FakeHospitalShortlist.simple(maternityUnitId: 'unit-1'));

      // Act
      await useCase.toggleShortlist('unit-1');

      // Assert
      verifyInOrder([
        () => mockRepository.isShortlisted('unit-1'),
        () => mockRepository.addToShortlist('unit-1', notes: null),
      ]);
    });

    test('should not call add when already shortlisted', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => true);
      when(() => mockRepository.removeByMaternityUnitId('unit-1'))
          .thenAnswer((_) async {});

      // Act
      await useCase.toggleShortlist('unit-1');

      // Assert
      verifyNever(() => mockRepository.addToShortlist(any(), notes: any(named: 'notes')));
    });

    test('should not call remove when not shortlisted', () async {
      // Arrange
      when(() => mockRepository.isShortlisted('unit-1'))
          .thenAnswer((_) async => false);
      when(() => mockRepository.addToShortlist('unit-1', notes: null))
          .thenAnswer((_) async => FakeHospitalShortlist.simple(maternityUnitId: 'unit-1'));

      // Act
      await useCase.toggleShortlist('unit-1');

      // Assert
      verifyNever(() => mockRepository.removeByMaternityUnitId(any()));
    });
  });
}
