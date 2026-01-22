@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/usecases/hospital/select_final_hospital_usecase.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  late MockHospitalShortlistRepository mockRepository;
  late SelectFinalHospitalUseCase useCase;

  setUp(() {
    mockRepository = MockHospitalShortlistRepository();
    useCase = SelectFinalHospitalUseCase(repository: mockRepository);
  });

  group('[HospitalChooser] SelectFinalHospitalUseCase - select', () {
    test('should call repository selectFinalChoice', () async {
      // Arrange
      when(() => mockRepository.selectFinalChoice('shortlist-123'))
          .thenAnswer((_) async {});

      // Act
      await useCase.select('shortlist-123');

      // Assert
      verify(() => mockRepository.selectFinalChoice('shortlist-123')).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.selectFinalChoice(any()))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.select('shortlist-123'),
        throwsA(isA<Exception>()),
      );
    });

    test('should complete without return value', () async {
      // Arrange
      when(() => mockRepository.selectFinalChoice('shortlist-123'))
          .thenAnswer((_) async {});

      // Act & Assert
      await expectLater(
        useCase.select('shortlist-123'),
        completes,
      );
    });
  });

  group('[HospitalChooser] SelectFinalHospitalUseCase - getSelected', () {
    test('should return selected hospital from repository', () async {
      // Arrange
      final selected = FakeShortlistWithUnit.selected();
      when(() => mockRepository.getSelectedHospital())
          .thenAnswer((_) async => selected);

      // Act
      final result = await useCase.getSelected();

      // Assert
      expect(result, equals(selected));
      expect(result?.shortlist.isSelected, true);
      verify(() => mockRepository.getSelectedHospital()).called(1);
    });

    test('should return null when no selection', () async {
      // Arrange
      when(() => mockRepository.getSelectedHospital())
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.getSelected();

      // Assert
      expect(result, isNull);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getSelectedHospital())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.getSelected(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('[HospitalChooser] SelectFinalHospitalUseCase - clearSelection', () {
    test('should call repository clearSelection', () async {
      // Arrange
      when(() => mockRepository.clearSelection())
          .thenAnswer((_) async {});

      // Act
      await useCase.clearSelection();

      // Assert
      verify(() => mockRepository.clearSelection()).called(1);
    });

    test('should complete without error when no selection', () async {
      // Arrange
      when(() => mockRepository.clearSelection())
          .thenAnswer((_) async {});

      // Act & Assert
      await expectLater(
        useCase.clearSelection(),
        completes,
      );
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.clearSelection())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase.clearSelection(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
